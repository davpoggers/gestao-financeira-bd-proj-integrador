USE gestao_financeira;
--
-- PARTE A - CRUD completo com um registro temporário

-- INSERT: cadastra um cliente de demonstração
INSERT INTO cliente (nome, cpf_cnpj, email, telefone)
VALUES ('Cliente Demonstração', '999.888.777-66', 'demo@example.com', '(11) 90000-0000');

-- SELECT: confere o cadastro
SELECT * FROM cliente WHERE cpf_cnpj = '999.888.777-66';

-- UPDATE: corrige telefone e e-mail
UPDATE cliente
   SET telefone = '(11) 91111-1111',
       email    = 'demo.novo@example.com'
 WHERE cpf_cnpj = '999.888.777-66';

SELECT * FROM cliente WHERE cpf_cnpj = '999.888.777-66';

-- DELETE: remove o cliente (permitido, pois ele não tem contas vinculadas)
DELETE FROM cliente WHERE cpf_cnpj = '999.888.777-66';

SELECT COUNT(*) AS deve_ser_zero FROM cliente WHERE cpf_cnpj = '999.888.777-66';



-- PARTE B - RISCOS DE ALTERAR OU EXCLUIR REGISTROS RELACIONADOS
--
--
-- Risco 1: excluir um fornecedor que possui contas.
--   Sem a FK, as contas ficariam "órfãs" (apontando para um fornecedor
--   inexistente). Com FK padrão (RESTRICT), o banco bloqueia.
--   Se a FK fosse ON DELETE CASCADE, as contas e o histórico financeiro
--   seriam apagados junto, perda grave de dados. Por isso NÃO usamos CASCADE.
--
-- DELETE FROM fornecedor WHERE id_fornecedor = 1;
--   Erro esperado 1451: Cannot delete or update a parent row: a foreign key constraint fails
--
-- Risco 2: excluir uma conta que já tem pagamentos.
--
-- DELETE FROM conta_pagar WHERE id_conta_pagar = 1;
--   Erro esperado 1451 (a conta 1 possui pagamento registrado)
--
-- Risco 3: alterar a chave primária de um registro referenciado.
--
-- UPDATE fornecedor SET id_fornecedor = 99 WHERE id_fornecedor = 1;
--   Erro esperado 1451
--
-- Risco 4: apontar uma conta para um fornecedor que não existe.
--
-- INSERT INTO conta_pagar (id_fornecedor, id_categoria, descricao, valor_total, data_emissao, data_vencimento)
-- VALUES (999, 1, 'Conta inválida', 100.00, '2026-11-01', '2026-11-10');
--   Erro esperado 1452: Cannot add or update a child row: a foreign key constraint fails
--
-- Risco 5 (importante): o banco PERMITE excluir um pagamento isolado, mas isso
--   deixaria a conta com status 'PAGA' sem pagamento que a sustente.
--   Por isso, na prática, um pagamento errado deve ser tratado como estorno
--   (novo registro/ajuste), e não apagado. Registrar essa limitação na
--   documentação e explicar no seminário.
