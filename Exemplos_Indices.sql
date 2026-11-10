/*
 Aula 12 — Indices e analise de desempenho (SQL Server / SSMS)

 PREPARACAO:
 1) Execute INDICES_LOJA.sql PRIMEIRO. Esse arquivo recria o banco didatico.
 2) Ative o plano de execucao real no SSMS: Ctrl+M (antes das consultas).
 3) Execute este arquivo POR BLOCOS, na ordem indicada, para comparar
    os resultados de antes e depois. NAO execute tudo de uma so vez.
 4) Consulte a guia Messages para logical reads, CPU time e elapsed time.

 Este script nao apaga os dados. As instrucoes DROP INDEX abaixo
 removem apenas os indices secundarios criados nestas demonstracoes.
 Planos e leituras variam conforme ambiente e otimizador.
*/
USE INDICES_LOJA;
GO

-- ETAPA 1 — Reconhecer o banco e os indices que ja existem (PRIMARY KEY).
SELECT 'Cliente' AS Tabela, COUNT(*) AS Quantidade FROM dbo.Cliente
UNION ALL SELECT 'Produto', COUNT(*) FROM dbo.Produto
UNION ALL SELECT 'Pedido', COUNT(*) FROM dbo.Pedido;
GO
SELECT t.name AS Tabela, i.name AS Indice, i.type_desc AS Tipo,
       i.is_primary_key AS CriadoPelaPK
FROM sys.indexes AS i
JOIN sys.tables AS t ON t.object_id = i.object_id
WHERE t.name IN ('Cliente', 'Produto', 'Pedido') AND i.index_id > 0
ORDER BY t.name, i.index_id;
GO

-- ETAPA 2 — Ativar as metricas da sessao (guia Messages).
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- ETAPA 3 — Clustered Index Seek na chave primaria (exploracao inicial).
SELECT PedidoID, DataPedido, ValorTotal
FROM dbo.Pedido
WHERE PedidoID = 150000;
GO

/* DEMONSTRACAO A — Filtro por data: antes e depois do indice simples.
   IMPORTANTE: execute cada consulta separadamente e anote logical reads.
*/
-- A1: Remover indice da demonstracao anterior, caso exista.
IF EXISTS (SELECT 1 FROM sys.indexes
           WHERE object_id = OBJECT_ID('dbo.Pedido') AND name = 'IX_Pedido_DataPedido')
    DROP INDEX IX_Pedido_DataPedido ON dbo.Pedido;
GO
-- A2: Consulta SEM indice secundario por DataPedido.
SELECT PedidoID, DataPedido
FROM dbo.Pedido
WHERE DataPedido = '20240115';
GO
-- A3: Criar indice nao clusterizado simples.
CREATE NONCLUSTERED INDEX IX_Pedido_DataPedido
ON dbo.Pedido (DataPedido);
GO
-- A4: Mesma consulta COM o indice por data.
SELECT PedidoID, DataPedido
FROM dbo.Pedido
WHERE DataPedido = '20240115';
GO

/* DEMONSTRACAO B — Indice composto, Key Lookup e INCLUDE.
   Vamos criar primeiro um indice que nao possui todas as colunas
   projetadas e depois um indice que pode cobrir a consulta.
*/
-- B1: Garantir um ponto de partida independente de repeticoes anteriores.
IF EXISTS (SELECT 1 FROM sys.indexes
           WHERE object_id = OBJECT_ID('dbo.Pedido') AND name = 'IX_Pedido_Cliente_Data')
    DROP INDEX IX_Pedido_Cliente_Data ON dbo.Pedido;
IF EXISTS (SELECT 1 FROM sys.indexes
           WHERE object_id = OBJECT_ID('dbo.Pedido') AND name = 'IX_Pedido_Cliente_Data_Cobertura')
    DROP INDEX IX_Pedido_Cliente_Data_Cobertura ON dbo.Pedido;
GO
-- B2: Consulta inicial (mantendo o indice por data da demonstracao A).
SELECT PedidoID, ClienteID, DataPedido, StatusPedido, ValorTotal
FROM dbo.Pedido
WHERE ClienteID = 1234
  AND DataPedido >= '20240101'
  AND DataPedido < '20250101';
