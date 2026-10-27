--Criar 2 bancos de dados para exemplo de Aula
--Database 1
IF EXISTS(SELECT name FROM sys.databases WHERE name = 'Seguranca_1')
	DROP DATABASE Seguranca_1
CREATE DATABASE Seguranca_1
--Database 2
IF EXISTS(SELECT name FROM sys.databases WHERE name = 'Seguranca_2')
	DROP DATABASE Seguranca_2
CREATE DATABASE Seguranca_2
--Crirar um novo usuário para acessar a database Seguranca_1
USE [master]
GO
CREATE LOGIN [Juca] WITH PASSWORD=N'juca@123', 
DEFAULT_DATABASE=[Seguranca_1], 
CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO
USE [Seguranca_1]
GO
CREATE USER [Juca] FOR LOGIN [Juca]
GO
--Query para verificar informações criadas no banco de dados
SELECT	name,
		create_date,
		modify_date,
		LOGINPROPERTY (name, 'DaysUntilExpiration') DaysUntilExpiration,
		LOGINPROPERTY (name, 'PasswordLastSetTime') PasswordLastSetTime,
		LOGINPROPERTY (name, 'IsExpired') IsExpired,
		LOGINPROPERTY (name, 'IsMustChange') IsMustChange,*
FROM sys.sql_logins

--Instancias de conexão pelo Juca
SELECT * FROM sys.sysprocesses
WHERE loginame = 'Juca'

--Com o loing SA criar uma tabela
CREATE TABLE Disciplina(
	Id int identity,
	data datetime default (getdate()),
	nome varchar(100))
GO
--Preencher a tabela com alguns valore
INSERT INTO Disciplina (nome)
SELECT 'Nome Exemplo'
GO 10 --repete 10 vezes a instrução
--Verificando a inserção de valores
SELECT * FROM Disciplina;

--Dar acesso ai menino Juca
GRANT SELECT ON Disciplina to Juca

--criar uma função
CREATE FUNCTION fncDisciplina(@Id int)
RETURNS TABLE
AS
RETURN
(
	SELECT * FROM Disciplina WHERE Id = @Id
)
--Verificando o funcionamento da função
SELECT * FROM fncDisciplina(3);
--Dando acesso da funcao ao Juca
GRANT SELECT ON fncDisciplina TO Juca

--Criando uma view
CREATE VIEW vwDisciplina
AS
SELECT data,nome FROM Disciplina
--verificando a view criada
SELECT * FROM vwDisciplina
--Dando acesso da view ao Juca
GRANT SELECT ON vwDisciplina to Juca

--Criando um procedure
CREATE PROCEDURE stpDisciplina_01
AS
SELECT * FROM Disciplina
--Verificando o funcionamento do meu procedure
EXEC stpDisciplina_01
--Dando acesso a execução do procedure ao Juca
GRANT EXECUTE ON stpDisciplina_01 TO Juca

--Criando mais 2 procedures
CREATE PROCEDURE stpDisciplina_02
AS
SELECT nome FROM Disciplina

CREATE PROCEDURE stpDisciplina_03
AS
SELECT data FROM Disciplina

--Dando acesso a execução de todos os procedure ao Juca
GRANT EXECUTE TO Juca

--Negar acesso a um procedure
DENY EXECUTE ON stpDisciplina_01 TO Juca

--Negar SLECT ao Juca
DENY SELECT TO Juca

--Criando tabela na database Seguranca_2
USE Seguranca_2

CREATE TABLE Instituicao (cod int)

INSERT INTO Instituicao(cod)
SELECT 1234
GO 20

SELECT * FROM Instituicao
--Retornando a database Seguranca_2
USE Seguranca_1
--Prcedure com interação de duas databases
CREATE PROCEDURE stpDisciplina_04
AS
BEGIN
	SELECT * FROM Disciplina

	SELECT * FROM Seguranca_2..Instituicao
END
--Exeutando o procedimento
EXEC stpDisciplina_04
--Revogando permissão
REVOKE SELECT ON vwDisciplina TO Juca


--Query para retonar as permissões que são dadas a nível de objetos
SELECT	state_desc, prmsn.permission_name as [Permission], sp.type_desc, sp.name,
		grantor_principal.name AS [Grantor], grantee_principal.name as [Grantee]
FROM sys.all_objects AS sp
	INNER JOIN sys.database_permissions AS prmsn 
	ON prmsn.major_id = sp.object_id AND prmsn.minor_id=0 AND prmsn.class = 1
	INNER JOIN sys.database_principals AS grantor_principal
	ON grantor_principal.principal_id = prmsn.grantor_principal_id
	INNER JOIN sys.database_principals AS grantee_principal 
	ON grantee_principal.principal_id = prmsn.grantee_principal_id
WHERE grantee_principal.name = 'Juca'

-- Query para visualizar as Database Roles
SELECT p.name, p.type_desc, pp.name, pp.type_desc, pp.is_fixed_role
FROM sys.database_role_members roles
	JOIN sys.database_principals p ON roles.member_principal_id = p.principal_id
	JOIN sys.database_principals pp ON roles.role_principal_id = pp.principal_id
ORDER BY 1

--02-26

