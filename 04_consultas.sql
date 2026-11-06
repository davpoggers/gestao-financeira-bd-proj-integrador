USE gestao_financeira;
SET @data_ref = '2026-11-05';

SELECT id_conta_pagar, descricao, valor_total, data_vencimento, status
FROM conta_pagar
WHERE status IN ('ABERTA','PARCIAL')
  AND data_vencimento BETWEEN @data_ref AND DATE_ADD(@data_ref, INTERVAL 30 DAY)
ORDER BY data_vencimento;


SELECT id_conta_receber, descricao, valor_total, status
FROM conta_receber
WHERE valor_total > 5000
  AND status <> 'CANCELADA';


SELECT cp.id_conta_pagar, f.razao_social AS fornecedor, c.nome AS categoria,
       cp.descricao, cp.valor_total, cp.data_vencimento, cp.status
FROM conta_pagar cp
JOIN fornecedor f ON f.id_fornecedor = cp.id_fornecedor
JOIN categoria  c ON c.id_categoria  = cp.id_categoria
ORDER BY cp.data_vencimento;


SELECT p.id_pagamento, f.razao_social AS fornecedor, cp.descricao AS conta,
       fp.nome AS forma_pagamento, p.data_pagamento, p.valor_pago
FROM pagamento p
JOIN conta_pagar cp ON cp.id_conta_pagar = p.id_conta_pagar
JOIN fornecedor f  ON f.id_fornecedor = cp.id_fornecedor
JOIN forma_pagamento  fp ON fp.id_forma_pagamento = p.id_forma_pagamento
ORDER BY p.data_pagamento;


SELECT COUNT(*)                     AS qtd_contas,
       SUM(valor_total)             AS total_lancado,
       ROUND(AVG(valor_total), 2)   AS valor_medio,
       MAX(valor_total)             AS maior_conta,
       MIN(valor_total)             AS menor_conta
FROM conta_pagar
WHERE status <> 'CANCELADA';


SELECT fp.nome AS forma_pagamento,
       COUNT(p.id_pagamento)          AS qtd_pagamentos,
       COALESCE(SUM(p.valor_pago), 0) AS total_pago
FROM forma_pagamento fp
LEFT JOIN pagamento p ON p.id_forma_pagamento = fp.id_forma_pagamento
GROUP BY fp.id_forma_pagamento, fp.nome
ORDER BY total_pago DESC;


SELECT f.razao_social AS fornecedor,
       COUNT(*)            AS qtd_contas,
       SUM(cp.valor_total) AS total_contas
FROM conta_pagar cp
JOIN fornecedor f ON f.id_fornecedor = cp.id_fornecedor
WHERE cp.status <> 'CANCELADA'
GROUP BY f.id_fornecedor, f.razao_social
HAVING SUM(cp.valor_total) > 3000
ORDER BY total_contas DESC;


SELECT cr.id_conta_receber, cl.nome AS cliente, cr.descricao,
       cr.valor_total, cr.status
FROM conta_receber cr
JOIN cliente cl ON cl.id_cliente = cr.id_cliente
WHERE cr.status <> 'CANCELADA'
ORDER BY cr.valor_total DESC, cl.nome ASC
LIMIT 5;


SELECT id_conta_pagar, descricao, valor_total
FROM conta_pagar
WHERE valor_total > (SELECT AVG(valor_total)
                     FROM conta_pagar
                     WHERE status <> 'CANCELADA')
  AND status <> 'CANCELADA'
ORDER BY valor_total DESC;


SELECT cp.id_conta_pagar,
       f.razao_social AS fornecedor,
       cp.descricao,
       cp.data_vencimento,
       cp.valor_total AS valor_lancado,
       COALESCE(SUM(p.valor_pago), 0)  AS valor_pago,
       cp.valor_total - COALESCE(SUM(p.valor_pago), 0) AS saldo_devedor,
       DATEDIFF(@data_ref, cp.data_vencimento) AS dias_atraso,
       CASE
         WHEN DATEDIFF(@data_ref, cp.data_vencimento) <= 15 THEN '1 a 15 dias'
         WHEN DATEDIFF(@data_ref, cp.data_vencimento) <= 30 THEN '16 a 30 dias'
         ELSE 'Mais de 30 dias'
       END                                             AS faixa_atraso
FROM conta_pagar cp
JOIN fornecedor f ON f.id_fornecedor = cp.id_fornecedor
LEFT JOIN pagamento p ON p.id_conta_pagar = cp.id_conta_pagar
WHERE cp.status IN ('ABERTA','PARCIAL')
  AND cp.data_vencimento < @data_ref
GROUP BY cp.id_conta_pagar, f.razao_social, cp.descricao, cp.data_vencimento, cp.valor_total
ORDER BY dias_atraso DESC;


SELECT cr.id_conta_receber,
       cl.nome AS cliente,
       cr.descricao,
       cr.data_vencimento,
       cr.valor_total AS valor_lancado,
       COALESCE(SUM(r.valor_recebido), 0) AS valor_recebido,
       cr.valor_total - COALESCE(SUM(r.valor_recebido), 0) AS saldo_a_receber,
       DATEDIFF(@data_ref, cr.data_vencimento) AS dias_atraso,
       CASE
         WHEN DATEDIFF(@data_ref, cr.data_vencimento) <= 15 THEN '1 a 15 dias'
         WHEN DATEDIFF(@data_ref, cr.data_vencimento) <= 30 THEN '16 a 30 dias'
         ELSE 'Mais de 30 dias'
       END AS faixa_atraso
FROM conta_receber cr
JOIN cliente cl ON cl.id_cliente = cr.id_cliente
LEFT JOIN recebimento r ON r.id_conta_receber = cr.id_conta_receber
WHERE cr.status IN ('ABERTA','PARCIAL')
  AND cr.data_vencimento < @data_ref
GROUP BY cr.id_conta_receber, cl.nome, cr.descricao, cr.data_vencimento, cr.valor_total
ORDER BY dias_atraso DESC;

SELECT DATE_FORMAT(mov.data_mov, '%Y-%m') AS mes,
       SUM(CASE WHEN mov.tipo = 'ENTRADA' THEN mov.valor ELSE 0 END) AS total_recebido,
       SUM(CASE WHEN mov.tipo = 'SAIDA'   THEN mov.valor ELSE 0 END) AS total_pago,
       SUM(CASE WHEN mov.tipo = 'ENTRADA' THEN mov.valor ELSE -mov.valor END) AS saldo
FROM (
  SELECT data_recebimento AS data_mov, valor_recebido AS valor, 'ENTRADA' AS tipo FROM recebimento
  UNION ALL
  SELECT data_pagamento, valor_pago, 'SAIDA' FROM pagamento
) mov
GROUP BY mes
ORDER BY mes;


SET @inicio = '2026-10-01';
SET @fim = '2026-10-31';

SELECT @inicio AS inicio, @fim AS fim,
       t.total_recebido, t.total_pago,
       t.total_recebido - t.total_pago AS saldo_periodo
FROM (
  SELECT
    (SELECT COALESCE(SUM(valor_recebido), 0) FROM recebimento
      WHERE data_recebimento BETWEEN @inicio AND @fim) AS total_recebido,
    (SELECT COALESCE(SUM(valor_pago), 0) FROM pagamento
      WHERE data_pagamento BETWEEN @inicio AND @fim)   AS total_pago
) t;
