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


## **7. Exercícios**

1. Crie uma tabela chamada `Vendas` com as colunas:
   - `VendaID` (int, PK), `Produto` (nvarchar), `Valor` (decimal), `DataVenda` (date).
   - Adicione um índice clusterizado e dois não clusterizados em colunas diferentes.

2. Insira 1.000 registros na tabela `Vendas` com valores randômicos e compare a performance da consulta:
```sql
SELECT * 
FROM Vendas
WHERE Valor > 100;
```

3. Explique em um breve parágrafo o impacto do uso de índices em tabelas grandes versus tabelas pequenas.
