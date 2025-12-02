## **1. Índices**

**O que são índices?**  
Os índices em banco de dados são estruturas que otimizam o acesso e recuperação de dados em tabelas, de forma similar ao índice de um livro, que facilita encontrar um tópico específico.

**Para que servem?**  
- Melhorar a performance de consultas (principalmente SELECT).
- Acelerar operações de busca, como `WHERE`, `JOIN`, `ORDER BY`, e `GROUP BY`.

**Quando não usar índices?**
- Em tabelas com poucas linhas.
- Quando as operações de gravação (INSERT, UPDATE e DELETE) são muito frequentes e exigem alta performance.

---

## **2. Tipos de Índices**

1. **Índice Clustered (Clusterizado)**  
   - Organiza fisicamente os dados na tabela com base na chave do índice.  
   - Uma tabela só pode ter **um** índice clusterizado.

2. **Índice Non-clustered (Não Clusterizado)**  
   - Cria uma estrutura separada que aponta para as linhas da tabela original.  
   - Uma tabela pode ter vários índices não clusterizados.

---

## **3. Criação e Uso de Índices no SQL Server**

### **Criar uma tabela de exemplo**
```sql
CREATE TABLE Funcionarios (
    FuncionarioID INT PRIMARY KEY,
    Nome NVARCHAR(100),
    Cargo NVARCHAR(50),
    Salario DECIMAL(10, 2),
    DataAdmissao DATE
);
```

### **Criando índices**

1. **Índice Clusterizado (automático na PK)**  
   - Ao definir uma `PRIMARY KEY`, o SQL Server cria automaticamente um índice clusterizado.

2. **Índice Não Clusterizado**
```sql
CREATE NONCLUSTERED INDEX IX_Funcionarios_Nome 
ON Funcionarios (Nome);
```

3. **Índice em múltiplas colunas**
```sql
CREATE NONCLUSTERED INDEX IX_Funcionarios_Cargo_Salario
ON Funcionarios (Cargo, Salario);
```

4. **Índice Único**
```sql
CREATE UNIQUE INDEX IX_Funcionarios_CPF
ON Funcionarios (FuncionarioID);
```

---

## **4. Consultas Utilizando Índices**

### **Sem Índices**
```sql
SELECT * 
FROM Funcionarios
WHERE Nome LIKE 'João%';
```
- O SQL Server realiza uma busca **Full Scan** na tabela.

### **Com Índices**
```sql
SELECT * 
FROM Funcionarios
WHERE Nome = 'João da Silva';
```
- Utiliza o índice `IX_Funcionarios_Nome` para buscar diretamente.

### **Verificar o uso de índice**
```sql
SET STATISTICS IO ON;

SELECT * 
FROM Funcionarios
WHERE Nome = 'João da Silva';
```

---

## **5. Práticas**

1. **Criação de Índices**  
   - Crie um índice não clusterizado na tabela `Funcionarios` para a coluna `Cargo`.
   - Crie um índice que combine as colunas `Salario` e `DataAdmissao`.

2. **Consultas Otimizadas**
   - Utilize o índice criado na coluna `Cargo` para retornar todos os funcionários com o cargo "Analista".

3. **Comparação de Performance**
   - Execute a seguinte consulta antes e depois de criar índices:
```sql
SELECT * 
FROM Funcionarios
WHERE Salario > 5000;
```
   - Use `SET STATISTICS IO ON` para verificar o impacto na performance.

4. **Verificar Impacto em Escritas**
   - Insira 100.000 registros na tabela `Funcionarios` usando o seguinte script e observe o impacto na performance com índices ativos.
```sql
DECLARE @i INT = 1;

WHILE @i <= 100000
BEGIN
    INSERT INTO Funcionarios (FuncionarioID, Nome, Cargo, Salario, DataAdmissao)
    VALUES (@i, CONCAT('Funcionario ', @i), 'Analista', RAND() * 10000, GETDATE());

    SET @i = @i + 1;
END;
```

---


## **7. Atividade prática: Importando dados JSON e criando índices**

Nesta atividade, você irá:

* Importar dados a partir de um arquivo **JSON** para uma tabela no SQL Server.
* Executar consultas com **ORDER BY**.
* Criar **índices** adequados e comparar a performance das consultas **com e sem índices**.

O objetivo é entender, na prática, **quando faz sentido criar índices** em tabelas com muitos registros.

> O professor fornecerá um arquivo JSON com uma lista de pessoas, contendo campos como: `nome`, `cidade`, `estado` e `cpf`.

---

### **7.1. Criar a tabela de trabalho**

Crie uma tabela chamada `PessoasResumo` contendo apenas os campos relevantes para a atividade:

```sql
CREATE TABLE Pessoa (
    Id     INT IDENTITY(1,1) PRIMARY KEY,
    Nome   VARCHAR(150),
    Cidade VARCHAR(100),
    Estado CHAR(2),
    CPF    VARCHAR(14) -- formato: 000.000.000-00
);
```

