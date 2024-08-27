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

**Exemplo 1:**

```sql
DECLARE @Nome VARCHAR(50);
DECLARE @Idade INT;
```

**Exemplo 2:**

```sql
DECLARE @TabelaAlunos TABLE (
    Numero_aluno INT PRIMARY KEY,
    Nome NVARCHAR(50),
    Tipo_aluno INT,
    Curso NVARCHAR(2)
);

-- Inserindo dados na tabela em memória
INSERT INTO @TabelaAlunos (Numero_aluno, Nome, Tipo_aluno, Curso)
VALUES 
(1, 'Silva', 1, 'CC'),
(2, 'Braga', 2, 'CC');

-- Selecionando dados da tabela em memória
SELECT * FROM @TabelaAlunos;
```

**Uso Comum de Tabelas Declaradas**

As tabelas declaradas com `DECLARE @TabelaAlunos TABLE (...)` são especialmente úteis quando você precisa armazenar resultados intermediários ou trabalhar com pequenos conjuntos de dados temporariamente durante a execução de um script ou procedimento armazenado. Essas tabelas são descartadas automaticamente quando a sessão ou o bloco de código termina.

**Limitações**

- Essas tabelas só existem na memória durante a execução da sessão ou script em que foram declaradas.
- Elas não podem ser indexadas com índices não-clustered, mas suportam índices clusterizados via chave primária.
- Não podem ser referenciadas fora do bloco onde foram declaradas.


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

Claro! A seguir, apresento exemplos de utilização dos comandos `DECLARE`, `SET` e `SELECT` no SQL Server para definir valores a variáveis, utilizando o banco de dados EMPRESA. Supondo que o banco de dados possua tabelas como `Funcionarios`, `Departamentos`, e `Projetos`, os exemplos abaixo demonstram como declarar variáveis, atribuir valores a elas e utilizá-las em consultas.


### 2.4 Exemplos

#### Exemplo: Obter o número total de funcionários

```sql
-- Declara a variável para armazenar o total de funcionários
DECLARE @TotalFuncionarios INT;

-- Atribui o valor à variável usando SET
SET @TotalFuncionarios = (SELECT COUNT(*) FROM Funcionarios);

-- Exibe o valor da variável
SELECT @TotalFuncionarios AS TotalFuncionarios;
```

**Explicação:**
- `DECLARE` cria uma variável chamada `@TotalFuncionarios` do tipo inteiro.
- `SET` atribui à variável o resultado da contagem de todos os registros na tabela `Funcionarios`.
- O `SELECT` final exibe o valor armazenado na variável.

#### Exemplo: Obter o nome de um departamento específico

```sql
-- Declara a variável para armazenar o nome do departamento
DECLARE @NomeDepartamento VARCHAR(50);

-- Atribui o valor à variável usando SELECT
SELECT @NomeDepartamento = NomeDepartamento
FROM Departamentos
WHERE DepartamentoID = 2;

-- Exibe o valor da variável
SELECT @NomeDepartamento AS NomeDepartamento;
```

**Explicação:**
- `DECLARE` cria uma variável chamada `@NomeDepartamento` do tipo `VARCHAR`.
- `SELECT` atribui à variável o valor de `NomeDepartamento` onde o `DepartamentoID` é 2.
- O `SELECT` final exibe o valor armazenado na variável.


#### Exemplo: Obter detalhes de um funcionário específico

```sql
-- Declara as variáveis
DECLARE @FuncionarioID INT;
DECLARE @PrimeiroNome VARCHAR(50);
DECLARE @UltimoNome VARCHAR(50);
DECLARE @Salario DECIMAL(10,2);

-- Define o ID do funcionário usando SET
SET @FuncionarioID = 1001;

-- Recupera os detalhes do funcionário usando SELECT
SELECT 
    @PrimeiroNome = PrimeiroNome,
    @UltimoNome = UltimoNome,
    @Salario = Salario
FROM Funcionarios
WHERE FuncionarioID = @FuncionarioID;

-- Exibe os valores das variáveis
SELECT 
    @FuncionarioID AS FuncionarioID,
    @PrimeiroNome AS PrimeiroNome,
    @UltimoNome AS UltimoNome,
    @Salario AS Salario;
```

