-- ============================================================================
-- EMPRESA_2026.sql | Base didática atualizada para Microsoft SQL Server
-- Versão: 20/10/2026
-- Dados integralmente FICTÍCIOS. Salários são valores simulados para exercícios.
-- ============================================================================

USE master;
GO

IF DB_ID(N'EMPRESA_2026') IS NULL
    EXEC(N'CREATE DATABASE EMPRESA_2026');
GO

USE EMPRESA_2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Remoção em ordem inversa às dependências (somente EMPRESA_2026).
    DROP TABLE IF EXISTS dbo.DEPENDENTE;
    DROP TABLE IF EXISTS dbo.TRABALHA_EM;
    DROP TABLE IF EXISTS dbo.PROJETO;
    DROP TABLE IF EXISTS dbo.LOCALIZACAO_DEP;

    -- FUNCIONARIO e DEPARTAMENTO possuem chaves estrangeiras recíprocas.
    -- Solta-se um dos vínculos antes de excluir as tabelas em nova execução.
    IF OBJECT_ID(N'dbo.FUNCIONARIO', N'U') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM sys.foreign_keys
           WHERE name = N'FK_FUNCIONARIO_DEPARTAMENTO'
             AND parent_object_id = OBJECT_ID(N'dbo.FUNCIONARIO')
       )
    BEGIN
        ALTER TABLE dbo.FUNCIONARIO
            DROP CONSTRAINT FK_FUNCIONARIO_DEPARTAMENTO;
    END;

    DROP TABLE IF EXISTS dbo.DEPARTAMENTO;
    DROP TABLE IF EXISTS dbo.FUNCIONARIO;

    -- ------------------------------------------------------------------------
    -- 1. ESTRUTURA DAS TABELAS
    -- ------------------------------------------------------------------------

    CREATE TABLE dbo.FUNCIONARIO (
        Pnome            NVARCHAR(40) NOT NULL,
        Minicial         NCHAR(1) NULL,
        Unome            NVARCHAR(50) NOT NULL,
        Cpf              CHAR(11) NOT NULL,
        Datanasc         DATE NOT NULL,
        Endereco         NVARCHAR(180) NOT NULL,
        Sexo             CHAR(1) NOT NULL,
        Salario          DECIMAL(10,2) NOT NULL,
        Cpf_supervisor   CHAR(11) NULL,
        Dnr              INT NOT NULL,
        Bonus            DECIMAL(10,2) NOT NULL CONSTRAINT DF_FUNCIONARIO_Bonus DEFAULT (0),
        Data_Admissao    DATE NOT NULL,
        CONSTRAINT PK_FUNCIONARIO PRIMARY KEY (Cpf),
        CONSTRAINT FK_FUNCIONARIO_SUPERVISOR FOREIGN KEY (Cpf_supervisor)
            REFERENCES dbo.FUNCIONARIO(Cpf),
        CONSTRAINT CK_FUNCIONARIO_SALARIO CHECK (Salario > 0),
        CONSTRAINT CK_FUNCIONARIO_BONUS CHECK (Bonus >= 0),
        CONSTRAINT CK_FUNCIONARIO_SEXO CHECK (Sexo IN ('M', 'F')),
        CONSTRAINT CK_FUNCIONARIO_SUPERVISOR CHECK (Cpf_supervisor IS NULL OR Cpf_supervisor <> Cpf),
        CONSTRAINT CK_FUNCIONARIO_IDADE_ADMISSAO CHECK
            (Data_Admissao >= DATEADD(YEAR, 16, Datanasc))
    );

    CREATE TABLE dbo.DEPARTAMENTO (
        Dnome                 NVARCHAR(40) NOT NULL,
        Dnumero               INT NOT NULL,
        Cpf_gerente           CHAR(11) NULL,
        Data_inicio_gerente   DATE NULL,
        CONSTRAINT PK_DEPARTAMENTO PRIMARY KEY (Dnumero),
        CONSTRAINT FK_DEPARTAMENTO_GERENTE FOREIGN KEY (Cpf_gerente)
            REFERENCES dbo.FUNCIONARIO(Cpf),
        CONSTRAINT CK_DEPARTAMENTO_GERENCIA CHECK
            ((Cpf_gerente IS NULL AND Data_inicio_gerente IS NULL) OR
             (Cpf_gerente IS NOT NULL AND Data_inicio_gerente IS NOT NULL))
    );

    -- Segundo vínculo entre FUNCIONARIO e DEPARTAMENTO (dependência circular).
    ALTER TABLE dbo.FUNCIONARIO
        ADD CONSTRAINT FK_FUNCIONARIO_DEPARTAMENTO
        FOREIGN KEY (Dnr) REFERENCES dbo.DEPARTAMENTO(Dnumero);

    CREATE TABLE dbo.LOCALIZACAO_DEP (
        Dnumero INT NOT NULL,
        Dlocal  NVARCHAR(60) NOT NULL,
        CONSTRAINT PK_LOCALIZACAO_DEP PRIMARY KEY (Dnumero, Dlocal),
        CONSTRAINT FK_LOCALIZACAO_DEP_DEPARTAMENTO FOREIGN KEY (Dnumero)
            REFERENCES dbo.DEPARTAMENTO(Dnumero)
    );

    CREATE TABLE dbo.PROJETO (
        Projnome   NVARCHAR(50) NOT NULL,
        Projnumero INT NOT NULL,
        Projlocal  NVARCHAR(60) NOT NULL,
        Dnum       INT NOT NULL,
        CONSTRAINT PK_PROJETO PRIMARY KEY (Projnumero),
        CONSTRAINT UQ_PROJETO_NOME UNIQUE (Projnome),
        CONSTRAINT FK_PROJETO_DEPARTAMENTO FOREIGN KEY (Dnum)
            REFERENCES dbo.DEPARTAMENTO(Dnumero)
    );

    CREATE TABLE dbo.TRABALHA_EM (
        Fcpf  CHAR(11) NOT NULL,
        Pnr   INT NOT NULL,
        Horas DECIMAL(4,1) NOT NULL,
        CONSTRAINT PK_TRABALHA_EM PRIMARY KEY (Fcpf, Pnr),
        CONSTRAINT FK_TRABALHA_EM_FUNCIONARIO FOREIGN KEY (Fcpf)
            REFERENCES dbo.FUNCIONARIO(Cpf),
        CONSTRAINT FK_TRABALHA_EM_PROJETO FOREIGN KEY (Pnr)
            REFERENCES dbo.PROJETO(Projnumero),
        CONSTRAINT CK_TRABALHA_EM_HORAS CHECK (Horas > 0 AND Horas <= 40)
    );

    CREATE TABLE dbo.DEPENDENTE (
        Fcpf             CHAR(11) NOT NULL,
        Nome_dependente  NVARCHAR(40) NOT NULL,
        Sexo             CHAR(1) NOT NULL,
        Datanasc         DATE NOT NULL,
        Parentesco       NVARCHAR(20) NOT NULL,
        CONSTRAINT PK_DEPENDENTE PRIMARY KEY (Fcpf, Nome_dependente),
        CONSTRAINT FK_DEPENDENTE_FUNCIONARIO FOREIGN KEY (Fcpf)
            REFERENCES dbo.FUNCIONARIO(Cpf),
        CONSTRAINT CK_DEPENDENTE_SEXO CHECK (Sexo IN ('M','F')),
        CONSTRAINT CK_DEPENDENTE_PARENTESCO CHECK
            (Parentesco IN (N'Filho', N'Filha', N'Marido', N'Esposa'))
    );

    -- ------------------------------------------------------------------------
    -- 2. DADOS DOS DEPARTAMENTOS (GERÊNCIA DEFINIDA DEPOIS)
    -- ------------------------------------------------------------------------

    INSERT INTO dbo.DEPARTAMENTO (Dnome, Dnumero) VALUES
    (N'Matriz', 1),
    (N'Administração', 4),
    (N'Pesquisa', 5),
    (N'Vendas', 6),
    (N'RH', 7),
    (N'TI', 8);

    -- ------------------------------------------------------------------------
    -- 3. FUNCIONÁRIOS (30 registros)
    -- Primeiro os gerentes e gestores, depois os colaboradores.
    -- CPF e demais dados são fictícios; CPF é apenas identificador didático.
    -- ------------------------------------------------------------------------

    INSERT INTO dbo.FUNCIONARIO
        (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr, Bonus, Data_Admissao)
    VALUES
    (N'Jorge', N'E', N'Brito', N'88866555576', '19741110', N'Rua do Horto, 35, São Paulo, SP', N'M', 24500, NULL, 1, 4500, '20150202'),
    (N'Jennifer', N'S', N'Souza', N'98765432168', '19800620', N'Av. Arthur de Lima, 54, Santo André, SP', N'F', 18400, N'88866555576', 4, 2800, '20170410'),
    (N'Fernando', N'T', N'Wong', N'33344555587', '19791208', N'Rua da Lapa, 34, São Paulo, SP', N'M', 19500, N'88866555576', 5, 3200, '20160801'),
    (N'João', N'B', N'Silva', N'12345678966', '19920109', N'Rua das Flores, 751, São Paulo, SP', N'M', 8500, N'33344555587', 5, 750, '20200203'),
    (N'Alice', N'J', N'Zelaya', N'99988777767', '19950119', N'Rua Souza Lima, 35, Mauá, SP', N'F', 7200, N'98765432168', 4, 500, '20210712'),
    (N'Ronaldo', N'K', N'Lima', N'66688444476', '19880915', N'Rua Rebouças, 65, Piracicaba, SP', N'M', 10400, N'33344555587', 5, 1000, '20191007'),
    (N'Joice', N'A', N'Leite', N'45345345376', '19980731', N'Av. Lucas Obes, 74, São Paulo, SP', N'F', 6300, N'33344555587', 5, 0, '20230313'),
    (N'André', N'E', N'Brito', N'98798798733', '19930329', N'Rua Timbira, 35, São Paulo, SP', N'M', 7900, N'98765432168', 4, 650, '20210601'),
    (N'Carlos', N'A', N'Silva', N'98765432100', '19850412', N'Rua Augusta, 123, São Paulo, SP', N'M', 14600, N'88866555576', 1, 1100, '20180301'),
    (N'Ana', N'B', N'Sousa', N'98765432200', '19900623', N'Rua Bela Cintra, 456, São Paulo, SP', N'F', 9800, N'98765432100', 1, 500, '20200115'),
    (N'Maria', N'C', N'Oliveira', N'98765432300', '19780917', N'Rua das Palmeiras, 789, Santo André, SP', N'F', 10800, N'33344555587', 5, 900, '20210201'),
    (N'Paulo', N'D', N'Silva', N'98765432400', '19821105', N'Av. Barão de Mauá, 101, Mauá, SP', N'M', 9400, N'98765432168', 4, 600, '20220515'),
    (N'Carlos', N'M', N'Ferreira', N'12312312311', '19800215', N'Av. Paulista, 1000, São Paulo, SP', N'M', 16500, N'88866555576', 6, 2500, '20180917'),
    (N'Mariana', N'L', N'Gomes', N'32132132122', '19850622', N'Rua das Acácias, 500, Rio de Janeiro, RJ', N'F', 14200, N'88866555576', 7, 1800, '20191104'),
    (N'Pedro', N'A', N'Silva', N'65465465433', '19901110', N'Rua da Praia, 200, Salvador, BA', N'M', 17500, N'88866555576', 8, 2600, '20170703'),
    (N'Beatriz', N'C', N'Almeida', N'10000000001', '19960814', N'Rua Visconde de Pirajá, 210, Rio de Janeiro, RJ', N'F', 6800, N'12312312311', 6, 300, '20220411'),
    (N'Rafael', N'D', N'Costa', N'10000000002', '19980521', N'Rua Cardoso de Almeida, 45, São Paulo, SP', N'M', 6100, N'12312312311', 6, 0, '20240805'),
    (N'Luiza', N'F', N'Martins', N'10000000003', '19941203', N'Rua Apeninos, 88, São Paulo, SP', N'F', 7500, N'32132132122', 7, 400, '20201019'),
    (N'Gustavo', N'R', N'Rocha', N'10000000004', '20010226', N'Rua Vergueiro, 320, São Paulo, SP', N'M', 4300, N'32132132122', 7, 0, '20250210'),
    (N'Camila', N'T', N'Araújo', N'10000000005', '19970709', N'Rua da Consolação, 550, São Paulo, SP', N'F', 11200, N'65465465433', 8, 950, '20210517'),
    (N'Thiago', N'P', N'Oliveira', N'10000000006', '19990318', N'Rua Pamplona, 62, São Paulo, SP', N'M', 8900, N'65465465433', 8, 500, '20230109'),
    (N'Isabela', N'N', N'Ribeiro', N'10000000007', '20000930', N'Rua das Figueiras, 70, Santo André, SP', N'F', 5400, N'33344555587', 5, 0, '20241111'),
    (N'Bruno', N'S', N'Carvalho', N'10000000008', '19960107', N'Rua Javari, 280, São Paulo, SP', N'M', 7900, N'98765432168', 4, 450, '20220801'),
    (N'Sofia', N'M', N'Nunes', N'10000000009', '20020424', N'Rua dos Pinheiros, 150, São Paulo, SP', N'F', 5200, N'98765432100', 1, 0, '20250701'),
    (N'Diego', N'L', N'Barros', N'10000000010', '19951029', N'Av. Atlântica, 120, Rio de Janeiro, RJ', N'M', 7200, N'12312312311', 6, 300, '20210906'),
    (N'Helena', N'P', N'Castro', N'10000000011', '19971116', N'Rua Haddock Lobo, 41, São Paulo, SP', N'F', 9800, N'65465465433', 8, 650, '20220620'),
    (N'Felipe', N'V', N'Moreira', N'10000000012', '20030603', N'Rua Frei Caneca, 90, São Paulo, SP', N'M', 4800, N'65465465433', 8, 0, '20260202'),
    (N'Patrícia', N'A', N'Menezes', N'10000000013', '19910428', N'Rua Sete de Setembro, 900, Curitiba, PR', N'F', 8400, N'98765432168', 4, 500, '20200914'),
    (N'Eduardo', N'J', N'Farias', N'10000000014', '19940202', N'Rua São Bento, 75, São Paulo, SP', N'M', 8700, N'33344555587', 5, 550, '20220307'),
    (N'Natália', N'G', N'Teixeira', N'10000000015', '19991210', N'Rua do Catete, 51, Rio de Janeiro, RJ', N'F', 6600, N'12312312311', 6, 200, '20231002');

    -- ------------------------------------------------------------------------
    -- 4. GERENTES DOS DEPARTAMENTOS
    -- Gerentes fazem parte do departamento que dirigem.
    -- ------------------------------------------------------------------------

    UPDATE dbo.DEPARTAMENTO
    SET Cpf_gerente = N'88866555576', Data_inicio_gerente = '20150202'
    WHERE Dnumero = 1;

    UPDATE dbo.DEPARTAMENTO
    SET Cpf_gerente = N'98765432168', Data_inicio_gerente = '20210301'
    WHERE Dnumero = 4;

    UPDATE dbo.DEPARTAMENTO
    SET Cpf_gerente = N'33344555587', Data_inicio_gerente = '20190201'
    WHERE Dnumero = 5;

    UPDATE dbo.DEPARTAMENTO
    SET Cpf_gerente = N'12312312311', Data_inicio_gerente = '20200106'
    WHERE Dnumero = 6;

    UPDATE dbo.DEPARTAMENTO
    SET Cpf_gerente = N'32132132122', Data_inicio_gerente = '20200803'
    WHERE Dnumero = 7;

    UPDATE dbo.DEPARTAMENTO
    SET Cpf_gerente = N'65465465433', Data_inicio_gerente = '20190603'
    WHERE Dnumero = 8;

    -- ------------------------------------------------------------------------
    -- 5. LOCALIZAÇÕES DOS DEPARTAMENTOS
    -- ------------------------------------------------------------------------

    INSERT INTO dbo.LOCALIZACAO_DEP (Dnumero, Dlocal) VALUES
    (1, N'São Paulo'),
    (4, N'Mauá'),
    (4, N'São Paulo'),
    (5, N'Santo André'),
    (5, N'Itu'),
    (5, N'São Paulo'),
    (6, N'Rio de Janeiro'),
    (6, N'São Paulo'),
    (7, N'São Paulo'),
    (7, N'Rio de Janeiro'),
    (8, N'São Paulo'),
    (8, N'Salvador');

    -- ------------------------------------------------------------------------
    -- 6. PROJETOS (14 registros; ProjetoPiloto ainda sem funcionários)
    -- ------------------------------------------------------------------------

    INSERT INTO dbo.PROJETO (Projnumero, Projnome, Projlocal, Dnum) VALUES
    (1, N'ProdutoX', N'Santo André', 5),
    (2, N'ProdutoY', N'Itu', 5),
    (3, N'ProdutoZ', N'São Paulo', 5),
    (10, N'Informatização', N'Mauá', 4),
    (20, N'Reorganização', N'São Paulo', 1),
    (30, N'Novosbenefícios', N'Mauá', 4),
    (40, N'PortalClientes', N'Rio de Janeiro', 6),
    (41, N'ExpansãoVendas', N'São Paulo', 6),
    (50, N'Capacitação', N'São Paulo', 7),
    (51, N'ClimaOrganizacional', N'Rio de Janeiro', 7),
    (60, N'InfraNuvem', N'São Paulo', 8),
    (61, N'SegurançaDados', N'São Paulo', 8),
    (62, N'AppCorporativo', N'Salvador', 8),
    (70, N'ProjetoPiloto', N'Itu', 5);

    -- ------------------------------------------------------------------------
    -- 7. ALOCAÇÕES EM PROJETOS (HORAS SEMANAIS)
    -- Foram preservadas as 15 alocações do arquivo original.
    -- Jorge e Sofia estão sem projetos para exercícios de LEFT JOIN / NOT EXISTS.
    -- A soma das horas por funcionário é sempre <= 40.
    -- ------------------------------------------------------------------------

    INSERT INTO dbo.TRABALHA_EM (Fcpf, Pnr, Horas) VALUES
    (N'12345678966', 1, 32.5),
    (N'12345678966', 2, 7.5),
    (N'66688444476', 3, 40),
    (N'45345345376', 1, 20),
    (N'45345345376', 2, 20),
    (N'33344555587', 2, 10),
    (N'33344555587', 3, 10),
    (N'33344555587', 10, 10),
    (N'33344555587', 20, 10),
    (N'99988777767', 10, 10),
    (N'99988777767', 30, 30),
    (N'98798798733', 10, 35),
    (N'98798798733', 30, 5),
    (N'98765432168', 30, 20),
    (N'98765432168', 20, 15),
    (N'98765432300', 3, 20),
    (N'98765432300', 1, 20),
    (N'98765432400', 10, 24),
    (N'98765432400', 30, 16),
    (N'98765432100', 20, 25),
    (N'98765432100', 50, 10),
    (N'98765432200', 20, 30),
    (N'98765432200', 51, 10),
    (N'12312312311', 40, 20),
    (N'12312312311', 41, 15),
    (N'32132132122', 50, 18),
    (N'32132132122', 51, 17),
    (N'65465465433', 60, 10),
    (N'65465465433', 61, 10),
    (N'65465465433', 62, 15),
    (N'10000000001', 40, 30),
    (N'10000000001', 41, 10),
    (N'10000000002', 41, 35),
    (N'10000000003', 50, 30),
    (N'10000000003', 51, 10),
    (N'10000000004', 51, 20),
    (N'10000000005', 60, 22),
    (N'10000000005', 61, 18),
    (N'10000000006', 60, 20),
    (N'10000000006', 62, 20),
    (N'10000000007', 2, 20),
    (N'10000000007', 3, 20),
    (N'10000000008', 10, 32),
    (N'10000000008', 30, 8),
    (N'10000000010', 40, 20),
    (N'10000000010', 41, 20),
    (N'10000000011', 61, 30),
    (N'10000000011', 62, 10),
    (N'10000000012', 62, 35),
    (N'10000000013', 30, 25),
    (N'10000000013', 10, 15),
    (N'10000000014', 1, 20),
    (N'10000000014', 3, 20),
    (N'10000000015', 40, 20),
    (N'10000000015', 41, 20);

    -- ------------------------------------------------------------------------
    -- 8. DEPENDENTES (14 registros; parentescos e datas corrigidos)
    -- ------------------------------------------------------------------------

    INSERT INTO dbo.DEPENDENTE (Fcpf, Nome_dependente, Sexo, Datanasc, Parentesco) VALUES
    (N'33344555587', N'Alicia', N'F', '20120405', N'Filha'),
    (N'33344555587', N'Tiago', N'M', '20151025', N'Filho'),
    (N'33344555587', N'Janaína', N'F', '19810503', N'Esposa'),
    (N'98765432168', N'Antônio', N'M', '19780228', N'Marido'),
    (N'12345678966', N'Michael', N'M', '20180104', N'Filho'),
    (N'12345678966', N'Alicia', N'F', '20211230', N'Filha'),
    (N'12345678966', N'Elizabeth', N'F', '19930505', N'Esposa'),
    (N'12312312311', N'Gabriel', N'M', '20140919', N'Filho'),
    (N'32132132122', N'Laura', N'F', '20160723', N'Filha'),
    (N'65465465433', N'Fernanda', N'F', '19920303', N'Esposa'),
    (N'10000000005', N'Luna', N'F', '20230214', N'Filha'),
    (N'10000000003', N'André', N'M', '20200506', N'Filho'),
    (N'66688444476', N'Bruna', N'F', '19901020', N'Esposa'),
    (N'10000000013', N'Davi', N'M', '20190807', N'Filho');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- ============================================================================
