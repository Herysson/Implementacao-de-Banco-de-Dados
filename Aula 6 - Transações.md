# Transações
Uma transação em banco de dados é um conjunto de operações que são tratadas como uma única unidade de trabalho. Essas operações podem incluir inserções, atualizações, exclusões ou consultas, 
e uma transação deve ser completamente concluída ou completamente revertida para garantir que o banco de dados permaneça em um estado consistente.

## O comando **TRANSACTION** 
Em SQL é utilizado para gerenciar uma sequência de operações (transações) no banco de dados, garantindo que essas operações sejam executadas de maneira segura e consistente. Uma transação é um bloco de comandos SQL que deve ser tratado como uma unidade indivisível: ou todos os comandos são executados com sucesso, ou nenhum deles é aplicado ao banco de dados (no caso de falha).

### Para que serve uma transação?

Uma transação serve para:
1. **Garantir integridade e consistência dos dados**: Se uma série de operações afeta vários registros ou tabelas, uma transação garante que todas essas operações sejam concluídas corretamente antes de serem confirmadas.
2. **Reverter alterações em caso de erro**: Se ocorrer um erro durante qualquer uma das operações de uma transação, você pode reverter todas as operações feitas até o momento, evitando deixar o banco de dados em um estado inconsistente.
3. **Controlar múltiplas operações simultâneas**: Em ambientes com múltiplos usuários e processos, transações ajudam a isolar as operações e prevenir problemas como "leituras sujas" ou "atualizações perdidas".

### Principais Comandos Relacionados a Transações

- **BEGIN TRANSACTION**: Inicia uma nova transação.
- **COMMIT TRANSACTION**: Confirma a transação, aplicando permanentemente todas as operações feitas no banco de dados.
- **ROLLBACK TRANSACTION**: Desfaz todas as operações realizadas desde o início da transação.
- **SAVEPOINT**: Define um ponto dentro de uma transação para permitir um rollback parcial, até esse ponto.

### Exemplo de Utilização de Transação

Imagine que estamos inserindo dados em duas tabelas, `FUNCIONARIO` e `DEPARTAMENTO`, e queremos garantir que ambas as operações sejam bem-sucedidas. Se a inserção em uma das tabelas falhar, todas as operações precisam ser revertidas.

```sql
BEGIN TRANSACTION;

-- Tentativa de inserir um novo funcionário
INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('João', 'A', 'Silva', '12345678901', '1990-01-01', 'Rua das Flores, 123', 'M', 5000, NULL, 1);

-- Tentativa de inserir um novo departamento
INSERT INTO DEPARTAMENTO (Dnumero, Dnome, Cpf_gerente, Data_inicio_gerente)
VALUES (3, 'Recursos Humanos', '12345678901', '2023-09-29');

-- Verifica se houve erro em alguma das inserções
IF @@ERROR <> 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Erro detectado. Transação revertida.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transação concluída com sucesso.';
END
```

### Explicação do Exemplo:

1. **BEGIN TRANSACTION**: Iniciamos uma nova transação. Todos os comandos subsequentes (inserções) farão parte desta transação.
2. **INSERT INTO FUNCIONARIO** e **INSERT INTO DEPARTAMENTO**: Tentamos inserir dados em duas tabelas.
3. **@@ERROR**: Este é um sistema interno do SQL Server que verifica se houve erro no comando anterior. Se algum dos comandos de inserção falhar, a variável `@@ERROR` retorna um valor diferente de zero.
4. **ROLLBACK TRANSACTION**: Se um erro for detectado, a transação inteira será revertida, ou seja, nenhuma das inserções será aplicada ao banco de dados.
5. **COMMIT TRANSACTION**: Se não houver erros, a transação é confirmada, e as inserções são salvas permanentemente no banco de dados.

### Por que usar transações?

- Para garantir que todas as operações críticas sejam completadas com sucesso. Por exemplo, ao fazer transferências bancárias, todas as operações (débito e crédito) devem ocorrer juntas.
- Em situações onde várias tabelas precisam ser atualizadas de forma coordenada, as transações previnem que o banco de dados fique em um estado inconsistente se algo der errado.

Transações são essenciais para garantir a integridade e a confiabilidade dos dados em sistemas de bancos de dados complexos e em ambientes de múltiplos usuários.

