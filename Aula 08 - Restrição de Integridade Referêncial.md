
# Aula sobre Restrições de Integridade

## Conteúdo Teórico

### O que é Integridade de Dados?
A integridade de dados refere-se à manutenção e garantia da consistência e precisão dos dados, um aspecto crítico no design, implementação e uso de sistemas de armazenamento de dados. A integridade é atingida através da aplicação de diversas restrições que asseguram que os dados inseridos em um banco estejam corretos e consistentes ao longo do tempo.

### Tipos de Restrições de Integridade

#### 1. Integridade de Domínio
A integridade de domínio especifica que o valor de cada atributo em uma tabela deve ser indivisível dentro de um domínio específico. Por exemplo, em uma coluna que armazena preços de mercadorias, os valores admitidos são do domínio numérico — ou seja, apenas números.

Exemplo de restrição de domínio:
```sql
CREATE TABLE Produtos (
    id_produto INT PRIMARY KEY,
    nome_produto VARCHAR(100),
    preco DECIMAL(10, 2) CHECK (preco > 0)
);
```
Este exemplo garante que o valor da coluna `preco` sempre será um número positivo.

#### 2. Integridade Referencial
A integridade referencial assegura que as relações entre tabelas permaneçam consistentes. Quando uma tabela contém uma chave estrangeira, essa chave deve corresponder a um valor existente na tabela referenciada.

Exemplo de restrição referencial:
```sql
CREATE TABLE Vendas (
    id_venda INT PRIMARY KEY,
    id_produto INT,
    CONSTRAINT fk_produto FOREIGN KEY (id_produto) REFERENCES Produtos(id_produto)
);
```
Neste exemplo, a venda de um produto só é permitida se o produto já estiver cadastrado na tabela `Produtos`.

#### 3. Integridade de Vazio (NULL)
Essa restrição define se uma coluna pode aceitar valores nulos. Colunas que fazem parte de uma chave primária, por exemplo, não podem aceitar valores nulos.

Exemplo de integridade de vazio:
```sql
CREATE TABLE Funcionarios (
    id_funcionario INT PRIMARY KEY,
    nome_funcionario VARCHAR(100) NOT NULL,
    salario DECIMAL(10, 2) NOT NULL
);
```
Aqui, a coluna `nome_funcionario` não pode ser nula, ou seja, todo funcionário deve ter um nome registrado.

#### 4. Integridade de Chave
A integridade de chave garante que os valores de uma chave primária sejam únicos em toda a tabela e que esses valores nunca sejam nulos.

Exemplo de integridade de chave:
```sql
CREATE TABLE Departamentos (
    id_departamento INT PRIMARY KEY,
    nome_departamento VARCHAR(100) NOT NULL
);
```
Neste exemplo, a coluna `id_departamento` deve ser única e sempre conter um valor.

#### 5. Integridade Definida pelo Usuário
A integridade definida pelo usuário permite criar restrições personalizadas para atender às necessidades específicas do negócio. Por exemplo, pode-se definir que uma coluna só aceitará um conjunto restrito de valores.

Exemplo de integridade definida pelo usuário:
```sql
CREATE TABLE Funcionarios (
    id_funcionario INT PRIMARY KEY,
    nome_funcionario VARCHAR(100),
    cargo VARCHAR(50) CHECK (cargo IN ('Gerente', 'Analista', 'Desenvolvedor'))
);
```
Aqui, a coluna `cargo` só aceita os valores `'Gerente'`, `'Analista'` ou `'Desenvolvedor'`.

---
