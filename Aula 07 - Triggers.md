
### O que são Triggers no SQL Server?

No SQL Server, um *trigger* (ou gatilho) é um objeto de banco de dados que é associado a uma tabela ou visão. Sua principal função é executar automaticamente uma série de instruções SQL em resposta a certos eventos, como operações de inserção (`INSERT`), atualização (`UPDATE`) ou exclusão (`DELETE`).

Diferente de procedimentos armazenados (*stored procedures*), que são executados manualmente, os *triggers* são executados automaticamente sempre que ocorre o evento ao qual estão associados.

#### Benefícios dos Triggers:
- **Validação de dados automática:** Pode garantir a integridade de dados além das restrições já definidas, como impedir alterações inválidas.
- **Auditoria de alterações:** Utilizados para registrar um histórico de mudanças nos dados, como manter registros de quem alterou um valor e quando.
- **Automação de processos:** Disparar ações automáticas, como enviar notificações ou atualizar outras tabelas quando dados são modificados.

---

### Tipos de Triggers no SQL Server

Existem dois tipos principais de *triggers* que você pode usar no SQL Server, dependendo de como você deseja que o evento seja tratado:

1. **AFTER Triggers** (também chamados de *FOR* triggers)
2. **INSTEAD OF Triggers**

#### 1. AFTER Trigger

Um *AFTER* trigger é executado **depois** que a operação associada (inserção, atualização ou exclusão) foi concluída com sucesso. Esse é o tipo de *trigger* mais comum e é útil quando você deseja validar os dados ou executar outra lógica após a conclusão do evento.

##### Sintaxe de um AFTER Trigger:
```sql
CREATE TRIGGER nome_do_trigger
ON nome_da_tabela
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Lógica do trigger
END;
```

- O *AFTER trigger* será executado **após** o comando ser bem-sucedido. Isso significa que, se houver um problema no *trigger*, ele ainda pode reverter a transação completa, anulando a operação que o acionou.

##### Exemplo de AFTER Trigger:

```sql
CREATE TRIGGER trg_check_salary
ON FUNCIONARIO
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @Salario DECIMAL(10,2);
    
    -- Obtém o salário que foi inserido ou atualizado
    SELECT @Salario = i.Salario FROM inserted i;
    
    -- Verifica se o salário é menor que o mínimo permitido
    IF @Salario < 1000.00
    BEGIN
        RAISERROR('O salário não pode ser menor que R$ 1.000,00.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
```

Neste exemplo, o *AFTER trigger* é executado após uma inserção ou atualização na tabela `FUNCIONARIO`. Ele verifica se o salário é menor que R$ 1.000,00 e, se for, a operação é desfeita.

#### 2. INSTEAD OF Trigger

Um *INSTEAD OF* trigger é executado **em vez** da operação associada (inserção, atualização ou exclusão). Esse tipo de *trigger* substitui a operação padrão e permite que você controle completamente o que acontece quando a operação é solicitada.

##### Sintaxe de um INSTEAD OF Trigger:
```sql
CREATE TRIGGER nome_do_trigger
ON nome_da_tabela
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    -- Lógica do trigger
END;
```

- O *INSTEAD OF trigger* substitui completamente a ação padrão de `INSERT`, `UPDATE` ou `DELETE`, permitindo que você defina um comportamento personalizado.

##### Exemplo de INSTEAD OF Trigger:

```sql
CREATE TRIGGER trg_instead_insert_funcionario
ON FUNCIONARIO
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Cpf CHAR(11), @Salario DECIMAL(10,2);
    
    -- Obtém os valores da nova inserção
    SELECT @Cpf = i.Cpf, @Salario = i.Salario FROM inserted i;
    
    -- Verifica se o salário é menor que o mínimo permitido
    IF @Salario >= 1000.00
    BEGIN
        -- Realiza a inserção normal se o salário for válido
        INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
        SELECT Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr FROM inserted;
    END
    ELSE
    BEGIN
        -- Se o salário for menor, gera um erro
        RAISERROR('Salário inválido. Não foi possível inserir o funcionário.', 16, 1);
    END
END;
GO
```

Aqui, o *INSTEAD OF trigger* é usado para substituir a operação padrão de inserção. Ele verifica se o salário inserido é válido e, caso contrário, a operação é interrompida. Se o salário for válido, a inserção ocorre normalmente.

---

### Comparação entre AFTER e INSTEAD OF

| Tipo de Trigger | Quando é Executado                                      | Aplicação Típica                       |
|-----------------|---------------------------------------------------------|----------------------------------------|
| **AFTER**       | Após a operação ser concluída com sucesso                | Validação de dados ou automação de tarefas pós-operação |
| **INSTEAD OF**  | Substitui a operação solicitada                          | Controle completo sobre como a operação é realizada       |

- Use **AFTER triggers** para validar ou complementar operações já realizadas.
- Use **INSTEAD OF triggers** quando você quiser substituir o comportamento padrão de inserções, atualizações ou exclusões.

---


### Exemplo 1: Trigger para impedir salários muito baixos

Vamos criar um *trigger* que impede que um funcionário tenha um salário abaixo de um valor mínimo definido, como R$ 1.000,00.

```sql
CREATE TRIGGER trg_check_salary
ON FUNCIONARIO
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @Salario DECIMAL(10,2);
    
    -- Obtendo o salário inserido ou atualizado
    SELECT @Salario = i.Salario FROM inserted i;
    
    -- Verificando se o salário é menor que o mínimo permitido
    IF @Salario < 1000.00
    BEGIN
        RAISERROR('O salário não pode ser menor que R$ 1.000,00.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
```

