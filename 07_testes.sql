USE gestao_financeira;

-- TESTE 1: pagamento parcial e depois quitação (Triggers 2 e 3)
SELECT id_conta_pagar, valor_total, status FROM conta_pagar WHERE id_conta_pagar = 3;
-- esperado: status ABERTA

INSERT INTO pagamento (id_conta_pagar, id_forma_pagamento, data_pagamento, valor_pago)
VALUES (3, 1, '2026-11-05', 1000.00);

SELECT id_conta_pagar, valor_total, status FROM conta_pagar WHERE id_conta_pagar = 3;
-- esperado: status PARCIAL

INSERT INTO pagamento (id_conta_pagar, id_forma_pagamento, data_pagamento, valor_pago)
VALUES (3, 1, '2026-11-08', 2500.00);

SELECT id_conta_pagar, valor_total, status FROM conta_pagar WHERE id_conta_pagar = 3;
-- esperado: status PAGA

SELECT * FROM historico_conta_pagar WHERE id_conta_pagar = 3 ORDER BY id_historico;
-- esperado: 2 linhas: status ABERTA -> PARCIAL e status PARCIAL -> PAGA

-- TESTE 2: alteração de valor e vencimento (Trigger 3)
UPDATE conta_pagar
   SET valor_total = 905.50,
       data_vencimento = '2026-11-30'
 WHERE id_conta_pagar = 4;

SELECT * FROM historico_conta_pagar WHERE id_conta_pagar = 4 ORDER BY id_historico;
-- esperado: 2 linhas: valor_total 890.50 -> 905.50 e data_vencimento 2026-10-20 -> 2026-11-30


-- TESTE 3: recebimentos (lado do cliente)
INSERT INTO recebimento (id_conta_receber, id_forma_pagamento, data_recebimento, valor_recebido)
VALUES (4, 1, '2026-11-05', 8100.00);          -- quita a conta 4 de uma vez

INSERT INTO recebimento (id_conta_receber, id_forma_pagamento, data_recebimento, valor_recebido)
VALUES (5, 3, '2026-11-05', 500.00);           -- recebimento parcial da conta 5

SELECT id_conta_receber, valor_total, status
FROM conta_receber WHERE id_conta_receber IN (4, 5);
-- esperado: conta 4 = RECEBIDA, conta 5 = PARCIAL

SELECT * FROM historico_conta_receber ORDER BY id_historico;
-- esperado: conta 4 ABERTA -> RECEBIDA; conta 5 ABERTA -> PARCIAL


-- TESTE 4: conferência com as Views (as contas quitadas saem das Views)
SELECT id_conta_pagar, status, saldo_devedor FROM vw_contas_pagar_em_aberto ORDER BY id_conta_pagar;
-- esperado: a conta 3 não aparece mais (está PAGA)


-- TESTES DE ERRO ESPERADO (executar um por vez)

-- E1: pagamento maior que o saldo (conta 8 deve R$ 4.800)
-- INSERT INTO pagamento (id_conta_pagar, id_forma_pagamento, data_pagamento, valor_pago)
-- VALUES (8, 1, '2026-11-05', 5000.00);
--   esperado: ERROR 1644 (45000) Pagamento excede o saldo devedor da conta

-- E2: pagamento em conta já quitada (conta 1)
-- INSERT INTO pagamento (id_conta_pagar, id_forma_pagamento, data_pagamento, valor_pago)
-- VALUES (1, 1, '2026-11-05', 10.00);
--   esperado: ERROR 1644 (45000) Conta ja quitada ou cancelada: pagamento nao permitido

-- E3: recebimento maior que o saldo (conta 7 tem R$ 9.800)
-- INSERT INTO recebimento (id_conta_receber, id_forma_pagamento, data_recebimento, valor_recebido)
-- VALUES (7, 1, '2026-11-05', 10000.00);
--   esperado: ERROR 1644 (45000) Recebimento excede o saldo a receber da conta

-- E4: valor negativo (restrição CHECK)
-- INSERT INTO pagamento (id_conta_pagar, id_forma_pagamento, data_pagamento, valor_pago)
-- VALUES (8, 1, '2026-11-05', -50.00);
--   esperado: ERROR 3819 Check constraint 'ck_pg_valor' is violated

-- E5: vencimento anterior à emissão (restrição CHECK)
-- INSERT INTO conta_pagar (id_fornecedor, id_categoria, descricao, valor_total, data_emissao, data_vencimento)
-- VALUES (1, 1, 'Teste datas', 100.00, '2026-11-10', '2026-11-01');
--   esperado: ERROR 3819 Check constraint 'ck_cp_datas' is violated

-- E6: CNPJ duplicado (restrição UNIQUE)
-- INSERT INTO fornecedor (razao_social, cnpj) VALUES ('Duplicado Ltda', '11.222.333/0001-44');
--   esperado: ERROR 1062 Duplicate entry
