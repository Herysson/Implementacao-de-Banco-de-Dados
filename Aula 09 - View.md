---

# Aula sobre Views e Subconsultas

## Conteúdo Teórico

### O que são Views?

Uma **view** (ou exibição) é uma tabela virtual gerada a partir de uma consulta SQL. Diferente de uma tabela tradicional, uma view não armazena dados, mas sim uma consulta SQL que é executada toda vez que a view é acessada, retornando dados atualizados. 

### Vantagens das Views

1. **Reutilização de Consultas**: Views podem ser reutilizadas em várias consultas, facilitando o gerenciamento de código.
2. **Segurança**: Pode-se limitar o acesso a determinadas colunas de uma tabela, criando views que mostram apenas os dados necessários para certos usuários.
3. **Simplicidade**: Views ajudam a esconder a complexidade das consultas SQL, tornando o código mais limpo e fácil de entender.
4. **Velocidade**: Uma view pode melhorar a performance em consultas complexas.
5. **Mascaramento de Dados**: Views permitem ocultar a complexidade do banco de dados e seus relacionamentos.

### Sintaxe de Criação de Views

A sintaxe básica para criar uma view é:

```sql
CREATE VIEW nome_da_view AS
SELECT colunas
FROM tabela
WHERE condição;
```

Exemplo:

```sql
CREATE VIEW VendedoresAtivos AS
SELECT Nome, Salario
FROM Funcionarios
WHERE Cargo = 'Vendedor' AND Status = 'Ativo';
```

### Exemplo com o Banco de Dados EMPRESA

No banco de dados EMPRESA, podemos criar uma view para exibir informações dos funcionários que trabalham em um determinado departamento. Suponha que queremos listar todos os funcionários do departamento de vendas.

```sql
CREATE VIEW FuncionariosVendas AS
SELECT Pnome, Unome, Salario
FROM Funcionarios
WHERE Dnr = 3;
```

Esta view irá exibir o primeiro nome, último nome e salário de todos os funcionários do departamento de vendas (supondo que o ID do departamento de vendas seja 3).

### Alterando uma View

Se for necessário modificar uma view, a sintaxe para alteração é:

```sql
ALTER VIEW nome_da_view AS
SELECT colunas
FROM tabela
WHERE condição;
```

Por exemplo, se quisermos adicionar a data de nascimento dos funcionários à view criada anteriormente:

```sql
ALTER VIEW FuncionariosVendas AS
SELECT Pnome, Unome, Salario, Datanasc
FROM Funcionarios
WHERE Dnr = 3;
```

### Excluindo uma View

Para remover uma view do banco de dados, utilizamos o comando:

```sql
DROP VIEW nome_da_view;
```

Por exemplo:

```sql
DROP VIEW FuncionariosVendas;
```

## Exercícios Práticos

### Exercício 1: Criação de Views

1. **View de Funcionários Sem Supervisores**: Crie uma view que liste todos os funcionários que não possuem supervisores. Utilize a coluna `Cpf_supervisor` para verificar quais funcionários não têm supervisores.

2. **View de Salários por Departamento**: Crie uma view que exiba a média salarial por departamento.

3. **View de Projetos Ativos**: Crie uma view que liste os projetos ativos, ou seja, aqueles que estão em andamento.


### Exercício 2: Subconsultas (Subqueries)

Uma **subconsulta** é uma consulta dentro de outra consulta. Subconsultas são usadas para retornar dados que serão utilizados na consulta principal.

Exemplo de uma subconsulta simples:

```sql
SELECT Pnome, Unome
FROM Funcionarios
WHERE Salario > (SELECT AVG(Salario) FROM Funcionarios);
```

Neste exemplo, a subconsulta retorna a média salarial de todos os funcionários, e a consulta principal lista os funcionários que ganham acima da média.

#### Subconsultas com o Banco EMPRESA

1. **Funcionários Acima da Média Salarial**: Liste todos os funcionários que ganham mais do que a média salarial do departamento em que trabalham.

2. **Projetos Com Mais de 5 Funcionários**: Liste os nomes dos projetos que têm mais de 5 funcionários alocados.

