# Gerenciamento de Banco de Dados no SQL Server: Criação de Usuário e Permissões

## Objetivo
Este material aborda conceitos fundamentais para gerenciar permissões em bancos de dados SQL Server, incluindo criação de usuários e o uso dos comandos `GRANT`, `DENY` e `REVOKE`.

## Pré-requisitos
Para seguir esta aula, é recomendado que você tenha:
- Conhecimento básico de SQL
- Acesso a um banco de dados SQL Server com permissões administrativas

## Índice
1. [Introdução ao Gerenciamento de Usuários e Permissões](#introdução-ao-gerenciamento-de-usuários-e-permissões)
2. [Criando um Usuário no SQL Server](#criando-um-usuário-no-sql-server)
3. [Comandos de Controle de Permissões](#comandos-de-controle-de-permissões)
   - [GRANT](#grant)
   - [DENY](#deny)
   - [REVOKE](#revoke)
4. [Exemplos Práticos](#exemplos-práticos)

---

## Introdução ao Gerenciamento de Usuários e Permissões

O gerenciamento de usuários e permissões em um banco de dados é essencial para controlar o acesso e garantir a segurança dos dados. No SQL Server, você pode configurar quais ações cada usuário pode realizar, como leitura, inserção, atualização ou exclusão de dados.

## Criando um Usuário no SQL Server

Para criar um novo usuário em um banco de dados SQL Server, primeiro você precisa criar um `Login` associado ao SQL Server (para autenticação de nível de servidor) e, em seguida, criar um `User` (para nível de banco de dados).

### Passo 1: Criando um Login
Para criar um login, utilize o comando `CREATE LOGIN`. Este comando cria um login com senha que pode ser usado para autenticar o usuário no servidor.

```sql
CREATE LOGIN MeuLogin WITH PASSWORD = 'MinhaSenhaForte';
```

> **Nota**: Substitua `MeuLogin` e `MinhaSenhaForte` pelos valores desejados. Escolha uma senha forte para aumentar a segurança.

### Passo 2: Criando um Usuário para o Login no Banco de Dados

Depois de criar o login, você pode criar um usuário no banco de dados específico:

```sql
USE MeuBancoDeDados;
CREATE USER MeuUsuario FOR LOGIN MeuLogin;
```

> **Nota**: Substitua `MeuBancoDeDados` e `MeuUsuario` pelos valores apropriados.

## Comandos de Controle de Permissões

Uma vez que o usuário está criado, é possível conceder ou negar permissões a ele. No SQL Server, as permissões são gerenciadas por três comandos principais: `GRANT`, `DENY` e `REVOKE`.

### GRANT

O comando `GRANT` concede uma permissão específica a um usuário ou função. Isso permite que o usuário execute certas ações, como selecionar dados ou modificar uma tabela.

#### Sintaxe
```sql
GRANT permissão ON objeto TO usuário;
```

#### Exemplo
```sql
GRANT SELECT ON dbo.MinhaTabela TO MeuUsuario;
```

### DENY

O comando `DENY` impede que o usuário realize uma determinada ação. Ao contrário do `REVOKE`, o `DENY` garante que a permissão negada tenha precedência, mesmo que o usuário faça parte de uma função que possui essa permissão.

#### Sintaxe
```sql
DENY permissão ON objeto TO usuário;
```

#### Exemplo
```sql
DENY DELETE ON dbo.MinhaTabela TO MeuUsuario;
```

### REVOKE

O comando `REVOKE` remove uma permissão concedida anteriormente (ou uma negação). Este comando não concede nem nega acesso explicitamente; ele simplesmente remove a permissão específica.

#### Sintaxe
```sql
REVOKE permissão ON objeto FROM usuário;
```

#### Exemplo
```sql
REVOKE SELECT ON dbo.MinhaTabela FROM MeuUsuario;
```

> **Nota**: Usar `REVOKE` é útil quando se deseja revogar permissões sem negar o acesso completamente.

## Exemplos Práticos

A seguir, veja alguns exemplos práticos para entender como esses comandos funcionam juntos.

### Exemplo 1: Concedendo Permissão de Leitura e Escrita

```sql
GRANT SELECT, INSERT ON dbo.MinhaTabela TO MeuUsuario;
```

Neste exemplo, o usuário `MeuUsuario` pode ler (`SELECT`) e inserir (`INSERT`) dados na tabela `MinhaTabela`.

### Exemplo 2: Negando Permissão de Exclusão

```sql
DENY DELETE ON dbo.MinhaTabela TO MeuUsuario;
```

Este comando impede que `MeuUsuario` exclua registros da tabela `MinhaTabela`.

### Exemplo 3: Revogando Permissão de Inserção

```sql
REVOKE INSERT ON dbo.MinhaTabela FROM MeuUsuario;
```

Neste caso, a permissão de `INSERT` é revogada. Caso `MeuUsuario` faça parte de outra função com a permissão `INSERT`, ele poderá inseri-los novamente (a menos que um `DENY` explícito seja aplicado).

