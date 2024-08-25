# Banco de Dados Ativos


## 1. Introdução

Nesta aula, vamos explorar conceitos fundamentais para a criação de procedimentos armazenados e scripts no SQL Server, abordando o uso de variáveis, conversões de dados, estruturas condicionais e loops. Essas ferramentas são essenciais para o desenvolvimento de bancos de dados ativos, onde a lógica de negócios pode ser incorporada diretamente no banco de dados, aumentando a eficiência e o controle sobre as operações.

### O que são Bancos de Dados Ativos?

Bancos de dados ativos são sistemas de gerenciamento de banco de dados que possuem a capacidade de reagir automaticamente a certos eventos ou condições definidas pelos usuários. Diferente dos bancos de dados tradicionais, onde as operações são executadas apenas quando explicitamente acionadas por comandos SQL, os bancos de dados ativos incorporam lógica reativa dentro do próprio sistema de gerenciamento de banco de dados (SGBD).

A reatividade dos bancos de dados ativos é geralmente implementada através de:

1. **Gatilhos (Triggers):** São regras que especificam uma ação a ser executada automaticamente quando um evento específico ocorre em uma tabela. Por exemplo, um gatilho pode ser configurado para disparar uma ação quando um registro é inserido, atualizado ou excluído.

2. **Regras Ativas:** Regras que consistem em um evento, uma condição e uma ação (frequentemente referenciadas como ECA - Event-Condition-Action). Quando o evento ocorre, a condição é avaliada, e se for verdadeira, a ação é executada automaticamente.

3. **Restrições e Validações:** Algumas restrições em bancos de dados, como chaves estrangeiras ou verificações de integridade, podem ser vistas como um tipo de lógica reativa onde o banco de dados impõe automaticamente certas regras para garantir a consistência dos dados.

### Benefícios dos Bancos de Dados Ativos

- **Automação:** Reduz a necessidade de intervenção manual para monitorar e gerenciar dados, pois muitas ações podem ser automatizadas.
- **Consistência:** Garante que as regras de negócio sejam aplicadas de maneira uniforme e consistente em todo o sistema.
- **Eficiência:** Reduz a sobrecarga da aplicação ao mover parte da lógica de negócio para o banco de dados, evitando a necessidade de consultas adicionais para verificar ou aplicar regras.
- **Segurança:** Regras ativas podem ajudar a proteger a integridade dos dados e a aplicar políticas de segurança de forma consistente.

### Exemplos de Aplicações de Bancos de Dados Ativos

- **Monitoramento de Fraudes:** Um banco de dados ativo pode monitorar transações em tempo real e, automaticamente, disparar alertas ou bloquear atividades suspeitas.
- **Manutenção de Inventário:** Gatilhos podem ser utilizados para atualizar automaticamente os níveis de estoque quando itens são vendidos ou devolvidos.
- **Gestão de Processos de Negócio:** Regras ativas podem ser usadas para gerenciar fluxos de trabalho complexos, garantindo que todos os passos sejam seguidos conforme especificado.

## 2. Variáveis no SQL Server

### 2.1 Declaração de Variáveis

No SQL Server, variáveis são utilizadas para armazenar valores temporários que podem ser manipulados durante a execução de um bloco de código. Para declarar uma variável, utilizamos a palavra-chave `DECLARE`.

```sql
DECLARE @NomeVariavel TipoDeDado;
```

**Exemplo:**

```sql
DECLARE @Nome VARCHAR(50);
DECLARE @Idade INT;
```

### 2.2 Atribuição de Valores

Atribuir valores a variáveis pode ser feito usando a instrução `SET` ou como parte de uma instrução `SELECT`.

**Exemplo:**

```sql
SET @Nome = 'João';
SET @Idade = 30;

-- Ou com SELECT
SELECT @Nome = 'Maria', @Idade = 25;
```

### 2.3 Exibir Valores

Para visualizar o valor de uma variável, podemos utilizar o comando `PRINT` ou incluir a variável em uma instrução `SELECT`.

