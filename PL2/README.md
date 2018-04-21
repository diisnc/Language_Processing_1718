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

`> result.html` envia o stdout para a criação do ficheiro result.html.

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

Ao encontrar um match para esta expressão regular, queremos pegar no que está entre o arroba e a chaveta (fazer trim de yytext, que foi o texto
capturado), verificar se é uma das categorias de que estamos à procura, e se sim, aumentar o contador dessa categoria.

Para além disso, e em acréscimo ao que foi feito na alínea A, queremos entrar no contexto ID, que deve capturar a ID da entrada que acabamos de
detetar.

#### 2. `<ID>[^,]+                                      { onIDDetection(yytext); BEGIN INITIAL; }`

Esta expressão captura qualquer sequência de caracteres até uma vírgula, dentro do contexto ID.

##### Ações Semânticas

Queremos capturar a ID da entrada por que estamos a passar. No final, queremos voltar ao contexto inicial.

#### 3. `^[ ]*author[ ]*=[ ]*                           BEGIN AUTHOR;`

Esta expressão captura qualquer linha começada por um número arbitrário de espaços, seguida de "author" e um "=",
com um número também arbitrário de espaços antes e depois do igual.

##### Ações Semânticas

Queremos detetar o campo `author` e entrar no contexto que o captura.

#### 4. `^[ ]*title[ ]*=[ ]*                            BEGIN TITLE;`

Esta expressão faz o mesmo que a anterior, mas em vez de capturar o autor, captura o título.

##### Ações Semânticas

Mais uma vez, queremos detetar o campoe entrar no contexto que o captura.

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
4. Indica que 2. e 3. podem ser repetidos 0 ou mais vezes.

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
