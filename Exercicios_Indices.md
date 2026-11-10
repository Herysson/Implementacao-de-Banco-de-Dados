# Aula 12 — Exercícios práticos: índices e desempenho

**Banco:** `INDICES_LOJA`  
**Tempo previsto:** 20 minutos  
**Entrega:** comandos SQL, leituras lógicas antes/depois, operadores do plano real e justificativa breve.

> Antes de iniciar, carregue `INDICES_LOJA.sql`. Os exercícios podem ser resolvidos na ordem proposta. Ative `Ctrl+M`, `SET STATISTICS IO ON` e `SET STATISTICS TIME ON`. Como o banco é didático, é permitido recriá-lo para restaurar o cenário inicial. Os valores medidos dependem da máquina e da versão do SQL Server.

## Exercício 1 — Localização de pedidos por produto

Uma equipe de atendimento precisa localizar os pedidos relacionados ao produto `42`:

```sql
SELECT PedidoID, ProdutoID
FROM dbo.Pedido
WHERE ProdutoID = 42;
```

1. Execute a consulta **antes** de criar um índice sobre `ProdutoID`. Registre o operador de acesso e `logical reads`.
2. Crie um índice não clusterizado apropriado.
3. Execute novamente a consulta e registre as mesmas informações.
4. Explique por que o índice pode reduzir a quantidade de páginas acessadas. Houve alteração no resultado da consulta?

## Exercício 2 — Atendimento de um cliente e custo de buscar colunas

A loja precisa visualizar o histórico de um cliente, em determinado período, incluindo suas observações:

```sql
SELECT PedidoID, ClienteID, DataPedido, ValorTotal, Observacao
FROM dbo.Pedido
WHERE ClienteID = 4321
  AND DataPedido >= '20230101'
  AND DataPedido < '20260101';
```

1. Registre as métricas e o plano antes de criar um índice novo para essa consulta.
2. Proponha e crie um índice **composto** adequado às duas condições do `WHERE`, respeitando a ordem das chaves.
3. Meça novamente e observe se aparecem operadores `Key Lookup`.
4. Se houver busca adicional de colunas, investigue uma alteração no índice que permita recuperar os dados solicitados diretamente dele; compare a nova medição. Explique o custo adicional dessa escolha.

**Observação:** registre o plano efetivamente obtido; o otimizador pode optar por um plano sem `Key Lookup` mesmo na segunda etapa.

## Exercício 3 — Quando um índice não compensa?

A gestão deseja obter uma lista de pedidos entregues:

```sql
SELECT PedidoID, StatusPedido, ValorTotal, Observacao
FROM dbo.Pedido
WHERE StatusPedido = 'Entregue';
```

1. Meça o desempenho sem índice secundário em `StatusPedido` e registre quantas linhas a consulta retorna.
2. Crie um índice não clusterizado apenas em `StatusPedido`, execute a consulta novamente e observe o plano.
3. Analise se houve ganho relevante em leituras lógicas e se o SQL Server de fato escolheu o índice.
4. Explique por que a frequência do valor pesquisado e as colunas solicitadas influenciam essa decisão. Recomenda manter o índice para essa consulta? Justifique com os dados observados.

> Ao terminar, desative as estatísticas (`SET STATISTICS IO OFF; SET STATISTICS TIME OFF;`). Não é necessário remover os índices, salvo se quiser refazer o experimento desde o início.