**Exemplo:**

```sql
PRINT @Nome;
SELECT @Nome, @Idade;
```

## 3. Conversão de Dados

### 3.1 CAST

A função `CAST` é utilizada para converter um tipo de dado em outro. É útil quando precisamos garantir que os dados estão no formato correto antes de realizar operações.

**Exemplo:**

```sql
SELECT CAST('2024-08-12' AS DATETIME) AS DataConvertida;
```

### 3.2 CONVERT

A função `CONVERT` oferece funcionalidades similares ao `CAST`, mas com maior flexibilidade para definir o formato de saída.

**Exemplo:**

```sql
SELECT CONVERT(VARCHAR(10), GETDATE(), 103) AS DataFormatada;  -- Saída: '12/08/2024'
```

## 4. Estruturas Condicionais no SQL

### 4.1 IF / ELSE

As estruturas condicionais permitem executar blocos de código diferentes com base em condições específicas.

**Exemplo:**

```sql
DECLARE @Valor INT = 10;

IF @Valor > 5
    PRINT 'O valor é maior que 5';
ELSE
    PRINT 'O valor é 5 ou menor';
```

### 4.2 `CASE`

O comando `CASE` no SQL é usado para realizar comparações condicionais e retornar valores baseados em diferentes condições. Ele é similar a uma estrutura `IF / ELSE` encontrada em linguagens de programação tradicionais, mas é aplicado dentro de consultas SQL. O `CASE` permite que você verifique várias condições e, dependendo de qual delas é verdadeira, retorna um valor específico. Se nenhuma das condições for verdadeira, um valor padrão pode ser retornado usando a cláusula `ELSE`.

```sql
CASE
    WHEN condição1 THEN valor1
    WHEN condição2 THEN valor2
    ...
    ELSE valor_default
END
```

- **`WHEN condição1 THEN valor1`**: Se a `condição1` for verdadeira, o `valor1` é retornado.
- **`ELSE valor_default`**: (Opcional) Se nenhuma das condições for verdadeira, `valor_default` é retornado.
- **`END`**: Marca o fim da expressão `CASE`.

### Exemplos Simples

#### Exemplo 1: Classificação de Salários

Vamos supor que você tem uma tabela `Funcionarios` com uma coluna `salario`. Você quer classificar os funcionários em categorias de "Alto", "Médio", ou "Baixo" com base no salário.

```sql
SELECT nome, 
       salario,
       CASE 
           WHEN salario > 5000 THEN 'Alto'
           WHEN salario BETWEEN 2500 AND 5000 THEN 'Médio'
           ELSE 'Baixo'
       END AS Categoria_Salario
FROM Funcionarios;
```

**Explicação**: 
- Se o salário for maior que 5000, a coluna `Categoria_Salario` retornará "Alto".
- Se o salário estiver entre 2500 e 5000, retornará "Médio".
- Se nenhuma dessas condições for atendida (ou seja, o salário é menor que 2500), retornará "Baixo".

#### Exemplo 2: Verificação de Admissão Recente

Você deseja saber se os funcionários foram admitidos nos últimos 6 meses.

```sql
SELECT nome,
       data_admissao,
       CASE 
           WHEN DATEDIFF(CURRENT_DATE, data_admissao) <= 180 THEN 'Recém-admitido'
           ELSE 'Admitido há mais de 6 meses'
       END AS Status
FROM Funcionarios;
```

**Explicação**:
- Se a diferença entre a data atual e a data de admissão for menor ou igual a 180 dias, a coluna `Status` retornará "Recém-admitido".
- Caso contrário, retornará "Admitido há mais de 6 meses".

#### Exemplo 3: Conversão de Notas para Conceitos
Suponha que você tenha uma tabela `Estudantes` com uma coluna `nota`. Você deseja converter as notas numéricas em conceitos (A, B, C, D, F).

