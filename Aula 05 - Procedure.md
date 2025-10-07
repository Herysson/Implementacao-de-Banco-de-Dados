# Aula 05 – Functions e Stored Procedures (SQL Server)

## Objetivos

* Compreender e aplicar **UDFs** e **Stored Procedures** no SQL Server.
* Reutilizar lógica, organizar consultas e melhorar performance/segurança.
* Praticar criação, uso, manutenção e boas práticas.

---

## Conceitos Essenciais

### UDF (User-Defined Functions)

* Encapsulam lógica que **retorna um valor** (escalar) ou **uma tabela** (TVF).
* **Usáveis dentro de consultas**: `SELECT`, `WHERE`, `JOIN`, `ORDER BY`, `APPLY`.
* **Não** devem alterar estado da base (sem DML em tabelas reais, sem `EXEC` de proc, sem `#temp`).

### Stored Procedures (visão geral)

* Blocos de T-SQL **pré-compilados**, executados via `EXEC`.
* Podem conter **lógica de negócio**, DML, controle transacional, etc.

---

## Functions

### 3.1 Padrões e Regras

* **Schema**: sempre explicitar (`dbo.fn_Nome`).
* **Criação**: prefira `CREATE OR ALTER`.
* **Nulos**: tratar com `ISNULL`/`COALESCE`.
* **Determinismo**: evite funções não determinísticas em *indexed views*.
* **Performance**: prefira **inline TVF** quando possível; no SQL Server 2019+ algumas **escalars** são *inlined*.

### 3.2 Funções Escalares

**Sintaxe básica**

```sql
CREATE OR ALTER FUNCTION dbo.fn_Dobro (@Numero INT)
RETURNS INT
AS
BEGIN
    RETURN @Numero * 2;
END;
GO
```

**Uso**

```sql
SELECT dbo.fn_Dobro(5) AS Resultado;

SELECT f.Pnome, f.Unome, f.Salario,
       dbo.fn_Dobro(f.Salario) AS Salario_Dobrado
FROM dbo.FUNCIONARIO AS f;
```

**Exemplo — Idade pela Data de Nascimento**

```sql
CREATE OR ALTER FUNCTION dbo.fn_Idade (@DataNasc DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @DataNasc, CAST(GETDATE() AS DATE))
         - CASE WHEN FORMAT(@DataNasc, 'MMdd') > FORMAT(GETDATE(), 'MMdd') THEN 1 ELSE 0 END;
END;
GO
```

**Exemplo — Nome Completo**

```sql
CREATE OR ALTER FUNCTION dbo.fn_NomeCompleto (@Pnome NVARCHAR(60), @Unome NVARCHAR(60))
RETURNS NVARCHAR(121)
AS
BEGIN
    RETURN LTRIM(RTRIM(CONCAT(@Pnome, ' ', @Unome)));
END;
GO
```

**Exemplo — Salário Anual com Bônus (%)**

```sql
CREATE OR ALTER FUNCTION dbo.fn_SalarioAnual (@SalarioMensal DECIMAL(12,2), @BonusPercent DECIMAL(5,2))
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN (12 * @SalarioMensal) * (1 + (@BonusPercent/100.0));
END;
GO
```

### 3.3 Funções que Retornam Tabela (TVFs)

#### 3.3.1 Inline Table-Valued Function (ITVF)

* **Uma única consulta** — geralmente a opção **mais rápida**.

```sql
CREATE OR ALTER FUNCTION dbo.fn_FuncionariosPorDepartamento (@NomeDepartamento NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT f.Cpf,
           dbo.fn_NomeCompleto(f.Pnome, f.Unome) AS NomeCompleto,
           f.Salario,
           d.Dnome AS Departamento
    FROM dbo.FUNCIONARIO AS f
    JOIN dbo.DEPARTAMENTO AS d ON d.Dnumero = f.Dnr
    WHERE d.Dnome = @NomeDepartamento
);
GO

-- Uso
SELECT * FROM dbo.fn_FuncionariosPorDepartamento(N'Pesquisa');
```

#### 3.3.2 Multi-Statement Table-Valued Function (MSTVF)

* Permite múltiplos passos, usando **variável de tabela** interna.

