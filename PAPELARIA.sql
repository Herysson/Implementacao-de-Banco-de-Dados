-- Apaga o banco de dados se ele já existir (facilita testes)
IF DB_ID('PapelariaDB') IS NOT NULL
BEGIN
    ALTER DATABASE PapelariaDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PapelariaDB;
END
GO

-- 1. Criação do Banco de Dados
CREATE DATABASE PapelariaDB;
GO

-- Mudar para o contexto do novo banco de dados
USE PapelariaDB;
GO

/*
================================================================================
Parte 1: DDL - Definição das Tabelas
================================================================================
*/

PRINT 'Iniciando criação das tabelas...';

-- Tabela de Categorias dos Produtos
CREATE TABLE Categorias (
    CategoriaID INT PRIMARY KEY IDENTITY(1,1),
    Nome NVARCHAR(100) NOT NULL UNIQUE
);
PRINT 'Tabela [Categorias] criada.';

-- Tabela de Fornecedores
CREATE TABLE Fornecedores (
    FornecedorID INT PRIMARY KEY IDENTITY(1,1),
    Nome NVARCHAR(150) NOT NULL,
    Contato NVARCHAR(100),
    Telefone NVARCHAR(20)
);
PRINT 'Tabela [Fornecedores] criada.';

-- Tabela de Clientes
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY IDENTITY(1,1),
    Nome NVARCHAR(150) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Telefone NVARCHAR(20),
    Endereco NVARCHAR(255),
	-- 'A' = Ativo, 'I' = Inativo
    Status CHAR(1) NOT NULL DEFAULT 'A', 
    CONSTRAINT CHK_StatusCliente CHECK (Status IN ('A', 'I')) 
);
PRINT 'Tabela [Clientes] criada.';

-- Tabela Principal de Produtos
CREATE TABLE Produtos (
    CodigoBarras VARCHAR(50) PRIMARY KEY NOT NULL, -- Nova PK
    Nome NVARCHAR(150) NOT NULL,
    Descricao NVARCHAR(500),
    PrecoVenda DECIMAL(10, 2) NOT NULL,
    QuantidadeEstoque INT NOT NULL DEFAULT 0,
    CategoriaID INT,
    FornecedorID INT,
    
    -- Definição das Chaves Estrangeiras (FKs)
    CONSTRAINT FK_Produtos_Categorias FOREIGN KEY (CategoriaID) REFERENCES Categorias(CategoriaID),
    CONSTRAINT FK_Produtos_Fornecedores FOREIGN KEY (FornecedorID) REFERENCES Fornecedores(FornecedorID),
    
    -- Restrição de Verificação (CHECK)
    CONSTRAINT CHK_PrecoVenda CHECK (PrecoVenda >= 0),
    CONSTRAINT CHK_QuantidadeEstoque CHECK (QuantidadeEstoque >= 0)
);
PRINT 'Tabela [Produtos] criada (PK = CodigoBarras).';

-- Tabela de Vendas (Cabeçalho da Venda)
CREATE TABLE Vendas (
    VendaID INT PRIMARY KEY IDENTITY(1,1),
    ClienteID INT,
    DataVenda DATETIME NOT NULL DEFAULT GETDATE(),
    ValorTotal DECIMAL(10, 2) NOT NULL DEFAULT 0,
    
    -- O ClienteID pode ser nulo para "Venda de Balcão"
    CONSTRAINT FK_Vendas_Clientes FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);
PRINT 'Tabela [Vendas] criada.';

-- Tabela de Itens da Venda
CREATE TABLE ItensVenda (
    VendaID INT NOT NULL,
    CodigoBarras VARCHAR(50) NOT NULL, 
    Quantidade INT NOT NULL,
    PrecoUnitario DECIMAL(10, 2) NOT NULL, -- Preço no momento da venda
    
    -- Chave Primária Composta alterada
    PRIMARY KEY (VendaID, CodigoBarras),
    
    -- Chaves Estrangeiras
    CONSTRAINT FK_ItensVenda_Vendas FOREIGN KEY (VendaID) REFERENCES Vendas(VendaID),
    
    -- FK agora aponta para Produtos(CodigoBarras)
    -- NOTA: Esta é a constraint que a Questão 3 irá alterar.
    CONSTRAINT FK_ItensVenda_Produtos FOREIGN KEY (CodigoBarras) REFERENCES Produtos(CodigoBarras), 
    
    -- Restrições
    CONSTRAINT CHK_Quantidade CHECK (Quantidade > 0)
);
PRINT 'Tabela [ItensVenda] criada (referenciando CodigoBarras).';

PRINT 'Estrutura DDL concluída.';
GO

/*
================================================================================
Parte 2: DML - População das Tabelas (Dados de Exemplo)
================================================================================
*/

PRINT 'Iniciando inserção de dados (DML)...';

-- Inserir Categorias (sem alteração)
INSERT INTO Categorias (Nome) VALUES
('Escrita'),
('Papelaria'),
('Organização'),
('Material Escolar'),
('Informática');
PRINT 'Dados inseridos em [Categorias].';

