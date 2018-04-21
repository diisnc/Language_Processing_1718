# Notas

Para sistematizar o trabalho que se pede em cada uma das propostas seguintes, considere que deve, em qualquer
um dos casos, realizar a seguinte lista de tarefas:

1. Especificar os padrões de frases que quer encontrar no texto-fonte, através de ERs.
2. Identificar as ações semânticas a realizar como reacçao ao reconhecimento de cada um desses padrões.
3. Identificar as Estruturas de Dados globais que possa eventualmente precisar para armazenar temporariamente
   a informação que vai extraindo do texto-fonte ou que vai construindo à medida que o processamento avança.
4. Desenvolver um Filtro de Texto para fazer o reconhecimento dos padrões identificados e proceder à transformação
   pretendida, com recurso ao Gerador FLex.

## a) Analisar e fazer contagem de categorias.

### Expressões Regulares

#### 1. `^@.+\{      { onCategoryDetection(yytext); }`

Um arroba no início da linha especifica a categoria da referência,
que termina numa chaveta.

Esta expressão regular captura qualquer sequência de caracteres (exceto nova linha) entre um arroba no início da linha e uma chaveta.

##### Ações Semânticas

Ao encontrar um match para esta expressão regular, queremos pegar no que está entre o arroba e a chaveta (fazer trim de yytext, que foi o texto
capturado), verificar se é uma das categorias de que estamos à procura, e se sim, aumentar o contador dessa categoria.

#### 2. `.|\n        { /* Ignore all other characters. */ }`

Captura todos os caracteres que não foram capturados pela expressão regular anterior.

##### Ações Semânticas

Queremos prevenir o `ECHO` por defeito de cada um destes caracteres, para não poluir o output.

### Estruturas de Dados Globais

* array de strings (char pointers) categories[], que contém as categorias a serem procuradas. Serve para listar as categorias que queremos contar.
* array de ints counters[], onde cada índice contém o contador relativo à categoria do mesmo índice no array categories. Serve para contar quantas vezes encontramos cada categoria.

### Filtro de Texto

Ficheiro `e1p1.l`.

### Como Correr

```text
flex e1p1.l
gcc -o e1p1 lex.yy.c -lfl
./e1p1 < exemplo-utf8.bib > result.html
```

`< exemplo-utf8.bib` troca o stdin pelo ficheiro `.bib`.

`> result.html` envia o stdout para a criação do ficheiro `result.html`.

## b) Filtrar a chave (1a palavra a seguir à chaveta), autores e título.

Nesta alínea, depois de terminar, tivemos de fazer o programa ignorar a capitalização dos campos
das entradas bibtex, por causa de uma entrada (só uma mesmo) que tinha os nomes dos campos em maiúsculas:

```text
@INPROCEEDINGS{CH2010a,
  AUTHOR =       {Daniela da Cruz and Pedro Rangel Henriques},
  TITLE =        {Exploring, Visualizing and Slicing the Soul of XML Documents},
  BOOKTITLE =    {Proceedings of 25th Symposium On Applied Computing - Document Engineering},
  YEAR =         {2010},
  note =         {to be published}
}
```

### Expressões Regulares

#### 1. `^@string\{                                     { /* Ignore @string */ }`

Com esta expressão regular capturamos as linhas que começam com "@string{".

##### Ações Semânticas

Queremos ignorar estas linhas, para que o programa não comece o processo de registo de uma nova entrada.

#### 2. `^@.+\{                                         { onCategoryDetection(yytext); BEGIN ID; }`

Um arroba no início da linha especifica a categoria da referência,
que termina numa chaveta.

Esta expressão regular captura qualquer sequência de caracteres (exceto nova linha) entre um arroba no início da linha e uma chaveta.

##### Ações Semânticas

Ao encontrar um match para esta expressão regular, queremos pegar no que está entre o arroba e a chaveta (aparar o primeiro e último caractere
de yytext, que foi o texto capturado), verificar se é uma das categorias de que estamos à procura, e se sim, aumentar o contador dessa categoria.

Para além disso, e em acréscimo ao que foi feito na alínea A, queremos entrar no contexto ID, que deve capturar a ID da entrada que acabamos de
detetar.

#### 2. `<ID>[^,]+                                      { onIDDetection(yytext); BEGIN INITIAL; }`

Esta expressão captura qualquer sequência de caracteres até uma vírgula, dentro do contexto ID.

##### Ações Semânticas

Queremos capturar a ID da entrada por que estamos a passar. No final, queremos voltar ao contexto inicial.

#### 3. `^[ ]*(author|AUTHOR)[ ]*=[ ]*                           BEGIN AUTHOR;`

Esta expressão captura qualquer linha começada por um número arbitrário de espaços, seguida de "author" em upper ou lower case
 e um "=", com um número também arbitrário de espaços antes e depois do igual.
