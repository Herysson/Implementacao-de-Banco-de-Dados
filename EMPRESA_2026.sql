USE master;
GO

IF DB_ID('EMPRESA_2026') IS NOT NULL
BEGIN
    -- Encerra outras conexoes e desfaz transacoes abertas nesse banco.
    ALTER DATABASE EMPRESA_2026
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE EMPRESA_2026;
END;
GO

CREATE DATABASE EMPRESA_2026;
GO

USE EMPRESA_2026;
GO

-- 2. TABELAS

CREATE TABLE FUNCIONARIO (
    Pnome VARCHAR(15) NOT NULL,
    Minicial CHAR,
    Unome VARCHAR(15) NOT NULL,
    Cpf CHAR(11),
    Datanasc DATE,
    Endereco VARCHAR(255),
    Sexo CHAR,
    Salario DECIMAL(10,2),
    Cpf_supervisor CHAR(11),
    Dnr INT,
    PRIMARY KEY (Cpf),
    FOREIGN KEY (Cpf_supervisor) REFERENCES FUNCIONARIO(Cpf)
);
GO

CREATE TABLE DEPARTAMENTO (
    Dnome VARCHAR(15) NOT NULL,
    Dnumero INT,
    Cpf_gerente CHAR(11),
    Data_inicio_gerente DATE,
    PRIMARY KEY (Dnumero),
    UNIQUE (Dnome),
    FOREIGN KEY (Cpf_gerente) REFERENCES FUNCIONARIO(Cpf)
);
GO

-- Mantido o nome da constraint usado na versao original.
ALTER TABLE FUNCIONARIO
ADD CONSTRAINT Dnr
FOREIGN KEY (Dnr) REFERENCES DEPARTAMENTO(Dnumero);
GO

CREATE TABLE LOCALIZACAO_DEP (
    Dnumero INT NOT NULL,
    Dlocal VARCHAR(15) NOT NULL,
    PRIMARY KEY (Dnumero, Dlocal),
    FOREIGN KEY (Dnumero) REFERENCES DEPARTAMENTO(Dnumero)
);
GO

CREATE TABLE PROJETO (
    Projnome VARCHAR(15) NOT NULL,
    Projnumero INT NOT NULL,
    Projlocal VARCHAR(15),
    Dnum INT,
    PRIMARY KEY (Projnumero),
    UNIQUE (Projnome),
    FOREIGN KEY (Dnum) REFERENCES DEPARTAMENTO(Dnumero)
);
GO

CREATE TABLE TRABALHA_EM (
    Fcpf CHAR(11) NOT NULL,
    Pnr INT NOT NULL,
    Horas DECIMAL(3,1) NOT NULL,
    PRIMARY KEY (Fcpf, Pnr),
    FOREIGN KEY (Fcpf) REFERENCES FUNCIONARIO(Cpf),
    FOREIGN KEY (Pnr) REFERENCES PROJETO(Projnumero)
);
GO

CREATE TABLE DEPENDENTE (
    Fcpf CHAR(11) NOT NULL,
    Nome_dependente VARCHAR(15) NOT NULL,
    Sexo CHAR,
    Datanasc DATE,
    Parentesco VARCHAR(8),
    PRIMARY KEY (Fcpf, Nome_dependente),
    FOREIGN KEY (Fcpf) REFERENCES FUNCIONARIO(Cpf)
);
GO

-- Colunas acrescentadas na versao original por ALTER TABLE.
ALTER TABLE FUNCIONARIO
ADD Bonus DECIMAL(10,2) NULL;
GO

ALTER TABLE FUNCIONARIO
ADD Data_Admissao DATE NULL;
GO

-- 3. REGISTROS

INSERT INTO dbo.DEPARTAMENTO (Dnome, Dnumero) VALUES
('Matriz', 1),
('Administração', 4),
('Pesquisa', 5),
('Vendas', 6),
('RH', 7),
('TI', 8);


INSERT INTO dbo.FUNCIONARIO
    (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr, Bonus, Data_Admissao)
