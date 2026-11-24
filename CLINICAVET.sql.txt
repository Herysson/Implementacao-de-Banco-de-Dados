CREATE DATABASE CLINICAVET;
GO

USE CLINICAVET;
GO

-- 1. Responsaveis pelos animais
CREATE TABLE dbo.Tutor (
    TutorID INT IDENTITY(1,1) NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Telefone VARCHAR(20) NULL,
    Email VARCHAR(120) NULL,
    Ativo BIT NOT NULL CONSTRAINT DF_Tutor_Ativo DEFAULT (1),
    CONSTRAINT PK_Tutor PRIMARY KEY (TutorID)
);
GO

-- 2. Animais atendidos pela clinica
CREATE TABLE dbo.Animal (
    AnimalID INT IDENTITY(1,1) NOT NULL,
    TutorID INT NOT NULL,
    Nome VARCHAR(80) NOT NULL,
    Especie VARCHAR(40) NOT NULL,
    Raca VARCHAR(60) NULL,
    DataNascimento DATE NULL,
    Ativo BIT NOT NULL CONSTRAINT DF_Animal_Ativo DEFAULT (1),
    CONSTRAINT PK_Animal PRIMARY KEY (AnimalID),
    CONSTRAINT FK_Animal_Tutor FOREIGN KEY (TutorID)
        REFERENCES dbo.Tutor (TutorID)
);
GO

-- 3. Profissionais responsaveis pelos atendimentos
CREATE TABLE dbo.Veterinario (
    VeterinarioID INT IDENTITY(1,1) NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    CRMV VARCHAR(20) NOT NULL,
    Especialidade VARCHAR(80) NULL,
    Ativo BIT NOT NULL CONSTRAINT DF_Veterinario_Ativo DEFAULT (1),
    CONSTRAINT PK_Veterinario PRIMARY KEY (VeterinarioID)
);
GO

-- 4. Catalogo de procedimentos e precos vigentes
-- ProcedimentoID usa codigos alfanumericos como identificadores naturais.
CREATE TABLE dbo.Procedimento (
    ProcedimentoID VARCHAR(10) NOT NULL,
    Descricao VARCHAR(100) NOT NULL,
    PrecoPadrao DECIMAL(10,2) NOT NULL,
    Ativo BIT NOT NULL CONSTRAINT DF_Procedimento_Ativo DEFAULT (1),
    CONSTRAINT PK_Procedimento PRIMARY KEY (ProcedimentoID)
);
GO

-- 5. Consultas agendadas ou realizadas
CREATE TABLE dbo.Consulta (
    ConsultaID INT IDENTITY(1,1) NOT NULL,
    AnimalID INT NOT NULL,
    VeterinarioID INT NOT NULL,
    DataConsulta DATETIME2(0) NOT NULL,
    Motivo VARCHAR(200) NOT NULL,
    Diagnostico VARCHAR(300) NULL,
    Situacao VARCHAR(15) NOT NULL
        CONSTRAINT DF_Consulta_Situacao DEFAULT ('Agendada'),
    ValorTotal DECIMAL(10,2) NOT NULL
        CONSTRAINT DF_Consulta_ValorTotal DEFAULT (0),
    CONSTRAINT PK_Consulta PRIMARY KEY (ConsultaID),
    CONSTRAINT FK_Consulta_Animal FOREIGN KEY (AnimalID)
        REFERENCES dbo.Animal (AnimalID),
    CONSTRAINT FK_Consulta_Veterinario FOREIGN KEY (VeterinarioID)
        REFERENCES dbo.Veterinario (VeterinarioID)
);
GO

-- 6. Procedimentos realizados em uma consulta (tabela associativa)
-- PrecoUnitario preserva o valor cobrado no momento do atendimento.
CREATE TABLE dbo.ConsultaProcedimento (
    ConsultaProcedimentoID INT IDENTITY(1,1) NOT NULL,
    ConsultaID INT NOT NULL,
    ProcedimentoID VARCHAR(10) NOT NULL,
    Quantidade INT NOT NULL,
    PrecoUnitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_ConsultaProcedimento PRIMARY KEY (ConsultaProcedimentoID),
    CONSTRAINT FK_ConsultaProcedimento_Consulta FOREIGN KEY (ConsultaID)
        REFERENCES dbo.Consulta (ConsultaID),
    CONSTRAINT FK_ConsultaProcedimento_Procedimento FOREIGN KEY (ProcedimentoID)
        REFERENCES dbo.Procedimento (ProcedimentoID)
);
GO

