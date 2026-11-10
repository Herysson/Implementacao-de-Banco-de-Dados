# Aula 12 — Índices e Análise de Desempenho de Consultas no SQL Server

**Disciplina:** Implementação de Banco de Dados — Sistemas de Informação  
**Ambiente:** Microsoft SQL Server e SQL Server Management Studio (SSMS)  
**Arquivos de apoio:** [`INDICES_LOJA.sql`](INDICES_LOJA.sql) (base de dados) e [`Exemplos_Indices.sql`](Exemplos_Indices.sql) (demonstrações da aula)

## 1. Objetivos de aprendizagem

Ao final da aula, os estudantes deverão ser capazes de explicar por que e quando índices podem melhorar consultas; diferenciar índices clusterizados e não clusterizados; criar e remover índices simples e compostos; observar planos de execução reais no SSMS; medir leituras lógicas e tempo de execução; e justificar uma decisão de indexação a partir de evidências.

## 2. Conhecimentos prévios e relação com a disciplina

Retomamos `CREATE TABLE`, `PRIMARY KEY`, `FOREIGN KEY`, `SELECT`, `WHERE`, `ORDER BY`, `JOIN`, `INSERT` e consultas com filtros. Esses recursos já integram a sequência da disciplina. Nesta aula introduzimos explicitamente `CREATE INDEX`, `DROP INDEX`, índices compostos e os mecanismos de inspeção de desempenho. O código de geração de massa de dados usa `WITH` (CTE), `CROSS JOIN` e operações aritméticas: **não é conteúdo a ser cobrado**; é apenas um script fornecido e explicado em alto nível.

> O arquivo anterior da disciplina, `Aula 12 - Índices.md`, já apresentava conceitos essenciais e `SET STATISTICS IO`. Esta versão complementa o material com exemplos controlados, maior quantidade de dados e interpretação dos planos. Não assume que a existência de um índice obrigue o SQL Server a utilizá-lo.

## 3. Como utilizar este tutorial

Este material foi elaborado para estudo acompanhado ou autônomo. Leia as explicações na sequência, prepare o banco didático e execute os exemplos conforme indicado. Antes de modificar um índice, registre o resultado e as métricas da consulta original. Em seguida, repita **exatamente a mesma consulta** e compare as evidências no SSMS.

Os exemplos estão reunidos em [`Exemplos_Indices.sql`](Exemplos_Indices.sql), identificados por etapas e demonstrações. **Execute cada bloco separadamente e na ordem indicada**, e não todo o arquivo de uma vez, pois é necessário observar o efeito de cada alteração. Os três exercícios para praticar estão em [`Exercicios_Indices.md`](Exercicios_Indices.md).

## 4. Por que uma consulta pode ficar lenta?

Imagine uma loja com 300 mil pedidos. O sistema precisa localizar pedidos de uma data específica. Sem uma estrutura de acesso adequada, o SQL Server pode ter de examinar muitas páginas da tabela. Índices organizam **chaves de busca** e localizadores, permitindo localizar conjuntos relevantes com menos trabalho — mas ocupam espaço e precisam ser mantidos durante inserções, atualizações e exclusões.

Um índice se parece com o índice remissivo de um livro: ele ajuda a encontrar uma informação sem percorrer todas as páginas. A comparação, porém, é limitada: o SQL Server tem um otimizador de consultas que decide, a partir das estatísticas, se compensa usar o índice ou realizar uma varredura.

**Para refletir:** se 70% dos pedidos estão com status `Entregue`, criar um índice em `StatusPedido` garante uma busca mais rápida por esses pedidos? **Não.** Para muitos resultados, examinar a tabela pode custar menos do que fazer inúmeros acessos adicionais por um índice.

### 4.1 Páginas, leituras e seletividade

O SQL Server organiza os dados em páginas de 8 KB. Uma **leitura lógica** é um acesso a uma página pelo mecanismo de buffer, ainda que a página já esteja na memória. Consultas que leem menos páginas geralmente exigem menos trabalho de E/S, embora isso não seja a única medida de desempenho. **Seletividade** descreve quanto um filtro restringe o conjunto: uma data específica pode selecionar poucas linhas; um status muito frequente pode selecionar grande parte da tabela.

## 5. Tipos de índices

### 5.1 Índice clusterizado (*clustered*)

O índice clusterizado organiza as linhas de dados na estrutura de árvore B+ segundo a chave do índice. Seu nível folha contém as linhas da tabela, por isso uma tabela possui **no máximo um** índice clusterizado. Em nossas tabelas, `PRIMARY KEY` foi declarada sem especificar `NONCLUSTERED`; no SQL Server, na ausência de índice clusterizado preexistente, a chave primária é criada como clusterizada por padrão. **Não confundir:** toda PK cria um índice de apoio, mas ela não precisa ser clusterizada em todos os esquemas.