-- Inserir Fornecedores (sem alteração)
INSERT INTO Fornecedores (Nome, Contato, Telefone) VALUES
('Faber-Castell S.A.', 'Ana Silva', '(11) 98765-4321'),
('Tilibra Ltda.', 'Carlos Mendes', '(11) 91234-5678'),
('3M do Brasil (Post-it)', 'Mariana Costa', '(19) 99887-7665'),
('Multilaser', 'Ricardo Souza', '(11) 95555-4444');
PRINT 'Dados inseridos em [Fornecedores].';

-- Inserir Clientes (sem alteração)
INSERT INTO Clientes (Nome, Email, Telefone, Endereco) VALUES
('João Pereira', 'joao.pereira@email.com', '(21) 98888-1111', 'Rua das Flores, 123, Rio de Janeiro'),
('Maria Oliveira', 'maria.o@email.com', '(31) 97777-2222', 'Av. Principal, 456, Belo Horizonte'),
('Escola Aprender Mais', 'compras@aprendermais.edu.br', '(51) 96666-3333', 'Rua da Educação, 789, Porto Alegre');
PRINT 'Dados inseridos em [Clientes].';

-- Inserir Produtos
INSERT INTO Produtos (CodigoBarras, Nome, Descricao, PrecoVenda, QuantidadeEstoque, CategoriaID, FornecedorID) VALUES
('7891360643734', 'Caneta Esferográfica Azul 1.0mm', 'Caneta BIC cristal', 2.50, 150, 1, 1),
('7891027142474', 'Caderno Universitário 10 Matérias', 'Caderno capa dura 200 folhas', 22.90, 80, 4, 2),
('7891360600102', 'Lápis de Cor 12 Cores', 'Caixa de lápis de cor aquarelável', 18.00, 50, 1, 1),
('7891360643758', 'Caneta Esferográfica Vermelha 1.0mm', 'Caneta BIC cristal', 3.50, 150, 1, 1),
('0005113190827', 'Bloco de Notas Adesivas Amarelo', 'Bloco Post-it 76x76mm', 8.50, 200, 3, 3),
('7891360643741', 'Caneta Esferográfica Preta 1.0mm', 'Caneta BIC cristal', 3.00, 150, 1, 1),
('7891027205018', 'Grampeador Pequeno', 'Grampeador para 20 folhas, modelo G10', 15.00, 30, 3, 2),
('7891027145307', 'Resma Papel A4 Branco 75g', 'Pacote 500 folhas sulfite', 29.90, 100, 2, 2),
('7898506450419', 'Mouse Óptico USB', 'Mouse com fio 1200 DPI', 35.00, 40, 5, 4);
PRINT 'Dados inseridos em [Produtos].';
GO

-- Inserir Produtos 
-- Venda 1: Cliente 'João Pereira' (ID 1)
INSERT INTO Vendas (ClienteID, DataVenda, ValorTotal) 
VALUES (1, DATEADD(day, -5, GETDATE()), 0); -- VendaID será 1

INSERT INTO ItensVenda (VendaID, CodigoBarras, Quantidade, PrecoUnitario)
VALUES 
    (1, '7891360643734', 2, 2.50),  -- 2x Caneta Azul
    (1, '7891027142474', 1, 22.90); -- 1x Caderno
GO

-- Venda 2: 'Escola Aprender Mais' (ID 3)
INSERT INTO Vendas (ClienteID, DataVenda, ValorTotal) 
VALUES (3, DATEADD(day, -2, GETDATE()), 0); -- VendaID será 2

INSERT INTO ItensVenda (VendaID, CodigoBarras, Quantidade, PrecoUnitario)
VALUES 
    (2, '7891027145307', 10, 29.90), -- 10x Resma A4
    (2, '7891360643741', 30, 3.00);  -- 30x Caneta Preta
GO

-- Venda 3: Venda de Balcão (Cliente NULO) -- Venda de balcão
INSERT INTO Vendas (ClienteID, DataVenda, ValorTotal) 
VALUES (NULL, DATEADD(day, -1, GETDATE()), 0); -- VendaID será 3

INSERT INTO ItensVenda (VendaID, CodigoBarras, Quantidade, PrecoUnitario)
VALUES 
    (3, '7898506450419', 1, 35.00), -- 1x Mouse
    (3, '0005113190827', 3, 8.50);  -- 3x Bloco Adesivas
GO

-- Venda 4: Cliente 'Maria Oliveira' (ID 2)
INSERT INTO Vendas (ClienteID, DataVenda, ValorTotal) 
VALUES (2, GETDATE(), 0); -- VendaID será 4

INSERT INTO ItensVenda (VendaID, CodigoBarras, Quantidade, PrecoUnitario)
VALUES 
    (4, '7891360600102', 1, 18.00), -- 1x Lápis de Cor
    (4, '7891027205018', 1, 15.00); -- 1x Grampeador
GO
