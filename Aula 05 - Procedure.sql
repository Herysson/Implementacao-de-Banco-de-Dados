-- Exemplo 1
CREATE PROCEDURE ExibirMeuNome
AS
BEGIN
    PRINT 'Herysson R. Figueiredo';
END;
--Execução
EXEC ExibirMeuNome;


--Stored Procedure para Consulta de Funcionários por Departamento
CREATE PROCEDURE ListarFuncionariosEDepartamentos
AS
BEGIN
    SELECT 
        F.Pnome + ' ' + F.Unome AS NomeCompleto, 
        D.NomeDepto AS NomeDepartamento
    FROM FUNCIONARIO F
    INNER JOIN DEPARTAMENTO D ON F.Dnr = D.Dnumero;
END;

--Executando a procedure
EXEC ListarFuncionariosPorDepartamento;

--Visualizar conteúdo de SP
EXEC sp_helptext ListarFuncionariosPorDepartamento;

--Criptografar Stored Procedure
CREATE PROCEDURE sp_Funcionario
WITH ENCRYPTION
AS
SELECT *
FROM FUNCIONARIO

EXEC sp_Funcionario;
  
EXEC sp_helptext sp_Funcionario;

--Modificando stored procedure
ALTER PROCEDURE sp_FuncionarioDepartamento
    @NomeDepartamento VARCHAR(100)
AS
BEGIN
    SELECT 
        F.Pnome + ' ' + F.Unome AS NomeCompleto, 
        D.NomeDepto AS NomeDepartamento
    FROM FUNCIONARIO F
    INNER JOIN DEPARTAMENTO D ON F.Dnr = D.Dnumero
    WHERE D.NomeDepto = @NomeDepartamento;
END;

--Executando a procedure
EXEC ListarFuncionariosPorDepartamento @DepartamentoID = 5;

--Crie uma procedure que atualiza o salário de um funcionário baseado no CPF.
CREATE PROCEDURE AtualizarSalarioFuncionario
    @Cpf VARCHAR(11),
    @NovoSalario DECIMAL(10, 2)
AS
BEGIN
    -- Atualiza o salário do funcionário com o CPF fornecido
    UPDATE FUNCIONARIO
    SET Salario = @NovoSalario
    WHERE Cpf = @Cpf;

    -- Verifica se a atualização foi feita
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Nenhum funcionário encontrado com o CPF fornecido.';
    END
    ELSE
    BEGIN
        PRINT 'Salário atualizado com sucesso.';
    END
END;

--Crie um procedure que insira um novo funcionário no banco
CREATE PROCEDURE InserirNovoFuncionario
    @Pnome VARCHAR(50),
    @Minicial CHAR(1),
    @Unome VARCHAR(50),
    @Cpf VARCHAR(11),
    @Datanasc DATE,
    @Endereco VARCHAR(100),
    @Sexo CHAR(1),
    @Salario DECIMAL(10, 2),
    @Cpf_supervisor VARCHAR(11),
    @Dnr INT
AS
BEGIN
    -- Insere um novo funcionário na tabela FUNCIONARIO
    INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
    VALUES (@Pnome, @Minicial, @Unome, @Cpf, @Datanasc, @Endereco, @Sexo, @Salario, @Cpf_supervisor, @Dnr);

    PRINT 'Novo funcionário inserido com sucesso.';
END;

EXEC InserirNovoFuncionario 
    @Pnome = 'Paula', 
    @Minicial = 'A', 
    @Unome = 'Silva', 
    @Cpf = '12345678900', 
    @Datanasc = '1990-01-01', 
    @Endereco = 'Rua ABC, 123', 
    @Sexo = 'F', 
    @Salario = 3500.00, 
    @Cpf_supervisor = '98765432100', 
    @Dnr = 5;

-- Crie um procedure que insira um novo funcionário e um novo departamento ao qual ele faz parte
CREATE PROCEDURE InserirFuncionarioEDepartamento
    @NomeDepto VARCHAR(100),
    @LocalizacaoDepto VARCHAR(100),
    @Pnome VARCHAR(50),
    @Minicial CHAR(1),
    @Unome VARCHAR(50),
    @Cpf VARCHAR(11),
    @Datanasc DATE,
    @Endereco VARCHAR(100),
    @Sexo CHAR(1),
    @Salario DECIMAL(10, 2),
    @Cpf_supervisor VARCHAR(11)
AS
BEGIN
    -- Declara uma variável para armazenar o ID do novo departamento
    DECLARE @NovoDeptoID INT;

    -- Insere um novo departamento
    INSERT INTO DEPARTAMENTO (NomeDepto, Localizacao)
    VALUES (@NomeDepto, @LocalizacaoDepto);

    -- Obtém o ID do departamento recém-criado
    SET @NovoDeptoID = SCOPE_IDENTITY();

    -- Insere o novo funcionário no departamento recém-criado
    INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
    VALUES (@Pnome, @Minicial, @Unome, @Cpf, @Datanasc, @Endereco, @Sexo, @Salario, @Cpf_supervisor, @NovoDeptoID);

    PRINT 'Novo funcionário e departamento inseridos com sucesso.';
