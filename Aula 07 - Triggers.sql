
--Exemplo 1
ALTER TRIGGER trg_after_insert_funcionario
ON FUNCIONARIO
AFTER INSERT
AS
BEGIN
	DECLARE @Cpf CHAR(11),
			@Pnome VARCHAR(15),
			@Unome VARCHAR(15),
			@Salario DECIMAL(10,2);
	--Recupera o valores contidos na inserção
	SELECT @Cpf = I.Cpf, @Pnome = I.Pnome, @Unome = I.Unome, @Salario = I.Salario
	FROM inserted AS I;
	-- Exibe os valores
	PRINT 'Funcioinario inserido: ';
	PRINT 'CPF:' + @Cpf;
	PRINT 'Nome: ' + @Pnome + ' ' + @Unome;
	PRINT 'Salario: ' + CAST(@Salario AS VARCHAR(20));
END;

INSERT INTO FUNCIONARIO (Cpf, Pnome,Unome, Salario)
VALUES ('32569994563', 'Madalena', 'Silva', 1500.00);

SELECT * FROM FUNCIONARIO;

-- Exemplo 2

CREATE TABLE Log_Funcionario (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    Cpf CHAR(11),
    Operacao VARCHAR(10),
    Data_Hora DATETIME DEFAULT GETDATE()
);
GO

  --Criação do trigger para INSERT:
CREATE TRIGGER trg_log_insert_funcionario
ON FUNCIONARIO
AFTER INSERT
AS
BEGIN
    -- Inserindo os dados na tabela de log
    INSERT INTO Log_Funcionario (Cpf, Operacao)
    SELECT Cpf, 'INSERT'
    FROM inserted;
END;
GO

  --Criação do trigger para UPDATE:
CREATE TRIGGER trg_log_update_funcionario
ON FUNCIONARIO
AFTER UPDATE
AS
BEGIN
    -- Inserindo os dados na tabela de log
    INSERT INTO Log_Funcionario (Cpf, Operacao)
    SELECT Cpf, 'UPDATE'
    FROM inserted;
END;
GO

  -- Criação do trigger para DELETE:
CREATE TRIGGER trg_log_delete_funcionario
ON FUNCIONARIO
AFTER DELETE
AS
BEGIN
    -- Inserindo os dados na tabela de log
    INSERT INTO Log_Funcionario (Cpf, Operacao)
    SELECT Cpf, 'DELETE'
    FROM deleted;
END;
GO

-- Exemplo1 
CREATE TRIGGER trg_after_insert_funcionario
ON FUNCIONARIO
AFTER INSERT
AS
BEGIN
    -- Registrar inserção na tabela de log
    INSERT INTO Log_Funcionario (Cpf, Operacao, Data_Hora)
    SELECT Cpf, 'INSERT', GETDATE()
    FROM inserted;
END;
GO

-- Exemplo 2
CREATE TRIGGER trg_instead_of_insert_funcionario
ON FUNCIONARIO
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Salario DECIMAL(10,2);
    
    -- Verifica se o salário inserido é válido
    SELECT @Salario = i.Salario FROM inserted i;
    
    IF @Salario >= 1000.00
    BEGIN
        -- Executa a inserção se o salário for válido
        INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
        SELECT Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr
        FROM inserted;
    END
    ELSE
    BEGIN
        -- Exibe uma mensagem de erro se o salário for inválido
        RAISERROR('O salário não pode ser menor que R$ 1.000,00.', 16, 1);
    END
END;
GO
-- exemplo 3 
CREATE TRIGGER trg_after_update_funcionario
ON FUNCIONARIO
AFTER UPDATE
AS
BEGIN
    -- Registrar atualização na tabela de log
    INSERT INTO Log_Funcionario (Cpf, Operacao, Data_Hora)
    SELECT Cpf, 'UPDATE', GETDATE()
    FROM inserted;
END;
GO

-- Exemplo 4

CREATE TRIGGER trg_instead_of_update_funcionario
ON FUNCIONARIO
INSTEAD OF UPDATE
AS
BEGIN
    DECLARE @NovoSalario DECIMAL(10,2);

    -- Verifica se o novo salário é válido
    SELECT @NovoSalario = i.Salario FROM inserted i;

    IF @NovoSalario >= 1000.00
    BEGIN
        -- Executa a atualização se o salário for válido
        UPDATE FUNCIONARIO
        SET Pnome = i.Pnome, Minicial = i.Minicial, Unome = i.Unome, Datanasc = i.Datanasc,
            Endereco = i.Endereco, Sexo = i.Sexo, Salario = i.Salario, Cpf_supervisor = i.Cpf_supervisor, Dnr = i.Dnr
        FROM inserted i
        WHERE FUNCIONARIO.Cpf = i.Cpf;
    END
    ELSE
    BEGIN
        -- Exibe uma mensagem de erro se o novo salário for inválido
        RAISERROR('O salário não pode ser menor que R$ 1.000,00.', 16, 1);
    END
END;
GO

-- Exemplo 5 
CREATE TRIGGER trg_after_delete_funcionario
ON FUNCIONARIO
AFTER DELETE
AS
BEGIN
    -- Registrar exclusão na tabela de log
    INSERT INTO Log_Funcionario (Cpf, Operacao, Data_Hora)
    SELECT Cpf, 'DELETE', GETDATE()
    FROM deleted;
END;
GO
-- Exemplo 6 

CREATE TRIGGER trg_instead_of_delete_funcionario
ON FUNCIONARIO
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @Cpf CHAR(11);

    -- Verifica se o funcionário a ser excluído é gerente de algum departamento
    SELECT @Cpf = d.Cpf_gerente
    FROM deleted del
    INNER JOIN DEPARTAMENTO d ON del.Cpf = d.Cpf_gerente;

    IF @Cpf IS NOT NULL
    BEGIN
        -- Atualiza a tabela DEPARTAMENTO, setando NULL para o Cpf_gerente e Data_inicio_gerente
        UPDATE DEPARTAMENTO
        SET Cpf_gerente = NULL, Data_inicio_gerente = NULL
        WHERE Cpf_gerente = @Cpf;

        -- Atualiza os funcionários que têm esse gerente, setando NULL para Cpf_supervisor
        UPDATE FUNCIONARIO
        SET Cpf_supervisor = NULL
        WHERE Cpf_supervisor = @Cpf;
    END

    -- Executa a exclusão normalmente para o funcionário
    DELETE FROM FUNCIONARIO
    WHERE Cpf IN (SELECT Cpf FROM deleted);
END;
GO

