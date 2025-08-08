-- DISTINCT
SELECT 
DISTINCT FUNCIONARIO.Salario 
FROM FUNCIONARIO;

-- WHERE
SELECT * FROM FUNCIONARIO 
WHERE Pnome = 'João';

SELECT * FROM FUNCIONARIO 
WHERE Salario = 25000;

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

SELECT 
  (SELECT COUNT(*) FROM FUNCIONARIO) + 
  (SELECT COUNT(*) FROM DEPENDENTE) AS total_pessoas;

SELECT 
  (SELECT COUNT(*) FROM FUNCIONARIO) AS total_funcionarios,
  (SELECT COUNT(*) FROM DEPENDENTE) AS total_dependentes,
  (SELECT COUNT(*) FROM FUNCIONARIO) + (SELECT COUNT(*) FROM DEPENDENTE) AS total_pessoas;

DECLARE @total_funcionarios INT;
DECLARE @total_dependentes INT;

SET @total_funcionarios = (SELECT COUNT(*) FROM FUNCIONARIO);
SET @total_dependentes = (SELECT COUNT(*) FROM DEPENDENTE);
PRINT @total_funcionarios + @total_dependentes;
SELECT @total_funcionarios + @total_dependentes AS total_pessoas;

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


SELECT 
    f.Pnome,
    f.Unome,
    te.Pnr,
    te.Horas
FROM 
    FUNCIONARIO f
JOIN 
    TRABALHA_EM te ON f.Cpf = te.Fcpf
JOIN 
    TRABALHA_EM te_f ON te.Pnr = te_f.Pnr AND te.Horas = te_f.Horas
JOIN 
    FUNCIONARIO f_f ON te_f.Fcpf = f_f.Cpf
WHERE 
    f_f.Pnome = 'Fernando';

/*
JOIN FUNCIONARIO f ON f.Cpf = te.Fcpf: Relaciona os funcionários com os registros de trabalho (TRABALHA_EM).
JOIN TRABALHA_EM te_f ON te.Pnr = te_f.Pnr AND te.Horas = te_f.Horas: Faz o JOIN de TRABALHA_EM com ele mesmo para verificar se o projeto (Pnr) e as horas (Horas) são iguais para ambos os funcionários.
JOIN FUNCIONARIO f_f ON te_f.Fcpf = f_f.Cpf: Une a tabela FUNCIONARIO novamente para garantir que estamos comparando com os dados do funcionário "Fernando".
WHERE f_f.Pnome = 'Fernando': Filtra os resultados para garantir que estamos comparando com o funcionário "Fernando".
*/
