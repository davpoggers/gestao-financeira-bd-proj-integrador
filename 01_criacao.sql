DROP DATABASE IF EXISTS gestao_financeira;
CREATE DATABASE gestao_financeira
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gestao_financeira;


-- Cadastros básicos
CREATE TABLE cliente (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cpf_cnpj VARCHAR(18)  NOT NULL UNIQUE,
  email VARCHAR(150),
  telefone VARCHAR(20)
);

CREATE TABLE fornecedor (
  id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
  razao_social VARCHAR(100) NOT NULL,
  cnpj VARCHAR(18)  NOT NULL UNIQUE,
  email VARCHAR(150),
  telefone VARCHAR(20)
);

CREATE TABLE categoria (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(60) NOT NULL,
  tipo ENUM('RECEITA','DESPESA') NOT NULL,
  CONSTRAINT uq_categoria UNIQUE (nome, tipo)
);

CREATE TABLE forma_pagamento (
  id_forma_pagamento INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(40) NOT NULL UNIQUE
);

-- Lançamentos (a conta em si)
CREATE TABLE conta_pagar (
  id_conta_pagar INT AUTO_INCREMENT PRIMARY KEY,
  id_fornecedor INT NOT NULL,
  id_categoria INT NOT NULL,
  descricao VARCHAR(150)  NOT NULL,
  valor_total  DECIMAL(12,2) NOT NULL,
  data_emissao  DATE NOT NULL,
  data_vencimento DATE NOT NULL,
  status ENUM('ABERTA','PARCIAL','PAGA','CANCELADA') NOT NULL DEFAULT 'ABERTA',
  CONSTRAINT fk_cp_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor),
  CONSTRAINT fk_cp_categoria  FOREIGN KEY (id_categoria)  REFERENCES categoria(id_categoria),
  CONSTRAINT ck_cp_valor CHECK (valor_total > 0),
  CONSTRAINT ck_cp_datas CHECK (data_vencimento >= data_emissao)
);

CREATE TABLE conta_receber (
  id_conta_receber INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  id_categoria INT NOT NULL,
  descricao VARCHAR(150)  NOT NULL,
  valor_total DECIMAL(12,2) NOT NULL,
  data_emissao DATE NOT NULL,
  data_vencimento DATE NOT NULL,
  status ENUM('ABERTA','PARCIAL','RECEBIDA','CANCELADA') NOT NULL DEFAULT 'ABERTA',
  CONSTRAINT fk_cr_cliente   FOREIGN KEY (id_cliente)   REFERENCES cliente(id_cliente),
  CONSTRAINT fk_cr_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
  CONSTRAINT ck_cr_valor CHECK (valor_total > 0),
  CONSTRAINT ck_cr_datas CHECK (data_vencimento >= data_emissao)
);


-- Registros de baixa (entidades associativas: conta N:N forma de pagamento)
CREATE TABLE pagamento (
  id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
  id_conta_pagar INT NOT NULL,
  id_forma_pagamento INT NOT NULL,
  data_pagamento DATE NOT NULL,
  valor_pago DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_pg_conta FOREIGN KEY (id_conta_pagar)     REFERENCES conta_pagar(id_conta_pagar),
  CONSTRAINT fk_pg_forma FOREIGN KEY (id_forma_pagamento) REFERENCES forma_pagamento(id_forma_pagamento),
  CONSTRAINT ck_pg_valor CHECK (valor_pago > 0)
);

CREATE TABLE recebimento (
  id_recebimento INT AUTO_INCREMENT PRIMARY KEY,
  id_conta_receber INT NOT NULL,
  id_forma_pagamento INT NOT NULL,
  data_recebimento DATE NOT NULL,
  valor_recebido DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_rc_conta FOREIGN KEY (id_conta_receber)   REFERENCES conta_receber(id_conta_receber),
  CONSTRAINT fk_rc_forma FOREIGN KEY (id_forma_pagamento) REFERENCES forma_pagamento(id_forma_pagamento),
  CONSTRAINT ck_rc_valor CHECK (valor_recebido > 0)
);

-- Históricos (preenchidos automaticamente por Triggers - arquivo 06)
CREATE TABLE historico_conta_pagar (
  id_historico   INT AUTO_INCREMENT PRIMARY KEY,
  id_conta_pagar INT NOT NULL,
  campo_alterado VARCHAR(30) NOT NULL,
  valor_anterior VARCHAR(100),
  valor_novo     VARCHAR(100),
  data_alteracao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_hcp_conta FOREIGN KEY (id_conta_pagar) REFERENCES conta_pagar(id_conta_pagar)
);

CREATE TABLE historico_conta_receber (
  id_historico     INT AUTO_INCREMENT PRIMARY KEY,
  id_conta_receber INT NOT NULL,
  campo_alterado   VARCHAR(30) NOT NULL,
  valor_anterior   VARCHAR(100),
  valor_novo       VARCHAR(100),
  data_alteracao   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_hcr_conta FOREIGN KEY (id_conta_receber) REFERENCES conta_receber(id_conta_receber)
);

-- Conferência: deve listar 10 tabelas
SHOW TABLES;
