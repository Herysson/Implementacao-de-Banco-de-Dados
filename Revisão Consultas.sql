-- DISTINCT
SELECT 
DISTINCT FUNCIONARIO.Salario 
FROM FUNCIONARIO;

-- WHERE
SELECT * FROM FUNCIONARIO 
WHERE Pnome = 'João';

-- AND
SELECT * 
FROM FUNCIONARIO 
WHERE Sexo = 'M' AND Salario >= 30000;

--OR
SELECT * 
FROM FUNCIONARIO
WHERE Endereco LIKE '%São Paulo%'
OR Endereco LIKE '%Curitiba%';

--NOT
SELECT * 
FROM FUNCIONARIO
WHERE NOT Endereco LIKE '%São Paulo%';

-- ORDER BY
SELECT * 
FROM FUNCIONARIO
ORDER BY Salario DESC;

--IS NULL
SELECT *
FROM FUNCIONARIO
WHERE Cpf_supervisor IS NULL;

--IS NOT NULL
SELECT *
FROM FUNCIONARIO
WHERE Cpf_supervisor IS NOT NULL;

--TOP
SELECT TOP 3 * 
FROM FUNCIONARIO
ORDER BY Salario DESC;

--MIN()
SELECT MIN(Salario)
FROM FUNCIONARIO;

SELECT *
FROM FUNCIONARIO
WHERE Salario = (
	SELECT MIN(Salario)
	FROM FUNCIONARIO
);

DECLARE @Salario_Min DECIMAL(10,2);

/*

SELECT @Salario_Min = MIN(FUNCIONARIO.Salario)
FROM FUNCIONARIO;
*/

SET @Salario_Min = (SELECT MIN(Salario)
					FROM FUNCIONARIO);

SELECT *
FROM FUNCIONARIO
WHERE Salario = @Salario_Min;

-- MAX()
SELECT *
FROM FUNCIONARIO
WHERE Salario = (
	SELECT MAX(Salario)
	FROM FUNCIONARIO
);

--COUNT()
SELECT COUNT (FUNCIONARIO.Cpf)
FROM FUNCIONARIO;

-- AVG
DECLARE @Salario_AVG DECIMAL(10,2)
SET @Salario_AVG  = (SELECT AVG(Salario)
					FROM FUNCIONARIO);
						
DECLARE @Salario_MAX DECIMAL(10,2)
SET @Salario_Max = (SELECT MAX(Salario)
					FROM FUNCIONARIO);
PRINT 'A difereça é: ' + CAST((@Salario_MAX - @Salario_AVG) AS VARCHAR (10));

--LIKE
SELECT * 
FROM FUNCIONARIO
WHERE Datanasc LIKE '_____06%';

-- IN
SELECT *
FROM FUNCIONARIO
WHERE Salario IN (25000,30000);

SELECT Cpf 
FROM FUNCIONARIO
WHERE Pnome = 'Fernando';


SELECT Pnr, Horas
FROM TRABALHA_EM
WHERE Fcpf = '33344555587';

DECLARE @Cpf_Funcionario VARCHAR(11);
SET @Cpf_Funcionario =	(SELECT Cpf 
						FROM FUNCIONARIO
						WHERE Pnome = 'Fernando');
SELECT DISTINCT CONCAT(F.Pnome,' ', F.Minicial,' ', F.Unome) AS 'Nome'
FROM TRABALHA_EM AS TE, FUNCIONARIO AS F
WHERE CONCAT(Pnr, Horas) IN (SELECT CONCAT(Pnr, Horas)
							FROM TRABALHA_EM
							WHERE Fcpf =(@Cpf_Funcionario))
AND Fcpf <> @Cpf_Funcionario
AND TE.Fcpf = F.Cpf;


SELECT f.*
FROM FUNCIONARIO f
JOIN TRABALHA_EM t ON f.Cpf = t.Fcpf
WHERE t.Pnr IN (SELECT Pnr FROM TRABALHA_EM WHERE Fcpf = '33344555587')
AND t.Horas IN (SELECT Horas FROM TRABALHA_EM WHERE Fcpf = '33344555587');


SELECT DISTINCT F.Pnome, F.Minicial, F.Unome
FROM TRABALHA_EM AS T1, TRABALHA_EM AS T2, FUNCIONARIO AS F
WHERE T1.Pnr = T2.Pnr
AND T1.Horas = T2.Horas
AND T2.Fcpf = (	SELECT Cpf 
				FROM FUNCIONARIO
				WHERE Pnome = 'Fernando')
AND T1.Fcpf <> (SELECT Cpf 
				FROM FUNCIONARIO
				WHERE Pnome = 'Fernando')
AND T1.Fcpf = F.Cpf;

SELECT DISTINCT T1.Fcpf
FROM TRABALHA_EM AS T1
JOIN TRABALHA_EM AS T2
	ON T1.Pnr = T2.Pnr
	AND T1.Horas = T2.Horas
WHERE T2.Fcpf = '33344555587';

-- JOIN





INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Carlos', 'M', 'Ferreira', '12312312311', '1980-02-15', 'Av. Paulista, 1000, São Paulo, SP', 'M', 45000, NULL, NULL);

INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Mariana', 'L', 'Gomes', '32132132122', '1985-06-22', 'Rua das Acácias, 500, Rio de Janeiro, RJ', 'F', 42000, NULL, NULL);

INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Pedro', 'A', 'Silva', '65465465433', '1990-11-10', 'Rua da Praia, 200, Salvador, BA', 'M', 47000, NULL, NULL);

INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Vendas', 6);

INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Recursos Humanos', 7);

INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('TI', 8);

--LEFT JOIN 
-- Econtre os funcionarios que não possuem um departamento a eles vinculado
SELECT 
    FUNCIONARIO.Pnome,
    FUNCIONARIO.Minicial,
    FUNCIONARIO.Unome,
    FUNCIONARIO.Cpf,
    FUNCIONARIO.Datanasc,
    FUNCIONARIO.Endereco,
    FUNCIONARIO.Sexo,
    FUNCIONARIO.Salario,
    FUNCIONARIO.Cpf_supervisor,
    FUNCIONARIO.Dnr,
    DEPARTAMENTO.Dnome
FROM 
    FUNCIONARIO
LEFT JOIN 
    DEPARTAMENTO 
ON 
    FUNCIONARIO.Dnr = DEPARTAMENTO.Dnumero;

-- Encontre os departamentos que ~não possuem nenhum funcionário
-- Exemplo 1
SELECT 
    DEPARTAMENTO.Dnome,
    DEPARTAMENTO.Dnumero
FROM 
    DEPARTAMENTO
LEFT JOIN 
    FUNCIONARIO 
ON 
    DEPARTAMENTO.Dnumero = FUNCIONARIO.Dnr
WHERE 
    FUNCIONARIO.Dnr IS NULL;

-- Exemplo 2
SELECT 
    Dnome, 
    Dnumero
FROM 
    DEPARTAMENTO
WHERE 
    Dnumero NOT IN (SELECT Dnr FROM FUNCIONARIO WHERE Dnr IS NOT NULL);

-- Exemplo 3
SELECT 
    Dnome, 
    Dnumero
FROM 
    DEPARTAMENTO d
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM FUNCIONARIO f 
        WHERE f.Dnr = d.Dnumero
    );


--RIGHT JOIN
SELECT 
    FUNCIONARIO.Pnome,
    FUNCIONARIO.Minicial,
    FUNCIONARIO.Unome,
    FUNCIONARIO.Cpf,
    FUNCIONARIO.Datanasc,
    FUNCIONARIO.Endereco,
    FUNCIONARIO.Sexo,
    FUNCIONARIO.Salario,
    FUNCIONARIO.Cpf_supervisor,
    FUNCIONARIO.Dnr,
    DEPARTAMENTO.Dnome
FROM 
    FUNCIONARIO
RIGHT JOIN 
    DEPARTAMENTO 
ON 
    FUNCIONARIO.Dnr = DEPARTAMENTO.Dnumero;

--FULL JOIN
SELECT 
    FUNCIONARIO.Pnome,
    FUNCIONARIO.Minicial,
    FUNCIONARIO.Unome,
    FUNCIONARIO.Cpf,
    FUNCIONARIO.Datanasc,
    FUNCIONARIO.Endereco,
    FUNCIONARIO.Sexo,
    FUNCIONARIO.Salario,
    FUNCIONARIO.Cpf_supervisor,
    FUNCIONARIO.Dnr,
    DEPARTAMENTO.Dnome
FROM 
    FUNCIONARIO
FULL JOIN 
    DEPARTAMENTO 
ON 
    FUNCIONARIO.Dnr = DEPARTAMENTO.Dnumero;

--  UNION/INTERSECT/EXCEPT
-- UNION: Combina os resultados de duas ou mais consultas em uma única tabela, eliminando duplicatas
-- Listar todos os nomes únicos de projetos e departamentos.
SELECT Dnome AS Nome
FROM DEPARTAMENTO

UNION

SELECT Projnome AS Nome
FROM PROJETO;

-- INTERSECT: Retorna apenas as linhas que aparecem em ambas as consultas.
-- Encontrar CPF de funcionários que também são gerentes de departamento.

SELECT Cpf
FROM FUNCIONARIO

INTERSECT

SELECT Cpf_gerente
FROM DEPARTAMENTO;

-- EXCEPT: Retorna as linhas da primeira consulta que não estão presentes na segunda consulta.
-- Listar os CPFs dos funcionários que não são gerentes de nenhum departamento.
SELECT Cpf
FROM FUNCIONARIO

EXCEPT

SELECT Cpf_gerente
FROM DEPARTAMENTO;

--GROUP BY
--Contar o número de funcionários por departamento
SELECT 
    DEPARTAMENTO.Dnome, 
    COUNT(FUNCIONARIO.Cpf) AS NumeroFuncionarios
FROM 
    FUNCIONARIO
