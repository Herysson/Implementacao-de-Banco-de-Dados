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
