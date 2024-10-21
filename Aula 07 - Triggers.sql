ALTER TRIGGER trg_after_update_funcionario
ON FUNCIONARIO
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @NomeAntigo VARCHAR(50),
			@NomeNovo VARCHAR(50);
	IF UPDATE(Pnome)
	BEGIN
		SELECT @NomeNovo = I.Pnome
		FROM inserted AS I;
		SELECT @NomeAntigo = D.Pnome
		FROM deleted AS D;
		PRINT 'O nome foi alterado ';
		PRINT 'Antigo: '+ @NomeAntigo;
		PRINT 'Novo: ' + @NomeNovo;
	END
	ELSE
		PRINT 'O nome não foi alterado'
END

INSERT INTO FUNCIONARIO (Pnome,Minicial, Unome, Cpf)
VALUES ('Heitor', 'R', 'Figueiredo', 01457889632);

UPDATE FUNCIONARIO
SET Pnome = 'Hercules'
WHERE Cpf = '1457889632';

SELECT * FROM FUNCIONARIO;


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
--Crie um tregger que não permita a inserção de um funcionário
--com o mesmo nome completo (Pnome + Minicial + Unome)
ALTER TRIGGER trg_after_insert_funcionario
ON FUNCIONARIO
AFTER INSERT
AS
BEGIN
	DECLARE @Pnome VARCHAR(50),
			@Minicial CHAR(1),
			@Unome VARCHAR(50),
			@Dubplicados INT;
	SELECT @Dubplicados = COUNT(*)
	FROM(
		SELECT Pnome, Unome,Minicial
		FROM FUNCIONARIO
		GROUP BY Pnome, Unome,Minicial
		HAVING COUNT(*)>1	
	) AS Duplicados;

	IF @Dubplicados > 0
	BEGIN
		PRINT 'Já existe um fincionário com o nome: ' + @Pnome+@Minicial+@Unome
		ROLLBACK TRANSACTION;
	END
	ELSE
	BEGIN
		COMMIT TRANSACTION;
		PRINT 'novo registro inserido'
	END		
END

-- INSTEAD OF --
CREATE TRIGGER trg_instead_of_insert_funcionario
ON FUNCIONARIO
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Pnome VARCHAR(15);
    DECLARE @Unome VARCHAR(15);

    -- Seleciona os valores que estão sendo inseridos
    SELECT @Pnome = i.Pnome, @Unome = i.Unome
    FROM inserted i;

    -- Verifica se já existe uma pessoa com o mesmo primeiro nome e último nome
    IF EXISTS (
        SELECT 1
        FROM FUNCIONARIO
        WHERE Pnome = @Pnome AND Unome = @Unome
    )
    BEGIN
        -- Se já existe, impede a inserção e exibe a mensagem de erro
        PRINT 'Funcionário com o mesmo primeiro nome e último nome já existe! A inserção foi cancelada.';
    END
    ELSE
    BEGIN
        -- Se não existe duplicata, realiza a inserção
        INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
        SELECT Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr
        FROM inserted;
        
        PRINT 'Funcionário inserido com sucesso!';
    END
END;
GO


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
CREATE TABLE Log_Funcionario ( 
LogID INT IDENTITY(1,1) PRIMARY KEY, 
Cpf CHAR(11), 
Operacao VARCHAR(10), 
Data_Hora DATETIME DEFAULT GETDATE() 
);

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

-- Crie um trigger que seja disparado depois que uma operação de inserção, update ou deleção ocorra na tabela FUNCIONARIO. 
-- Esse trigger deve registrar o CPF do novo funcionário inserido, alterado ou deletado e a operação realizada ("INSERT, DELETE, UPDATE") 
-- em uma tabela de log (Log_Funcionario), juntamente com a data e hora da inserção. Esse trigger ajudará a manter um histórico 
-- das inserções realizadas na tabela de funcionários.

CREATE TRIGGER trg_log_operations_funcionario
ON FUNCIONARIO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Verifica se houve uma operação de DELETE
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        -- Inserindo no log para DELETE
        INSERT INTO Log_Funcionario (Cpf, Operacao, Data_Hora)
        SELECT Cpf, 'DELETE', GETDATE()
        FROM deleted;
    END

    -- Verifica se houve uma operação de INSERT ou UPDATE
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Verifica se a operação foi UPDATE ou INSERT
        IF EXISTS (SELECT * FROM deleted)
        BEGIN
            -- Inserindo no log para UPDATE
            INSERT INTO Log_Funcionario (Cpf, Operacao, Data_Hora)
            SELECT Cpf, 'UPDATE', GETDATE()
            FROM inserted;
        END
        ELSE
        BEGIN
            -- Inserindo no log para INSERT
            INSERT INTO Log_Funcionario (Cpf, Operacao, Data_Hora)
            SELECT Cpf, 'INSERT', GETDATE()
            FROM inserted;
        END
    END
END;
GO