É necessário lidar com author em upper ou lower case porque há uma entrada no ficheiro `exemplo-utf8.bib` (só uma) que tem
estes campos em maiúsculas.

##### Ações Semânticas

Queremos detetar o campo `author` e entrar no contexto que o captura.

#### 4. `^[ ]*(title|TITLE)[ ]*=[ ]*                            BEGIN TITLE;`

Esta expressão faz o mesmo que a anterior, mas em vez de capturar o autor, captura o título.

##### Ações Semânticas

Mais uma vez, queremos detetar o campo e entrar no contexto que o captura.

#### 5. `<AUTHOR>[{"](\{[^{}"]*\}|[^{}"])*[}"]  { onAuthorDetection(yytext); BEGIN INITIAL; }`

Esta expressão é a mais complicada do ficheiro.

Dentro do contexto AUTHOR, queremos capturar o valor do campo, que pode ser delimitado por chavetas ({}) ou aspas (""),
e que pelo meio pode ter "newlines" e mais um nível de profundidade de chavetas ({}), desde que sejam fechadas.

```text
[{"]  (  \{[^{}"]*\}  |  [^{}"]  )*  [}"]
1            2             3     4    1
```

1. Indica que o campo pode ser delimitado por chavetas ou aspas.
2. Indica que o campo pode conter chavetas fechadas com qualquer coisa lá dentro que não seja chavetas ou aspas. Provavelmente também não devem haver "newlines" dentro destas chavetas, mas isso não entra em conflito com os nossos objetivos, e o nosso trabalho não é validar o ficheiro.
3. Indica que o campo pode conter quaisquer caracteres que não chavetas ou aspas, incluindo "newlines".
4. Indica que 2. ou 3. podem ser repetidos 0 ou mais vezes.

##### Ações Semânticas

Queremos guardar o valor do campo autor da entrada pela qual estamos a passar, e de seguida voltar ao contexto inicial.

#### 6. `<TITLE>[{"](\{[^{}"]*\}|[^{}"])*[}"]   { onTitleDetection(yytext); BEGIN INITIAL; }`

Esta expressão é igual à anterior, mas acionada no contexto TITLE em vez de AUTHOR.

##### Ações Semânticas

Queremos guardar o título da entrada pela qual estamos a passar, e de seguida voltar ao contexto inicial.

#### 2\. `.|\n        { /* Ignore all other characters. */ }`

Captura todos os caracteres que não foram capturados pela expressão regular anterior.

##### Ações Semânticas

Queremos prevenir o `ECHO` por defeito de cada um destes caracteres, para não poluir o output.

### Estruturas de Dados Globais

* Arrays categories e counters, já usados na alínea a)
* Contador global entryCounter, que conta quantas entradas já foram registadas
* Arrays de strings ids, authors, e titles, que guardam os valores dos respetivos campos para cada entrada. O contador entryCounter é usado para guardar estes valores no índice correto.

### Filtro de Texto

Ficheiro `e1p2.l`.

### Como Correr

Igual ao `e1p1.l`.

## c) Criar um indíce de autores e as entradas em que aparecem, em plain text para ser "procurável" em linux.

### Expressões Regulares

#### `^@string\{                               { /* Ignore @string */ }`

Já usada na alínea B. Queremos ignorar linhas que começam em `@string{` para não entrar no
processo de captura de uma nova entrada.

#### `^@.+\{                                   { storeData(); BEGIN ID; }`

Já usada também!

#### `<ID>[^,]+                                { storeID(yytext); BEGIN INITIAL; }`

Já usada.

#### `^[ ]*(author|AUTHOR)[ ]*=[ ]*[{"]*       BEGIN AUTHOR;`

Já usada.

#### `^[ ]*(title|TITLE)[ ]*=[ ]*              BEGIN TITLE;`

Já usada.

#### Contexto AUTHOR

Enquanto que anteriormente Simplesmente apanhávamos o campo `author` inteiro com uma expressão regular,
agora queremos apanhar os autores um a um, pelo que precisamos de entrar num contexto especial.

O campo `author` pode conter mais do que um autor, sendo estes separados pela palavra "and".

##### `<AUTHOR>\{                               { oneCharOfAuthor("{"); BEGIN AUTHOR_BRACKET; }`

Enquanto estamos a apanhar um campo `author`, se encontrarmos uma chaveta, entramos no contexto `AUTHOR_BRACKET`.
O contexto `AUTHOR_BRACKET` é necessário porque se continuássemos dentro do contexto `AUTHOR`, daríamos o campo por
terminado quando encontrássemos a respetiva chaveta a fechar (}), o que faria com que o programa deixasse de funcionar
corretamente.

##### `<AUTHOR>[^{\n\r]                           { oneCharOfAuthor(yytext); }`