VALUES
('Jorge', 'E', 'Brito', '88866555576', '19741110', 'Rua do Horto, 35, São Paulo, SP', 'M', 24500, NULL, 1, 4500, '20150202'),
('Jennifer', 'S', 'Souza', '98765432168', '19800620', 'Av. Arthur de Lima, 54, Santo André, SP', 'F', 18400, '88866555576', 4, 2800, '20170410'),
('Fernando', 'T', 'Wong', '33344555587', '19791208', 'Rua da Lapa, 34, São Paulo, SP', 'M', 19500, '88866555576', 5, 3200, '20160801'),
('João', 'B', 'Silva', '12345678966', '19920109', 'Rua das Flores, 751, São Paulo, SP', 'M', 8500, '33344555587', 5, 750, '20200203'),
('Alice', 'J', 'Zelaya', '99988777767', '19950119', 'Rua Souza Lima, 35, Mauá, SP', 'F', 7200, '98765432168', 4, 500, '20210712'),
('Ronaldo', 'K', 'Lima', '66688444476', '19880915', 'Rua Rebouças, 65, Piracicaba, SP', 'M', 10400, '33344555587', 5, 1000, '20191007'),
('Joice', 'A', 'Leite', '45345345376', '19980731', 'Av. Lucas Obes, 74, São Paulo, SP', 'F', 6300, '33344555587', 5, 0, '20230313'),
('André', 'E', 'Brito', '98798798733', '19930329', 'Rua Timbira, 35, São Paulo, SP', 'M', 7900, '98765432168', 4, 650, '20210601'),
('Carlos', 'A', 'Silva', '98765432100', '19850412', 'Rua Augusta, 123, São Paulo, SP', 'M', 14600, '88866555576', 1, 1100, '20180301'),
('Ana', 'B', 'Sousa', '98765432200', '19900623', 'Rua Bela Cintra, 456, São Paulo, SP', 'F', 9800, '98765432100', 1, 500, '20200115'),
('Maria', 'C', 'Oliveira', '98765432300', '19780917', 'Rua das Palmeiras, 789, Santo André, SP', 'F', 10800, '33344555587', 5, 900, '20210201'),
('Paulo', 'D', 'Silva', '98765432400', '19821105', 'Av. Barão de Mauá, 101, Mauá, SP', 'M', 9400, '98765432168', 4, 600, '20220515'),
('Carlos', 'M', 'Ferreira', '12312312311', '19800215', 'Av. Paulista, 1000, São Paulo, SP', 'M', 16500, '88866555576', 6, 2500, '20180917'),
('Mariana', 'L', 'Gomes', '32132132122', '19850622', 'Rua das Acácias, 500, Rio de Janeiro, RJ', 'F', 14200, '88866555576', 7, 1800, '20191104'),
('Pedro', 'A', 'Silva', '65465465433', '19901110', 'Rua da Praia, 200, Salvador, BA', 'M', 17500, '88866555576', 8, 2600, '20170703'),
('Beatriz', 'C', 'Almeida', '10000000001', '19960814', 'Rua Visconde de Pirajá, 210, Rio de Janeiro, RJ', 'F', 6800, '12312312311', 6, 300, '20220411'),
('Rafael', 'D', 'Costa', '10000000002', '19980521', 'Rua Cardoso de Almeida, 45, São Paulo, SP', 'M', 6100, '12312312311', 6, 0, '20240805'),
('Luiza', 'F', 'Martins', '10000000003', '19941203', 'Rua Apeninos, 88, São Paulo, SP', 'F', 7500, '32132132122', 7, 400, '20201019'),
('Gustavo', 'R', 'Rocha', '10000000004', '20010226', 'Rua Vergueiro, 320, São Paulo, SP', 'M', 4300, '32132132122', 7, 0, '20250210'),
('Camila', 'T', 'Araújo', '10000000005', '19970709', 'Rua da Consolação, 550, São Paulo, SP', 'F', 11200, '65465465433', 8, 950, '20210517'),
('Thiago', 'P', 'Oliveira', '10000000006', '19990318', 'Rua Pamplona, 62, São Paulo, SP', 'M', 8900, '65465465433', 8, 500, '20230109'),
('Isabela', 'N', 'Ribeiro', '10000000007', '20000930', 'Rua das Figueiras, 70, Santo André, SP', 'F', 5400, '33344555587', 5, 0, '20241111'),
('Bruno', 'S', 'Carvalho', '10000000008', '19960107', 'Rua Javari, 280, São Paulo, SP', 'M', 7900, '98765432168', 4, 450, '20220801'),
('Sofia', 'M', 'Nunes', '10000000009', '20020424', 'Rua dos Pinheiros, 150, São Paulo, SP', 'F', 5200, '98765432100', 1, 0, '20250701'),
('Diego', 'L', 'Barros', '10000000010', '19951029', 'Av. Atlântica, 120, Rio de Janeiro, RJ', 'M', 7200, '12312312311', 6, 300, '20210906'),
('Helena', 'P', 'Castro', '10000000011', '19971116', 'Rua Haddock Lobo, 41, São Paulo, SP', 'F', 9800, '65465465433', 8, 650, '20220620'),
('Felipe', 'V', 'Moreira', '10000000012', '20030603', 'Rua Frei Caneca, 90, São Paulo, SP', 'M', 4800, '65465465433', 8, 0, '20260202'),
('Patrícia', 'A', 'Menezes', '10000000013', '19910428', 'Rua Sete de Setembro, 900, Curitiba, PR', 'F', 8400, '98765432168', 4, 500, '20200914'),
('Eduardo', 'J', 'Farias', '10000000014', '19940202', 'Rua São Bento, 75, São Paulo, SP', 'M', 8700, '33344555587', 5, 550, '20220307'),
('Natália', 'G', 'Teixeira', '10000000015', '19991210', 'Rua do Catete, 51, Rio de Janeiro, RJ', 'F', 6600, '12312312311', 6, 200, '20231002');