```sql
CREATE OR ALTER FUNCTION dbo.fn_FuncionarioRendaAnual ()
RETURNS @T TABLE
(
    Cpf           CHAR(11),
    NomeCompleto  NVARCHAR(121),
    SalarioMensal DECIMAL(12,2),
    SalarioAnual  DECIMAL(12,2)
)
AS
BEGIN
    INSERT INTO @T (Cpf, NomeCompleto, SalarioMensal, SalarioAnual)
    SELECT f.Cpf,
           dbo.fn_NomeCompleto(f.Pnome, f.Unome),
           f.Salario,
           (12 * f.Salario)        -- 12 meses
           + f.Salario             -- 13º
           + (f.Salario / 3.0)     -- 1/3 de férias
    FROM dbo.FUNCIONARIO AS f;

    RETURN;
END;
GO

-- Uso
SELECT * FROM dbo.fn_FuncionarioRendaAnual();
```

### 3.4 Snippets Úteis (UDF)

```sql
-- Remoção segura
DROP FUNCTION IF EXISTS dbo.fn_Dobro;
GO

-- APPLY com ITVF
SELECT d.Dnome, x.*
FROM dbo.DEPARTAMENTO AS d
CROSS APPLY dbo.fn_FuncionariosPorDepartamento(d.Dnome) AS x;
```

### 3.5 Exercícios (UDF)

1. `fn_IdadeFuncionario(@Cpf)` (Escalar): usar `FUNCIONARIO.Datanasc`; listar `Cpf, NomeCompleto, Idade`.
2. `fn_FuncionariosDepartamento(@DeptoNome)` (ITVF): `Cpf, NomeCompleto, Salario, Departamento`.
3. `fn_SalarioTotalDepartamento(@DeptoNome)` (Escalar): somar salários do depto e comparar com subquery.
4. `fn_PagamentoAnual(@Cpf, @BonusPercent)` (Escalar): `(12*sal)+13º + 1/3 férias` com bônus; retornar `NULL` se bônus < 0.
5. `fn_BuscaPorSobrenome(@Termo)` (MSTVF): `Cpf, NomeCompleto, Departamento` filtrando por `LIKE`.

---

## Stored Procedures

### 4.1 Conceito e Benefícios

* **Definição**: conjunto de instruções T-SQL **armazenadas e pré-compiladas**.
* **Benefícios**: reuso, otimização, segurança (controle de acesso), manutenção.

### 4.2 Criação Simples

```sql
CREATE OR ALTER PROCEDURE dbo.pr_ListarFuncionarios
AS
BEGIN
    SET NOCOUNT ON;

    SELECT f.Cpf, f.Pnome, f.Unome, f.Salario, f.Dnr
    FROM dbo.FUNCIONARIO AS f;
END;
GO

-- Execução
EXEC dbo.pr_ListarFuncionarios;
```

### 4.3 Parâmetros de Entrada e Saída

**Entrada**

```sql
CREATE OR ALTER PROCEDURE dbo.pr_ListarFuncionariosPorDepartamento
    @DepartamentoNumero INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT f.Cpf, f.Pnome, f.Unome, f.Salario
    FROM dbo.FUNCIONARIO AS f
    WHERE f.Dnr = @DepartamentoNumero;
END;
GO

EXEC dbo.pr_ListarFuncionariosPorDepartamento @DepartamentoNumero = 5;
```

**Saída**

```sql
CREATE OR ALTER PROCEDURE dbo.pr_ObterSalarioFuncionario
    @Cpf CHAR(11),
    @Salario DECIMAL(12,2) OUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @Salario = f.Salario
    FROM dbo.FUNCIONARIO AS f
    WHERE f.Cpf = @Cpf;
END;
GO

DECLARE @SalarioFuncionario DECIMAL(12,2);
EXEC dbo.pr_ObterSalarioFuncionario @Cpf = '12345678901', @Salario = @SalarioFuncionario OUTPUT;
PRINT @SalarioFuncionario;
```

### 4.4 Controle de Fluxo

```sql
CREATE OR ALTER PROCEDURE dbo.pr_AjustarSalarios
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.FUNCIONARIO
    SET Salario = Salario * 1.10
    WHERE Datanasc < '1980-01-01';
END;
GO
```

### 4.5 Gerenciamento

```sql
-- Alterar
CREATE OR ALTER PROCEDURE dbo.pr_Exemplo
AS
BEGIN
    SELECT 1 AS OK;
END;
GO

-- Remover
DROP PROCEDURE IF EXISTS dbo.pr_Exemplo;
GO
```

### 4.6 Boas Práticas (Procedures)

* Use **parâmetros** (evite concatenação) para mitigar SQL Injection.
* Valide entradas e trate erros.
* Centralize lógica de negócio que necessite DML, transações e permissões específicas.
* Padronize **nomenclatura** (ex.: `dbo.pr_NomeVerbo`).

---

## Referências

* Microsoft Learn — **User-Defined Functions** (SQL Server)
* Microsoft Learn — **Stored Procedures** (SQL Server)
* Materiais e exemplos da disciplina

---
