USE gestao_financeira;

DELIMITER $$


-- PAR 1 - PAGAMENTO (contas a pagar)

-- TRIGGER 1: trg_pagamento_valida_before_insert
-- Evento: BEFORE INSERT em pagamento (antes de gravar a linha).
-- Resultado esperado: bloqueia (erro 45000) pagamento em conta PAGA/CANCELADA
-- ou cujo valor ultrapasse o saldo devedor. Caso contrário, o INSERT segue.
CREATE TRIGGER trg_pagamento_valida_before_insert
BEFORE INSERT ON pagamento
FOR EACH ROW
BEGIN
  DECLARE v_total  DECIMAL(12,2);
  DECLARE v_status VARCHAR(20);
  DECLARE v_pago   DECIMAL(12,2);

  SELECT valor_total, status
    INTO v_total, v_status
    FROM conta_pagar
   WHERE id_conta_pagar = NEW.id_conta_pagar;

  IF v_status IN ('PAGA', 'CANCELADA') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Conta ja quitada ou cancelada: pagamento nao permitido';
  END IF;

  SELECT COALESCE(SUM(valor_pago), 0)
    INTO v_pago
    FROM pagamento
   WHERE id_conta_pagar = NEW.id_conta_pagar;

  IF v_pago + NEW.valor_pago > v_total THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Pagamento excede o saldo devedor da conta';
  END IF;
END$$


-- TRIGGER 2: trg_pagamento_status_after_insert
-- Evento: AFTER INSERT em pagamento (depois de gravar a linha).
-- Resultado esperado: a conta vira PARCIAL (pagou parte) ou PAGA (quitou).
CREATE TRIGGER trg_pagamento_status_after_insert
AFTER INSERT ON pagamento
FOR EACH ROW
BEGIN
  DECLARE v_total DECIMAL(12,2);
  DECLARE v_pago  DECIMAL(12,2);

  SELECT valor_total INTO v_total
    FROM conta_pagar
   WHERE id_conta_pagar = NEW.id_conta_pagar;

  SELECT COALESCE(SUM(valor_pago), 0) INTO v_pago
    FROM pagamento
   WHERE id_conta_pagar = NEW.id_conta_pagar;

  UPDATE conta_pagar
     SET status = CASE WHEN v_pago >= v_total THEN 'PAGA' ELSE 'PARCIAL' END
   WHERE id_conta_pagar = NEW.id_conta_pagar;
END$$


-- TRIGGER 3: trg_conta_pagar_historico_after_update
-- Evento: AFTER UPDATE em conta_pagar.
-- Resultado esperado: uma linha em historico_conta_pagar para cada campo
-- alterado entre status, valor_total e data_vencimento (valor antigo e novo).
-- Obs.: a mudança de status feita pela Trigger 2 também é registrada aqui.
CREATE TRIGGER trg_conta_pagar_historico_after_update
AFTER UPDATE ON conta_pagar
FOR EACH ROW
BEGIN
  IF OLD.status <> NEW.status THEN
    INSERT INTO historico_conta_pagar (id_conta_pagar, campo_alterado, valor_anterior, valor_novo)
    VALUES (NEW.id_conta_pagar, 'status', OLD.status, NEW.status);
  END IF;

  IF OLD.valor_total <> NEW.valor_total THEN
    INSERT INTO historico_conta_pagar (id_conta_pagar, campo_alterado, valor_anterior, valor_novo)
    VALUES (NEW.id_conta_pagar, 'valor_total', CAST(OLD.valor_total AS CHAR), CAST(NEW.valor_total AS CHAR));
  END IF;

  IF OLD.data_vencimento <> NEW.data_vencimento THEN
    INSERT INTO historico_conta_pagar (id_conta_pagar, campo_alterado, valor_anterior, valor_novo)
    VALUES (NEW.id_conta_pagar, 'data_vencimento', CAST(OLD.data_vencimento AS CHAR), CAST(NEW.data_vencimento AS CHAR));
  END IF;
END$$







-- PAR 2 - RECEBIMENTO (contas a receber): mesma lógica, lado do cliente

CREATE TRIGGER trg_recebimento_valida_before_insert
BEFORE INSERT ON recebimento
FOR EACH ROW
BEGIN
  DECLARE v_total  DECIMAL(12,2);
  DECLARE v_status VARCHAR(20);
  DECLARE v_receb  DECIMAL(12,2);

  SELECT valor_total, status
    INTO v_total, v_status
    FROM conta_receber
   WHERE id_conta_receber = NEW.id_conta_receber;

  IF v_status IN ('RECEBIDA', 'CANCELADA') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Conta ja recebida ou cancelada: recebimento nao permitido';
  END IF;

  SELECT COALESCE(SUM(valor_recebido), 0)
    INTO v_receb
    FROM recebimento
   WHERE id_conta_receber = NEW.id_conta_receber;

  IF v_receb + NEW.valor_recebido > v_total THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Recebimento excede o saldo a receber da conta';
  END IF;
END$$

CREATE TRIGGER trg_recebimento_status_after_insert
AFTER INSERT ON recebimento
FOR EACH ROW
BEGIN
  DECLARE v_total DECIMAL(12,2);
  DECLARE v_receb DECIMAL(12,2);

  SELECT valor_total INTO v_total
    FROM conta_receber
   WHERE id_conta_receber = NEW.id_conta_receber;

  SELECT COALESCE(SUM(valor_recebido), 0) INTO v_receb
    FROM recebimento
   WHERE id_conta_receber = NEW.id_conta_receber;

  UPDATE conta_receber
     SET status = CASE WHEN v_receb >= v_total THEN 'RECEBIDA' ELSE 'PARCIAL' END
   WHERE id_conta_receber = NEW.id_conta_receber;
END$$

CREATE TRIGGER trg_conta_receber_historico_after_update
AFTER UPDATE ON conta_receber
FOR EACH ROW
BEGIN
  IF OLD.status <> NEW.status THEN
    INSERT INTO historico_conta_receber (id_conta_receber, campo_alterado, valor_anterior, valor_novo)
    VALUES (NEW.id_conta_receber, 'status', OLD.status, NEW.status);
  END IF;

  IF OLD.valor_total <> NEW.valor_total THEN
    INSERT INTO historico_conta_receber (id_conta_receber, campo_alterado, valor_anterior, valor_novo)
    VALUES (NEW.id_conta_receber, 'valor_total', CAST(OLD.valor_total AS CHAR), CAST(NEW.valor_total AS CHAR));
  END IF;

  IF OLD.data_vencimento <> NEW.data_vencimento THEN
    INSERT INTO historico_conta_receber (id_conta_receber, campo_alterado, valor_anterior, valor_novo)
    VALUES (NEW.id_conta_receber, 'data_vencimento', CAST(OLD.data_vencimento AS CHAR), CAST(NEW.data_vencimento AS CHAR));
  END IF;
END$$

DELIMITER ;

-- Conferência: deve listar as 6 triggers
SHOW TRIGGERS;
