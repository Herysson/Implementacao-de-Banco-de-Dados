IF DB_ID('FACULDADE_2') IS NULL
    EXEC('CREATE DATABASE FACULDADE_2');
GO

USE FACULDADE_2;
GO

DROP TABLE IF EXISTS PRE_REQUISITO;
DROP TABLE IF EXISTS HISTORICO_ESCOLAR;
DROP TABLE IF EXISTS TURMA;
DROP TABLE IF EXISTS DISCIPLINA;
DROP TABLE IF EXISTS ALUNO;
GO

CREATE TABLE ALUNO (
    Numero_aluno INT PRIMARY KEY,
    Nome NVARCHAR(80) NOT NULL,
    Tipo_aluno INT NOT NULL,
    Curso NVARCHAR(5) NOT NULL,
    Data_nascimento DATE NOT NULL
);

CREATE TABLE DISCIPLINA (
    Numero_disciplina NVARCHAR(10) PRIMARY KEY,
    Nome_disciplina NVARCHAR(100) NOT NULL,
    Creditos INT NOT NULL CHECK (Creditos > 0),
    Departamento NVARCHAR(10) NOT NULL
);

CREATE TABLE TURMA (
    Identificacao_turma INT PRIMARY KEY,
    Numero_disciplina NVARCHAR(10) NOT NULL,
    Semestre TINYINT NOT NULL CHECK (Semestre IN (1, 2)),
    Ano SMALLINT NOT NULL,
    Professor NVARCHAR(80) NOT NULL,
    Capacidade INT NOT NULL CHECK (Capacidade > 0),
    CONSTRAINT FK_TURMA_DISCIPLINA FOREIGN KEY (Numero_disciplina)
        REFERENCES DISCIPLINA (Numero_disciplina)
);

CREATE TABLE HISTORICO_ESCOLAR (
    Numero_aluno INT NOT NULL,
    Identificacao_turma INT NOT NULL,
    Nota DECIMAL(4,2) NULL CHECK (Nota BETWEEN 0 AND 10),
    Frequencia DECIMAL(5,2) NULL CHECK (Frequencia BETWEEN 0 AND 100),
    CONSTRAINT PK_HISTORICO_ESCOLAR PRIMARY KEY
        (Numero_aluno, Identificacao_turma),
    CONSTRAINT FK_HISTORICO_ALUNO FOREIGN KEY (Numero_aluno)
        REFERENCES ALUNO (Numero_aluno),
    CONSTRAINT FK_HISTORICO_TURMA FOREIGN KEY (Identificacao_turma)
        REFERENCES TURMA (Identificacao_turma)
);

CREATE TABLE PRE_REQUISITO (
    Numero_disciplina NVARCHAR(10) NOT NULL,
    Numero_pre_requisito NVARCHAR(10) NOT NULL,
    CONSTRAINT PK_PRE_REQUISITO PRIMARY KEY
        (Numero_disciplina, Numero_pre_requisito),
    CONSTRAINT FK_PR_DISCIPLINA FOREIGN KEY (Numero_disciplina)
        REFERENCES DISCIPLINA (Numero_disciplina),
    CONSTRAINT FK_PR_REQUISITO FOREIGN KEY (Numero_pre_requisito)
        REFERENCES DISCIPLINA (Numero_disciplina),
    CONSTRAINT CK_PR_DIFERENTES CHECK (Numero_disciplina <> Numero_pre_requisito)
);
GO

INSERT INTO ALUNO
    (Numero_aluno, Nome, Tipo_aluno, Curso, Data_nascimento)
