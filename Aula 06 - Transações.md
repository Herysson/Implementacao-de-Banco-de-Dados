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
BEGIN TRAN;

SELECT * 
FROM dbo.FUNCIONARIO;

-- Marca o momento em que o SELECT terminou (aparece já no Results/Messages)
PRINT 'SELECT concluído em: ' + CONVERT(varchar(23), SYSDATETIME(), 121);
RAISERROR('Segurando locks por 10s...', 0, 1) WITH NOWAIT;

-- Pausa de 20 segundos com a transação aberta (locks mantidos)
WAITFOR DELAY '00:00:20';

COMMIT TRAN;
PRINT 'COMMIT em: ' + CONVERT(varchar(23), SYSDATETIME(), 121);


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

### 5. **Exemplo de `SAVEPOINT` para Reversão Parcial**

O comando `SAVEPOINT` (ou `SAVE TRANSACTION`) define um ponto de salvamento dentro de uma transação. [cite\_start]Isso permite reverter apenas uma parte das operações realizadas, sem a necessidade de desfazer a transação inteira[cite: 64, 152].

**Cenário:** Vamos adicionar um novo departamento à empresa. Em seguida, tentaremos cadastrar um funcionário para esse novo departamento. Usaremos um `SAVEPOINT` após a criação do departamento para que, se decidirmos não manter o funcionário, possamos reverter apenas a inserção do funcionário, mas ainda assim manter o novo departamento.

```sql
-- Inicia a transação
BEGIN TRANSACTION;

-- 1. Primeira operação: Inserir um novo departamento.
-- Esta operação será permanente se a transação for confirmada.
INSERT INTO DEPARTAMENTO (Dnome, Dnumero, Cpf_gerente, Data_inicio_gerente)
VALUES ('Marketing', 9, NULL, NULL);

-- 2. Criar um ponto de salvamento (savepoint) após a primeira operação.
[cite_start]SAVE TRANSACTION PontoDeSalvamento; [cite: 145]

-- 3. Segunda operação: Inserir um novo funcionário para o departamento de Marketing.
-- Esta operação é experimental e poderá ser desfeita.
INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Julia', 'M', 'Santos', '99988877766', '1992-08-10', 'Rua das Ideias, 789', 'F', 3800, NULL, 9);

-- 4. Suponha que decidimos não prosseguir com a contratação de Julia.
-- Vamos reverter a transação APENAS até o ponto de salvamento.
-- Isso irá desfazer a inserção da funcionária Julia, mas manterá a criação do departamento de Marketing.
ROLLBACK TRANSACTION PontoDeSalvamento;

-- 5. Confirmar (COMMIT) o restante da transação.
-- Apenas a criação do departamento de Marketing será salva permanentemente.
COMMIT TRANSACTION;

```

#### Verificação do Resultado

Após executar o script acima, você pode verificar o estado do banco de dados:

1.  **O departamento "Marketing" existirá:**

    ```sql
    SELECT * FROM DEPARTAMENTO WHERE Dnome = 'Marketing';
    ```

    *(Esta consulta retornará a linha do departamento de Marketing)*

2.  **A funcionária "Julia" não existirá:**

    ```sql
    SELECT * FROM FUNCIONARIO WHERE Pnome = 'Julia';
    ```

    *(Esta consulta não retornará nenhum resultado, pois sua inserção foi revertida pelo `ROLLBACK` ao `SAVEPOINT`)*

## 4. **TRY…CATCH**

É um “cinto de segurança” do SQL Server: você coloca o código no **TRY**; se der erro, o SQL **pula** para o **CATCH**, onde você decide o que fazer (avisar, desfazer, registrar, etc.).

#### Por que usar?

* Evitar que seu script pare “no susto”.
* **Desfazer** mudanças em caso de erro (manter os dados corretos).
* Escrever **mensagens claras** de erro para quem for depurar.

### A estrutura básica

```sql
BEGIN TRY
  -- coisas que podem dar erro
END TRY
BEGIN CATCH
  -- o que fazer se deu erro
END CATCH
```

#### Como funciona o fluxo

1. O SQL executa o que está dentro do **TRY**.
2. Se **não** houver erro → o **CATCH** é ignorado.
3. Se **houver** erro → o SQL **interrompe** o TRY e **salta** para o CATCH.
4. No CATCH você tem funções úteis como:

   * `ERROR_NUMBER()`, `ERROR_MESSAGE()`, `ERROR_LINE()`
   * `XACT_STATE()` → diz o estado da transação (se dá pra `COMMIT` ou só `ROLLBACK`).

### Exemplo simples (sem transação)

```sql
BEGIN TRY
  SELECT 1 / 0;  -- erro proposital (divisão por zero)
  PRINT 'Não chegarei aqui';
END TRY
BEGIN CATCH
  PRINT 'Deu erro!';
  PRINT 'Número: ' + CAST(ERROR_NUMBER() AS varchar(10));
  PRINT 'Mensagem: ' + ERROR_MESSAGE();
END CATCH;
```

O SQL pula pro CATCH e mostra as infos do erro.

### Exemplo prático com transação

Quando mexemos em dados (INSERT/UPDATE/DELETE), usamos transação para garantir **tudo-ou-nada**.