/*
 AULA 11 - GERENCIAMENTO DE ACESSOS (SQL SERVER)
 Exemplo: operador de cadastro da loja
 Banco preexistente: AULA08_LOJA (Aula 08)
 Tabela utilizada: dbo.PRODUTO

 Conteudos: CREATE LOGIN, CREATE USER, GRANT, DENY, REVOKE,
            EXECUTE AS USER e REVERT.

 PRE-REQUISITOS:
 - Execute antes o arquivo Aula_08_Restricoes_Integridade_Loja.sql.
 - Execute esta aula usando uma conta com permissoes para criar logins,
   criar usuarios e gerenciar permissoes no banco.
 - A senha e apenas para ambiente didatico; nao reutilize em producao.

 Este script NAO exclui nem recria o banco AULA08_LOJA.
 Os testes de INSERT sao revertidos para nao alterar os dados da loja.
*/

-- 1. LOGIN: identidade autenticavel no servidor SQL Server.
USE master;
GO

IF DB_ID('AULA08_LOJA') IS NULL
    THROW 50001, 'Execute primeiro o script da Aula 08.', 1;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.server_principals WHERE name = 'operador_loja'
)
BEGIN
    CREATE LOGIN operador_loja
    WITH PASSWORD = 'Aula11#Perm2026_SQL',
         CHECK_POLICY = ON,
         DEFAULT_DATABASE = AULA08_LOJA;
END;
GO

-- 2. USER: vincula o login ao banco AULA08_LOJA.
USE AULA08_LOJA;
GO

IF USER_ID('operador_loja') IS NULL
BEGIN
    CREATE USER operador_loja FOR LOGIN operador_loja;
END;
GO

-- Reinicializa somente as permissoes deste usuario nessa tabela,
-- para que o exemplo possa ser executado novamente.
REVOKE SELECT, INSERT, DELETE ON dbo.PRODUTO FROM operador_loja;
GO

-- 3. GRANT: o operador pode consultar e inserir produtos.
GRANT SELECT, INSERT ON dbo.PRODUTO TO operador_loja;
GO

-- 4. DENY: o operador nao pode excluir produtos.
DENY DELETE ON dbo.PRODUTO TO operador_loja;
GO

-- 5. Teste das permissoes: simular a identidade sem abrir nova conexao.
-- SELECT e INSERT devem funcionar; ROLLBACK desfaz a insercao de teste.
BEGIN TRANSACTION;
EXECUTE AS USER = 'operador_loja';

SELECT IdProduto, Nome, Preco
FROM dbo.PRODUTO
ORDER BY IdProduto;

INSERT INTO dbo.PRODUTO
    (IdProduto, Nome, Preco, Quantidade, IdCategoria)
VALUES
    (901, 'Suporte notebook', 59.90, 5, 30);

SELECT IdProduto, Nome, Preco
FROM dbo.PRODUTO
WHERE IdProduto = 901;

REVERT;               -- Volta ao usuario administrador.
ROLLBACK TRANSACTION; -- Desfaz apenas o INSERT de teste.
GO

-- 6. Teste do DENY DELETE: a exclusao deve ser impedida.
EXECUTE AS USER = 'operador_loja';
BEGIN TRY
    DELETE FROM dbo.PRODUTO WHERE IdProduto = 105;
END TRY
BEGIN CATCH
    PRINT 'DELETE bloqueado: ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 7. REVOKE: retirar a permissao de inserir (sem criar um DENY).
REVOKE INSERT ON dbo.PRODUTO FROM operador_loja;
GO

-- 8. Teste apos o REVOKE: o INSERT deve falhar.
EXECUTE AS USER = 'operador_loja';
BEGIN TRY
    INSERT INTO dbo.PRODUTO
        (IdProduto, Nome, Preco, IdCategoria)
    VALUES (902, 'Base para mouse', 39.90, 30);
END TRY
BEGIN CATCH
    PRINT 'INSERT sem permissao: ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 9. Consultar as permissoes explicitas ao final da aula.
SELECT
    u.name AS Usuario,
    p.state_desc AS Estado,
    p.permission_name AS Permissao,
    OBJECT_NAME(p.major_id) AS Objeto
FROM sys.database_permissions AS p
INNER JOIN sys.database_principals AS u
    ON p.grantee_principal_id = u.principal_id
WHERE u.name = 'operador_loja'
  AND p.class = 1
  AND p.major_id = OBJECT_ID('dbo.PRODUTO')
ORDER BY p.permission_name;
GO

/*
 RESULTADO FINAL ESPERADO (permissoes explicitas na tabela PRODUTO):
 - SELECT => GRANT
 - DELETE => DENY
 - INSERT => sem permissao explicita, apos REVOKE

 OBSERVACAO: REVOKE nao equivale a DENY. Ele remove a concessao
 (ou negacao) explicita. O usuario ainda poderia receber a permissao
 por outra funcao (role) ou outro caminho de autorizacao.

 Para voltar a permitir INSERT:
     GRANT INSERT ON dbo.PRODUTO TO operador_loja;

 Para retirar a negacao de DELETE:
     REVOKE DELETE ON dbo.PRODUTO FROM operador_loja;

 Evite adicionar este usuario a db_owner ou db_datawriter durante o
 exemplo: permissoes herdadas podem mudar o resultado dos testes.

 Para remover o usuario e login depois da aula (executar como admin):
     USE AULA08_LOJA;
     DROP USER operador_loja;
     USE master;
     DROP LOGIN operador_loja;
*/