VALUES
    (1,  'Ana Martins',       1, 'SI', '2003-02-15'),
    (2,  'Bernardo Lopes',    1, 'CC', '2002-07-21'),
    (3,  'Camila Ribeiro',    2, 'SI', '2004-01-08'),
    (4,  'Daniel Souza',      1, 'CC', '2001-11-30'),
    (5,  'Elisa Fernandes',   2, 'SI', '2003-05-12'),
    (6,  'Felipe Costa',      1, 'CC', '2002-09-19'),
    (7,  'Gabriela Almeida',  1, 'SI', '2004-03-26'),
    (8,  'Henrique Moraes',   2, 'CC', '2001-06-02'),
    (9,  'Isadora Nunes',     1, 'SI', '2003-12-17'),
    (10, 'Joao Pedro Silva',  1, 'CC', '2002-04-09'),
    (11, 'Larissa Oliveira',  2, 'SI', '2004-08-05'),
    (12, 'Matheus Santos',    1, 'CC', '2003-10-28');

INSERT INTO DISCIPLINA
    (Numero_disciplina, Nome_disciplina, Creditos, Departamento)
VALUES
    ('CC1001',  'Algoritmos e Programacao',       4, 'CC'),
    ('CC2001',  'Estruturas de Dados',            4, 'CC'),
    ('CC2101',  'Banco de Dados I',               4, 'CC'),
    ('CC2201',  'Engenharia de Software',          4, 'CC'),
    ('CC2301',  'Programacao para Web',            4, 'CC'),
    ('CC3101',  'Implementacao de Banco de Dados', 4, 'CC'),
    ('MAT1101', 'Matematica Discreta',             4, 'MAT');

INSERT INTO TURMA
    (Identificacao_turma, Numero_disciplina, Semestre, Ano, Professor, Capacidade)
VALUES
    (201, 'CC1001',  1, 2025, 'Profa. Ana',    6),
    (202, 'CC2001',  2, 2025, 'Prof. Bruno',   5),
    (203, 'CC2101',  2, 2025, 'Profa. Carla',  6),
    (204, 'CC3101',  1, 2026, 'Prof. Diego',   4),
    (205, 'CC2201',  1, 2026, 'Profa. Elisa',  5),
    (206, 'MAT1101', 1, 2025, 'Prof. Fabio',   6),
    (207, 'CC2101',  2, 2026, 'Profa. Carla',  4),
    (208, 'CC2301',  1, 2026, 'Prof. Gustavo', 5);

INSERT INTO HISTORICO_ESCOLAR
    (Numero_aluno, Identificacao_turma, Nota, Frequencia)
VALUES
    (1,  201, 8.50, 92.00),
    (2,  201, 6.00, 80.00),
    (3,  201, 7.20, 72.00),
    (4,  201, 4.50, 88.00),
    (5,  201, 9.00, 96.00),
    (1,  202, 7.50, 85.00),
    (2,  202, 8.00, 90.00),
    (5,  202, 6.00, 78.00),
    (6,  202, 9.20, 94.00),
    (1,  203, 8.80, 90.00),
    (3,  203, 5.50, 82.00),
    (4,  203, 7.00, 76.00),
    (6,  203, 6.80, 74.00),
    (7,  203, 9.50, 98.00),
    (1,  204, 8.20, 88.00),
    (4,  204, 5.00, 80.00),
    (7,  204, 7.80, 72.00),
    (2,  206, 7.00, 75.00),
    (3,  206, 8.00, 91.00),
    (8,  206, 4.00, 70.00),
    (9,  206, 6.00, 86.00),
    (5,  207, NULL, NULL),
    (10, 207, NULL, NULL),
    (11, 207, NULL, NULL),
    (2,  208, 8.40, 89.00),
    (6,  208, 7.30, 81.00),
    (9,  208, 9.10, 95.00),
    (12, 208, 6.50, 77.00);

INSERT INTO PRE_REQUISITO
    (Numero_disciplina, Numero_pre_requisito)
VALUES
    ('CC2001', 'CC1001'),
    ('CC2101', 'CC1001'),
    ('CC2301', 'CC1001'),
    ('CC3101', 'CC2001'),
    ('CC3101', 'CC2101');
GO