Este *trigger* irá disparar toda vez que um novo funcionário for inserido ou quando o salário de um funcionário for atualizado. Se o salário for menor que R$ 1.000,00, ele lançará um erro e reverterá a operação.

### Exemplo 2: Trigger para registrar alterações no salário

Este exemplo mostra como usar um *trigger* para armazenar o histórico de mudanças no salário dos funcionários.

1. Crie a tabela de histórico de salários:

```sql
CREATE TABLE Historico_Salario (
    Cpf CHAR(11),
    Data_Mudanca DATE,
    Salario_Antigo DECIMAL(10,2),
    Salario_Novo DECIMAL(10,2)
);
GO
```

2. Crie o *trigger* que insere um registro no histórico sempre que o salário for alterado:

```sql
CREATE TRIGGER trg_salario_update
ON FUNCIONARIO
FOR UPDATE
AS
BEGIN
    DECLARE @Cpf CHAR(11), @SalarioAntigo DECIMAL(10,2), @SalarioNovo DECIMAL(10,2);
    
    -- Verifica se o salário foi alterado
    IF UPDATE(Salario)
    BEGIN
        -- Obtendo o CPF, salário antigo e novo
        SELECT @Cpf = i.Cpf, @SalarioAntigo = d.Salario, @SalarioNovo = i.Salario
        FROM inserted i
        INNER JOIN deleted d ON i.Cpf = d.Cpf;
        
        -- Inserindo um registro no histórico de salários
        INSERT INTO Historico_Salario (Cpf, Data_Mudanca, Salario_Antigo, Salario_Novo)
        VALUES (@Cpf, GETDATE(), @SalarioAntigo, @SalarioNovo);
    END
END;
GO
```

Esse *trigger* será disparado sempre que um salário for atualizado e registrará a mudança na tabela `Historico_Salario`.

### Exemplo 3: Trigger para evitar exclusão de gerentes

Vamos criar um *trigger* que impede que um funcionário seja excluído se ele for gerente de algum departamento.

```sql
CREATE TRIGGER trg_prevent_delete_gerente
ON FUNCIONARIO
FOR DELETE
AS
BEGIN
    DECLARE @Cpf CHAR(11);
    
    -- Verifica se o funcionário a ser excluído é gerente de algum departamento
    SELECT @Cpf = d.Cpf_gerente FROM deleted del
    INNER JOIN DEPARTAMENTO d ON del.Cpf = d.Cpf_gerente;
    
    IF @Cpf IS NOT NULL
    BEGIN
        RAISERROR('O gerente não pode ser excluído enquanto estiver gerenciando um departamento.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
```

## RAISERROR( )

A função `RAISERROR` no SQL Server é usada para gerar um erro personalizado e exibir uma mensagem ao usuário, interrompendo a execução da transação em andamento, caso seja necessário. A sintaxe básica é:

```sql
RAISERROR('Mensagem de erro', Severidade, Estado);
```

Aqui está a explicação detalhada dos três parâmetros:

### 1. **Mensagem de erro:**
   - O primeiro parâmetro (`'O salário não pode ser menor que R$ 1.000,00.'`) é a mensagem de erro personalizada que será exibida quando o erro for disparado. Nesse caso, a mensagem informa que o salário inserido não é permitido, pois é menor do que R$ 1.000,00.

### 2. **Severidade (16):**
   - O segundo parâmetro (neste caso, `16`) é o **nível de severidade** do erro. Esse valor indica a gravidade do erro e pode variar de 0 a 25.
   - No SQL Server, os níveis de severidade têm os seguintes significados:
     - **0 a 10**: Informativo ou advertências que não causam interrupção na execução. Geralmente usados para mensagens de log ou alertas leves.
     - **11 a 16**: Erros que indicam um problema com a consulta, como violação de regras de negócios ou erros de sintaxe. Esses erros podem interromper a execução da consulta atual, mas não comprometem o SQL Server em si.
     - **17 a 25**: Erros graves ou críticos que indicam falhas no servidor, recursos ou corrupção de dados. Esses erros podem interromper transações ou até mesmo causar falhas no servidor.

   - O nível `16`, como no seu exemplo, é comumente usado para erros de aplicação, como violação de regras de negócio. Isso significa que o erro foi causado por algo no código SQL ou nas operações de negócios, e não por uma falha grave no servidor.

### 3. **Estado (1):**
   - O terceiro parâmetro (neste caso, `1`) é o **estado** do erro. Esse parâmetro é usado para fornecer informações adicionais sobre onde o erro ocorreu dentro da execução da transação.
   - Normalmente, o valor de estado não tem um impacto funcional significativo, mas pode ser usado para identificar diferentes partes de um código onde o erro pode ter ocorrido. Valores comuns são `0` ou `1`, mas você pode usar outros valores para diferenciar erros dentro de diferentes blocos de código ou condições.

### Exemplo completo:
No contexto da função que você forneceu:

```sql
RAISERROR('O salário não pode ser menor que R$ 1.000,00.', 16, 1);
```

- A mensagem exibirá: `'O salário não pode ser menor que R$ 1.000,00.'`.
- A severidade `16` indica que este é um erro gerado pelo usuário ou uma violação de regras de negócios, que interromperá a transação atual.
- O estado `1` é simplesmente um identificador de estado padrão, que você poderia alterar para outro número se quisesse diferenciar este erro de outros semelhantes.

### Efeitos de `RAISERROR`:

- Ao executar `RAISERROR`, o SQL Server exibe a mensagem de erro especificada e pode abortar a transação em andamento (dependendo da severidade e do contexto).
- Em ambientes onde transações são usadas, como em triggers ou procedimentos armazenados, `RAISERROR` pode ser acompanhado de uma instrução `ROLLBACK` para garantir que a transação seja revertida quando uma violação ocorrer.

