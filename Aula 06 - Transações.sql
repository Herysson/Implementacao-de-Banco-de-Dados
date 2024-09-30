-- Crie uma transação para inserir um novo funcionário e um novo departamento. Caso uma das inserções falhe, reverta a transação completamente.
BEGIN TRANSACTION;

-- Insira um novo funcionário
INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Carlos', 'M', 'Almeida', '98765432100', '1991-07-23', 'Av. Brasil, 500', 'M', 4500, NULL, 2);

-- Insira um novo departamento
INSERT INTO DEPARTAMENTO (Dnumero, Dnome, Cpf_gerente, Data_inicio_gerente)
VALUES (10, 'Marketing', '98765432100', '2023-09-29');

-- Verifique se houve erro
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

--Escreva uma transação que tente inserir um funcionário com um Cpf_supervisor que não existe. O banco de dados deve rejeitar a operação, e a transação deve ser revertida.
BEGIN TRANSACTION;

-- Tentativa de inserir um funcionário com supervisor inexistente
INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Ana', 'L', 'Souza', '55544433322', '1985-12-12', 'Rua Central, 300', 'F', 5000, '00000000000', 3);

-- Verifica se houve erro (Cpf_supervisor inválido)
IF @@ERROR <> 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Erro: Cpf_supervisor inexistente. Transação revertida.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transação concluída com sucesso.';
END


--Execute duas transações simultaneamente para testar o isolamento de transações no SQL Server. Utilize o nível de isolamento SERIALIZABLE para garantir que uma transação bloqueie a outra até ser finalizada.
-- Transação 1: Nível de isolamento SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

-- Selecione todos os funcionários
SELECT * FROM FUNCIONARIO;

-- Pause por 10 segundos
WAITFOR DELAY '00:00:10'; 

COMMIT TRANSACTION;

-- Transação 2: Tentativa de inserção (bloqueada até a conclusão da transação 1)
BEGIN TRANSACTION;

INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Lucas', 'S', 'Pereira', '33322211100', '1995-05-15', 'Rua Verde, 123', 'M', 5500, NULL, 1);

COMMIT TRANSACTION;

-- Escreva uma transação que insira dados em uma tabela, mas deve falhar devido a uma violação de restrição de chave primária. A transação deve ser revertida.
BEGIN TRANSACTION;

-- Tentativa de inserir um funcionário com CPF duplicado
INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Mariana', 'A', 'Costa', '12345678901', '1992-03-15', 'Rua Azul, 400', 'F', 6000, NULL, 2); -- CPF já existente

-- Verifica se houve erro de chave primária
IF @@ERROR <> 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Erro: CPF duplicado. Transação revertida.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transação concluída com sucesso.';
END

-- Crie uma transação que atualize o salário de todos os funcionários de um determinado departamento. Se a atualização de qualquer funcionário falhar, reverta todas as alterações.
BEGIN TRANSACTION;

-- Atualizar salários dos funcionários do departamento 2
UPDATE FUNCIONARIO
SET Salario = Salario * 1.10
WHERE Dnr = 2;

-- Verificar se houve erro
IF @@ERROR <> 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Erro detectado. Transação revertida.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Salários atualizados com sucesso.';
END

-- Implemente uma transação que simule uma compra. Verifique o estoque antes de permitir a compra e, se o estoque for insuficiente, reverta a transação. Use uma tabela chamada PRODUTO para registrar o estoque dos produtos.

-- Criação da tabela de produtos
CREATE TABLE PRODUTO (
    Id INT PRIMARY KEY,
    Nome VARCHAR(50),
    Quantidade INT
);

-- Exemplo de inserção de produtos
INSERT INTO PRODUTO (Id, Nome, Quantidade) VALUES (1, 'Notebook', 10), (2, 'Mouse', 50);

-- Transação de compra
BEGIN TRANSACTION;

DECLARE @produtoId INT = 1;
DECLARE @quantidadeCompra INT = 5;

-- Verificar o estoque
IF (SELECT Quantidade FROM PRODUTO WHERE Id = @produtoId) >= @quantidadeCompra
BEGIN
    -- Subtrair a quantidade do estoque
    UPDATE PRODUTO 
    SET Quantidade = Quantidade - @quantidadeCompra 
    WHERE Id = @produtoId;

    COMMIT TRANSACTION;
    PRINT 'Compra realizada com sucesso!';
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Estoque insuficiente. Transação cancelada.';
END

-- Implemente uma transação que simule a transferência de fundos entre duas contas bancárias. Se o saldo da conta de origem for insuficiente, a transação deve ser revertida.

-- Criação da tabela de contas
CREATE TABLE CONTA (
    ContaId INT PRIMARY KEY,
    Nome VARCHAR(50),
    Saldo DECIMAL(10, 2)
);

-- Exemplo de inserção de contas
INSERT INTO CONTA (ContaId, Nome, Saldo) VALUES (1, 'João', 1000.00), (2, 'Maria', 500.00);

-- Transação de transferência
BEGIN TRANSACTION;

DECLARE @contaOrigem INT = 1;
DECLARE @contaDestino INT = 2;
DECLARE @valorTransferencia DECIMAL(10, 2) = 200.00;

-- Verificar saldo da conta de origem
IF (SELECT Saldo FROM CONTA WHERE ContaId = @contaOrigem) >= @valorTransferencia
BEGIN
    -- Subtrair da conta de origem
    UPDATE CONTA
    SET Saldo = Saldo - @valorTransferencia
    WHERE ContaId = @contaOrigem;

    -- Adicionar à conta de destino
    UPDATE CONTA
    SET Saldo = Saldo + @valorTransferencia
    WHERE ContaId = @contaDestino;

    COMMIT TRANSACTION;
    PRINT 'Transferência realizada com sucesso!';
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Saldo insuficiente. Transação cancelada.';
END

-- Implemente uma transação que insira dados em três tabelas diferentes. Use um SAVEPOINT para marcar um ponto dentro da transação. Se uma parte falhar, reverta apenas até o ponto de salvamento (savepoint) sem desfazer toda a transação.

BEGIN TRANSACTION;

-- Inserção de funcionário
INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
VALUES ('Carlos', 'M', 'Almeida', '98765432100', '1991-07-23', 'Av. Brasil, 500', 'M', 4500, NULL, 2);

-- Inserção de departamento
INSERT INTO DEPARTAMENTO (Dnumero, Dnome, Cpf_gerente, Data_inicio_gerente)
VALUES (10, 'Vendas', '98765432100', '2023-09-29');

-- Criar um SAVEPOINT antes da próxima operação
SAVE TRANSACTION SavePointProjeto;

-- Tentativa de inserção de projeto (falha por violação de chave primária)
INSERT INTO PROJETO (Projnumero, Projnome, Local, Dnumero)
VALUES (1, 'Desenvolvimento Software', 'São Paulo', 10); -- Chave duplicada (Projnumero = 1)

-- Verificar se houve erro
IF @@ERROR <> 0 
BEGIN
    -- Reverter apenas até o SAVEPOINT
    ROLLBACK TRANSACTION SavePointProjeto;
    PRINT 'Erro ao inserir projeto. Alterações anteriores mantidas.';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transação concluída com sucesso.';
END

--
