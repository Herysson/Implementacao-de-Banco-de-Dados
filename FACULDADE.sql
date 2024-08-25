
CREATE TABLE ALUNO (
    Nome NVARCHAR(50),
    Numero_aluno INT PRIMARY KEY,
    Tipo_aluno INT,
    Curso NVARCHAR(2)
);

CREATE TABLE DISCIPLINA (
    Nome_disciplina NVARCHAR(100),
    Numero_disciplina NVARCHAR(10) PRIMARY KEY,
    Creditos INT,
    Departamento NVARCHAR(10)
);

CREATE TABLE TURMA (
    Identificacao_turma INT PRIMARY KEY,
    Numero_disciplina NVARCHAR(10),
    Semestre NVARCHAR(10),
    Ano INT,
    Professor NVARCHAR(50),
    FOREIGN KEY (Numero_disciplina) REFERENCES DISCIPLINA(Numero_disciplina)
);

CREATE TABLE HISTORICO_ESCOLAR (
    Numero_aluno INT,
    Identificacao_turma INT,
    Nota CHAR(1),
    FOREIGN KEY (Numero_aluno) REFERENCES ALUNO(Numero_aluno),
    FOREIGN KEY (Identificacao_turma) REFERENCES TURMA(Identificacao_turma)
);

CREATE TABLE PRE_REQUISITO (
    Numero_disciplina NVARCHAR(10),
    Numero_pre_requisito NVARCHAR(10),
    FOREIGN KEY (Numero_disciplina) REFERENCES DISCIPLINA(Numero_disciplina),
    FOREIGN KEY (Numero_pre_requisito) REFERENCES DISCIPLINA(Numero_disciplina)
);



INSERT INTO ALUNO (Nome, Numero_aluno, Tipo_aluno, Curso) VALUES 
('Silva', 17, 1, 'CC'),
('Braga', 8, 2, 'CC');



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
```


INSERT INTO HISTORICO_ESCOLAR (Numero_aluno, Identificacao_turma, Nota) VALUES 
(17, 112, 'B'),
(17, 119, 'C'),
(8, 85, 'A'),
(8, 92, 'A'),
(8, 102, 'B'),
(8, 135, 'A');

INSERT INTO PRE_REQUISITO (Numero_disciplina, Numero_pre_requisito) VALUES 
('CC3380', 'CC3320'),
('CC3380', 'MAT2410'),
('CC3320', 'CC1310');





Esses comandos SQL Server criarão as tabelas conforme o esquema fornecido na imagem e inserir os dados de exemplo nas respectivas tabelas. Se precisar de mais alguma coisa, estou à disposição!
