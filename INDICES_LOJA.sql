/*
 Aula 12 - Indices e planos de execucao
 Banco didatico independente. Executar em ambiente de laboratorio.
 A execucao recria o banco INDICES_LOJA e APAGA todos os seus dados anteriores.
 Volume: 10.000 clientes, 1.000 produtos e 300.000 pedidos.
 Nao cria indices secundarios: os alunos deverao cria-los na aula.
*/
USE master;
GO
IF DB_ID('INDICES_LOJA') IS NOT NULL
BEGIN
    ALTER DATABASE INDICES_LOJA SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE INDICES_LOJA;
END;
GO
CREATE DATABASE INDICES_LOJA;
GO
USE INDICES_LOJA;
GO
CREATE TABLE dbo.Cliente (
    ClienteID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Cidade VARCHAR(60) NOT NULL,
    Estado CHAR(2) NOT NULL
);
GO
CREATE TABLE dbo.Produto (
    ProdutoID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Descricao VARCHAR(100) NOT NULL,
    Categoria VARCHAR(40) NOT NULL,
    Preco DECIMAL(10,2) NOT NULL
);
GO
CREATE TABLE dbo.Pedido (
    PedidoID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClienteID INT NOT NULL,
    ProdutoID INT NOT NULL,
    DataPedido DATE NOT NULL,
    StatusPedido VARCHAR(20) NOT NULL,
    ValorTotal DECIMAL(10,2) NOT NULL,
    Observacao VARCHAR(120) NOT NULL,
    CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (ClienteID) REFERENCES dbo.Cliente(ClienteID),
    CONSTRAINT FK_Pedido_Produto FOREIGN KEY (ProdutoID) REFERENCES dbo.Produto(ProdutoID)
);
GO
-- Gerador numerico por produto cartesiano de digitos: 0 a 9999.
WITH Digitos AS (
    SELECT V.n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS V(n)
), Numeros AS (
    SELECT (a.n + b.n*10 + c.n*100 + d.n*1000) AS n
    FROM Digitos a CROSS JOIN Digitos b CROSS JOIN Digitos c CROSS JOIN Digitos d
)
INSERT INTO dbo.Cliente (Nome, Cidade, Estado)
SELECT CONCAT('Cliente ', RIGHT(CONCAT('00000', n+1),5)),
       CASE n % 5 WHEN 0 THEN 'Santa Maria' WHEN 1 THEN 'Porto Alegre'
                    WHEN 2 THEN 'Caxias do Sul' WHEN 3 THEN 'Pelotas' ELSE 'Canoas' END,
       'RS'
FROM Numeros
ORDER BY n;
GO
WITH Digitos AS (
    SELECT V.n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS V(n)
), Numeros AS (
    SELECT (a.n + b.n*10 + c.n*100) AS n
    FROM Digitos a CROSS JOIN Digitos b CROSS JOIN Digitos c
)
INSERT INTO dbo.Produto (Descricao, Categoria, Preco)
SELECT CONCAT('Produto ', RIGHT(CONCAT('0000',n+1),4)),
       CASE n % 4 WHEN 0 THEN 'Informatica' WHEN 1 THEN 'Papelaria'
                    WHEN 2 THEN 'Escritorio' ELSE 'Eletronicos' END,
       CAST(10 + (n % 500) * 1.5 AS DECIMAL(10,2))
FROM Numeros
ORDER BY n;
GO
-- 300.000 linhas, uma unica instrucao INSERT ... SELECT (sem WHILE).
WITH Digitos AS (
    SELECT V.n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS V(n)
), Numeros AS (
    SELECT (a.n + b.n*10 + c.n*100 + d.n*1000 + e.n*10000 + f.n*100000) AS n
    FROM Digitos a CROSS JOIN Digitos b CROSS JOIN Digitos c
         CROSS JOIN Digitos d CROSS JOIN Digitos e CROSS JOIN Digitos f
)
INSERT INTO dbo.Pedido (ClienteID, ProdutoID, DataPedido, StatusPedido, ValorTotal, Observacao)
SELECT (n * 37 % 10000) + 1,
       (n * 17 % 1000) + 1,
       DATEADD(DAY, n % 1095, CONVERT(DATE,'20230101',112)),
       CASE WHEN n % 10 < 7 THEN 'Entregue'
            WHEN n % 10 < 9 THEN 'Pendente' ELSE 'Cancelado' END,
       CAST(20 + (n % 20000) / 10.0 AS DECIMAL(10,2)),
       CONCAT('Pedido demonstrativo numero ',n+1,' para pratica de indices')
FROM Numeros
WHERE n < 300000
ORDER BY n;
GO
-- Atualiza as estatisticas das tabelas apos a carga inicial.
UPDATE STATISTICS dbo.Cliente WITH FULLSCAN;
UPDATE STATISTICS dbo.Produto WITH FULLSCAN;
UPDATE STATISTICS dbo.Pedido WITH FULLSCAN;
GO
SELECT 'Cliente' AS Tabela, COUNT(*) AS Quantidade FROM dbo.Cliente
UNION ALL SELECT 'Produto', COUNT(*) FROM dbo.Produto
UNION ALL SELECT 'Pedido', COUNT(*) FROM dbo.Pedido;
GO
-- Inspecao dos indices existentes (PKs, antes dos exercicios).
SELECT t.name AS Tabela, i.name AS Indice, i.type_desc AS Tipo
FROM sys.indexes AS i
JOIN sys.tables AS t ON t.object_id = i.object_id
WHERE t.name IN ('Cliente','Produto','Pedido') AND i.index_id > 0
ORDER BY t.name, i.index_id;
GO