UPDATE dbo.DEPARTAMENTO
SET Cpf_gerente = '88866555576', Data_inicio_gerente = '20150202'
WHERE Dnumero = 1;

UPDATE dbo.DEPARTAMENTO
SET Cpf_gerente = '98765432168', Data_inicio_gerente = '20210301'
WHERE Dnumero = 4;

UPDATE dbo.DEPARTAMENTO
SET Cpf_gerente = '33344555587', Data_inicio_gerente = '20190201'
WHERE Dnumero = 5;

UPDATE dbo.DEPARTAMENTO
SET Cpf_gerente = '12312312311', Data_inicio_gerente = '20200106'
WHERE Dnumero = 6;

UPDATE dbo.DEPARTAMENTO
SET Cpf_gerente = '32132132122', Data_inicio_gerente = '20200803'
WHERE Dnumero = 7;

UPDATE dbo.DEPARTAMENTO
SET Cpf_gerente = '65465465433', Data_inicio_gerente = '20190603'
WHERE Dnumero = 8;

INSERT INTO dbo.LOCALIZACAO_DEP (Dnumero, Dlocal) VALUES
(1, 'São Paulo'),
(4, 'Mauá'),
(4, 'São Paulo'),
(5, 'Santo André'),
(5, 'Itu'),
(5, 'São Paulo'),
(6, 'Rio de Janeiro'),
(6, 'São Paulo'),
(7, 'São Paulo'),
(7, 'Rio de Janeiro'),
(8, 'São Paulo'),
(8, 'Salvador');

INSERT INTO dbo.PROJETO (Projnumero, Projnome, Projlocal, Dnum) VALUES
(1, 'ProdutoX', 'Santo André', 5),
(2, 'ProdutoY', 'Itu', 5),
(3, 'ProdutoZ', 'São Paulo', 5),
(10, 'Informatização', 'Mauá', 4),
(20, 'Reorganização', 'São Paulo', 1),
(30, 'Novosbenefícios', 'Mauá', 4),
(40, 'PortalClientes', 'Rio de Janeiro', 6),
(41, 'ExpansãoVendas', 'São Paulo', 6),
(50, 'Capacitação', 'São Paulo', 7),
(51, 'ClimaEquipe', 'Rio de Janeiro', 7),
(60, 'InfraNuvem', 'São Paulo', 8),
(61, 'SegurançaDados', 'São Paulo', 8),
(62, 'AppCorporativo', 'Salvador', 8),
(70, 'ProjetoPiloto', 'Itu', 5);