JOIN 
    DEPARTAMENTO ON FUNCIONARIO.Dnr = DEPARTAMENTO.Dnumero
GROUP BY 
    DEPARTAMENTO.Dnome;

--Somar os salários por departamento
SELECT 
    DEPARTAMENTO.Dnome, 
    SUM(FUNCIONARIO.Salario) AS SalarioTotal
FROM 
    FUNCIONARIO
JOIN 
    DEPARTAMENTO ON FUNCIONARIO.Dnr = DEPARTAMENTO.Dnumero
GROUP BY 
    DEPARTAMENTO.Dnome;

-- Média de horas trabalhadas por projeto
SELECT 
    PROJETO.Projnome, 
    AVG(TRABALHA_EM.Horas) AS MediaHorasTrabalhadas
FROM 
    TRABALHA_EM
JOIN 
    PROJETO ON TRABALHA_EM.Pnr = PROJETO.Projnumero
GROUP BY 
    PROJETO.Projnome;
-- Quantidade de funcionários por sexo
SELECT 
    Sexo, 
    COUNT(*) AS NumeroFuncionarios
FROM 
    FUNCIONARIO
GROUP BY 
    Sexo;
--Maior salário em cada departamento
SELECT 
    DEPARTAMENTO.Dnome, 
    MAX(FUNCIONARIO.Salario) AS MaiorSalario
FROM 
    FUNCIONARIO
JOIN 
    DEPARTAMENTO ON FUNCIONARIO.Dnr = DEPARTAMENTO.Dnumero
GROUP BY 
    DEPARTAMENTO.Dnome;

--Número de projetos em cada local
-- COUNT(*): Conta todas as linhas da tabela ou do conjunto de resultados que correspondem às condições da consulta. Isso inclui todas as linhas, mesmo que todas as colunas contenham valores nulos
SELECT 
    Projlocal, 
    COUNT(*) AS NumeroProjetos
FROM 
    PROJETO
GROUP BY 
    Projlocal;

--HAVING
--Encontrar departamentos com mais de 3 funcionários
SELECT 
    DEPARTAMENTO.Dnome, 
    COUNT(FUNCIONARIO.Cpf) AS NumeroFuncionarios
FROM 
    FUNCIONARIO
JOIN 
    DEPARTAMENTO ON FUNCIONARIO.Dnr = DEPARTAMENTO.Dnumero
GROUP BY 
    DEPARTAMENTO.Dnome
HAVING 
    COUNT(FUNCIONARIO.Cpf) > 3;

-- Listar projetos que exigem mais de 100 horas de trabalho no total
SELECT 
    PROJETO.Projnome, 
    SUM(TRABALHA_EM.Horas) AS TotalHoras
FROM 
    TRABALHA_EM
JOIN 
    PROJETO ON TRABALHA_EM.Pnr = PROJETO.Projnumero
GROUP BY 
    PROJETO.Projnome
HAVING 
    SUM(TRABALHA_EM.Horas) > 100;

-- EXISTIS
-- Listar funcionários que são gerentes de algum departamento
SELECT 
    Pnome, 
    Unome, 
    Cpf
FROM 
    FUNCIONARIO
WHERE 
    EXISTS (
        SELECT 1 
        FROM DEPARTAMENTO 
        WHERE DEPARTAMENTO.Cpf_gerente = FUNCIONARIO.Cpf
    );
--Listar departamentos que possuem projetos associados
SELECT 
    Dnome, 
    Dnumero
FROM 
    DEPARTAMENTO
WHERE 
    EXISTS (
        SELECT 1 
        FROM PROJETO 
        WHERE PROJETO.Dnum = DEPARTAMENTO.Dnumero
    );

-- ANY / ALL
--ANY 
-- Encontrar funcionários que ganham mais do que qualquer funcionário do departamento de 'Administração
SELECT 
    Pnome, 
    Unome, 
    Salario
FROM 
    FUNCIONARIO
WHERE 
    Salario > ANY (
        SELECT Salario 
        FROM FUNCIONARIO 
        JOIN DEPARTAMENTO ON FUNCIONARIO.Dnr = DEPARTAMENTO.Dnumero
        WHERE DEPARTAMENTO.Dnome = 'Administração'
    );

--ALL
--Encontrar projetos que exigem mais horas do que todos os projetos no local 'São Paulo'
SELECT 
    Projnome, 
    SUM(TRABALHA_EM.Horas) AS TotalHoras
FROM 
    PROJETO
JOIN 
    TRABALHA_EM ON PROJETO.Projnumero = TRABALHA_EM.Pnr
GROUP BY 
    Projnome
HAVING 
    SUM(TRABALHA_EM.Horas) > ALL (
        SELECT SUM(TRABALHA_EM.Horas) 
        FROM PROJETO
        JOIN TRABALHA_EM ON PROJETO.Projnumero = TRABALHA_EM.Pnr
        WHERE PROJETO.Projlocal = 'São Paulo'
        GROUP BY PROJETO.Projnumero
    );