```sql
SELECT PedidoID, DataPedido, ValorTotal
FROM dbo.Pedido
WHERE PedidoID = 150000;
```

**Para refletir:** qual é a vantagem de buscar um valor exato de `PedidoID` no índice da PK? O plano provavelmente terá `Clustered Index Seek`, pois o SQL Server consegue navegar pela chave.

### 5.2 Índice não clusterizado (*nonclustered*)

É outra estrutura ordenada de chaves que contém referências às linhas-base. No caso de uma tabela clusterizada, o localizador utiliza a chave clusterizada. Um índice não clusterizado pode acelerar filtros sobre colunas que não são a PK:

```sql
CREATE NONCLUSTERED INDEX IX_Pedido_DataPedido
ON dbo.Pedido (DataPedido);
```

A criação **não altera o resultado lógico** do `SELECT`: altera as alternativas disponíveis ao otimizador. Se a consulta solicitar colunas não presentes no índice, pode ser necessário um `Key Lookup` para buscar dados adicionais na tabela clusterizada.

### 5.3 Índice composto e ordem das chaves

```sql
CREATE NONCLUSTERED INDEX IX_Pedido_Cliente_Data
ON dbo.Pedido (ClienteID, DataPedido);
```

Esse índice é ordenado primeiro por `ClienteID` e, dentro de cada cliente, por `DataPedido`. Costuma servir bem a filtros por cliente ou por cliente e data. Um filtro somente por data **não tem o mesmo acesso direto** ao primeiro nível de ordenação. A ordem das colunas importa.

Para adicionar colunas recuperadas, mas não pesquisadas, existe a cláusula `INCLUDE`:

```sql
CREATE NONCLUSTERED INDEX IX_Pedido_Cliente_Data_Cobertura
ON dbo.Pedido (ClienteID, DataPedido)
INCLUDE (StatusPedido, ValorTotal);
```

Esse índice pode atender à projeção de certas consultas sem `Key Lookup`. `INCLUDE` aumenta o tamanho e a manutenção do índice; não é motivo para incluir todas as colunas indiscriminadamente. Um índice *coberto* é aquele que contém todas as colunas exigidas por uma consulta, nas chaves, colunas incluídas ou localizador.

## 6. Preparação do laboratório

1. Abra o arquivo [`INDICES_LOJA.sql`](INDICES_LOJA.sql) no SSMS. **Atenção:** o script exclui e recria apenas o banco didático `INDICES_LOJA` se ele já existir. Não o execute em um banco que contenha trabalho a preservar.
2. Execute o script completo e aguarde a carga. Ele gera 10.000 clientes, 1.000 produtos e 300.000 pedidos. Os pedidos contêm datas distribuídas em 1.095 dias e diferentes status.
3. Confira a contagem final e observe os índices já existentes por causa das chaves primárias.
4. Abra [`Exemplos_Indices.sql`](Exemplos_Indices.sql) em outra janela e execute suas etapas individualmente. Não crie índices secundários antes das primeiras medições. As chaves estrangeiras **não criam índices automaticamente** no SQL Server.

O gerador utiliza combinações dos dígitos de 0 a 9 via `CROSS JOIN` e uma única inserção em conjunto para a tabela de pedidos. Essa técnica é muito mais apropriada para preparar o laboratório do que realizar 300 mil `INSERT`s separados. O tempo de carga varia com o computador, o disco e a configuração do servidor.

## 7. Instrumentos de inspeção

### 7.1 Plano de execução real

No SSMS, abra uma janela de consulta, escolha o banco `INDICES_LOJA`, ative **Query > Include Actual Execution Plan** (atalho **Ctrl+M**) e então execute a consulta com **F5**. O SSMS exibe a guia **Execution Plan**. Passe o mouse sobre cada operador ou abra **Properties (F4)**.

| Operador | Interpretação inicial |
|---|---|
| `Clustered Index Scan` | Percorre parte ou a totalidade da estrutura clusterizada |
| `Index Scan` | Percorre parte ou a totalidade de um índice não clusterizado |
| `Index Seek` | Acessa uma região de chaves do índice; pode ainda ler muitas linhas |
| `Key Lookup` | Busca colunas adicionais na estrutura clusterizada |
| `Sort` | Realiza uma ordenação que pode ter custo relevante |