**Explicação:**
- `DECLARE` cria quatro variáveis para armazenar diferentes informações do funcionário.
- `SET` atribui o valor `1001` à variável `@FuncionarioID`.
- `SELECT` recupera `PrimeiroNome`, `UltimoNome` e `Salario` da tabela `Funcionarios` onde o `Funcionario


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

### 3.3 Exemplos
Aqui estão exemplos de uso de `CAST` e `CONVERT` adaptados para o banco de dados `EMPRESA`, utilizando a tabela `Funcionarios`:

### Exemplo 1: Usando `CAST`

```sql
-- Usando CAST para converter o salário decimal em uma string
SELECT	'O funcionário ' 
		+ Nome 
		+ ' tem um salário de: R$ ' 
		+ CAST(Salario AS VARCHAR(20)) AS 'Nome / Salário'
FROM Funcionarios;
```

**Explicação:**
- Aqui, o `CAST` está sendo utilizado para converter o campo `Salario`, que é do tipo `DECIMAL`, para `VARCHAR`, permitindo concatenar essa informação em uma string.

### Exemplo 2: Usando `CONVERT`

```sql
-- Usando CONVERT para converter o salário decimal em uma string
SELECT	'O funcionário ' 
		+ Nome 
		+ ' tem um salário de: R$ ' 
		+ CONVERT(VARCHAR(20), Salario) AS 'Nome / Salário'
FROM Funcionarios;
```

**Explicação:**
- Esse exemplo é similar ao anterior, mas usa `CONVERT` para realizar a conversão do salário de `DECIMAL` para `VARCHAR`.

### Exemplo 3: Usando `CONVERT` com Estilo

```sql
-- Usando CONVERT para formatar a data de nascimento no formato DD/MM/YYYY
SELECT	'O funcionário '
		+ Nome
		+ ' nasceu em: '
		+ CONVERT(VARCHAR(10), Data_Nasc, 103) AS 'Nome / Data de Nascimento'
FROM Funcionarios;
```

**Explicação:**
- Aqui, `CONVERT` é usado para formatar a data de nascimento (`Data_Nasc`) no formato `DD/MM/YYYY` (estilo 103). Isso facilita a leitura da data em um formato comum.

### Exemplo 4: Usando `CAST` em um Cálculo

```sql
-- Usando CAST para converter o resultado de um cálculo de idade em uma string
DECLARE @Ano_Atual INT = 2024;

SELECT	'O funcionário ' 
		+ Nome 
		+ ' tem ' 
		+ CAST(@Ano_Atual - YEAR(Data_Nasc) AS VARCHAR(3)) 
		+ ' anos.' AS 'Nome / Idade'
FROM Funcionarios;
```

**Explicação:**
- Neste exemplo, `CAST` converte o resultado do cálculo de idade (`@Ano_Atual - YEAR(Data_Nasc)`) para `VARCHAR`, permitindo a inclusão da idade em uma string.

Esses exemplos mostram como `CAST` e `CONVERT` podem ser usados para manipular e formatar dados no banco de dados `EMPRESA`, de maneira similar aos exemplos fornecidos, mas adaptados ao contexto dos funcionários.

#### Exemplo 5: Conversão de Dados com `CONVERT` (Data)
```sql
-- Exemplo 2: Convertendo a data de contratação para diferentes formatos de string
DECLARE @Datanasc DATETIME;
SET @Datanasc = (SELECT Datanasc FROM FUNCIONARIO WHERE cpf = '88866555576');

-- Convertendo para o formato DD/MM/YYYY
SELECT CONVERT(NVARCHAR(10), @HireDate, 103) AS 'Data no formato DD/MM/YYYY';

-- Convertendo para o formato MM-DD-YYYY
SELECT CONVERT(NVARCHAR(10), @HireDate, 110) AS 'Data no formato MM-DD-YYYY';

-- Convertendo para o formato YYYYMMDD
SELECT CONVERT(NVARCHAR(8), @HireDate, 112) AS 'Data no formato YYYYMMDD';
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

### Verificando se um Banco de Dados já Existe

Para verificar se um banco de dados já existe antes de criá-lo, você pode usar a seguinte estrutura:

```sql
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'NomeDoBancoDeDados')
BEGIN
    CREATE DATABASE NomeDoBancoDeDados;
END;
```