-- 9. VERIFICAÇÕES E CONSULTAS DIDÁTICAS
-- ============================================================================

-- Contagem de registros de cada tabela.
SELECT N'FUNCIONARIO' AS Tabela, COUNT(*) AS Quantidade FROM dbo.FUNCIONARIO
UNION ALL SELECT N'DEPARTAMENTO', COUNT(*) FROM dbo.DEPARTAMENTO
UNION ALL SELECT N'LOCALIZACAO_DEP', COUNT(*) FROM dbo.LOCALIZACAO_DEP
UNION ALL SELECT N'PROJETO', COUNT(*) FROM dbo.PROJETO
UNION ALL SELECT N'TRABALHA_EM', COUNT(*) FROM dbo.TRABALHA_EM
UNION ALL SELECT N'DEPENDENTE', COUNT(*) FROM dbo.DEPENDENTE;

-- Funcionários e seus departamentos (INNER JOIN).
SELECT f.Pnome, f.Unome, d.Dnome, f.Salario, f.Data_Admissao
FROM dbo.FUNCIONARIO AS f
INNER JOIN dbo.DEPARTAMENTO AS d ON d.Dnumero = f.Dnr
ORDER BY d.Dnome, f.Pnome;

-- Funcionários que ainda não participam de projetos (LEFT JOIN + IS NULL).
SELECT f.Pnome, f.Unome, f.Cpf
FROM dbo.FUNCIONARIO AS f
LEFT JOIN dbo.TRABALHA_EM AS t ON t.Fcpf = f.Cpf
WHERE t.Fcpf IS NULL
ORDER BY f.Pnome;

-- Projetos sem funcionários (NOT EXISTS).
SELECT p.Projnumero, p.Projnome
FROM dbo.PROJETO AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.TRABALHA_EM AS t
    WHERE t.Pnr = p.Projnumero
);

-- Média salarial e quantidade de funcionários por departamento (GROUP BY).
SELECT d.Dnome,
       COUNT(*) AS Qtde_Funcionarios,
       CAST(AVG(f.Salario) AS DECIMAL(10,2)) AS Media_Salarial
FROM dbo.DEPARTAMENTO AS d
INNER JOIN dbo.FUNCIONARIO AS f ON f.Dnr = d.Dnumero
GROUP BY d.Dnumero, d.Dnome
ORDER BY d.Dnome;

-- Conferência das horas semanais: nenhuma soma pode ultrapassar 40 horas.
SELECT f.Pnome, f.Unome, SUM(t.Horas) AS Horas_Semanais
FROM dbo.FUNCIONARIO AS f
INNER JOIN dbo.TRABALHA_EM AS t ON t.Fcpf = f.Cpf
GROUP BY f.Cpf, f.Pnome, f.Unome
HAVING SUM(t.Horas) > 40;
-- Resultado esperado da consulta anterior: zero linhas.

