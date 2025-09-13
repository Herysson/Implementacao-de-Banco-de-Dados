--REVISÂO

IF (YEAR(GETDATE()) - YEAR(data) = 18 
    AND MONTH(data) < MONTH(GETDATE()) 
    AND DAY(data) < DAY(GETDATE()))
    PRINT 'Maior de idade'
ELSE IF (YEAR(GETDATE()) - YEAR(data) > 18)
    PRINT 'Maior de idade'
ELSE
    PRINT 'Menor de idade'

	
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
DECLARE @NomeFuncionario VARCHAR(100),
        @Salario DECIMAL(10, 2),
        @Aumento DECIMAL(10, 2),
        @NovoSalario DECIMAL(10, 2);

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
-- Verificando se uma tabela já existe
IF NOT EXISTS (	SELECT * FROM sys.objects 
				WHERE object_id = OBJECT_ID(N'Faculdade') 
				AND type IN (N'U'))
	BEGIN
		CREATE TABLE Faculdade(
			Id INT IDENTITY PRIMARY KEY,
			Nome VARCHAR(50),
			Nota1 FLOAT,
			Nota2 FLOAT,
			Nota3 FLOAT
		);
	END
ELSE 
	PRINT 'A tabela já existe';

-- Inserindo dados na tabela Faculdade
INSERT INTO Faculdade 
VALUES	('Herysson', 9,8,7),
		('Paulo', 6,8,7),
		('Pedro', 7,8,7),
		('José', 9,10,6),
		('Maria', 8,9,10),
		('Juca', 4,5,6),
		('Judas', -3,-8,-25);

-- Calcular a média de um dos Alunos
DECLARE @media FLOAT,
        @nome_aluno VARCHAR(50) = 'Herysson'; -- Escolha o aluno desejado

SELECT @media = ((F.Nota1 + F.Nota2 + F.Nota3) / 3)
FROM Faculdade AS F
WHERE F.Nome = @nome_aluno;

PRINT 'Média: ' + CAST(@media AS VARCHAR(10));

-- Verificar se o aluno está aprovado ou reprovado
IF @media >= 7
	PRINT @nome_aluno + ' está Aprovado(a)';
ELSE
	PRINT @nome_aluno + ' está Reprovado(a)';

-- Verificar se um Funcionário Recebe Abaixo da Média Salarial
-- Declarando variáveis
DECLARE @Salario_Medio DECIMAL(10, 2),
        @Salario_Funcionario DECIMAL(10, 2),
        @Nome_Funcionario VARCHAR(100) = 'João Silva'; -- Substitua pelo nome do funcionário desejado

-- Calculando a média salarial de todos os funcionários
SELECT @Salario_Medio = AVG(Salario)
FROM Funcionarios;

-- Obtendo o salário do funcionário específico
SELECT @Salario_Funcionario = Salario
FROM Funcionarios
WHERE Nome = @Nome_Funcionario;

-- Verificando se o salário do funcionário é abaixo da média
IF @Salario_Funcionario < @Salario_Medio
	PRINT @Nome_Funcionario + ' recebe abaixo da média salarial.';
ELSE
	PRINT @Nome_Funcionario + ' recebe na média ou acima da média salarial.';

--Verificar se um Funcionário Está Próximo da Aposentadoria
-- Declarando variáveis
DECLARE @Idade_Funcionario INT,
        @Nome_Funcionario VARCHAR(100) = 'Maria Oliveira'; -- Substitua pelo nome do funcionário desejado

-- Calculando a idade do funcionário
SELECT @Idade_Funcionario = DATEDIFF(YEAR, Data_Nasc, GETDATE())
FROM Funcionarios
WHERE Nome = @Nome_Funcionario;

-- Verificando se o funcionário está próximo da aposentadoria (considerando 65 anos)
IF @Idade_Funcionario >= 60
	PRINT @Nome_Funcionario + ' está próximo(a) da aposentadoria.';
ELSE
	PRINT @Nome_Funcionario + ' ainda tem tempo até a aposentadoria.';

-- Verificar se um Funcionário Já Recebeu Bônus Este Ano
-- Verificar se a coluna de Bônus existe na tabela Funcionarios
IF EXISTS (
	SELECT * FROM sys.columns 
	WHERE object_id = OBJECT_ID(N'Funcionarios') 
	AND name = 'Bonus'
)
BEGIN
	DECLARE @Bonus_Atual DECIMAL(10, 2),
			@Nome_Funcionario VARCHAR(100) = 'Carlos Silva'; -- Substitua pelo nome do funcionário desejado

	-- Obtendo o valor do bônus atual do funcionário
	SELECT @Bonus_Atual = Bonus
	FROM Funcionarios
	WHERE Nome = @Nome_Funcionario;

	-- Verificando se o funcionário já recebeu bônus este ano
	IF @Bonus_Atual > 0
		PRINT @Nome_Funcionario + ' já recebeu bônus este ano.';
	ELSE
		PRINT @Nome_Funcionario + ' ainda não recebeu bônus este ano.';
END
ELSE
BEGIN
	PRINT 'A coluna Bonus não existe na tabela Funcionarios.';
END

--Verificar se o Funcionário é um Novo Contratado
-- Declarando variáveis
DECLARE @Data_Admissao DATE,
        @Nome_Funcionario VARCHAR(100) = 'Ana Sousa'; -- Substitua pelo nome do funcionário desejado

-- Obtendo a data de admissão do funcionário
SELECT @Data_Admissao = Data_Admissao
FROM Funcionarios
WHERE Nome = @Nome_Funcionario;

-- Verificando se o funcionário é novo (admitido nos últimos 6 meses)
IF DATEDIFF(MONTH, @Data_Admissao, GETDATE()) <= 6
	PRINT @Nome_Funcionario + ' é um(a) novo(a) contratado(a).';
ELSE
	PRINT @Nome_Funcionario + ' já está na empresa há mais de 6 meses.';

DECLARE @QtdFuncionarios INT;

-- Conta quantos funcionários estão no departamento 5
SELECT @QtdFuncionarios = COUNT(*)
FROM FUNCIONARIO
WHERE Dnr = 5;

-- Agora, usa o IF para decidir o que fazer
IF @QtdFuncionarios > 5
BEGIN
    PRINT 'O departamento de Pesquisa tem uma equipe grande!';
END
ELSE IF @QtdFuncionarios > 0 AND @QtdFuncionarios <= 5
BEGIN
    PRINT 'O departamento de Pesquisa tem uma equipe de tamanho padrão.';
    PRINT 'Quantidade de funcionários: ' + CAST(@QtdFuncionarios AS VARCHAR);
END
ELSE
BEGIN
    PRINT 'Atenção: Não há funcionários alocados no departamento de Pesquisa.';
END

-- While
DECLARE @salario DECIMAL(10,2);

SELECT @salario = F.Salario
FROM FUNCIONARIO AS F
WHERE F.Pnome = 'Joice' AND F.Unome = 'Leite';

WHILE (@salario <= 30000)
	BEGIN
		PRINT @salario;
		SET @salario = @salario*1.05;
	END;
PRINT @salario;
