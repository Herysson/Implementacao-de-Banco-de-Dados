
--View de Funcionários Sem Supervisores: Crie uma view que liste todos os funcionários que não possuem supervisores. Utilize a coluna Cpf_supervisor para verificar quais funcionários não têm supervisores.
CREATE VIEW FuncionariosSemSupervisores AS
SELECT Pnome, Unome, Salario
FROM Funcionarios
WHERE Cpf_supervisor IS NULL;

--View de Salários por Departamento: Crie uma view que exiba a média salarial por departamento.
CREATE VIEW MediaSalarialPorDepartamento AS
SELECT Dnr, AVG(Salario) AS MediaSalarial
FROM Funcionarios
GROUP BY Dnr;


--View de Projetos Ativos: Crie uma view que liste os projetos ativos, ou seja, aqueles que estão em andamento.
CREATE VIEW ProjetosAtivos AS
SELECT Nome_projeto, Dnum
FROM Projeto
WHERE Status = 'Ativo';

--Funcionários com Alto Desempenho: Crie uma view que liste os funcionários que participaram de mais de 3 projetos no total. Inclua as colunas de nome, CPF e o número de projetos em que o funcionário participou.
CREATE VIEW FuncionariosAltoDesempenho AS
SELECT F.Pnome, F.Unome, F.Cpf, COUNT(T.Numero_projeto) AS NumProjetos
FROM Funcionarios F
JOIN Trabalha_em T ON F.Cpf = T.Cpf_funcionario
GROUP BY F.Pnome, F.Unome, F.Cpf
HAVING COUNT(T.Numero_projeto) > 3;

--Funcionários Perto da Aposentadoria: Crie uma view que liste os funcionários que estão a menos de 5 anos de se aposentar (assumindo que a idade de aposentadoria seja 65 anos). Inclua nome, CPF e o número de anos restantes para a aposentadoria.
CREATE VIEW FuncionariosPertoAposentadoria AS
SELECT Pnome, Unome, Cpf, (65 - YEAR(GETDATE()) + YEAR(Datanasc)) AS AnosRestantes
FROM Funcionarios
WHERE (65 - YEAR(GETDATE()) + YEAR(Datanasc)) <= 5;




--Funcionários Acima da Média Salarial: Liste todos os funcionários que ganham mais do que a média salarial do departamento em que trabalham.
SELECT Pnome, Unome, Salario
FROM Funcionarios F
WHERE Salario > (SELECT AVG(Salario) 
                 FROM Funcionarios 
                 WHERE Dnr = F.Dnr);

--Projetos Com Mais de 5 Funcionários: Liste os nomes dos projetos que têm mais de 5 funcionários alocados.
SELECT Nome_projeto
FROM Projeto
WHERE (SELECT COUNT(*) 
       FROM Trabalha_em 
       WHERE Numero_projeto = Projeto.Numero_projeto) > 5;

--Média de Salário por Departamento: Liste os departamentos onde a média salarial é maior que a média geral da empresa. Utilize uma subconsulta para calcular a média geral e compare com a média por departamento.
SELECT D.Nome AS Departamento, AVG(F.Salario) AS MediaSalario
FROM Departamento D
JOIN Funcionarios F ON D.Dnr = F.Dnr
GROUP BY D.Nome
HAVING AVG(F.Salario) > (SELECT AVG(Salario) FROM Funcionarios);

--Desafio: Views e Subconsultas
--Monitoramento de Performance de Funcionários e Projetos:** Crie uma view que mostre a performance dos funcionários com base na quantidade de projetos em que estão alocados, comparando com a média de participação em projetos de outros funcionários do mesmo departamento.
CREATE VIEW PerformanceFuncionarios AS
SELECT F.Pnome, F.Unome, F.Cpf, COUNT(T.Numero_projeto) AS NumProjetos, 
       (SELECT AVG(Contagem) 
        FROM (SELECT COUNT(T2.Numero_projeto) AS Contagem
              FROM Funcionarios F2
              JOIN Trabalha_em T2 ON F2.Cpf = T2.Cpf_funcionario
              WHERE F2.Dnr = F.Dnr
              GROUP BY F2.Cpf) AS Subconsulta) AS MediaDepto
FROM Funcionarios F
JOIN Trabalha_em T ON F.Cpf = T.Cpf_funcionario
GROUP BY F.Pnome, F.Unome, F.Cpf, F.Dnr;