```sql
BEGIN TRY
  BEGIN TRAN;  -- começa a transação

  UPDATE dbo.FUNCIONARIO
  SET Salario = Salario * 1.02
  WHERE Dnr = 1;

  -- Força um erro só para demonstrar
  SELECT 1/0;

  COMMIT;  -- não será executado porque houve erro acima
END TRY
BEGIN CATCH
  -- Se ainda houver transação ativa, desfaz
  IF XACT_STATE() <> 0
      ROLLBACK;

  -- Mostra o que aconteceu
  DECLARE @msg nvarchar(4000) =
    CONCAT('Erro ', ERROR_NUMBER(), ' na linha ', ERROR_LINE(), ': ', ERROR_MESSAGE());
  PRINT @msg;

  -- Opcional: relançar o erro
  -- THROW;
END CATCH;
```

### O que é `XACT_STATE()`?

* **1** → há transação **ativa e “comitável”** (tecnicamente daria pra `COMMIT`, mas após erro geralmente fazemos `ROLLBACK`).
* **-1** → transação **incomitável** (corrompida); **só** `ROLLBACK` funciona.
* **0** → não há transação ativa.

### E o `XACT_ABORT ON`?

* Se você liga `XACT_ABORT ON`, a maioria dos erros de runtime faz a transação ficar **incomitável** (estado -1).
* É útil para garantir rollback automático em erros mais chatos (ex.: timeouts, violação de FK), mas **sempre** cheque a política do seu projeto.

```sql
SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  -- seus DMLs aqui...
  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW; -- reenvia o erro
END CATCH;
```

### Boas práticas (bem resumidas)

* Sempre que fizer DML “de verdade”, use **TRY…CATCH + TRANSAÇÃO**.
* No CATCH, **tente reverter** (`ROLLBACK`) se ainda houver transação.
* Logue `ERROR_NUMBER()`, `ERROR_MESSAGE()`, `ERROR_LINE()`.
* Evite “engolir” o erro: use `THROW;` para não esconder problemas.

### Erros comuns de iniciante

* Esquecer o `BEGIN TRAN` (aí não tem o que reverter).
* Tentar `COMMIT` depois de um erro sem checar `XACT_STATE()` (pode estar incomitável).
* “Sumir” com o erro (não dar `THROW`/log), dificultando depuração.

## Exercícios:

1) Autocommit × Transação Explícita
Tarefa: Insira dois departamentos: um em modo autocommit e outro dentro de uma transação explícita. Em seguida, desfaça o segundo (Rollback) e confirme o primeiro.
Entregável: Demonstre, por consulta, qual linha permaneceu e explique por quê.

2) SAVEPOINT e ROLLBACK Parcial
Tarefa: Dentro de uma única transação, insira dois departamentos. Crie um SAVEPOINT após o primeiro insert e faça ROLLBACK para o savepoint (mantendo o primeiro e desfazendo o segundo).
Entregável: Evidencie que apenas o primeiro persiste após COMMIT.

3) UPDATE com Conferência e Decisão
Tarefa: Inicie transação, atualize o endereço de um funcionário específico, conferir a alteração e então decidir entre COMMIT ou ROLLBACK com base na conferência.
Entregável: Registre a decisão e o estado final do registro.

4) SAVEPOINT antes de UPDATE em Massa
Tarefa: Em uma transação, crie um SAVEPOINT e aplique um reajuste salarial (ex.: +2%) para um departamento. Avalie o impacto (média e quantidade). Caso o efeito não seja desejado, ROLLBACK para o savepoint; caso contrário, COMMIT.
Entregável: Relatório curto do antes/depois e a decisão tomada.

5) Operação Composta: INSERT + UPDATE (Tudo-ou-Nada)
Tarefa: Em uma única transação, crie um novo departamento e realoque um funcionário para esse departamento. Ao final, decida entre COMMIT ou ROLLBACK (tudo deve persistir ou nada).
Entregável: Comprove atomicidade: se desfizer, nem o depto novo nem a realocação devem permanecer.

6) Tratamento de Erros com TRY…CATCH e XACT_STATE()
Tarefa: Dentro de uma transação, faça um UPDATE válido e, em seguida, provoque um erro (por ex., atualizar uma coluna inexistente). Trate o erro com TRY…CATCH e decida COMMIT/ROLLBACK conforme XACT_STATE().
Entregável: Explique quando XACT_STATE retorna 1 ou -1 e o que isso implica para a recuperação.

## Referências:
1. **Elmasri, R., & Navathe, S. B.** (2016). *Sistemas de Banco de Dados*. 6ª edição. Pearson.  
   - Este livro oferece uma base sólida sobre transações, propriedades ACID e detalhes sobre gerenciamento de transações em sistemas de banco de dados.

2. **Silberschatz, A., Korth, H., & Sudarshan, S.** (2019). *Sistemas de Banco de Dados*. 7ª edição. McGraw-Hill.
   - Esta obra explora conceitos avançados de transações, isolamento, integridade de dados, além de práticas de controle de concorrência.

3. **Microsoft SQL Server Documentation**. *Transactions (Transact-SQL)*. Disponível em:  
   [https://learn.microsoft.com/en-us/sql/t-sql/statements/transactions-transact-sql](https://learn.microsoft.com/en-us/sql/t-sql/statements/transactions-transact-sql)
   - A documentação oficial do SQL Server detalha os comandos de transação, como `BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK`, e discute a implementação de transações no contexto do SQL Server.

4. **Connolly, T. & Begg, C.** (2015). *Database Systems: A Practical Approach to Design, Implementation, and Management*. 6th edition. Pearson.
   - Este livro apresenta uma introdução prática a transações em bancos de dados, explicando as propriedades ACID com exemplos e estudos de caso.

5. **Kroenke, D. M., & Auer, D.** (2013). *Database Concepts*. 7th Edition. Pearson.
   - Esse livro cobre os fundamentos de bancos de dados, com ênfase em como transações e ACID são usados para manter a integridade dos dados em ambientes multiusuário.