```sql
SELECT nome, 
       nota,
       CASE 
           WHEN nota >= 90 THEN 'A'
           WHEN nota >= 80 THEN 'B'
           WHEN nota >= 70 THEN 'C'
           WHEN nota >= 60 THEN 'D'
           ELSE 'F'
       END AS Conceito
FROM Estudantes;
```

**Explicação**:
- Se a `nota` for 90 ou mais, o conceito será "A".
- Se estiver entre 80 e 89, será "B".
- Se estiver entre 70 e 79, será "C".
- Se estiver entre 60 e 69, será "D".
- Se a `nota` for menor que 60, será "F".

## 5. Loops no SQL

### 5.1 `WHILE` Loop

O comando `WHILE` é a principal estrutura de laço de repetição no SQL Server. Ele repete um bloco de código enquanto uma condição especificada for verdadeira.

#### Sintaxe:

```sql
WHILE condição
BEGIN
    -- Bloco de código a ser repetido
END
```

#### Exemplo:

```sql
DECLARE @contador INT = 1;

WHILE @contador <= 10
BEGIN
    PRINT 'Contador: ' + CAST(@contador AS VARCHAR);
    SET @contador = @contador + 1;
END
```

**Explicação**: 
- Neste exemplo, o bloco de código dentro do `WHILE` será repetido enquanto a variável `@contador` for menor ou igual a 10. A cada iteração, o valor de `@contador` é incrementado em 1.

#### 5.1.2. `BREAK` e `CONTINUE`

Embora não sejam laços de repetição por si só, `BREAK` e `CONTINUE` são comandos que controlam o fluxo de execução dentro de um laço `WHILE`.

- **`BREAK`**: Sai imediatamente do laço `WHILE`, interrompendo a repetição.
  
- **`CONTINUE`**: Pula o restante do código na iteração atual e retorna ao início do laço `WHILE`, verificando a condição novamente.

#### Exemplo com `BREAK`:

```sql
DECLARE @contador INT = 1;

WHILE @contador <= 10
BEGIN
    IF @contador = 5
        BREAK;

    PRINT 'Contador: ' + CAST(@contador AS VARCHAR);
    SET @contador = @contador + 1;
END
```

**Explicação**:
- Quando o valor de `@contador` chega a 5, o comando `BREAK` é executado, e o laço é interrompido imediatamente.

#### Exemplo com `CONTINUE`:

```sql
DECLARE @contador INT = 1;

WHILE @contador <= 10
BEGIN
    SET @contador = @contador + 1;

    IF @contador % 2 = 0
        CONTINUE;

    PRINT 'Contador: ' + CAST(@contador AS VARCHAR);
END
```

**Explicação**:
- Neste exemplo, o laço imprime apenas os valores ímpares de `@contador`. Se o valor for par, o `CONTINUE` faz com que o restante do bloco seja ignorado e o laço continue para a próxima iteração.

### 5.3. Cursores (Cursors)

Embora não sejam laços de repetição tradicionais, cursores permitem a iteração linha por linha em um conjunto de resultados. Eles são usados em situações onde você precisa processar cada linha de uma consulta individualmente.

#### Exemplo de Cursor:

```sql
DECLARE @nome NVARCHAR(50);

DECLARE cursorFuncionarios CURSOR FOR
SELECT nome FROM Funcionarios;

OPEN cursorFuncionarios;

FETCH NEXT FROM cursorFuncionarios INTO @nome;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @nome;
    FETCH NEXT FROM cursorFuncionarios INTO @nome;
END;

CLOSE cursorFuncionarios;
DEALLOCATE cursorFuncionarios;
```

**Explicação**:
- Esse exemplo cria um cursor que itera sobre todos os nomes dos funcionários, processando cada linha de forma sequencial.

### Resumo

- **`WHILE`**: É o laço de repetição padrão em SQL Server, que repete um bloco de código enquanto uma condição for verdadeira.
- **`BREAK` e `CONTINUE`**: Comandos de controle de fluxo usados dentro de um laço `WHILE`.
- **Cursores**: Usados para iterar sobre um conjunto de resultados linha por linha.