Um **Seek não é sempre bom**, e um **Scan não é sempre ruim**: a quantidade real de páginas e linhas acessadas, a seletividade e o custo total importam. Os percentuais de custo no desenho do plano são estimativas relativas, **não tempos reais**.

### 7.2 Leituras lógicas e tempo

Ative as duas medidas e execute cada `SELECT` separadamente:

```sql
USE INDICES_LOJA;
GO
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO
-- Execute aqui a consulta que deseja analisar.
-- Leia as informacoes na guia Messages.
```

Ao terminar:

```sql
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

Em **Messages**, `logical reads` corresponde a acessos lógicos a páginas; `physical reads`, a leituras físicas; `CPU time`, ao tempo de processamento; e `elapsed time`, ao tempo decorrido, que também sofre influência de outros fatores. A contagem de `scan count` **não é o número de linhas nem o número de páginas lidas**. Os números obtidos variam conforme ambiente, versão, estatísticas, cache, paralelismo e plano escolhido.

**Procedimento de comparação:** execute a mesma consulta antes e depois da alteração, registre as leituras lógicas e observe os operadores. Para comparar tempos, repita a execução algumas vezes e desconsidere conclusões baseadas apenas numa primeira execução ou numa diferença de poucos milissegundos. Não use limpeza de cache ou comandos globais em servidores compartilhados.

## 8. Demonstrações orientadas

### Demonstração A — busca por uma data (índice simples)

**Problema:** localizar identificadores de pedidos de um único dia.

**Antes do índice:** o script de exemplos remove o índice da demonstração, caso exista. Assim, não é necessário recriar todo o banco para repetir esse teste:

```sql
SELECT PedidoID, DataPedido
FROM dbo.Pedido
WHERE DataPedido = '20240115';
```

Ative o plano de execução com `Ctrl+M` e as opções `STATISTICS IO` e `STATISTICS TIME`. Como não há índice secundário por data, espera-se uma varredura da estrutura clusterizada. Registre as leituras lógicas e o operador real.

**Crie o índice e execute exatamente a mesma consulta:**

```sql
CREATE NONCLUSTERED INDEX IX_Pedido_DataPedido
ON dbo.Pedido (DataPedido);

SELECT PedidoID, DataPedido
FROM dbo.Pedido
WHERE DataPedido = '20240115';
```

Espera-se que a busca seletiva possa ser atendida por um `Index Seek`, com menos leituras lógicas. A PK clusterizada integra o localizador do índice não clusterizado, de modo que, nesse caso, também é possível recuperar `PedidoID` diretamente. **Não atribua números de desempenho antes de medir.**

**Interpretação guiada:** o que mudou no plano? Quantas páginas foram acessadas? O índice serviu para localizar uma pequena parte dos registros ou para ler grande parte da tabela?

### Demonstração B — índice composto e cobertura

**Problema:** consultar pedidos de um cliente, em um período, exibindo valor e status.

```sql
SELECT PedidoID, ClienteID, DataPedido, StatusPedido, ValorTotal
FROM dbo.Pedido
WHERE ClienteID = 1234
  AND DataPedido >= '20240101'
  AND DataPedido < '20250101';
```

Execute primeiro com apenas o índice secundário em `DataPedido` criado na demonstração A. O SQL Server pode optar por diferentes planos; registre o real. Para investigar a necessidade de buscar colunas adicionais, crie inicialmente um índice composto sem `INCLUDE`:

```sql
CREATE NONCLUSTERED INDEX IX_Pedido_Cliente_Data
ON dbo.Pedido (ClienteID, DataPedido);
```

Execute novamente a consulta e observe se o plano utiliza `Key Lookup`. Como o filtro por cliente costuma retornar poucas linhas, esse operador pode ser aceitável. Agora substitua o índice por uma versão que também armazene as colunas exibidas:

```sql
DROP INDEX IX_Pedido_Cliente_Data ON dbo.Pedido;

CREATE NONCLUSTERED INDEX IX_Pedido_Cliente_Data_Cobertura
ON dbo.Pedido (ClienteID, DataPedido)
INCLUDE (StatusPedido, ValorTotal);
```

Execute novamente a consulta. Com as colunas necessárias disponíveis no índice, é plausível observar `Index Seek` sem `Key Lookup`. O objetivo é relacionar filtro, ordem das chaves, projeção e leituras lógicas, não simplesmente obter um nome de operador.

### Demonstração C — índice adequado não resolve tudo

**Problema:** comparar duas maneiras de solicitar pedidos de 2024.

```sql
-- Consulta 1: aplica uma funcao sobre a coluna filtrada.
SELECT COUNT(*) AS Total
FROM dbo.Pedido
WHERE YEAR(DataPedido) = 2024;