-- Dados de exemplo (identificadores gerados a partir de 1)
INSERT INTO dbo.Tutor (Nome, Telefone, Email, Ativo) VALUES
('Ana Martins', '55999910001', 'ana.martins@exemplo.com', 1),
('Carlos Souza', '55999910002', 'carlos.souza@exemplo.com', 1),
('Beatriz Lima', NULL, 'beatriz.lima@exemplo.com', 1),
('Rafael Oliveira', '55999910004', NULL, 1);
GO

INSERT INTO dbo.Animal
    (TutorID, Nome, Especie, Raca, DataNascimento, Ativo) VALUES
(1, 'Mel', 'Cao', 'SRD', '2021-05-10', 1),
(1, 'Luna', 'Gato', 'Siames', '2022-03-18', 1),
(2, 'Thor', 'Cao', 'Labrador', '2020-08-20', 1),
(3, 'Nina', 'Gato', 'SRD', '2023-01-12', 1),
(4, 'Pipoca', 'Coelho', 'Mini Lop', '2024-04-01', 1),
(2, 'Bento', 'Cao', 'Poodle', '2019-06-15', 0),
(3, 'Amora', 'Gato', 'SRD', '2020-09-10', 0);
GO

INSERT INTO dbo.Veterinario (Nome, CRMV, Especialidade, Ativo) VALUES
('Juliana Mendes', 'RS-15836', 'Clinica geral', 0),
('Ricardo Nunes', 'RS-16429', 'Cirurgia', 0),
('Mariana Costa', 'RS-12540', 'Clinica geral', 1),
('Pedro Almeida', 'RS-13822', 'Dermatologia', 1),
('Fernanda Ribeiro', 'RS-14710', 'Clinica de felinos', 1);
GO

INSERT INTO dbo.Procedimento
    (ProcedimentoID, Descricao, PrecoPadrao, Ativo) VALUES
('CONS', 'Consulta clinica', 120.00, 1),
('VAC', 'Vacinacao', 85.00, 1),
('COLETA', 'Coleta de material', 25.00, 1),
('HEMO', 'Hemograma', 90.00, 1),
('CURA', 'Curativo', 60.00, 1);
GO

INSERT INTO dbo.Consulta
    (AnimalID, VeterinarioID, DataConsulta, Motivo, Diagnostico, Situacao, ValorTotal) VALUES
(1, 1, '2026-10-20T09:00:00', 'Consulta de rotina', 'Animal sem alteracoes clinicas', 'Realizada', 120.00),
(2, 3, '2026-10-23T10:30:00', 'Vacinacao anual', NULL, 'Realizada', 110.00),
(3, 1, '2026-10-28T14:00:00', 'Apatia e perda de apetite', 'Exames complementares solicitados', 'Realizada', 210.00),
(4, 3, '2026-11-12T08:30:00', 'Avaliacao preventiva', NULL, 'Agendada', 0.00),
(5, 2, '2026-11-13T15:00:00', 'Irritacao na pele', NULL, 'Agendada', 0.00),
(1, 1, '2026-10-30T16:00:00', 'Reavaliacao', NULL, 'Cancelada', 0.00);
GO

INSERT INTO dbo.ConsultaProcedimento
 (ConsultaID, ProcedimentoID, Quantidade, PrecoUnitario) VALUES
(1, 'CONS', 1, 120.00),
(2, 'VAC', 1, 85.00),
(2, 'COLETA', 1, 25.00),
(3, 'CONS', 1, 120.00),
(3, 'HEMO', 1, 90.00);
GO

-- Consultas de conferencia (opcionais)
SELECT * FROM dbo.Tutor;
SELECT * FROM dbo.Animal;
SELECT * FROM dbo.Veterinario;
SELECT * FROM dbo.Procedimento;
SELECT * FROM dbo.Consulta;
SELECT * FROM dbo.ConsultaProcedimento;
GO