Estes são os principais mecanismos de repetição e controle de fluxo disponíveis no SQL Server.

## 6. Exemplos em SQL

### 6.1 Exemplo Completo: Procedimento Armazenado com Estruturas Condicionais e Loop

```sql
CREATE PROCEDURE CalcularMedia
    @Nota1 INT,
    @Nota2 INT,
    @Nota3 INT,
    @MediaSaida FLOAT OUTPUT
AS
BEGIN
    DECLARE @Soma INT;
    SET @Soma = @Nota1 + @Nota2 + @Nota3;

    IF @Soma > 0
        SET @MediaSaida = CAST(@Soma AS FLOAT) / 3;
    ELSE
        SET @MediaSaida = 0;

    PRINT 'A média das notas é: ' + CAST(@MediaSaida AS VARCHAR(10));
END
```

**Execução:**

```sql
DECLARE @Resultado FLOAT;

EXEC CalcularMedia 85, 90, 78, @MediaSaida = @Resultado OUTPUT;

SELECT @Resultado AS MediaCalculada;
```

## Exercícios

#### 1. **Variáveis no SQL Server**
   1.1. **Declaração de Variáveis**  
   Declare três variáveis no SQL Server: uma para armazenar o nome de um produto (tipo `VARCHAR`), outra para armazenar a quantidade em estoque (tipo `INT`) e a última para armazenar o preço do produto (tipo `DECIMAL(10,2)`).

   1.2. **Atribuição de Valores**  
   Atribua os seguintes valores às variáveis declaradas:
   - Nome do Produto: "Notebook"
   - Quantidade em Estoque: 15
   - Preço do Produto: 2999.99

   1.3. **Exibição de Valores**  
   Exiba os valores atribuídos às variáveis utilizando tanto o comando `PRINT` quanto o comando `SELECT`.

   1.4. **Cálculo utilizando Variáveis**  
   Declare três variáveis: `@SalarioBase` (tipo `DECIMAL(10,2)`), `@Bonus` (tipo `DECIMAL(10,2)`) e `@SalarioTotal` (tipo `DECIMAL(10,2)`). Atribua valores de 5000.00 e 800.00 às variáveis `@SalarioBase` e `@Bonus`, respectivamente. Em seguida, calcule o valor total do salário somando `@SalarioBase` e `@Bonus` e armazene o resultado em `@SalarioTotal`. Exiba o valor de `@SalarioTotal`.

Essas questões adicionais aprofundam a compreensão dos tópicos abordados, oferecendo uma prática extra para manipulação de variáveis, conversões, estruturas condicionais e loops no SQL Server.

#### 2. **Conversão de Dados**
   2.1. **CAST**  
   Converta a data atual (`GETDATE()`) para o formato `VARCHAR(10)` utilizando a função `CAST` e exiba o resultado.

   2.2. **CONVERT**  
   Converta o número 12345.67 para o tipo `INT` utilizando a função `CONVERT` e exiba o resultado.

   2.3. **Exercício Prático**  
   Crie uma variável para armazenar um número decimal e outra para armazenar um número inteiro. Atribua valores a essas variáveis e utilize `CAST` e `CONVERT` para converter o decimal para inteiro e vice-versa, exibindo os resultados.

   2.4. **Conversão de String para Data**  
   Declare uma variável `@DataNascimento` do tipo `VARCHAR(10)` e atribua a ela o valor '15/08/1990'. Em seguida, converta essa variável para o tipo `DATE` utilizando a função `CONVERT` e exiba o resultado.