### Verificando se uma Tabela já Existe

Para verificar se uma tabela já existe antes de criá-la, use a seguinte estrutura:

```sql
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'NomeDaTabela') AND type in (N'U'))
BEGIN
    CREATE TABLE NomeDaTabela (
        -- Definição das colunas
    );
END;
```

### Exemplo Completo

Vamos supor que você queira criar um banco de dados chamado `MinhaEscola` e uma tabela chamada `Aluno`. Aqui está como você pode fazer isso, verificando se ambos já existem:

#### Verificando e Criando o Banco de Dados:

```sql
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MinhaEscola')
BEGIN
    CREATE DATABASE MinhaEscola;
END;
```

#### Verificando e Criando a Tabela `Aluno`:

```sql
USE MinhaEscola;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Aluno') AND type in (N'U'))
BEGIN
    CREATE TABLE Aluno (
        Numero_aluno INT PRIMARY KEY,
        Nome NVARCHAR(50),
        Tipo_aluno INT,
        Curso NVARCHAR(2)
    );
END;
```

### Explicação:

- **Verificação de Banco de Dados (`sys.databases`)**: A consulta `SELECT * FROM sys.databases WHERE name = 'NomeDoBancoDeDados'` verifica se um banco de dados com o nome especificado já existe. Se não existir (`IF NOT EXISTS`), o banco de dados será criado.
  
- **Verificação de Tabela (`sys.objects`)**: A consulta `SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'NomeDaTabela') AND type in (N'U')` verifica se uma tabela com o nome especificado já existe no banco de dados atual. A função `OBJECT_ID` retorna o ID do objeto (nesse caso, a tabela) se ele existir, e a condição `type in (N'U')` filtra para garantir que estamos verificando por tabelas de usuário (`U`).

Essa abordagem garante que o banco de dados e a tabela só serão criados se ainda não existirem, evitando erros ou duplicação de estruturas no seu banco de dados.

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
Para modificar as notas dos alunos e substituir as letras por valores numéricos com base na escala fornecida (A ≥ 90, B ≥ 80 e < 90, C ≥ 70 e < 80, D ≥ 60 e < 70), você pode seguir os passos abaixo:

**Atualizar a Tabela `HISTORICO_ESCOLAR`**

Primeiro, precisaremos modificar a estrutura da tabela `HISTORICO_ESCOLAR` para que a coluna `Nota` aceite valores numéricos em vez de caracteres.

**Alterando a coluna `Nota` para `INT`:**

```sql
ALTER TABLE HISTORICO_ESCOLAR
ALTER COLUMN Nota INT;
```

**Atualizar as Notas com Base nas Letras Originais**

Agora, você pode usar o comando `UPDATE` para modificar as notas conforme as regras especificadas:

```sql
UPDATE HISTORICO_ESCOLAR
SET Nota = CASE 
               WHEN Nota = 'A' THEN 90
               WHEN Nota = 'B' THEN 85
               WHEN Nota = 'C' THEN 75
               WHEN Nota = 'D' THEN 65
               ELSE 0
           END;
```

**Revisão das Regras de Mapeamento**

Aqui está como cada nota é mapeada:

- **A**: Transformado para **90** (ou maior).
- **B**: Transformado para **85** (valor central na faixa entre 80 e 89).
- **C**: Transformado para **75** (valor central na faixa entre 70 e 79).
- **D**: Transformado para **65** (valor central na faixa entre 60 e 69).
- **Notas diferentes de A, B, C, D**: Transformado para **0** (ou você pode definir qualquer outro valor padrão ou expandir a lógica do `CASE`).

**Verificando as Alterações**

Após a atualização, você pode verificar os resultados com uma consulta simples:

```sql
SELECT * FROM HISTORICO_ESCOLAR;
```
#### Exemplo 4: Calcular a idade do aluno utilizando
Para calcular a idade do aluno utilizando a tabela `@ALUNO`, você pode usar a função `DATEDIFF` em conjunto com `GETDATE()` para calcular a diferença entre a data atual e a data de nascimento do aluno. Abaixo está o exemplo de como fazer isso:

