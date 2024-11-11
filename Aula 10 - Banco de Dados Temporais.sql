CREATE DATABASE DB_Temporal;
USE DB_Temporal;
IF OBJECT_ID('dbo.InventarioCarros', 'U') IS NOT NULL 
BEGIN
	-- Ao excluir uma tabela temporal, precisamos primeiro desativar o controle de versão
    ALTER TABLE [dbo].[InventarioCarros] SET ( SYSTEM_VERSIONING = OFF  ) 
    DROP TABLE dbo.InventarioCarros
    DROP TABLE dbo.HistoricoInventarioCarros
END
CREATE TABLE InventarioCarros  
(    
    CarroId INT IDENTITY PRIMARY KEY,
    Ano INT,
    Marca VARCHAR(40),
    Modelo VARCHAR(40),
    Cor varchar(10),
    Quilometragem INT,
    Disponivel BIT NOT NULL DEFAULT 1,
    SysStartTime datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    SysEndTime datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)     
)   
WITH 
( 
	--provividencia um nome para a tabela de históricos
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.HistoricoInventarioCarros)   
)

/*As principais coisas a serem observadas com nossa nova tabela acima são que:
1- Ela contém uma CHAVE PRIMÁRIA.
2- Ela contém dois campos datetime2, marcados com GENERATED ALWAYS AS ROW START/END .
3- Ela contém a instrução PERIOD FOR SYSTEM_TIME.
4 -Ela contém a propriedade SYSTEM_VERSIONING = ON com o nome da tabela histórica (opcional) ( dbo.InventarioCarros).*/

--Se consultarmos nossas tabelas recém-criadas, você notará que nossos layouts de coluna são idênticos:
SELECT * FROM dbo.InventarioCarros;
SELECT * FROM dbo.HistoricoInventarioCarros;

--Vamos preenchê-lo com os carros mais escolhidos das agências de locação de carros em todo o Brasil
Insert into dbo.InventarioCarros (Ano,Marca,Modelo,Cor,Quilometragem,Disponivel) 
values (2004, 'Fiat', 'Uno', 'Branco', 150000, 1);
Insert into dbo.InventarioCarros (Ano,Marca,Modelo,Cor,Quilometragem,Disponivel) 
values (2015, 'Ford', 'Ka', 'Preto', 30000, 1);
Insert into dbo.InventarioCarros (Ano,Marca,Modelo,Cor,Quilometragem,Disponivel) 
values (2022, 'Hyundai', 'HB20', 'Prata', 0, 1);
Insert into dbo.InventarioCarros (Ano,Marca,Modelo,Cor,Quilometragem,Disponivel) 
values (2022, 'Hyundai', 'HB20', 'Branco', 0, 1);

--Verificando os valor inserido em ambas tabelas
SELECT * FROM dbo.InventarioCarros;
SELECT * FROM HistoricoInventarioCarros;

/*Em todas as pesquisas restantes, o resultado superior é nossa tabela temporal dbo.InventarioCarro 
e o resultado inferior é nossa tabela histórica dbo.HistoricoInventarioCarros .

Você notará que, como inserimos apenas uma linha para cada carro, ainda não há histórico de linha e, portanto,
nossa tabela histórica está vazia.*/

--Vamos mudar isso conseguindo alguns clientes e alugando nossos carros
UPDATE dbo.InventarioCarros SET Disponivel = 0 WHERE CarroId = 1;
UPDATE dbo.InventarioCarros SET Disponivel = 0 WHERE CarroId = 4;

--Verificando os valores das tabelas após a Locação dos veículos
SELECT * FROM dbo.InventarioCarros;
SELECT * FROM HistoricoInventarioCarros;

/*Agora vemos nossa tabela temporal funcionando: atualizamos as linhas em dbo.CarInventory e nossa tabela 
histórica foi atualizada automaticamente com nossos valores originais, bem como os timestamps de quanto 
tempo essas linhas existiram em nossa tabela.*/

--Depois de um tempo, nossos clientes devolvem seus carros alugados:
UPDATE dbo.InventarioCarros SET Disponivel = 1, Quilometragem = 160000 WHERE CarroId = 1;
UPDATE dbo.InventarioCarros SET Disponivel = 1, Quilometragem = 3000 WHERE CarroId = 4;

--Verificando os valores das tabelas após a devolução dos carros Locados
SELECT * FROM dbo.InventarioCarros;
SELECT * FROM HistoricoInventarioCarros;

/*Nossa tabela temporal mostra o estado atual de nossos carros alugados: os clientes devolveram os carros 
ao nosso estacionamento e cada carro acumulou alguma quilometragem.

Enquanto isso, nossa tabela histórica obteve uma cópia das linhas de nossa tabela temporal logo antes de nossa 
última instrução UPDATE. Está automaticamente acompanhando todo esse histórico para nós!*/

--Continuando, os negócios vão bem na locadora. Conseguimos outro cliente para alugar nosso prata UNO
UPDATE dbo.InventarioCarros SET Disponivel = 0 WHERE CarroId = 1;

--Verificando os valores das tabelas após a Locação do Uno
SELECT * FROM dbo.InventarioCarros;
SELECT * FROM HistoricoInventarioCarros;

--Infelizmente, nosso segundo cliente sofre um acidente e destrói nosso carro:
DELETE FROM dbo.InventarioCarros WHERE CarroId = 1;

--Verificando os valores das tabelas após o acidente
SELECT * FROM dbo.InventarioCarros;
SELECT * FROM HistoricoInventarioCarros;

/*Com a exclusão de nosso UNO, nossos dados de teste estão completos.
Agora que temos todos esses ótimos dados rastreados historicamente, como podemos consultá-los?

Se quisermos relembrar tempos melhores quando ambos os carros estavam livres de danos 
e estávamos ganhando dinheiro:podemos escrever uma consulta usando SYSTEM_TIME AS OF 
para nos mostrar como era nossa tabela naquele momento no passado:*/

-- Olhando para um estado no passado utilizando SYSTEM_TIME AS OF
SELECT * FROM dbo.InventarioCarros
FOR SYSTEM_TIME AS OF '2022-08-16 17:46:00' ORDER BY Carroid;

--Recupera todo o histórico de um Veículo
SELECT * FROM InventarioCarros
  FOR SYSTEM_TIME ALL 
  WHERE CarroId = 1

/*E se quisermos fazer uma análise mais detalhada, como quais linhas foram excluídas, 
também podemos consultar tabelas temporais e históricas normalmente:*/

--Encontre os CarIds de carros que foram destruídos e excluídos
SELECT DISTINCT
    h.CarroId AS DeletedCarId
FROM
    dbo.InventorioCarros t
    RIGHT JOIN dbo.HistoricoInventorioCarros h
    ON t.CarroId = h.CarroId 
WHERE 
    t.CarroId IS NULL

--Conclusão
/*Mesmo com meu negócio de aluguel de carros não dando certo, pelo menos é possivel ver como as tabelas temporais 
do SQL Server nos ajudaram a acompanhar nossos dados de inventário de carros.*/