## ACID:  Atomicidade, Consistência, Isolamento e Durabilidade

O principal objetivo de uma transação é garantir a integridade e consistência dos dados, mesmo diante de falhas, como erros no sistema ou interrupções inesperadas. 
Isso é realizado com base nas propriedades **ACID: Atomicidade, Consistência, Isolamento e Durabilidade.**

### 1. **Atomicidade**
A atomicidade garante que uma transação é tratada como uma única unidade, o que significa que ela deve ser completamente concluída ou totalmente desfeita. Se qualquer parte da transação falhar, todo o resto também falha.

#### Exemplo de Atomicidade:
Neste exemplo, vamos realizar duas inserções dentro de uma transação: uma na tabela `FUNCIONARIO` e outra na tabela `DEPARTAMENTO`. Se a segunda inserção falhar, a primeira será revertida.

```sql
BEGIN TRANSACTION;

-- Tentativa de inserir um novo funcionário
INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Maria', 'C', 'Silva', '12345678901', '1985-05-10', 'Rua A, 123', 'F', 3500, NULL, 1);

-- Tentativa de inserir um novo departamento (errada, falha por conta da chave primária)
INSERT INTO DEPARTAMENTO (Dnumero, Dnome, Cpf_gerente, Data_inicio_gerente)
VALUES (1, 'TI', '12345678901', '2023-09-29'); -- Dnumero duplicado

-- Se houver erro, rollback de todas as operações
IF @@ERROR <> 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Transação revertida por erro na inserção de departamento.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transação concluída com sucesso.';
END
```

### 2. **Consistência**
A consistência garante que uma transação leve o banco de dados de um estado válido para outro estado válido, respeitando todas as regras definidas, como chaves primárias, integridade referencial, etc.

#### Exemplo de Consistência:
Aqui, vamos tentar inserir um funcionário com um `Cpf_supervisor` que não existe. O banco de dados não permitirá essa operação, garantindo consistência.

```sql
BEGIN TRANSACTION;

-- Tentativa de inserir um funcionário com um supervisor inexistente
INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Carlos', 'B', 'Pereira', '98765432100', '1990-02-15', 'Rua B, 456', 'M', 5000, '00000000000', 1);

-- A transação falhará porque o Cpf_supervisor '00000000000' não existe
IF @@ERROR <> 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Erro de consistência: Cpf_supervisor não existe.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transação concluída com sucesso.';
END
```

### 3. **Isolamento**
O isolamento garante que as transações sejam executadas de forma isolada, sem que as operações de uma transação afetem as operações de outra. O nível de isolamento pode variar, afetando a visibilidade das mudanças feitas por transações concorrentes.

#### Exemplo de Isolamento:
Aqui, usaremos um exemplo com `SET TRANSACTION ISOLATION LEVEL` para definir o nível de isolamento e mostrar como uma transação bloqueia leituras concorrentes.

```sql
-- Transação 1: Definindo nível de isolamento para SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

-- Tentativa de selecionar todos os funcionários
SELECT * FROM FUNCIONARIO;

-- Neste ponto, a transação 2 tentará inserir um novo funcionário, mas será bloqueada
WAITFOR DELAY '00:00:10'; -- Simulando uma pausa

COMMIT TRANSACTION;

-- Transação 2: Tentativa de inserção será bloqueada até a transação 1 ser finalizada
BEGIN TRANSACTION;

INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('João', 'D', 'Santos', '11122233344', '1988-03-22', 'Rua C, 789', 'M', 4000, NULL, 2);

COMMIT TRANSACTION;
```

### 4. **Durabilidade**
A durabilidade garante que, uma vez que uma transação é confirmada (committed), ela permanecerá no banco de dados, mesmo que ocorra uma falha no sistema. Os dados serão persistidos no armazenamento.

#### Exemplo de Durabilidade:
Neste exemplo, após realizar um `COMMIT`, os dados persistem mesmo que o servidor seja reiniciado.

```sql
BEGIN TRANSACTION;

-- Inserção de um novo funcionário
INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Ana', 'E', 'Costa', '55544433322', '1987-09-01', 'Rua D, 321', 'F', 4500, NULL, 2);

COMMIT TRANSACTION;

-- Verificar que os dados persistem
SELECT * FROM FUNCIONARIO WHERE Cpf = '55544433322';
```
