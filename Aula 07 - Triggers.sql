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
--20/10/2026

-- TRIGGER AFTER_INSERT
CREATE TRIGGER trg_after_insert_departamento
ON DEPARTAMENTO
AFTER INSERT
AS
BEGIN
	PRINT 'Olá meu primeiro trigger =D'
END;
GO
-- DROPAR UM TRIGGER
DROP TRIGGER trg_after_insert_departamento;
GO;
-- TRIGGER INSTEAD OF INSERT
CREATE OR ALTER TRIGGER trg_io_insert_departamento
ON DEPARTAMENTO
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @nome VARCHAR(40);
	SELECT @nome = I.Dnome
	FROM inserted AS I;
	IF EXISTS (SELECT 1 FROM DEPARTAMENTO WHERE Dnome = @nome)
		RAISERROR('Já existe esse departamento',16,1)
	ELSE
		INSERT INTO DEPARTAMENTO (Dnome, Dnumero, Cpf_gerente, Data_inicio_gerente)
		SELECT I.Dnome, I.Dnumero, I.Cpf_gerente, I.Data_inicio_gerente
		FROM inserted AS I;
END;
GO
-- DESABILITAR / HABILITAR TRIGGER -- DISABLE - ENABLE
ALTER TABLE DEPARTAMENTO
DISABLE TRIGGER trg_after_insert_departamento;

INSERT INTO DEPARTAMENTO (Dnome,Dnumero)
VALUES ('Expedição', 66);
SELECT * FROM DEPARTAMENTO;

-- VERFICAR TRIGGERS EM UM TABELA
EXEC sp_helptrigger DEPARTAMENTO;

-- VERIFICAR TRIGGERS NO BANCO DE DADOS
SELECT *
FROM sys.triggers
WHERE is_disabled = 0 or is_disabled =1;
GO

-- FUNÇÃO UPDATE()
--Verifiando se o nome do departamento foi alterado
CREATE OR ALTER TRIGGER trg_aftter_update_nome
ON DEPARTAMENTO
FOR UPDATE
AS
BEGIN
	DECLARE @antigo VARCHAR(50),
			@novo VARCHAR(50);
	SELECT @antigo = D.Dnome FROM deleted AS D;
	SELECT @novo = I.Dnome FROM inserted AS I;
	IF UPDATE(Dnome)
	BEGIN
		PRINT 'O nome antigo era: ' + @antigo;
		PRINT 'O novo nome é: ' + @novo;
	END
	ELSE
		PRINT 'O nome não foi modificado'
END

UPDATE DEPARTAMENTO
SET Dnome = 'Recursos Humanos'
WHERE Dnome = 'RH';
SELECT * FROM DEPARTAMENTO;
UPDATE DEPARTAMENTO
SET Dnumero = 9
WHERE Dnome = 'Expedição';

UPDATE DEPARTAMENTO
SET Dnome = 'Informática'
WHERE Dnome = 'TI';
GO

-- Impedir que um funcinário receba menos de 1000 reais
CREATE TRIGGER trg_after_insert_sal_func
ON FUNCIONARIO
FOR INSERT
AS
BEGIN
	DECLARE @salario DECIMAL(10,2);
	SELECT @salario = I.Salario
	FROM inserted AS I
	IF(@salario < 1000)
	BEGIN
		ROLLBACK;
		RAISERROR('Salário não pode ser <1000,00',16,1);
	END
END

INSERT INTO FUNCIONARIO (Pnome,Unome,Cpf,Datanasc,Endereco,Sexo,Salario,Bonus,Data_Admissao,Dnr)
VALUES ('Herysson', 'Figueiredo','0184447778','1988-06-07','Rua Sete', 'M', 1800, 0, '2026-10-20',9);

SELECT * FROM FUNCIONARIO;
GO
--CRIAR UMA TABELA DE LOG
CREATE TABLE LOG_FUNCIONARIO(
	log_id INT IDENTITY(100,1) PRIMARY KEY,
	cpf CHAR(11),
	operacao VARCHAR(10),
	data_hora DATETIME DEFAULT GETDATE()
)
GO

--TRIGGER DE INSERT
CREATE TRIGGER trg_for_insert_funcionario
ON FUNCIONARIO
FOR INSERT
AS
BEGIN
	INSERT INTO LOG_FUNCIONARIO (cpf, operacao)
	SELECT Cpf, 'INSERT'
	FROM inserted	
END
GO

CREATE TRIGGER trg_for_update_funcionario
ON FUNCIONARIO
FOR UPDATE
AS
BEGIN
	INSERT INTO LOG_FUNCIONARIO (cpf, operacao)
	SELECT Cpf, 'UPDATE'
	FROM inserted	
END
GO

CREATE TRIGGER trg_for_delete_funcionario
ON FUNCIONARIO
FOR DELETE
AS
BEGIN
	INSERT INTO LOG_FUNCIONARIO (cpf, operacao)
	SELECT Cpf, 'DELETE'
	FROM deleted	
END

INSERT INTO FUNCIONARIO (Pnome,Unome,Cpf,Datanasc,Endereco,Sexo,Salario,Bonus,Data_Admissao,Dnr)
VALUES ('Juca', 'Da Silva','4885696','2005-06-07','Rua Cinco', 'M', 1100, 0, '2026-10-20',9);
SELECT * FROM FUNCIONARIO ORDER BY Pnome;
SELECT * FROM LOG_FUNCIONARIO;

UPDATE FUNCIONARIO
SET Salario = 500
WHERE Cpf='4885696';

DELETE FROM FUNCIONARIO
WHERE Cpf='4885696';

--1 Criar uma tabela para guardar todas as alteração 
-- de salário sofridas por um funcióario. Em seguida
-- crie triggers para guardar nesta tabela informações
-- sobre essas alteraçõe (id, cpf, salrio anterior, data e hora)

--2 Crie uma nova coluna na tabela departamente chamada de status.
--Agora crie um trigger que impeça o usuário de deletar um departamento
--já existente. Ou seja ao invés de deltar o departamento altere o valor 
--da coluna de status para '0'.

--3 Crie um trigger que seja disparado depois que uma operação de inserção, 
-- update ou deleção ocorra na tabela FUNCIONARIO. 
-- Esse trigger deve registrar o CPF do novo funcionário 
--inserido, alterado ou deletado e a operação realizada ("INSERT, DELETE, UPDATE") 
-- em uma tabela de log (Log_Funcionario), juntamente com a data e hora da inserção. Esse trigger ajudará a manter um histórico 
-- das inserções realizadas na tabela de funcionários.
GO

-- VIEW
CREATE VIEW vw_rh_funcionario_dpt
AS
SELECT 
	CONCAT(Pnome,' ',Minicial,'. ', Unome) AS 'Nome',
	DATEDIFF(YEAR, Datanasc, GETDATE()) AS 'Idade',
	Endereco AS 'Endereço',
	Data_Admissao AS 'Adimição',
	D.Dnome AS 'Departamento'
FROM FUNCIONARIO AS F
INNER JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero;
GO

SELECT * 
FROM vw_rh_funcionario_dpt
ORDER BY Nome;

SELECT * 
FROM vw_rh_funcionario_dpt
WHERE Nome LIKE '%B.%';
