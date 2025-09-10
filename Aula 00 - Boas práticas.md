## Padrões e Boas Práticas de Nomenclatura em SQL Server

Ao desenvolver em SQL para o SQL Server, a ausência de um padrão de nomenclatura oficial e obrigatório da Microsoft abre espaço para a adoção de convenções que visam a clareza, consistência e manutenibilidade do código. Embora não haja uma regra única, a comunidade de desenvolvedores e administradores de banco de dados consolidou um conjunto de boas práticas amplamente aceito.

A regra de ouro é: **escolha um padrão e seja consistente em todo o projeto.**

A seguir, estão detalhadas as boas práticas e os padrões mais comuns para a nomeação de objetos em um banco de dados SQL Server.

### Regras Gerais (Aplicáveis a Todos os Objetos)

* **Clareza e Significado:** Os nomes devem ser descritivos e autoexplicativos. Evite abreviações excessivas ou enigmáticas (ex: `NomeCliente` em vez de `nmcli`).
* **Sem Espaços ou Caracteres Especiais:** Não utilize espaços, acentos, hifens ou outros caracteres especiais. Para separar palavras, prefira `PascalCase` ou `snake_case`.
* **Evite Palavras-Chave Reservadas:** Nunca nomeie um objeto com uma palavra reservada do SQL, como `SELECT`, `TABLE`, `CREATE`, `INDEX`, etc.
* **Idioma:** Mantenha um único idioma para todos os objetos do banco de dados, preferencialmente o português ou o inglês, dependendo do contexto da equipe e do projeto.

---

### Padrões Específicos por Objeto

#### 1. Tabelas (Tables)

A nomeação de tabelas é um dos pontos com maior debate, principalmente entre o uso de singular e plural.

* **Convenção (Recomendada):** `PascalCase`, Singular.
    * **Exemplos:** `Cliente`, `Produto`, `Pedido`, `NotaFiscal`
    * **Justificativa:** A tabela representa a entidade ou o "molde" para um único registro. Fica mais natural e legível em instruções SQL, como `SELECT C.Nome FROM Cliente C`.
* **Alternativa (Comum):** `PascalCase`, Plural.
    * **Exemplos:** `Clientes`, `Produtos`, `Pedidos`, `NotasFiscais`
    * **Justificativa:** A tabela armazena uma coleção de registros.
* **Tabelas Associativas (N:N):** Geralmente, o nome é a concatenação das duas tabelas que ela relaciona, em `PascalCase`.
    * **Exemplos:** `PedidoProduto`, `AlunoCurso`

**Má Prática:** Evite o uso de prefixos como `tbl_` ou `TB_` (ex: `tbl_Cliente`). Isso adiciona ruído desnecessário, já que o tipo do objeto é facilmente identificável no SQL Server Management Studio (SSMS) ou pelo contexto da query.

#### 2. Colunas (Columns)

* **Convenção:** `PascalCase`.
    * **Exemplos:** `Nome`, `DataNascimento`, `ValorTotal`, `EnderecoEmail`
* **Chave Primária (Primary Key - PK):** O padrão mais comum é `NomeDaTabelaID` ou simplesmente `ID` se o contexto for inequívoco (embora o primeiro seja mais explícito e melhor para `JOINs`).
    * **Exemplos:** `ClienteID`, `ProdutoID`
* **Chave Estrangeira (Foreign Key - FK):** O nome deve corresponder exatamente ao nome da chave primária da tabela referenciada.
    * **Exemplo:** Na tabela `Pedido`, a coluna que referencia a tabela `Cliente` deve se chamar `ClienteID`.
* **Colunas Booleanas:** Dê nomes que sugiram uma pergunta de sim/não.
    * **Exemplos:** `Ativo`, `FlagExcluido`, `PermiteEnvioEmail`

#### 3. Procedimentos Armazenados (Stored Procedures)

* **Convenção:** Usar um prefixo, seguido por um nome que indica a ação (verbo) e o objeto sobre o qual a ação é executada. O padrão `PascalCase` é o mais comum.
* **Prefixo:** É altamente recomendável usar um prefixo como `usp_` (User Stored Procedure) ou `sp_` seguido de um nome não conflitante.
    * **Atenção:** Evite o prefixo `sp_` para procedimentos que não estão no banco de dados `master`. O SQL Server procura primeiro no `master`, o que pode causar uma pequena perda de performance ("procedure cache lookup miss"). O prefixo `usp_` é uma alternativa segura e popular.
* **Padrão de Nomeação:** `Prefixo_VerboObjeto`
    * **Exemplos:**
        * `usp_SelecionarClientePorID`
        * `usp_InserirNovoPedido`
        * `usp_AtualizarEstoqueProduto`
        * `usp_ExcluirNotaFiscal`

#### 4. Funções (Functions)

A nomeação de funções segue um padrão semelhante ao de Stored Procedures, mas com prefixos diferentes para distingui-las.

* **Convenção:** `Prefixo_NomeDescritivo`
* **Prefixos Comuns:**
    * `fn_` para todos os tipos de função.
    * `udf_` (User Defined Function).
    * Prefixos mais específicos como `ufn_` (User Function), `sfn_` (Scalar Function) ou `tfn_` (Table-valued Function).
* **Exemplos:**
    * `fn_CalcularIdade`
    * `fn_ObterNomeCompletoUsuario`
    * `fn_ListarProdutosEmEstoque` (para uma função com valor de tabela)

#### 5. Gatilhos (Triggers)

O nome de um gatilho deve deixar claro a qual tabela ele pertence, qual evento o dispara e, opcionalmente, sua ordem.

* **Convenção:** `Prefixo_NomeDaTabela_Evento`
* **Prefixo Comum:** `TR_` ou `trg_`
* **Evento:** `AfterInsert`, `AfterUpdate`, `AfterDelete`, `InsteadOfInsert`, etc.
* **Exemplos:**
    * `TR_Produto_AfterUpdate`
    * `TR_Pedido_AfterInsert`
    * `TR_NotaFiscalItem_InsteadOfDelete`

#### 6. Views

* **Convenção:** `Prefixo_NomeDescritivo`
* **Prefixo Comum:** `vw_` ou `v_`
* **Exemplos:**
    * `vw_ClientesAtivos`
    * `vw_RelatorioVendasMensal`
    * `vw_DetalhesPedidoProduto`

#### 7. Índices (Indexes) e Constraints

* **Convenção:** `Prefixo_NomeTabela_ColunasEnvolvidas`
* **Prefixos Comuns:**
    * **PK\_**: Primary Key
    * **FK\_**: Foreign Key
    * **IX\_**: Index (não clusterizado)
    * **UX\_**: Unique Index / Unique Constraint
    * **CK\_**: Check Constraint
    * **DF\_**: Default Constraint
* **Exemplos:**
    * `PK_Cliente`: Chave primária da tabela `Cliente`.
    * `FK_Pedido_Cliente`: Chave estrangeira na tabela `Pedido` referenciando `Cliente`.
    * `IX_Cliente_Nome`: Índice na coluna `Nome` da tabela `Cliente`.
    * `UX_Usuario_Email`: Constraint de unicidade na coluna `Email` da tabela `Usuario`.
