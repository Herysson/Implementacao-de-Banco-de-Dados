IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'BIBLIOTECA')
BEGIN
    CREATE DATABASE [BIBLIOTECA];
END
GO

USE BIBLIOTECA;
GO

/*Cria todas as tabelas do banco de dados  - Categoria - Autor - Editora - Livro - LivroAutor*/
CREATE TABLE [Categoria] (
  [id] int not null identity,
  [tipo_categoria] varchar(50) not null unique,
  PRIMARY KEY ([id])
);

CREATE TABLE [Autor] (
  [id] int not null identity,
  [nome] varchar(100) not null,
  [nacionalidade] varchar(50),
  PRIMARY KEY ([id])
);

CREATE TABLE [Editora] (
  [id] int not null identity,
  [nome] varchar(100) unique,
  PRIMARY KEY ([id])
);

/*existe uma peculiaridade nesta tabela o isbn é um valor inteiro, mas um int possui 4 bytes comporta somente 
valores entre -2147483648 to +2147483647, logo não podemos setar o isb como int. Para solucionar isto podemos
utilizar varhcar ou bigint */
CREATE TABLE [Livro] (
  [isbn] varchar (50) not null,
  [titulo] varchar (100) not null,
  [ano] int not null,
  [fk_editora] int not null,
  [fk_categoria] int not null,
  PRIMARY KEY ([isbn]),
  CONSTRAINT [FK_Livro.fk_categoria]
    FOREIGN KEY ([fk_categoria])
      REFERENCES [Categoria]([id]),
  CONSTRAINT [FK_Livro.fk_editora]
    FOREIGN KEY ([fk_editora])
      REFERENCES [Editora]([id])
);

CREATE TABLE [LivroAutor] (
  [id] int not null identity,
  [fk_autor] int not null,
  [fk_livro] varchar(50) not null,
  PRIMARY KEY ([id]),
  CONSTRAINT [FK_LivroAutor.fk_autor]
    FOREIGN KEY ([fk_autor])
      REFERENCES [Autor]([id]),
  CONSTRAINT [FK_LivroAutor.fk_livro]
    FOREIGN KEY ([fk_livro])
      REFERENCES [Livro]([isbn])
);

select * from Livro;

/*Abaixo todas as inserções das tabela do banco de dados
Insere valores na tabela categoria
INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...);*/

insert into categoria (tipo_categoria) values ('Literatura Juvenil');
insert into categoria (tipo_categoria) values ('Ficção Científica');
insert into categoria (tipo_categoria) values ('Humo');
insert into categoria (tipo_categoria) values ('Ação');
insert into categoria (tipo_categoria) values ('Romance');


/*Altera o atributo da tabela categoria onde o id é 3 */
update categoria
set tipo_categoria = 'Humor'
where id = 3;

/*Insere valores na tabela autor*/
insert into autor (nome) values ('J.K. Rowling');
insert into autor (nome, nacionalidade) values ('Clive Staples Lewis','Inglaterra');
insert into autor (nome, nacionalidade) values ('Affonso Solano','Brasil');
insert into autor (nome, nacionalidade) values ('Marcos Piangers','Brasil');
insert into autor (nome, nacionalidade) values ('Ciro Botelho - Tiririca','Brasil');
insert into autor (nome, nacionalidade) values ('Bianca Mól','Brasil');

/*Insere valores na tabela editora*/
insert into editora (nome) values ('Rocco');
insert into editora (nome) values ('Wmf Martins Fontes');
insert into editora (nome) values ('Casa da Palavra');
insert into editora (nome) values ('Belas Letras');
insert into editora (nome) values ('Matrix');

/*Insere valores na tabela de livros*/
insert into livro values('8532511015','Harry Potter e A Pedra Filosofal','2000',1,1);
insert into livro values('9788578270698','As Crônicas de Nárnia','2009',2,1);
insert into livro values('9788577343348','O Espadachim de Carvão','2013',3,2);
insert into livro values('9788581742458','O Papai é Pop','2015',4,3);
insert into livro values('9788582302026','Pior Que Tá Não Fica','2015',5,3);
insert into livro values('9788577345670','Garota Desdobrável','2015',3,1);
insert into livro values('8532512062','Harry Potter e o Prisioneiro de Azkaban','2000',1,1);

/*Insere valores na tabela livroautor - Relaçãoo de cada livro com seu respectivo autor*/
insert into livroautor (fk_livro, fk_autor) values('8532511015',1);
insert into livroautor (fk_livro, fk_autor) values('9788578270698',2);
insert into livroautor (fk_livro, fk_autor) values('9788577343348',3);
insert into livroautor (fk_livro, fk_autor) values('9788581742458',4);
insert into livroautor (fk_livro, fk_autor) values('9788582302026',5);
insert into livroautor (fk_livro, fk_autor) values('9788577345670',6);
insert into livroautor (fk_livro, fk_autor) values('8532512062',1);

