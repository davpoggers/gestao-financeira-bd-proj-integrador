USE gestao_financeira;

-- VIEW 1: contas a pagar em aberto, com saldo devedor e situação
-- Utilidade: o financeiro vê o que falta pagar e o que já está em atraso.
CREATE OR REPLACE VIEW vw_contas_pagar_em_aberto AS
SELECT cp.id_conta_pagar,
       f.razao_social AS fornecedor,
       c.nome AS categoria,
       cp.descricao,
       cp.data_vencimento,
       cp.valor_total,
       COALESCE(SUM(p.valor_pago), 0) AS valor_pago,
       cp.valor_total - COALESCE(SUM(p.valor_pago), 0) AS saldo_devedor,
       cp.status,
       CASE WHEN cp.data_vencimento < CURDATE() THEN 'EM ATRASO' ELSE 'A VENCER' END AS situacao,
       CASE WHEN cp.data_vencimento < CURDATE()
            THEN DATEDIFF(CURDATE(), cp.data_vencimento) ELSE 0 END AS dias_atraso
FROM conta_pagar cp
JOIN fornecedor f ON f.id_fornecedor = cp.id_fornecedor
JOIN categoria  c ON c.id_categoria  = cp.id_categoria
LEFT JOIN pagamento p ON p.id_conta_pagar = cp.id_conta_pagar
WHERE cp.status IN ('ABERTA','PARCIAL')
GROUP BY cp.id_conta_pagar, f.razao_social, c.nome, cp.descricao,
         cp.data_vencimento, cp.valor_total, cp.status;


-- VIEW 2: contas a receber em aberto, com saldo a receber e situação
-- Utilidade: acompanhar clientes inadimplentes e a previsão de entrada.
CREATE OR REPLACE VIEW vw_contas_receber_em_aberto AS
SELECT cr.id_conta_receber,
       cl.nome AS cliente,
       c.nome AS categoria,
       cr.descricao,
       cr.data_vencimento,
       cr.valor_total,
       COALESCE(SUM(r.valor_recebido), 0) AS valor_recebido,
       cr.valor_total - COALESCE(SUM(r.valor_recebido), 0) AS saldo_a_receber,
       cr.status,
       CASE WHEN cr.data_vencimento < CURDATE() THEN 'EM ATRASO' ELSE 'A VENCER' END AS situacao,
       CASE WHEN cr.data_vencimento < CURDATE()
            THEN DATEDIFF(CURDATE(), cr.data_vencimento) ELSE 0 END AS dias_atraso
FROM conta_receber cr
JOIN cliente   cl ON cl.id_cliente   = cr.id_cliente
JOIN categoria c  ON c.id_categoria  = cr.id_categoria
LEFT JOIN recebimento r ON r.id_conta_receber = cr.id_conta_receber
WHERE cr.status IN ('ABERTA','PARCIAL')
GROUP BY cr.id_conta_receber, cl.nome, c.nome, cr.descricao,
         cr.data_vencimento, cr.valor_total, cr.status;


-- VIEW 3: fluxo de caixa mensal realizado
-- Utilidade: resultado mensal (entradas - saídas) para os relatórios do gestor.
CREATE OR REPLACE VIEW vw_fluxo_caixa_mensal AS
SELECT DATE_FORMAT(mov.data_mov, '%Y-%m') AS mes,
       SUM(CASE WHEN mov.tipo = 'ENTRADA' THEN mov.valor ELSE 0 END)          AS total_recebido,
       SUM(CASE WHEN mov.tipo = 'SAIDA'   THEN mov.valor ELSE 0 END)          AS total_pago,
       SUM(CASE WHEN mov.tipo = 'ENTRADA' THEN mov.valor ELSE -mov.valor END) AS saldo
FROM (
  SELECT data_recebimento AS data_mov, valor_recebido AS valor, 'ENTRADA' AS tipo FROM recebimento
  UNION ALL
  SELECT data_pagamento, valor_pago, 'SAIDA' FROM pagamento
) mov
GROUP BY mes;


-- EXECUÇÃO DAS VIEWS (demonstração)
SELECT * FROM vw_contas_pagar_em_aberto ORDER BY dias_atraso DESC;
SELECT * FROM vw_contas_receber_em_aberto ORDER BY dias_atraso DESC;
SELECT * FROM vw_fluxo_caixa_mensal ORDER BY mes;

-- Uso da View com filtro (como se fosse uma tabela):
SELECT fornecedor, SUM(saldo_devedor) AS total_em_atraso
FROM vw_contas_pagar_em_aberto
WHERE situacao = 'EM ATRASO'
GROUP BY fornecedor;
