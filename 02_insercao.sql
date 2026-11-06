USE gestao_financeira;

INSERT INTO cliente (nome, cpf_cnpj, email, telefone) VALUES
('Padaria Pão Amassado Ltda', '12.345.678/0001-90', 'contato@paoamassado.example.com', '(11) 4701-1001'),
('Mercado Tel Aviv Ltda','23.456.789/0001-01', 'compras@telaviv.example.com', '(11) 4701-1002'),
('Maria Aparecida Santos', '111.222.333-44', 'maria.santos@example.com', '(11) 98701-1003'),
('Construtora Tung Tung S.A.', '34.567.890/0001-12', 'financeiro@tung.example.com', '(11) 4701-1004'),
('Clínica Vida Vivida Ltda', '45.678.901/0001-23', 'adm@vidavivida.example.com', '(11) 4701-1005'),
('João José Estrela', '222.333.444-55', 'jojo.joestar@example.com', '(11) 98701-1006');

INSERT INTO fornecedor (razao_social, cnpj, email, telefone) VALUES
('Imobiliária Central Ltda', '11.222.333/0001-44', 'cobranca@imobcentral.example.com', '(11) 4702-2001'),
('Companhia de Energia Paulista', '22.333.444/0001-55', 'faturas@energiapaulista.example.com', '(11) 4702-2002'),
('Papelaria Rio Preto ME', '33.444.555/0001-66', 'vendas@riopreto.example.com', '(11) 4702-2003'),
('TechExplosões Informática Ltda', '44.555.666/0001-77', 'suporte@techexplosoes.example.com', '(11) 4702-2004'),
('Gráfica Express Ltda', '55.666.777/0001-88', 'orcamento@graficaexpress.example.com', '(11) 4702-2005'),
('Agência Pixel Marketing Ltda', '66.777.888/0001-99', 'contato@agenciapixel.example.com', '(11) 4702-2006');

INSERT INTO categoria (nome, tipo) VALUES
('Aluguel', 'DESPESA'),   -- 1
('Energia e Água', 'DESPESA'),   -- 2
('Material de Escritório', 'DESPESA'),   -- 3
('Serviços de TI', 'DESPESA'),   -- 4
('Marketing', 'DESPESA'),   -- 5
('Venda de Produtos', 'RECEITA'),   -- 6
('Prestação de Serviços', 'RECEITA');   -- 7

INSERT INTO forma_pagamento (nome) VALUES
('PIX'), -- 1
('Boleto'), -- 2
('Transferência'), -- 3
('Cartão de Crédito'), -- 4
('Dinheiro'); -- 5

-- Contas a pagar (id_fornecedor, id_categoria, descricao, valor, emissao, vencimento, status)
INSERT INTO conta_pagar
(id_fornecedor, id_categoria, descricao, valor_total, data_emissao, data_vencimento, status) VALUES
(1, 1, 'Aluguel setembro/2026',        3500.00, '2026-09-01', '2026-09-10', 'PAGA'),      -- 1
(1, 1, 'Aluguel outubro/2026',         3500.00, '2026-10-01', '2026-10-10', 'PAGA'),      -- 2
(1, 1, 'Aluguel novembro/2026',        3500.00, '2026-11-01', '2026-11-10', 'ABERTA'),    -- 3
(2, 2, 'Energia outubro/2026',          890.50, '2026-10-05', '2026-10-20', 'ABERTA'),    -- 4 (vencida)
(2, 2, 'Energia setembro/2026',         845.30, '2026-09-05', '2026-09-20', 'PAGA'),      -- 5
(3, 3, 'Compra de papel e toner',      1250.00, '2026-10-02', '2026-10-30', 'PARCIAL'),   -- 6 (vencida)
(4, 4, 'Suporte de TI outubro/2026',   2200.00, '2026-10-01', '2026-10-15', 'PAGA'),      -- 7 (2 formas)
(4, 4, 'Licenças de software anual',   4800.00, '2026-10-15', '2026-12-15', 'ABERTA'),    -- 8
(5, 5, 'Impressão de folders',         1800.00, '2026-09-15', '2026-10-05', 'ABERTA'),    -- 9 (vencida)
(6, 5, 'Campanha de redes sociais',    2600.00, '2026-10-20', '2026-11-20', 'ABERTA'),    -- 10
(3, 3, 'Material de escritório dez/26', 780.00, '2026-11-02', '2026-12-05', 'ABERTA'),    -- 11
(6, 5, 'Campanha cancelada',           1500.00, '2026-08-10', '2026-09-10', 'CANCELADA'); -- 12