Enquanto estamos a apanhar um campo `author`, capturamos todos os caracteres que façam parte do nome (todos menos abre chaveta
e nova linha, sendo incluído também o `\r` para ser compatível com os newlines do ambiente linux).

*Ação semântica*: Adicionar o caractere atual à string que contém o nome do autor que estamos a guardar.

##### `<AUTHOR>[}"],                            BEGIN INITIAL;`

Enquanto estamos a apanhar um campo `author`, se encontrarmos uma "fechação" de chaveta ou uma aspa, damos como terminado o campo
e voltamos ao contexto inicial.

##### `<AUTHOR>[ \n\r]+and[ \n\r]+                  { anotherAuthor(); }`

Quando estamos a apanhar um campo `author`, queremos detectar a palavra "and" rodeada de espaços ou newlines, que significa que
de seguida vai aparecer o nome de um outro autor que faz parte da mesma obra.

*Ação semântica*: Guardar o autor anterior, e preparar o array de autores da obra atual com uma string vazia para começar a receber
o nome do próximo.

O "and" que separa os autores pode estar rodeado de espaços ou newlines. Inicialmente só planeamos para espaços,
e entradas como a seguinte faziam o programa escachar:

```text
author = {Diana Santos and Alberto Sim�es and Ana Frankenberg-Garcia and
   Ana Pinto and Anabela Barreiro and Belinda Maia and Cristina Mota and D�bora
   Oliveira and Eckhard Bick and Elisabete Ranchhod and J.J. Almeida
   and Lu�s Cabral and Lu�s Costa and Lu�s Sarmento and Marcirio Chaves and Nuno
   Cardoso and Paulo Rocha and Rachel Aires and Ros�rio Silva and Rui Vilela and
   Susana Afonso},
```

##### `<AUTHOR>\n                               { /* Ignore newlines in the middle of author names */ }`

Esta expressão ignora newlines no meio de nomes de autores, para que não apareçam nomes duplicados com newlines no meio.

##### `<AUTHOR_BRACKET>[^}]                     { oneCharOfAuthor(yytext); }`

Dentro do contexto `AUTHOR_BRACKET`, todos os caracteres menos chaveta a fechar (}) são
adicionados ao nome do autor.
Assumimos que os conteúdos de um bracket num campo autor não podem conter newlines.

##### `<AUTHOR_BRACKET>\}                       { oneCharOfAuthor("}"); BEGIN AUTHOR; }`

Dentro do contexto `AUTHOR_BRACKET`, uma chaveta a fechar significa que voltamos ao contexto `AUTHOR`.

#### `<TITLE>[{"](\{[^{}"]*\}|[^{}"])*[}"]     { storeTitle(yytext); BEGIN INITIAL; }`

Já usada, apanha o campo título.

#### `.|\n                                     { /* Ignore all other characters. */ }`

Já usada, ignora todos os outros caracteres não apanhados.

### Estruturas de Dados Globais

De uma maneira simples, este programa passa pelas entradas uma a uma,
e vai guardando a informação dos autores, título, e ID à medida que os atravessa.

Ao chegar uma nova entrada, esta informação é toda guardada, e é dado reset
às variáveis que guardam os valores da entrada atual.

`char* currentTitle;`

Guarda o título da entrada atual.

`char* currentID;`

Guarda a ID da entrada atual.

`char* currentAuthors[MAX_AUTHORS];`

Guarda a lista dos autores da entrada atual.

`int currentAuthorsLength = 0;`

Guarda o tamanho da lista dos autores da entrada atual.

`int startedWritingCurrentAuthor = 0;`

Uma flag que indica se já começamos a guardar os caracteres do autor atual.
Se a flag se encontra a zero, sabemos que temos de alocar espaço para uma
nova string que será colocada no array de autores.

`char* allAuthors[MAX_AUTHORS];`

Guarda os nomes de todos os autores encontrados. Juntamente com o array
`allWorks`, guarda os resultados que pretendemos obter.

`int allAuthorsLength = 0;`

Guarda o tamanho do array allAuthors.

`char* allWorks[MAX_AUTHORS];`

Guarda os trabalhos de cada autor em allAuthors no índice respetivo,
no formato "título por extenso (ID), outro título (outra ID), etc."

### Filtro de Texto

Ficheiro `e1p3.l`.

### Como Correr

Igual ao `e1p1.l`, só que a output é em `.txt` em vez de `.html`.

```text
flex e1p3.l
gcc -o e1p3 lex.yy.c -lfl
./e1p3 < exemplo-utf8.bib > result.txt
```

`< exemplo-utf8.bib` troca o stdin pelo ficheiro `.bib`.

`> result.txt` envia o stdout para a criação do ficheiro `result.txt`.