-- Consulta 2: utiliza um intervalo diretamente na coluna.
SELECT COUNT(*) AS Total
FROM dbo.Pedido
WHERE DataPedido >= '20240101'
  AND DataPedido < '20250101';
```

Ambas devem retornar a mesma contagem nesse banco. Compare o plano e as leituras de cada uma. O predicado de intervalo é geralmente mais favorável ao uso de um acesso por chave, pois não precisa calcular `YEAR` para avaliar cada valor. Ainda assim, dada a quantidade de pedidos de um ano inteiro, o otimizador pode preferir varreduras de índice; a medida é indispensável. Introduzimos aqui o conceito de **predicado sargable**: uma condição que favorece localizar intervalos de chaves por um índice, em vez de calcular a condição para cada registro.

### Demonstração D — baixa seletividade e escolha do otimizador

**Problema:** investigar se um índice em uma coluna com valores muito repetidos é sempre vantajoso. Na tabela de pedidos, a maior parte das linhas possui `StatusPedido = 'Entregue'`.

Primeiro, observe a distribuição dos valores e meça uma consulta de contagem sem índice por status:

```sql
SELECT StatusPedido, COUNT(*) AS Quantidade
FROM dbo.Pedido
GROUP BY StatusPedido;

SELECT COUNT(*) AS TotalEntregues
FROM dbo.Pedido
WHERE StatusPedido = 'Entregue';
```

Agora crie o índice e repita **a consulta de contagem**:

```sql
CREATE NONCLUSTERED INDEX IX_Pedido_StatusPedido
ON dbo.Pedido (StatusPedido);

SELECT COUNT(*) AS TotalEntregues
FROM dbo.Pedido
WHERE StatusPedido = 'Entregue';
```

Mesmo com baixa seletividade, um índice estreito pode melhorar uma contagem por permitir ler menos páginas. Isso **não significa** que o índice ajudará igualmente uma consulta que solicite muitas outras colunas da tabela. No arquivo de exemplos há também uma consulta que retorna `ValorTotal` e `Observacao`: compare seu plano, considerando que ela pode devolver um grande volume de linhas e sobrecarregar a grade de resultados do SSMS.

**Para refletir:** por que o índice pode ser útil para `COUNT(*)` e não trazer o mesmo benefício ao recuperar o conteúdo completo de milhares de pedidos?

## 9. Atividade prática

Resolva os **três exercícios do arquivo separado** [`Exercicios_Indices.md`](Exercicios_Indices.md). Cada resposta deve incluir SQL, plano observado e valores medidos. Não basta afirmar que um índice “melhorou”: é necessário indicar **qual medida mudou** e se o custo adicional de manutenção parece justificado.

## 10. Síntese

Ao concluir o tutorial, retome as três ideias centrais: (1) índices oferecem caminhos alternativos de acesso, mas o otimizador escolhe o plano; (2) ordem das chaves, seletividade e colunas retornadas determinam a utilidade; (3) `Execution Plan`, `STATISTICS IO` e `STATISTICS TIME` permitem verificar resultados, sem reduzir desempenho a uma única medida.

**Verifique sua compreensão:** por que um índice em uma coluna pode existir e mesmo assim não ser utilizado por determinada consulta?

## 11. Referências técnicas

- [Microsoft Learn — SQL Server: Index architecture and design guide](https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide?view=sql-server-ver16)
- [Microsoft Learn — CREATE INDEX (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-index-transact-sql?view=sql-server-ver16)
- [Microsoft Learn — Display an Actual Execution Plan](https://learn.microsoft.com/en-us/sql/relational-databases/performance/display-an-actual-execution-plan?view=sql-server-ver16)
- [Microsoft Learn — SET STATISTICS IO](https://learn.microsoft.com/pt-br/sql/t-sql/statements/set-statistics-io-transact-sql?view=sql-server-ver16)
- [Microsoft Learn — SET STATISTICS TIME](https://learn.microsoft.com/pt-br/sql/t-sql/statements/set-statistics-time-transact-sql?view=sql-server-ver16)
- [Repositório da disciplina — Aula 12: Índices](https://github.com/Herysson/Implementacao-de-Banco-de-Dados/blob/main/Aula%2012%20-%20%C3%8Dndices.md)

> Os scripts foram revisados em termos de sintaxe e coerência estrutural, mas **não foram executados em uma instância SQL Server neste ambiente**. Os planos e tempos descritos são expectativas a confirmar no laboratório.