-- Pagamentos (id_conta_pagar, id_forma_pagamento, data, valor)
INSERT INTO pagamento (id_conta_pagar, id_forma_pagamento, data_pagamento, valor_pago) VALUES
(1, 1, '2026-09-09', 3500.00),
(2, 1, '2026-10-10', 3500.00),
(5, 2, '2026-09-19',  845.30),
(6, 5, '2026-10-28',  500.00),   -- pagamento parcial
(7, 1, '2026-10-14', 1200.00),   -- conta 7 paga em duas formas (PIX + transferência)
(7, 3, '2026-10-15', 1000.00);


-- Contas a receber (id_cliente, id_categoria, descricao, valor, emissao, vencimento, status)
INSERT INTO conta_receber
(id_cliente, id_categoria, descricao, valor_total, data_emissao, data_vencimento, status) VALUES
(1, 6, 'Venda de pães - setembro',         4200.00, '2026-09-02', '2026-09-30', 'RECEBIDA'),  -- 1
(1, 6, 'Venda de pães - outubro',          4600.00, '2026-10-02', '2026-10-31', 'RECEBIDA'),  -- 2
(2, 6, 'Fornecimento mercado - setembro',  7800.00, '2026-09-05', '2026-10-05', 'PARCIAL'),   -- 3 (vencida)
(2, 6, 'Fornecimento mercado - outubro',   8100.00, '2026-10-05', '2026-11-12', 'ABERTA'),    -- 4
(3, 7, 'Consultoria financeira',           1500.00, '2026-10-10', '2026-10-25', 'ABERTA'),    -- 5 (vencida)
(4, 7, 'Projeto elétrico - obra A',       12500.00, '2026-09-10', '2026-10-10', 'PARCIAL'),   -- 6 (vencida)
(4, 7, 'Projeto elétrico - obra B',        9800.00, '2026-11-01', '2026-12-01', 'ABERTA'),    -- 7
(5, 7, 'Mensalidade de serviços - outubro', 2300.00, '2026-10-01', '2026-10-15', 'RECEBIDA'), -- 8 (recebida com atraso)
(5, 7, 'Mensalidade de serviços - novembro', 2300.00, '2026-11-01', '2026-11-15', 'ABERTA'),   -- 9
(6, 6, 'Venda avulsa',                      650.00, '2026-10-20', '2026-11-03', 'ABERTA'),    -- 10 (vencida)
(3, 6, 'Venda cancelada',                   900.00, '2026-08-20', '2026-09-20', 'CANCELADA'); -- 11

-- Recebimentos (id_conta_receber, id_forma_pagamento, data, valor)
INSERT INTO recebimento (id_conta_receber, id_forma_pagamento, data_recebimento, valor_recebido) VALUES
(1, 1, '2026-09-28', 4200.00),
(2, 1, '2026-10-29', 4600.00),
(3, 2, '2026-10-03', 5000.00),   -- parcial (saldo 2800)
(6, 3, '2026-10-09', 6000.00),   -- parcial em duas parcelas (saldo 3500)
(6, 1, '2026-10-30', 3000.00),
(8, 4, '2026-10-16', 2300.00);   -- recebida 1 dia após o vencimento

-- Conferência rápida da carga
SELECT 'cliente' AS tabela, COUNT(*) AS registros FROM cliente
UNION ALL SELECT 'fornecedor', COUNT(*) FROM fornecedor
UNION ALL SELECT 'categoria', COUNT(*) FROM categoria
UNION ALL SELECT 'forma_pagamento', COUNT(*) FROM forma_pagamento
UNION ALL SELECT 'conta_pagar', COUNT(*) FROM conta_pagar
UNION ALL SELECT 'pagamento', COUNT(*) FROM pagamento
UNION ALL SELECT 'conta_receber', COUNT(*) FROM conta_receber
UNION ALL SELECT 'recebimento', COUNT(*) FROM recebimento;