```sql
-- Declarando a tabela temporária @ALUNO
DECLARE @ALUNO TABLE(
	Id INT IDENTITY PRIMARY KEY,
	Nome VARCHAR(50),
	Data_Nasc DATE,
	Curso VARCHAR(2)
);

-- Inserindo dados na tabela @ALUNO
INSERT INTO @ALUNO 
VALUES ('Herysson R. Figueredo', '1988-06-07','SI');

-- Calculando a idade do aluno
DECLARE @Nome_Aluno VARCHAR(50),
        @Data_Nasc DATE,
        @Idade INT;

-- Atribuindo valores
SELECT @Nome_Aluno = Nome, @Data_Nasc = Data_Nasc
FROM @ALUNO
WHERE Nome = 'Herysson R. Figueredo';

-- Calculando a idade
SET @Idade = DATEDIFF(YEAR, @Data_Nasc, GETDATE()) - 
    CASE WHEN MONTH(@Data_Nasc) > MONTH(GETDATE()) OR 
              (MONTH(@Data_Nasc) = MONTH(GETDATE()) AND DAY(@Data_Nasc) > DAY(GETDATE())) 
         THEN 1 
         ELSE 0 
    END;

-- Exibindo o resultado
SELECT @Nome_Aluno AS 'Nome do Aluno', 
       @Idade AS 'Idade';
```

### Explicação:

1. **Tabela Temporária `@ALUNO`:**
   - Declaramos uma tabela temporária `@ALUNO` com as colunas `Id`, `Nome`, `Data_Nasc`, e `Curso`.

2. **Inserção de Dados:**
   - Inserimos um registro na tabela `@ALUNO` com o nome 'Herysson R. Figueredo' e a data de nascimento '1988-06-07'.

3. **Atribuição de Valores:**
   - Extraímos o nome e a data de nascimento do aluno e armazenamos nas variáveis `@Nome_Aluno` e `@Data_Nasc`.

4. **Cálculo da Idade:**
   - Utilizamos `DATEDIFF(YEAR, @Data_Nasc, GETDATE())` para calcular a diferença em anos entre a data de nascimento e a data atual.
   - Para ajustar o cálculo, subtraímos 1 ano se o mês e o dia de nascimento ainda não tiverem ocorrido no ano atual.

5. **Exibição do Resultado:**
   - Exibimos o nome do aluno e a idade calculada.

Esse método assegura que a idade seja calculada corretamente, considerando se o aniversário do aluno já passou ou não no ano corrente.

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
- `@@FETCH_STATUS` é uma função global do SQL Server que retorna o status da última operação de `FETCH` realizada em um cursor. Ele é usado principalmente em conjunto com cursores para controlar o fluxo de um laço que itera sobre um conjunto de resultados, garantindo que o laço continue enquanto ainda houver linhas a serem processadas.
- `@@FETCH_STATUS` é comumente utilizado dentro de um laço `WHILE` para iterar sobre todas as linhas em um cursor. O laço continua executando enquanto `@@FETCH_STATUS` retornar `0`, ou seja, enquanto o cursor conseguir recuperar linhas com sucesso.

**Valores Retornados por `@@FETCH_STATUS`**

`@@FETCH_STATUS` pode retornar três valores diferentes, cada um indicando o status da última operação de `FETCH`:

1. **0**: A última operação de `FETCH` foi bem-sucedida. Isso significa que a linha foi recuperada com sucesso do conjunto de resultados.
2. **-1**: A operação de `FETCH` falhou ou a linha solicitada não existe. Esse valor geralmente indica que o cursor atingiu o final do conjunto de resultados.
3. **-2**: A linha solicitada foi excluída ou perdeu a precisão devido a uma modificação externa (como uma alteração na tabela subjacente).

### Importância de `@@FETCH_STATUS`

- **Controle de Fluxo**: `@@FETCH_STATUS` é crucial para garantir que o laço que percorre um cursor termine corretamente quando todas as linhas forem processadas.
- **Erro no `FETCH`**: Se ocorrer algum problema durante a recuperação de uma linha, `@@FETCH_STATUS` indica isso, permitindo que você trate erros ou interrupções na execução.

Em resumo, `@@FETCH_STATUS` é uma função essencial para controlar laços que processam dados com cursores no SQL Server, garantindo que o código funcione corretamente até que todos os dados tenham sido processados.

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