END;

EXEC InserirFuncionarioEDepartamento 
    @NomeDepto = 'Tecnologia da Informação', 
    @LocalizacaoDepto = 'São Paulo',
    @Pnome = 'João', 
    @Minicial = 'B', 
    @Unome = 'Silva', 
    @Cpf = '12345678901', 
    @Datanasc = '1985-05-10', 
    @Endereco = 'Rua ABC, 123', 
    @Sexo = 'M', 
    @Salario = 4500.00, 
    @Cpf_supervisor = '98765432101';

--Crie um procedure que insira um novo funcionário e um novo departamento ao qual ele faz parte, mas antes verifique se já não existe um funcionário com o mesmo nome (nome completo).
CREATE PROCEDURE VerificarEInserirFuncionario
    @Pnome VARCHAR(50),
    @Minicial CHAR(1),
    @Unome VARCHAR(50),
    @Cpf VARCHAR(11),
    @Datanasc DATE,
    @Endereco VARCHAR(100),
    @Sexo CHAR(1),
    @Salario DECIMAL(10, 2),
    @Cpf_supervisor VARCHAR(11),
    @Dnr INT
AS
BEGIN
    -- Verifica se já existe um funcionário com o mesmo nome no banco
    IF EXISTS (SELECT 1 
               FROM FUNCIONARIO 
               WHERE Pnome = @Pnome 
                 AND Minicial = @Minicial 
                 AND Unome = @Unome)
    BEGIN
        PRINT 'Funcionário já existe no banco de dados.';
        RETURN; -- Encerra a execução se o funcionário já existir
    END

    -- Se não existir, insere o novo funcionário
    INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
    VALUES (@Pnome, @Minicial, @Unome, @Cpf, @Datanasc, @Endereco, @Sexo, @Salario, @Cpf_supervisor, @Dnr);

    PRINT 'Novo funcionário inserido com sucesso.';
END;

--verificando
EXEC VerificarEInserirFuncionario 
    @Pnome = 'João', 
    @Minicial = 'B', 
    @Unome = 'Silva', 
    @Cpf = '12345678901', 
    @Datanasc = '1985-05-10', 
    @Endereco = 'Rua ABC, 123', 
    @Sexo = 'M', 
    @Salario = 4500.00, 
    @Cpf_supervisor = '98765432101', 
    @Dnr = 5;


--Crie uma procedure lista os funcionários cujo salário está entre dois valores fornecidos.
CREATE PROCEDURE ListarFuncionariosPorFaixaSalarial
    @SalarioMin DECIMAL(10, 2),
    @SalarioMax DECIMAL(10, 2)
AS
BEGIN
    -- Seleciona os funcionários cujo salário está entre os valores fornecidos
    SELECT Pnome, Unome, Salario
    FROM FUNCIONARIO
    WHERE Salario BETWEEN @SalarioMin AND @SalarioMax
    ORDER BY Salario ASC;
END;

EXEC ListarFuncionariosPorFaixaSalarial @SalarioMin = 25000.00, @SalarioMax = 35000.00;

--Crie uma procedure que faz uma listagem dos funcionários por departamento, mas se o departamento não for especificado, ela lista todos os funcionários.
CREATE PROCEDURE ListarFuncionariosPorDepartamento
    @DepartamentoID INT = NULL
AS
BEGIN
    -- Se o DepartamentoID for fornecido, lista os funcionários daquele departamento
    IF @DepartamentoID IS NOT NULL
    BEGIN
        SELECT Pnome, Unome, Salario, Datanasc, Dnr
        FROM FUNCIONARIO
        WHERE Dnr = @DepartamentoID;
    END
    ELSE
    BEGIN
        -- Se o DepartamentoID não for fornecido, lista todos os funcionários
        SELECT Pnome, Unome, Salario, Datanasc, Dnr
        FROM FUNCIONARIO;
    END
END;
--Listar Funcionários de um Departamento Específico (por exemplo, o departamento 5):
EXEC ListarFuncionariosPorDepartamento @DepartamentoID = 5;

--Listar Todos os Funcionários (sem passar o parâmetro):
EXEC ListarFuncionariosPorDepartamento;

--Crie uma procedure que retorna o nome completo de um funcionário com base no CPF passado como parâmetro de entrada.
CREATE PROCEDURE ObterNomeCompletoFuncionario
    @Cpf VARCHAR(11),
    @NomeCompleto VARCHAR(100) OUTPUT
AS
BEGIN
    -- Concatenar o primeiro nome e o último nome para formar o nome completo
    SELECT @NomeCompleto = Pnome + ' ' + Unome
    FROM FUNCIONARIO
    WHERE Cpf = @Cpf;

    -- Verifica se o CPF foi encontrado
    IF @NomeCompleto IS NULL
    BEGIN
        SET @NomeCompleto = 'Funcionário não encontrado.';
    END
END;

