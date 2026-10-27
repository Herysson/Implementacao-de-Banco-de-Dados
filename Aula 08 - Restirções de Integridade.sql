*
	SQL Constrains (RESTRIÇÕES): São especificadas para aplicar regras nos dados da tabela

	NOT NULL - A coluna não pode ser nula
	UNIQUE - Todos o valores nesta coluna são diferentes
	PRIMARY KEY - Combinação entre NOT NULL e UNIQUE - Identifica a tupla da tabela
	FOREIGN KEY - Links entre as tabelas
	CHECK -Especifica que os valor contidos na coluna sadisfazer uma condição
	DEFAULT  - Seta valores padrão para a coluna em questão
	CREAT INDEX - usado para riar e recuperar dados de uma tabela
*/
CREATE DATABASE Aula9;
USE Aula9;
--cadastro de um Pet Shop
CREATE TABLE tbl_pessoa
(
	id INTEGER NOT NULL PRIMARY KEY IDENTITY,
	nome_pessoa VARCHAR(50),
	nome_pet VARCHAR(50),
	num_pet INTEGER CHECK(num_pet > 0),
	idade INTEGER CHECK (idade BETWEEN 18 AND 99),
	sexo CHAR CHECK (sexo IN ('M','F','N'))
);
--Testado as restrições criadas
INSERT INTO tbl_pessoa VALUES ('Herysson','Logan',2,34,'M');
INSERT INTO tbl_pessoa VALUES ('Deise','Phoebs',2,36,'F');

INSERT INTO tbl_pessoa VALUES ('Juca','Gargameu',0,30,'M');
INSERT INTO tbl_pessoa VALUES ('Juca','Rambo',1,17,'M');
INSERT INTO tbl_pessoa VALUES ('Juca','Rambo',1,18,'X');
INSERT INTO tbl_pessoa VALUES ('Juca','Rambo',-15,150,'Y');
--Verificadno a inserção dos valore
SELECT * FROM tbl_pessoa;


-- Primeiro exemplo para arplicação de CASCADE
CREATE TABLE Pais
(	
	id_pais INT PRIMARY KEY,
	nome_pais VARCHAR(50),
	cod_pais VARCHAR(3)
);
CREATE TABLE Estados
(
	id_estado INT PRIMARY KEY,
	nome_estado VARCHAR(50),
	cod_estado VARCHAR(3),
	id_pais INT
);
--Criando restrição de alteração com CHECK + CASCADE
ALTER TABLE [dbo].[Estados] WITH CHECK ADD CONSTRAINT [FK_estado_pais] FOREIGN KEY([id_pais])
REFERENCES [dbo].[Pais] ([id_pais])
ON DELETE CASCADE

--exibe informações das tabelas
--sp_help Estados;

--Inserindo informações no banco nas tabelas criadas acima
INSERT INTO [dbo].[Pais] VALUES (1,'Estados Unidos','EUA');
INSERT INTO [dbo].[Pais] VALUES (2,'Brasil','BR');
INSERT INTO [dbo].[Pais] VALUES (3,'Canada','CA');

INSERT INTO [dbo].[Estados] VALUES (1,'Califórnia','CA', 1);
INSERT INTO [dbo].[Estados] VALUES (2,'Alasca','AK', 1);
INSERT INTO [dbo].[Estados] VALUES (3,'Florida','FL', 1);
INSERT INTO [dbo].[Estados] VALUES (4,'Arizona','AZ', 1);

INSERT INTO [dbo].[Estados] VALUES (5,'Rio Grande do Sul','RS', 2);
INSERT INTO [dbo].[Estados] VALUES (6,'Acre','AC', 2);
INSERT INTO [dbo].[Estados] VALUES (7,'São Paulo','SP', 2);
INSERT INTO [dbo].[Estados] VALUES (8,'Sergipe','SE', 2);

INSERT INTO [dbo].[Estados] VALUES (9,'Ontario','ON', 3);
INSERT INTO [dbo].[Estados] VALUES (10,'Quebec','QC', 3);
INSERT INTO [dbo].[Estados] VALUES (11,'Toronto','TR', 3);
INSERT INTO [dbo].[Estados] VALUES (12,'Nova Escócia','NS', 3);

--Verificnado o preenchimento das tabelas
SELECT * FROM [dbo].[Pais];
SELECT * FROM [dbo].[Estados];
--Deletando um Pais
DELETE FROM [dbo].[Pais] WHERE [id_pais] = 2;

--Outra forma de criação de restrições CONSTRAINT
CREATE TABLE tbl_produtos
(	
	id_produto INT PRIMARY KEY,
	nome_produto VARCHAR(50),
	categoria VARCHAR(25)
);
CREATE TABLE tbl_inventario
(
	id_inventario INT PRIMARY KEY,
	fk_id_produto INT,
	quantidade INT,
	min_level INT,
	max_level INT,
	CONSTRAINT fk_inv_produto
		FOREIGN KEY (fk_id_produto)
		REFERENCES tbl_produtos (id_produto)
		ON DELETE CASCADE
);

