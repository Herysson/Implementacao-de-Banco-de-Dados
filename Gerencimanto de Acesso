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