DECLARE @NomeFuncionario VARCHAR(100);
EXEC ObterNomeCompletoFuncionario @Cpf = '12345678901', @NomeCompleto = @NomeFuncionario OUTPUT;
PRINT @NomeFuncionario;


--Crie um procedure para calcular o salário total de todos os funcionários de um determinado departamento e retorna o valor por meio de um parâmetro de saída.
CREATE PROCEDURE CalcularSalarioTotalPorDepartamento
    @DepartamentoID INT,
    @SalarioTotal DECIMAL(18, 2) OUTPUT
AS
BEGIN
    -- Calcula o salário total dos funcionários no departamento especificado
    SELECT @SalarioTotal = SUM(Salario)
    FROM FUNCIONARIO
    WHERE Dnr = @DepartamentoID;

    -- Verifica se o departamento possui funcionários e se o valor foi calculado
    IF @SalarioTotal IS NULL
    BEGIN
        SET @SalarioTotal = 0;
    END
END;

DECLARE @TotalSalarios DECIMAL(18, 2);
EXEC CalcularSalarioTotalPorDepartamento @DepartamentoID = 5, @SalarioTotal = @TotalSalarios OUTPUT;
PRINT 'O salário total é: ' + CAST(@TotalSalarios AS VARCHAR(20));

--Crie uma procedure que calcula um aumento salarial com base em uma porcentagem fornecida e retorna o novo salário via um parâmetro de saída. Ela também  deve verificar se o salário resultante excede um valor máximo predefinido (60000)
CREATE PROCEDURE CalcularAumentoSalarial
    @Cpf VARCHAR(11),
    @PercentualAumento DECIMAL(5, 2),
    @NovoSalario DECIMAL(10, 2) OUTPUT,
    @SalarioMaximo DECIMAL(10, 2) = 60000.00 -- Valor máximo permitido para o salário
AS
BEGIN
    DECLARE @SalarioAtual DECIMAL(10, 2);

    -- Obter o salário atual do funcionário
    SELECT @SalarioAtual = Salario
    FROM FUNCIONARIO
    WHERE Cpf = @Cpf;

    -- Verifica se o CPF foi encontrado
    IF @SalarioAtual IS NULL
    BEGIN
        PRINT 'Funcionário não encontrado.';
        RETURN;
    END

    -- Calcular o novo salário
    SET @NovoSalario = @SalarioAtual + (@SalarioAtual * @PercentualAumento / 100);

    -- Verificar se o novo salário excede o salário máximo permitido
    IF @NovoSalario > @SalarioMaximo
    BEGIN
        PRINT 'Aumento não permitido, excede o salário máximo de 60.000.';
        SET @NovoSalario = @SalarioMaximo; -- Define o salário no valor máximo
    END
    ELSE
    BEGIN
        PRINT 'Aumento aplicado com sucesso.';
    END
END;

DECLARE @NovoSalarioFuncionario DECIMAL(10, 2);
EXEC CalcularAumentoSalarial @Cpf = '12345678901', @PercentualAumento = 10, @NovoSalario = @NovoSalarioFuncionario OUTPUT;
PRINT 'Novo salário: ' + CAST(@NovoSalarioFuncionario AS VARCHAR(10));

--Crie uma procedure que calcula o tempo de serviço de um funcionário a partir de sua data de admissão e retorna os anos, meses e dias de serviço como parâmetros de saída.
CREATE PROCEDURE CalcularTempoDeServico
    @Cpf VARCHAR(11),
    @Anos INT OUTPUT,
    @Meses INT OUTPUT,
    @Dias INT OUTPUT
AS
BEGIN
    DECLARE @DataAdmissao DATE;
    DECLARE @DataAtual DATE = GETDATE();

    -- Obter a data de admissão do funcionário
    SELECT @DataAdmissao = DataAdmissao
    FROM FUNCIONARIO
    WHERE Cpf = @Cpf;

    -- Verifica se o CPF foi encontrado
    IF @DataAdmissao IS NULL
    BEGIN
        PRINT 'Funcionário não encontrado.';
        SET @Anos = 0;
        SET @Meses = 0;
        SET @Dias = 0;
        RETURN;
    END

    -- Calcular o tempo de serviço em anos, meses e dias
    SELECT @Anos = DATEDIFF(YEAR, @DataAdmissao, @DataAtual),
           @Meses = DATEDIFF(MONTH, @DataAdmissao, @DataAtual) % 12,
           @Dias = DATEDIFF(DAY, DATEADD(MONTH, DATEDIFF(MONTH, @DataAdmissao, @DataAtual), @DataAdmissao), @DataAtual);
END;

DECLARE @Anos INT, @Meses INT, @Dias INT;
EXEC CalcularTempoDeServico @Cpf = '12345678901', @Anos = @Anos OUTPUT, @Meses = @Meses OUTPUT, @Dias = @Dias OUTPUT;
PRINT 'Tempo de serviço: ' + CAST(@Anos AS VARCHAR(2)) + ' anos, ' + CAST(@Meses AS VARCHAR(2)) + ' meses, ' + CAST(@Dias AS VARCHAR(2)) + ' dias';