INSERT INTO dbo.TRABALHA_EM (Fcpf, Pnr, Horas) VALUES
('12345678966', 1, 32.5),
('12345678966', 2, 7.5),
('66688444476', 3, 40),
('45345345376', 1, 20),
('45345345376', 2, 20),
('33344555587', 2, 10),
('33344555587', 3, 10),
('33344555587', 10, 10),
('33344555587', 20, 10),
('99988777767', 10, 10),
('99988777767', 30, 30),
('98798798733', 10, 35),
('98798798733', 30, 5),
('98765432168', 30, 20),
('98765432168', 20, 15),
('98765432300', 3, 20),
('98765432300', 1, 20),
('98765432400', 10, 24),
('98765432400', 30, 16),
('98765432100', 20, 25),
('98765432100', 50, 10),
('98765432200', 20, 30),
('98765432200', 51, 10),
('12312312311', 40, 20),
('12312312311', 41, 15),
('32132132122', 50, 18),
('32132132122', 51, 17),
('65465465433', 60, 10),
('65465465433', 61, 10),
('65465465433', 62, 15),
('10000000001', 40, 30),
('10000000001', 41, 10),
('10000000002', 41, 35),
('10000000003', 50, 30),
('10000000003', 51, 10),
('10000000004', 51, 20),
('10000000005', 60, 22),
('10000000005', 61, 18),
('10000000006', 60, 20),
('10000000006', 62, 20),
('10000000007', 2, 20),
('10000000007', 3, 20),
('10000000008', 10, 32),
('10000000008', 30, 8),
('10000000010', 40, 20),
('10000000010', 41, 20),
('10000000011', 61, 30),
('10000000011', 62, 10),
('10000000012', 62, 35),
('10000000013', 30, 25),
('10000000013', 10, 15),
('10000000014', 1, 20),
('10000000014', 3, 20),
('10000000015', 40, 20),
('10000000015', 41, 20);


INSERT INTO dbo.DEPENDENTE (Fcpf, Nome_dependente, Sexo, Datanasc, Parentesco) VALUES
('33344555587', 'Alicia', 'F', '20120405', 'Filha'),
('33344555587', 'Tiago', 'M', '20151025', 'Filho'),
('33344555587', 'Janaína', 'F', '19810503', 'Esposa'),
('98765432168', 'Antônio', 'M', '19780228', 'Marido'),
('12345678966', 'Michael', 'M', '20180104', 'Filho'),
('12345678966', 'Alicia', 'F', '20211230', 'Filha'),
('12345678966', 'Elizabeth', 'F', '19930505', 'Esposa'),
('12312312311', 'Gabriel', 'M', '20140919', 'Filho'),
('32132132122', 'Laura', 'F', '20160723', 'Filha'),
('65465465433', 'Fernanda', 'F', '19920303', 'Esposa'),
('10000000005', 'Luna', 'F', '20230214', 'Filha'),
('10000000003', 'André', 'M', '20200506', 'Filho'),
('66688444476', 'Bruna', 'F', '19901020', 'Esposa'),
('10000000013', 'Davi', 'M', '20190807', 'Filho');

GO
    
-- 4. VERIFICAÇÕES E CONSULTAS DIDÁTICAS

-- Contagem de registros de cada tabela.
SELECT 'FUNCIONARIO' AS Tabela, COUNT(*) AS Quantidade FROM dbo.FUNCIONARIO
UNION ALL SELECT 'DEPARTAMENTO', COUNT(*) FROM dbo.DEPARTAMENTO
UNION ALL SELECT 'LOCALIZACAO_DEP', COUNT(*) FROM dbo.LOCALIZACAO_DEP
UNION ALL SELECT 'PROJETO', COUNT(*) FROM dbo.PROJETO
UNION ALL SELECT 'TRABALHA_EM', COUNT(*) FROM dbo.TRABALHA_EM
UNION ALL SELECT 'DEPENDENTE', COUNT(*) FROM dbo.DEPENDENTE;

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