#### 3. **Estruturas Condicionais no SQL**
   3.1. **IF / ELSE Básico**  
   Crie uma variável chamada `@Idade` e atribua a ela um valor inteiro. Escreva um bloco `IF / ELSE` que exiba "Maior de Idade" se a idade for maior ou igual a 18, e "Menor de Idade" caso contrário.

   3.2. **IF / ELSE com Múltiplas Condições**  
   Crie uma variável chamada `@NotaFinal` e atribua um valor entre 0 e 100. Utilize um bloco `IF / ELSE` para exibir as seguintes mensagens baseadas no valor da nota:
   - Nota >= 90: "Aprovado com Excelência"
   - Nota >= 70 e < 90: "Aprovado"
   - Nota >= 50 e < 70: "Em Recuperação"
   - Nota < 50: "Reprovado"

  3.3. **IF / ELSE com Operadores Lógicos**  
   Crie uma variável `@Ano` do tipo `INT` e atribua a ela um valor. Escreva um bloco `IF / ELSE` que exiba "Ano Bissexto" se o ano for divisível por 4, mas não divisível por 100, ou se for divisível por 400. Caso contrário, exiba "Ano Comum".


#### 4. **Loops no SQL**
   4.1. **While Simples**  
   Crie um loop `WHILE` que exiba os números de 1 a 10, incrementando uma variável chamada `@Contador` a cada iteração.

   4.2. **While com Condição Complexa**  
   Escreva um loop `WHILE` que comece com uma variável `@Valor` igual a 100 e a cada iteração subtraia 5 de `@Valor`. O loop deve continuar até que `@Valor` seja menor que 50. Exiba o valor de `@Valor` a cada iteração.

   4.3. **Exercício Prático**  
   Crie um loop `WHILE` que percorra uma lista de produtos armazenada em uma tabela chamada `Produtos` e exiba o nome de cada produto cujo preço seja maior que 100. Utilize uma variável `@Indice` para controlar o loop e uma variável `@PrecoLimite` para armazenar o valor de 100.

   4.4. **Loop While com Incremento Condicional**  
   Crie uma variável `@Numero` com valor inicial igual a 2. Escreva um loop `WHILE` que continue a dobrar o valor de `@Numero` até que ele ultrapasse 1000. Exiba o valor de `@Numero` a cada iteração.


#### 5. **Exercício de Integração - DESAFIO**
   5.1. **Procedimento Armazenado com Variáveis, Condicional e Loop**
   Crie um procedimento armazenado chamado `CalcularDesconto` que:
   - Receba como parâmetros o preço original de um produto e a quantidade comprada.
   - Calcule o desconto baseado na quantidade comprada (10% de desconto se a quantidade for maior que 10).
   - Retorne o preço final após o desconto.
   - Utilize variáveis para armazenar o preço original, a quantidade, o desconto e o preço final.
   - Utilize um bloco `IF / ELSE` para determinar o desconto.
   - Se a quantidade comprada for menor que 5, utilize um loop `WHILE` para aplicar um desconto adicional de 1% por unidade acima de 1, até atingir a quantidade comprada.



## Referências do Material Apresentado

1. **Elmasri, R., & Navathe, S. B. (2015). *Fundamentals of Database Systems* (7th Edition).** Este livro oferece uma visão abrangente sobre os conceitos de bancos de dados, incluindo uma seção dedicada a bancos de dados ativos e o uso de gatilhos.
   
2. **Garcia-Molina, H., Ullman, J. D., & Widom, J. (2008). *Database Systems: The Complete Book* (2nd Edition).** Neste livro, os autores discutem os princípios dos sistemas de banco de dados, com um foco específico em mecanismos de triggers e regras ativas.

3. **Gray, J., & Reuter, A. (1993). *Transaction Processing: Concepts and Techniques*.** Este livro detalha técnicas de processamento de transações em bancos de dados, com uma cobertura sobre como bancos de dados ativos podem ser utilizados para melhorar a gestão de transações.

4. **Chakravarthy, S., & Mishra, D. (1994). *Snoop: An Expressive Event Specification Language for Active Databases*.** Um artigo que apresenta a linguagem Snoop, projetada para especificar eventos complexos em bancos de dados ativos, oferecendo uma visão sobre as técnicas avançadas para gerenciamento de eventos.
