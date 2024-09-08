### Aula: Stored Procedures em SQL Server

#### Objetivos:
- Compreender o conceito e a utilidade das stored procedures.
- Aprender a criar e gerenciar stored procedures no SQL Server.
- Utilizar stored procedures para otimizar consultas e melhorar a segurança no banco de dados.

#### Conteúdo Programático:

1. **O que são Stored Procedures?**
   - Definição: Uma stored procedure é um conjunto de instruções SQL pré-compiladas armazenadas no banco de dados, que podem ser executadas sempre que necessário.
   - Benefícios:
     - Reuso de código.
     - Otimização de performance (compilação prévia).
     - Segurança (controle de acesso).
     - Manutenção facilitada.

2. **Criação de uma Stored Procedure Simples**
   - Sintaxe básica:
     ```sql
     CREATE PROCEDURE NomeProcedure
     AS
     BEGIN
       -- Comandos SQL aqui
     END
     ```
   - Exemplo prático:
     ```sql
     CREATE PROCEDURE ListarFuncionarios
     AS
     BEGIN
       SELECT * FROM Funcionarios;
     END;
     ```
   - Executando a procedure:
     ```sql
     EXEC ListarFuncionarios;
     ```

3. **Stored Procedures com Parâmetros**
   - Sintaxe com parâmetros de entrada:
     ```sql
     CREATE PROCEDURE NomeProcedure @Parametro1 Tipo, @Parametro2 Tipo
     AS
     BEGIN
       -- Comandos SQL com uso de parâmetros
     END
     ```
   - Exemplo com parâmetros:
     ```sql
     CREATE PROCEDURE ListarFuncionariosPorDepartamento @DepartamentoID INT
     AS
     BEGIN
       SELECT * FROM Funcionarios WHERE Dnr = @DepartamentoID;
     END;
     ```
   - Executando com parâmetro:
     ```sql
     EXEC ListarFuncionariosPorDepartamento @DepartamentoID = 5;
     ```

4. **Stored Procedures com Parâmetros de Saída**
   - Definição de parâmetros de saída:
     ```sql
     CREATE PROCEDURE NomeProcedure @Parametro1 Tipo OUT
     AS
     BEGIN
       -- Lógica que atribui valor ao parâmetro de saída
     END;
     ```
   - Exemplo de uso de parâmetro de saída:
     ```sql
     CREATE PROCEDURE ObterSalarioFuncionario @Cpf VARCHAR(11), @Salario DECIMAL(10, 2) OUT
     AS
     BEGIN
       SELECT @Salario = Salario FROM Funcionarios WHERE Cpf = @Cpf;
     END;
     ```
   - Executando com parâmetro de saída:
     ```sql
     DECLARE @SalarioFuncionario DECIMAL(10, 2);
     EXEC ObterSalarioFuncionario @Cpf = '12345678901', @Salario = @SalarioFuncionario OUTPUT;
     PRINT @SalarioFuncionario;
     ```

5. **Stored Procedures com Controle de Fluxo**
   - Uso de condições e loops:
     ```sql
     CREATE PROCEDURE AtualizarSalarios
     AS
     BEGIN
       UPDATE Funcionarios SET Salario = Salario * 1.1 WHERE Datanasc < '1980-01-01';
     END;
     ```

6. **Gerenciamento de Stored Procedures**
   - Alterando uma stored procedure existente:
     ```sql
     ALTER PROCEDURE NomeProcedure
     AS
     BEGIN
       -- Modificações
     END;
     ```
   - Excluindo uma stored procedure:
     ```sql
     DROP PROCEDURE NomeProcedure;
     ```

7. **Boas Práticas e Considerações**
   - Use parâmetros em vez de concatenação de strings para evitar SQL Injection.
   - Valide sempre os dados de entrada.
   - Armazene a lógica de negócios complexa nas stored procedures para reduzir o tráfego de rede.


#### Referências:
- Documentação oficial do SQL Server: [Stored Procedures - SQL Server](https://learn.microsoft.com/en-us/sql/relational-databases/stored-procedures/stored-procedures-database-engine)

---

Esta estrutura oferece uma introdução ao conceito de stored procedures, seguida de exemplos práticos que ilustram seu uso e benefícios no SQL Server.
