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

Eu cheira-me que o professor nesta alínea queria que nós metessemos uma expressão regular para cada categoria, e que incrementássemos o contador de cada uma ao haver match. Só que aí íamos ter de repetir as categorias para as expressões regulares e para os contadores, e possivelmente mais uma vez para saber quais são dentro do código C, para imprimir no HTML.

Por causa disso, afinal acho que se calhar não queria nada dessa maneira.
Mesmo que quisesse, sabemos explicar que fizemos assim porque é mais simples e só se escreve as categorias uma vez no ficheiro, no array categories.

### Expressões Regulares

#### 1\. **`^@(.*)\{`**

Um arroba no início da linha especifica a categoria da referência,
que termina numa chaveta.

Esta expressão regular captura qualquer sequência de caracteres (exceto nova linha) entre um arroba no início da linha e uma chaveta.

##### Ações Semânticas

Ao encontrar um match para esta expressão regular, queremos pegar no que está entre o arroba e a chaveta, verificar se é uma das categorias de que estamos à procura, e se sim, aumentar o contador dessa categoria.

#### 2\. **`.|\n`**

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

Notas para esta alínea: isto é estúpido, estamos a fazer manipulação de strings em C basicamente, a fazer cenas malucas com FLex que não são para o que a ferramenta foi inventada. Será que estou a fazer isto mal?? I don't think so!!!

### Expressões Regulares

#### 1\. **`^@(.*)\{`**

Um arroba no início da linha especifica a categoria da referência,
que termina numa chaveta.

Esta expressão regular captura qualquer sequência de caracteres (exceto nova linha) entre um arroba no início da linha e uma chaveta.

##### Ações Semânticas

Ao encontrar um match para esta expressão regular, queremos pegar no que está entre o arroba e a chaveta, verificar se é uma das categorias de que estamos à procura, e se sim, aumentar o contador dessa categoria.

#### 2\. **`.|\n`**

Captura todos os caracteres que não foram capturados.

##### Ações Semânticas

Queremos prevenir o `ECHO` por defeito de cada um destes caracteres, para não poluir o output.

### Estruturas de Dados Globais

* array de strings (char pointers) categories[]
* array de ints counters[]

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

