
--DECLARE
--Declarando variáveis
DECLARE @valor INT,
		@texto VARCHAR(40),
		@data DATE,
		@nada MONEY

--SET
--Setando os valores das variáveis
SET @valor = 50
SET @texto = 'Herysson R. Figueiredo'
SET @data = GETDATE()
SET @nada = 50.50

--Exibir os valores (consulta)
SELECT @valor AS 'Idade', @texto AS 'Nome', @data AS 'Acesso'

--Exibir valores utilizando PRINT
PRINT 'O valor da variavel nome é: ' 
	+ @texto 
	+ ', e seu ultimo acesso foi em: '
	+ CAST(@data AS VARCHAR(15));
GO

--SELECT para colocar valor em uma variável
-- Declarando variáveis
DECLARE @Nome_Funcionario VARCHAR(100),
        @Salario DECIMAL(10, 2),
        @Aumento DECIMAL(10, 2),
        @Novo_Salario DECIMAL(10, 2);

-- Atribuindo valores
SELECT @Nome_Funcionario = F.Nome, @Salario = F.Salario
FROM Funcionarios as F
WHERE F.CPF = '98765432100';

-- Calculando o novo salário com um aumento de 10%
SET @Aumento = 0.10;
SET @Novo_Salario = @Salario + (@Salario * @Aumento);

-- Exibindo o resultado
SELECT  @Nome_Funcionario AS 'Nome do Funcionário',
        @Salario AS 'Salário Atual',
        @Novo_Salario AS 'Novo Salário com Aumento';

-- Exemplo bilioteca.
DECLARE @Nome_Livro VARCHAR(100)

SELECT @Nome_Livro = L.titulo
FROM Livro as L
WHERE isbn = '9788581742458';

SELECT @Nome_Livro AS 'Nome do Livro';

--Atribuição de valores com calculo
DECLARE @Ano_Publicacao INT,
		@Ano_Atual INT,
		@Nome_Livro VARCHAR(50)
--Atribuir os valroe
SET @Ano_Atual = 2024
SELECT @Nome_Livro = titulo, @Ano_Publicacao = ano
FROM Livro
WHERE isbn = '9788581742458';

--Exibir resultado
SELECT	@Nome_Livro AS 'Nome do Livro',
		@Ano_Atual - @Ano_Publicacao AS 'Idade do Livro';

--Declaração de tabelas
--Calculando idade 
DECLARE @ALUNO TABLE(
	Id INT IDENTITY PRIMARY KEY,
	Nome VARCHAR(50),
	Data_Nasc DATE,
	Curso VARCHAR(2)
);

INSERT INTO @ALUNO 
VALUES ('Herysson R. Figueredo', '1988-06-07','SI');

SELECT * FROM @ALUNO;

--Calculando Idade
DECLARE @idade INT

-- Isso ainda não está correto precisamos melhorar esta consulta.
SELECT @idade = (YEAR(GETDATE()) - YEAR(Data_Nasc)) 
FROM ALUNO
WHERE id = 1;

PRINT 'Idade: ' + CAST(@Idade AS VARCHAR(10));

---------------------------------------------------------------------------------------------------------------
--CAST 
-- Usando CAST para converter o salário decimal em uma string
SELECT	'O funcionário ' 
		+ Nome 
		+ ' tem um salário de: R$ ' 
		+ CAST(Salario AS VARCHAR(20)) AS 'Nome / Salário'
FROM Funcionarios;

-- Usando CONVERT para converter o salário decimal em uma string
SELECT	'O funcionário ' 
		+ Nome 
		+ ' tem um salário de: R$ ' 
		+ CONVERT(VARCHAR(20), Salario) AS 'Nome / Salário'
FROM Funcionarios;
-- Usando CONVERT para formatar a data de nascimento no formato DD/MM/YYYY
SELECT	'O funcionário '
		+ Nome
		+ ' nasceu em: '
		+ CONVERT(VARCHAR(10), Data_Nasc, 103) AS 'Nome / Data de Nascimento'
FROM Funcionarios;
-- Usando CAST para converter o resultado de um cálculo de idade em uma string
DECLARE @Ano_Atual INT = 2024;

SELECT	'O funcionário ' 
		+ Nome 
		+ ' tem ' 
		+ CAST(@Ano_Atual - YEAR(Data_Nasc) AS VARCHAR(3)) 
		+ ' anos.' AS 'Nome / Idade'
FROM Funcionarios;

-- Convertendo a data de contratação para diferentes formatos de string
DECLARE @Datanasc DATETIME;
SET @Datanasc = (SELECT Datanasc FROM FUNCIONARIO WHERE cpf = '88866555576');

-- Convertendo para o formato DD/MM/YYYY
SELECT CONVERT(NVARCHAR(10), @HireDate, 103) AS 'Data no formato DD/MM/YYYY';

-- Convertendo para o formato MM-DD-YYYY
SELECT CONVERT(NVARCHAR(10), @HireDate, 110) AS 'Data no formato MM-DD-YYYY';

-- Convertendo para o formato YYYYMMDD
SELECT CONVERT(NVARCHAR(8), @HireDate, 112) AS 'Data no formato YYYYMMDD';

--------------------------------------------------------------------------------
-- IF / ELSE

--Declarando uma variável
DECLARE @numero INT,
		@texto VARCHAR(10)
--Setando os valore
SET @numero = 20
SET @texto = 'Herysson'

--Condição IF
IF (@numero>18)
	PRINT 'O Usuario ' + @texto + ', pode acessar o site'
ELSE
	PRINT 'O Usuario ' + @texto + ', não tem idade permitida'

--Condição IF/ELSE com mais de uma declaração
IF	@texto = 'Juca'
	BEGIN
		SET @numero = 500
		PRINT @numero
	END
ELSE
	BEGIN
		SET @numero = -25
		PRINT 'NUMERO INCORRETO: ' 
		+ CONVERT(VARCHAR(10), @numero)
	END

--Verificando se um banco já existe
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Bilioteca')
	CREATE DATABASE Biblioteca;
ELSE
	PRINT 'O Banco já existe';
--Verificando se uma tabela já existe
IF NOT EXISTS (	SELECT * FROM sys.objects 
				WHERE object_id = OBJECT_ID(N'Faculdade') 
				AND type IN (N'U'))
	BEGIN
		CREATE TABLE Faculdade(
			Id INT  IDENTITY PRIMARY KEY,
			Nome VARCHAR(50),
			Nota1 FLOAT,
			Nota2 FLOAT,
			Nota3 FLOAT
		);
	END
ELSE 
	PRINT 'A tablea ja existe';

INSERT INTO Faculdade 
VALUES	('Herysson', 9,8,7),
		('Paulo', 6,8,7),
		('Pedro', 7,8,7),
		('José', 9,10,6),
		('Maria', 8,9,10),
		('Juca', 4,5,6),
		('Judas', -3,-8,-25);

-- Calcular a média de um dos Alunos
DECLARE @media FLOAT
SELECT @media = ((F.Nota1+F.Nota2+F.Nota3)/3)
FROM Faculdade  AS F

PRINT @media

-- Verificar se o aluno está aprovado ou reprovado