GO
-- B3: Indice composto nas colunas filtradas, sem INCLUDE.
CREATE NONCLUSTERED INDEX IX_Pedido_Cliente_Data
ON dbo.Pedido (ClienteID, DataPedido);
GO
-- B4: Repetir e investigar se ocorre Key Lookup.
SELECT PedidoID, ClienteID, DataPedido, StatusPedido, ValorTotal
FROM dbo.Pedido
WHERE ClienteID = 1234
  AND DataPedido >= '20240101'
  AND DataPedido < '20250101';
GO
-- B5: Trocar pelo indice composto com colunas incluidas.
DROP INDEX IX_Pedido_Cliente_Data ON dbo.Pedido;
GO
CREATE NONCLUSTERED INDEX IX_Pedido_Cliente_Data_Cobertura
ON dbo.Pedido (ClienteID, DataPedido)
INCLUDE (StatusPedido, ValorTotal);
GO
-- B6: Repetir e comparar plano e logical reads com B2 e B4.
SELECT PedidoID, ClienteID, DataPedido, StatusPedido, ValorTotal
FROM dbo.Pedido
WHERE ClienteID = 1234
  AND DataPedido >= '20240101'
  AND DataPedido < '20250101';
GO

/* DEMONSTRACAO C — Predicado com funcao e predicado por intervalo.
   Comparar as duas consultas: mesmo resultado, potencial de acesso distinto.
*/
-- C1: Funcao aplicada sobre a coluna filtrada.
SELECT COUNT(*) AS TotalPedidos2024
FROM dbo.Pedido
WHERE YEAR(DataPedido) = 2024;
GO
-- C2: Intervalo semiaberto (inclui 2024, exclui 2025).
SELECT COUNT(*) AS TotalPedidos2024
FROM dbo.Pedido
WHERE DataPedido >= '20240101'
  AND DataPedido < '20250101';
GO

/* DEMONSTRACAO D — Coluna de baixa seletividade.
   Muitos pedidos estao com o status 'Entregue'. Um indice simples
   pode nao ser aproveitado para a consulta que solicita outras colunas.
*/
IF EXISTS (SELECT 1 FROM sys.indexes
           WHERE object_id = OBJECT_ID('dbo.Pedido') AND name = 'IX_Pedido_StatusPedido')
    DROP INDEX IX_Pedido_StatusPedido ON dbo.Pedido;
GO
-- D1: Sem indice por status. COUNT para visualizar distribuicao.
SELECT StatusPedido, COUNT(*) AS Quantidade
FROM dbo.Pedido
GROUP BY StatusPedido
ORDER BY Quantidade DESC;
GO
-- D2: Consulta de demonstracao (nao exige recuperar 210 mil linhas no grid).
SELECT COUNT(*) AS TotalEntregues
FROM dbo.Pedido
WHERE StatusPedido = 'Entregue';
GO
-- D3: Indice simples sobre coluna de baixa seletividade.
CREATE NONCLUSTERED INDEX IX_Pedido_StatusPedido
ON dbo.Pedido (StatusPedido);
GO
-- D4: Mesma consulta COUNT; observe que INDEX SCAN/SEEK ainda pode ser util.
SELECT COUNT(*) AS TotalEntregues
FROM dbo.Pedido
WHERE StatusPedido = 'Entregue';
GO
-- D5: Opcional: devolve cerca de 210 mil linhas e pode carregar a grade do SSMS.
--     Com outras colunas, comparar plano; nao pressupor ganho.
SELECT PedidoID, StatusPedido, ValorTotal, Observacao
FROM dbo.Pedido
WHERE StatusPedido = 'Entregue';
GO

-- ETAPA FINAL — Visualizar indices presentes depois das demonstracoes.
SELECT i.name AS Indice, i.type_desc AS Tipo, i.is_primary_key AS CriadoPelaPK
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('dbo.Pedido') AND i.index_id > 0
ORDER BY i.index_id;
GO
-- Desativar as metricas desta sessao.
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

/* REINICIO OPCIONAL DAS DEMONSTRACOES:
   Execute o bloco abaixo se quiser remover os indices adicionais e refazer
   toda a investigacao, SEM apagar os dados. Descomente e execute separado.

DROP INDEX IF EXISTS IX_Pedido_DataPedido ON dbo.Pedido;
DROP INDEX IF EXISTS IX_Pedido_Cliente_Data ON dbo.Pedido;
DROP INDEX IF EXISTS IX_Pedido_Cliente_Data_Cobertura ON dbo.Pedido;
DROP INDEX IF EXISTS IX_Pedido_StatusPedido ON dbo.Pedido;
*/