---

### **7.2. Importar os dados a partir de um arquivo JSON**

Considere que o arquivo JSON (por exemplo: `pessoas.json`) está salvo em um local acessível ao SQL Server, e possui uma estrutura semelhante a:

```json
[
  {
    "nome": "Ana Silva",
    "cidade": "Santa Maria",
    "estado": "RS",
    "cpf": "000.000.000-00"
  },
  {
    "nome": "Bruno Souza",
    "cidade": "Porto Alegre",
    "estado": "RS",
    "cpf": "111.111.111-11"
  }
]
```

> Atenção: o arquivo deve estar em **UTF-8** para evitar problemas com acentuação.

Use o script abaixo para carregar o JSON em uma variável e, em seguida, inserir os dados na tabela:

```sql
DECLARE @json NVARCHAR(MAX);

SELECT @json = BulkColumn
FROM OPENROWSET(
        BULK 'C:\dados\pessoas.json',   -- ajuste o caminho conforme o seu ambiente
        SINGLE_CLOB,
        CODEPAGE = '65001'              -- UTF-8
     ) AS j;

INSERT INTO Pessoa (Nome, Cidade, Estado, CPF)
SELECT
    Nome,
    Cidade,
    Estado,
    CPF
FROM OPENJSON(@json)
WITH (
    Nome   VARCHAR(150) '$.nome',
    Cidade VARCHAR(100) '$.cidade',
    Estado CHAR(2)      '$.estado',
    CPF    VARCHAR(14)  '$.cpf'
);
```

Após a importação, confira:

```sql
SELECT TOP 10 *
FROM Pessoa;
```

---

### **7.3. Popular a tabela com muitos registros (simulação)**

Para simular um cenário com muitos dados (por exemplo, **300.000 registros**), você pode duplicar os dados várias vezes com um script de inserção em loop, se o professor julgar adequado.
*(Opcional — o professor pode fornecer um script pronto de carga em massa.)*

---

### **7.4. Consultas sem índices específicos**

Ative as estatísticas de tempo e IO para medir a performance **sem índices**:

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Nome, Cidade, Estado, CPF
FROM PessoasResumo
ORDER BY Nome, Estado;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

Anote:

* Tempo de execução (`elapsed time`).
* Leituras lógicas (`logical reads`) mostradas na aba **Messages**.

---

### **7.5. Criação de índices para otimizar a ordenação**

Agora, crie um índice **não clusterizado** que ajude nas consultas que ordenam por `Nome` e `Estado`.

#### Opção 1: índice focado em filtro por Estado e ordenação por Nome

Se você costuma filtrar por estado, por exemplo:

```sql
SELECT Nome, Cidade, Estado, CPF
FROM PessoasResumo
WHERE Estado = 'RS'
ORDER BY Nome, Estado;
```

crie o índice:

```sql
CREATE NONCLUSTERED INDEX IX_Pessoas_Estado_Nome
ON PessoasResumo (Estado, Nome);
```

#### Opção 2: índice focado apenas na ordenação global por Nome, Estado

Se a consulta mais comum é só:

```sql
SELECT Nome, Cidade, Estado, CPF
FROM PessoasResumo
ORDER BY Nome, Estado;
```

poderia ser usado:

```sql
CREATE NONCLUSTERED INDEX IX_Pessoas_Nome_Estado
ON PessoasResumo (Nome, Estado);
```

> Para a atividade, o professor pode indicar qual das duas opções utilizar ou pedir para os alunos testarem as duas e compararem.

---

### **7.6. Repetir as consultas e comparar a performance**

Repita as mesmas consultas da etapa 8.4, agora com o índice criado:

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Nome, Cidade, Estado, CPF
FROM PessoasResumo
ORDER BY Nome, Estado;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

Compare:

* O tempo de execução antes e depois do índice.
* As leituras lógicas (`logical reads`).

---

### **7.7. Entregáveis da atividade**

Cada grupo/aluno deve entregar:

1. **Scripts SQL**, contendo:

   * `CREATE TABLE` da tabela `PessoasResumo`.
   * Script de importação do JSON (`OPENROWSET` + `OPENJSON`).
   * Criação dos índices.
   * Consultas utilizadas para teste.

2. **Relatório curto (1–2 páginas)** respondendo:

   * O que aconteceu com o tempo de execução das consultas depois da criação do índice?
   * Houve redução no número de leituras lógicas? Justifique com base nos dados de `SET STATISTICS IO`.
   * Em quais situações **vale a pena** criar índices para consultas com `ORDER BY`?
   * Qual o impacto potencial de muitos índices nas operações de escrita (`INSERT`, `UPDATE`, `DELETE`)?

3. **(Opcional)**: Testar um segundo índice com outra combinação de colunas e comparar o resultado (por exemplo, primeiro `Nome, Estado` e depois `Estado, Nome`).