/*Exemplo de inserçãoo errada, aqui vinculamos 
o livro Harry Potter e o Prisioneiro de Azkabam ao autor Clive Staples*/
insert into livroautor (fk_livro, fk_autor) values('8532512062',2);
/*Exemplo de como removemos o registro que estava errado.*/
delete from livroautor where fk_livro = '8532512062' and fk_autor = 2;

/*Selects para verificação do preenchimento das tabelas*/
select * from livro;
select * from autor;
select * from categoria;
select * from editora;
select * from livroautor;

/*Este select recupera todos os livros da categoria "Literaturo Juvenil"*/
select livro.titulo, categoria.tipo_categoria
from livro, categoria
where livro.fk_categoria = categoria.id
and categoria.tipo_categoria = 'Literatura Juvenil';

/*Este Select recupera todos os registros dos livros escritos por J.K Rowling*/
select livro.titulo, autor.nome
from livro, autor, livroautor
where livroautor.fk_autor = autor.id
and livroautor.fk_livro = livro.isbn
and autor.nome like '%Rowl%';

/*Exercício 7:
Crie uma consulta para relacionar todos os dados disponíveis de todos os livros existêntes na biblioteca em 
ordem alfabética.*/
/*neste select recuperamso somente as informações contidas na tabela livros, mas por exemplo o nome da 
editora o nome da categoria estão representado pelos id's*/
select * from livro;
/*recuperando informações da editora e da categoria*/
select	livro.isbn as 'ISBN', livro.titulo as 'Título', livro.ano as 'Ano', editora.nome as 'Editora', 
categoria.tipo_categoria as 'Categoria'
from livro, editora, categoria
where livro.fk_editora = editora.id
and livro.fk_categoria = categoria.id
order by livro.titulo;
/*recuperando as informações referente aos autores*/
/*Este Select recupera todos os dados da mesma forma atrenstada no exercício
o as é utilizado para modificar o nome da couna onde os valores serão apresentados
a funcção concat é para concatenar (agrupar os valores e uma mesma coluna). os valoer que estão como nullos 
é devido a uma das colunas possuir valor nullo no caso a nascionalidad de autor J.K. no foi preenchida.
*/
select livro.isbn as 'ISBN', livro.titulo as 'Título', livro.ano as 'Ano', editora.nome as 'Editora', 
concat(autor.nome, ' (' ,autor.nacionalidade, ')') as  'Autor/Nascionalidade',categoria.tipo_categoria as 'Categoria'
from livro, editora, categoria, autor, livroautor
where livro.fk_editora = editora.id
and livro.fk_categoria = categoria.id
and livroautor.fk_autor = autor.id
and livroautor.fk_livro = livro.isbn
order by livro.titulo;

/*adicionando uma nascionalidade ao Autor J.K. Roliwn , após este comando utilize nomvamente o comando acima ^*/
update autor
set autor.nacionalidade = 'Inglaterra'
where autor.id = 1;

/*Exercício 8:
Crie uma consulta para relacionar todos os dados dos livros disponíveis na biblioteca em ordem alfabéticas
de Autor*/
select livro.isbn as 'ISBN', livro.titulo as 'Título', livro.ano as 'Ano', editora.nome as 'Editora', 
concat(autor.nome, ' (' ,autor.nacionalidade, ')') as  'Autor/Nascionalidade',categoria.tipo_categoria as 'Categoria'
from livro, editora, categoria, autor, livroautor
where livro.fk_editora = editora.id
and livro.fk_categoria = categoria.id
and livroautor.fk_autor = autor.id
and livroautor.fk_livro = livro.isbn
order by autor.nome;

/*Exercício 9:
Crie uma consulta para relacionar todos os dados disponíveis dos livros da categoria de literatura Juvenil 
em ordem de ano*/
select livro.isbn as 'ISBN', livro.titulo as 'Título', livro.ano as 'Ano', editora.nome as 'Editora', 
concat(autor.nome, ' (' ,autor.nacionalidade, ')') as  'Autor/Nascionalidade',categoria.tipo_categoria as 'Categoria'
from livro, editora, categoria, autor, livroautor
where livro.fk_editora = editora.id
and livro.fk_categoria = categoria.id
and livroautor.fk_autor = autor.id
and livroautor.fk_livro = livro.isbn
and categoria.tipo_categoria like '%Juve%'
order by livro.ano;

/*Exercício 10
Crie uma consulta para relacionar todos os dados disponíveis dos livros de humor ou ficção cientifica 
com ano entre 2000 e 2010
Altere a data máxima para 2015 para que possamos ter alguma informação recuperada.
*/
select livro.isbn as 'ISBN', livro.titulo as 'Título', livro.ano as 'Ano', editora.nome as 'Editora', 
concat(autor.nome, ' (' ,autor.nacionalidade, ')') as  'Autor/Nascionalidade',categoria.tipo_categoria as 'Categoria'
from livro, editora, categoria, autor, livroautor
where livro.fk_editora = editora.id
and livro.fk_categoria = categoria.id
and livroautor.fk_autor = autor.id
and livroautor.fk_livro = livro.isbn
and categoria.tipo_categoria in ('Humor', 'Ficçã Científica')
and livro.ano between 2000 and 2015
order by livro.ano;



