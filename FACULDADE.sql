CREATE DATABASE FACULDADE;
USE FACULDADE;

-- Criação da tabela ALUNO
CREATE TABLE ALUNO (
    Nome NVARCHAR(50),
    Numero_aluno INT PRIMARY KEY,
    Tipo_aluno INT,
    Curso NVARCHAR(3),
    Data_Nascimento DATE
);

-- Criação da tabela DISCIPLINA
CREATE TABLE DISCIPLINA (
    Nome_disciplina NVARCHAR(100),
    Numero_disciplina NVARCHAR(10) PRIMARY KEY,
    Creditos INT,
    Departamento NVARCHAR(10)
);

-- Criação da tabela TURMA
CREATE TABLE TURMA (
    Identificacao_turma INT PRIMARY KEY,
    Numero_disciplina NVARCHAR(10),
    Semestre NVARCHAR(10),
    Ano INT,
    Professor NVARCHAR(50),
    FOREIGN KEY (Numero_disciplina) REFERENCES DISCIPLINA(Numero_disciplina)
);

-- Criação da tabela HISTORICO_ESCOLAR
CREATE TABLE HISTORICO_ESCOLAR (
    Numero_aluno INT,
    Identificacao_turma INT,
    Nota CHAR(1),
    FOREIGN KEY (Numero_aluno) REFERENCES ALUNO(Numero_aluno),
    FOREIGN KEY (Identificacao_turma) REFERENCES TURMA(Identificacao_turma)
);

-- Criação da tabela PRE_REQUISITO
CREATE TABLE PRE_REQUISITO (
    Numero_disciplina NVARCHAR(10),
    Numero_pre_requisito NVARCHAR(10),
    FOREIGN KEY (Numero_disciplina) REFERENCES DISCIPLINA(Numero_disciplina),
    FOREIGN KEY (Numero_pre_requisito) REFERENCES DISCIPLINA(Numero_disciplina)
);

INSERT INTO ALUNO (Nome, Numero_aluno, Tipo_aluno, Curso, Data_Nascimento) VALUES
('Silva', 17, 1, 'CC', '1996-06-17'),
('Braga', 8, 2, 'CC', '1997-07-08'),
('Alice Oliveira', 1, 1, 'CC', '1998-02-15'),
('Bruno Fernandes', 2, 2, 'MAT', '1997-11-23'),
('Carla Souza', 3, 1, 'CC', '1999-05-10'),
('Daniel Lima', 4, 2, 'CC', '1998-08-30'),
('Eduardo Pereira', 5, 1, 'MAT', '1997-07-18'),
('Fernanda Costa', 6, 1, 'CC', '1996-12-02'),
('Gabriel Almeida', 7, 2, 'MAT', '1997-03-25'),
('Helena Martins', 9, 1, 'CC', '1999-09-12'),
('Isabela Ribeiro', 10, 2, 'CC', '1998-01-05'),
('João Santos', 11, 1, 'MAT', '1996-04-28');

INSERT INTO DISCIPLINA (Nome_disciplina, Numero_disciplina, Creditos, Departamento) VALUES 
('Introdução à ciência da computação', 'CC1310', 4, 'CC'),
('Estruturas de dados', 'CC3320', 4, 'CC'),
('Matemática discreta', 'MAT2410', 3, 'MAT'),
('Banco de dados', 'CC3380', 3, 'CC');


INSERT INTO TURMA (Identificacao_turma, Numero_disciplina, Semestre, Ano, Professor) VALUES 
(85, 'MAT2410', 'Segundo', 07, 'Kleber'),
(92, 'CC1310', 'Segundo', 07, 'Anderson'),
(102, 'CC3320', 'Primeiro', 08, 'Carlos'),
(112, 'MAT2410', 'Segundo', 08, 'Chang'),
(119, 'CC1310', 'Segundo', 08, 'Anderson'),
(135, 'CC3380', 'Segundo', 08, 'Santos');


INSERT INTO HISTORICO_ESCOLAR (Numero_aluno, Identificacao_turma, Nota) VALUES 
(17, 112, 'B'),
(17, 119, 'C'),
(8, 85, 'A'),
(8, 92, 'A'),
(8, 102, 'B'),
(8, 135, 'A'),
(1, 85, 'A'),   -- Alice Oliveira - Matemática Discreta
(1, 92, 'B'),   -- Alice Oliveira - Introdução à Ciência da Computação
(1, 102, 'A'),  -- Alice Oliveira - Estruturas de Dados
(2, 85, 'C'),   -- Bruno Fernandes - Matemática Discreta
(2, 92, 'B'),   -- Bruno Fernandes - Introdução à Ciência da Computação
(3, 119, 'B'),  -- Carla Souza - Introdução à Ciência da Computação
(3, 135, 'F'),  -- Carla Souza - Banco de Dados (Conceito F)
(3, 112, 'C'),  -- Carla Souza - Matemática Discreta
(4, 85, 'A'),   -- Daniel Lima - Matemática Discreta
(4, 102, 'F'),  -- Daniel Lima - Estruturas de Dados (Conceito F)
(5, 135, 'B'),  -- Eduardo Pereira - Banco de Dados
(5, 119, 'A'),  -- Eduardo Pereira - Introdução à Ciência da Computação
(6, 112, 'C'),  -- Fernanda Costa - Matemática Discreta
(6, 85, 'F'),   -- Fernanda Costa - Matemática Discreta (Conceito F)
(7, 102, 'A'),  -- Gabriel Almeida - Estruturas de Dados
(7, 135, 'F'),  -- Gabriel Almeida - Banco de Dados (Conceito F)
(9, 119, 'C'),  -- Helena Martins - Introdução à Ciência da Computação
(9, 92, 'B'),   -- Helena Martins - Introdução à Ciência da Computação
(10, 102, 'F'), -- Isabela Ribeiro - Estruturas de Dados (Conceito F)
(10, 85, 'A');  -- Isabela Ribeiro - Matemática Discreta

INSERT INTO PRE_REQUISITO (Numero_disciplina, Numero_pre_requisito) VALUES 
('CC3380', 'CC3320'),
('CC3380', 'MAT2410'),
('CC3320', 'CC1310');