--Inserindo registroro nas tabelas acima (Distribuidora de bebidas)
INSERT INTO  [dbo].[tbl_produtos] VALUES (1, 'Refrigerante','Bebidas');
INSERT INTO  [dbo].[tbl_produtos] VALUES (2, 'Cerveja','Bebidas');
INSERT INTO  [dbo].[tbl_produtos] VALUES (3, 'Tequila','Bebidas');
INSERT INTO  [dbo].[tbl_produtos] VALUES (4, 'Energético','Bebidas');

INSERT INTO [dbo].[tbl_inventario] VALUES (1,1,500,10,1000);
INSERT INTO [dbo].[tbl_inventario] VALUES (2,4,50,5,50);
INSERT INTO [dbo].[tbl_inventario] VALUES (3,2,1000,5,5000);

--Verificando as inserções realizadas nas tabelas acima
SELECT * FROM [dbo].[tbl_produtos];
SELECT * FROM [dbo].[tbl_inventario];

--Deletando um produto
DELETE FROM [dbo].[tbl_produtos] WHERE [id_produto] = 1;

--TENTADO ALTERAR A CONSTRAINT
ALTER TABLE [dbo].[tbl_inventario] WITH CHECK ADD CONSTRAINT [fk_inv_produto] FOREIGN KEY ([fk_id_produto])
REFERENCES [dbo].[tbl_produtos] ([id_produto])
ON UPDATE CASCADE

--Deletando a CONSTRAINT Existente
ALTER TABLE [dbo].[tbl_inventario] DROP CONSTRAINT [fk_inv_produto];

--Alterando um ID da tabela produto
UPDATE [dbo].[tbl_produtos] SET [id_produto] = 54 WHERE [id_produto] = 1;

--Criando uma nova restriação para DELETE e UPDATE
--TENTADO ALTERAR A CONSTRAINT
ALTER TABLE [dbo].[tbl_inventario] WITH CHECK ADD CONSTRAINT [fk_inv_produto] FOREIGN KEY ([fk_id_produto])
REFERENCES [dbo].[tbl_produtos] ([id_produto])
ON UPDATE CASCADE
ON DELETE SET NULL

--Deletando um produto
DELETE FROM [dbo].[tbl_produtos] WHERE [id_produto] = 4;

--Exemplo de criação caso a FK ja exista na tabela
ALTER TABLE [dbo].[tbl_inventario] ADD CONSTRAINT [fk_inv_produto] FOREIGN KEY ([fk_id_produto])
REFERENCES [dbo].[tbl_produtos] ([id_produto])
ON UPDATE CASCADE
ON DELETE SET NULL

--02-2026

-- 1. Criar o banco de dados (permitindo executar novamente o exemplo)
USE master;
GO

IF DB_ID('AULA08_LOJA') IS NOT NULL
BEGIN
    ALTER DATABASE AULA08_LOJA
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AULA08_LOJA;
END;
GO

CREATE DATABASE AULA08_LOJA;
GO
USE AULA08_LOJA;
GO

-- 2. Criar tabelas e restricoes

-- Cada categoria tem um identificador unico e nome obrigatorio e unico.
CREATE TABLE CATEGORIA (
    IdCategoria INT PRIMARY KEY,
    Nome VARCHAR(60) NOT NULL,
    CONSTRAINT UQ_CATEGORIA_NOME UNIQUE (Nome)
);
GO

-- O telefone e opcional (aceita NULL).
CREATE TABLE FORNECEDOR (
    IdFornecedor INT PRIMARY KEY,
    Nome VARCHAR(60) NOT NULL,
    Telefone VARCHAR(20) NULL
);
GO

-- Cada produto pertence a uma categoria e pode ter um fornecedor.
CREATE TABLE PRODUTO (
    IdProduto INT PRIMARY KEY,
    Nome VARCHAR(80) NOT NULL,
    Preco DECIMAL(10,2) NOT NULL,
    Quantidade INT NOT NULL CONSTRAINT DF_PRODUTO_QUANTIDADE DEFAULT 0,
    Situacao VARCHAR(10) NOT NULL CONSTRAINT DF_PRODUTO_SITUACAO DEFAULT 'Ativo',
    IdCategoria INT NOT NULL,
    IdFornecedor INT NULL,

    CONSTRAINT CK_PRODUTO_PRECO CHECK (Preco > 0),
    CONSTRAINT CK_PRODUTO_QUANTIDADE CHECK (Quantidade >= 0),
    CONSTRAINT CK_PRODUTO_SITUACAO CHECK (Situacao IN ('Ativo', 'Inativo')),

    CONSTRAINT FK_PRODUTO_CATEGORIA
        FOREIGN KEY (IdCategoria) REFERENCES CATEGORIA(IdCategoria)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

-- Exemplo de inclusao de restricao posteriormente com ALTER TABLE.
-- Ao excluir o fornecedor, o produto permanece com IdFornecedor = NULL.
ALTER TABLE PRODUTO
ADD CONSTRAINT FK_PRODUTO_FORNECEDOR
    FOREIGN KEY (IdFornecedor) REFERENCES FORNECEDOR(IdFornecedor)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
GO

-- 3. Inserir dados validos
INSERT INTO CATEGORIA (IdCategoria, Nome) VALUES
    (10, 'Informatica'),
    (20, 'Papelaria'),
    (30, 'Acessorios');

INSERT INTO FORNECEDOR (IdFornecedor, Nome, Telefone) VALUES
    (1, 'Distribuidora Alfa', '5555-1010'),
    (2, 'Comercial Beta', NULL);

INSERT INTO PRODUTO
    (IdProduto, Nome, Preco, Quantidade, Situacao, IdCategoria, IdFornecedor)
VALUES
    (101, 'Mouse sem fio', 79.90, 15, 'Ativo', 10, 1),
    (102, 'Teclado USB', 120.00, 8, 'Ativo', 10, 2),
    (103, 'Caderno', 29.90, 50, 'Ativo', 20, 1),
    (104, 'Caneta', 4.50, 100, 'Ativo', 20, 2);

-- Nao informa Quantidade, Situacao e IdFornecedor:
-- aplica DEFAULT 0, DEFAULT 'Ativo' e NULL, respectivamente.
INSERT INTO PRODUTO (IdProduto, Nome, Preco, IdCategoria)
VALUES (105, 'Fone de ouvido', 99.90, 30);
GO

-- 4. Consultar dados cadastrados
SELECT * FROM CATEGORIA;
SELECT * FROM FORNECEDOR;
SELECT * FROM PRODUTO;
GO

/*
  5. TESTES DE VIOLACAO DAS RESTRICOES

  Os comandos abaixo estao COMENTADOS porque geram erros intencionais.
  Para cada teste, remova o comentario de somente UM comando e execute.

  -- UNIQUE: nome da categoria ja existente
  INSERT INTO CATEGORIA (IdCategoria, Nome)
  VALUES (40, 'Papelaria');

  -- PRIMARY KEY: identificador de categoria ja existente
  INSERT INTO CATEGORIA (IdCategoria, Nome)
  VALUES (10, 'Escritorio');

  -- NOT NULL: nome obrigatorio
  INSERT INTO CATEGORIA (IdCategoria, Nome)
  VALUES (40, NULL);

  -- CHECK: preco nao pode ser negativo
  INSERT INTO PRODUTO (IdProduto, Nome, Preco, IdCategoria)
  VALUES (106, 'Monitor', -500.00, 10);

  -- CHECK: quantidade nao pode ser negativa
  INSERT INTO PRODUTO (IdProduto, Nome, Preco, Quantidade, IdCategoria)
  VALUES (106, 'Monitor', 500.00, -2, 10);

  -- CHECK: situacao aceita somente 'Ativo' ou 'Inativo'
  INSERT INTO PRODUTO (IdProduto, Nome, Preco, Situacao, IdCategoria)
  VALUES (106, 'Monitor', 500.00, 'Pendente', 10);

  -- FOREIGN KEY: categoria inexistente
  INSERT INTO PRODUTO (IdProduto, Nome, Preco, IdCategoria)
  VALUES (106, 'Monitor', 500.00, 999);
*/

-- 6. ON UPDATE CASCADE
-- Atualizar o identificador da categoria 10 para 11.
-- Os produtos 101 e 102 passam a apontar para a categoria 11.
UPDATE CATEGORIA
SET IdCategoria = 11
WHERE IdCategoria = 10;

SELECT IdProduto, Nome, IdCategoria
FROM PRODUTO
ORDER BY IdProduto;
GO

-- 7. ON DELETE SET NULL
-- Excluir o fornecedor 1. Produtos 101 e 103 continuam cadastrados,
-- mas ficam sem fornecedor.
DELETE FROM FORNECEDOR
WHERE IdFornecedor = 1;

SELECT IdProduto, Nome, IdFornecedor
FROM PRODUTO
ORDER BY IdProduto;
GO

-- 8. ON DELETE CASCADE
-- Excluir a categoria 20 (Papelaria). Produtos 103 e 104 sao
-- excluidos automaticamente pelo banco de dados.
DELETE FROM CATEGORIA
WHERE IdCategoria = 20;

SELECT * FROM CATEGORIA;
SELECT * FROM PRODUTO;
GO

/*
  9. EXEMPLO ADICIONAL: ALTERAR UMA RESTRICAO EXISTENTE

  Para modificar uma restricao nomeada, normalmente a removemos
  e a criamos novamente com a regra desejada.

  ALTER TABLE PRODUTO
  DROP CONSTRAINT CK_PRODUTO_QUANTIDADE;

  ALTER TABLE PRODUTO WITH CHECK
  ADD CONSTRAINT CK_PRODUTO_QUANTIDADE
  CHECK (Quantidade >= 0);

  Esse trecho e opcional: executar somente ao demonstrar ALTER TABLE.
*/

