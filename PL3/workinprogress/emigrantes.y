%{
#include <stdio.h>
#include <glib.h>
#include <string.h>
#include "y.tab.h"

extern int yylineno;
extern char* yytext;
extern int yylex();
int yyerror(char*);

// node_data vai guardar todos os tokens relacionados com nodos do grafo,
// na ordem em que foram recebidos.
// edge_data vai guardar todos os tokens relacionados com ligações do grafo.
// O trabalho de interpretar os conteúdos destes arrays (tendo em conta a ordem dos dados)
// é do for loop que itera sobre o array.
GArray* node_data; // Formato: ["nome", "joao alberto", "idade", "895", [...], "emigrante", "joao", [...]]
GArray* edge_data; // Formato: ["joao", "capela", "fez", "antonio", "baile", "participou"]
%}

%token OBJECT_TYPE STRING OBJECT_ID FIELD_ID FEZ PARTICIPOU ERR

%union{
  char* str;
}

%type <str> STRING OBJECT_TYPE OBJECT_ID FIELD_ID

%start OBJECTS

%%

OBJECTS : OBJECTS OBJECT
        | OBJECTS CONNECTION
        |
        ;

OBJECT : OBJECT_TYPE OBJECT_ID FIELDS        { char* one = strdup($1); char* two = strdup($2); g_array_append_val(node_data, one); g_array_append_val(node_data, two); }
       ;

FIELDS : FIELDS FIELD
       | FIELD
       ;

FIELD : FIELD_ID STRING                      { char* one = strdup($1); char* two = strdup($2); g_array_append_val(node_data, one); g_array_append_val(node_data, two); }
      ;

CONNECTION : OBJECT_ID FEZ OBJECT_ID         { char* one = strdup($1); char* three = strdup($3); char* f = "fez"; g_array_append_val(edge_data, one); g_array_append_val(edge_data, three); g_array_append_val(edge_data, f); }
           | OBJECT_ID PARTICIPOU OBJECT_ID  { char* one = strdup($1); char* three = strdup($3); char* p = "participou"; g_array_append_val(edge_data, one); g_array_append_val(edge_data, three); g_array_append_val(edge_data, p); }
           ;
%%

int main() {
  node_data = g_array_new( FALSE, TRUE, sizeof(char*));
  edge_data = g_array_new( FALSE, TRUE, sizeof(char*));
  yyparse();

  printf("\n\n\n\n\n=================== DOT OUTPUT ===================\n\n");

  // Graph header
  printf("digraph D {\n  node [shape=Mrecord fontname=\"Arial\"];\n  edge [fontname=\"Arial\"];\n");

  // Print every node
  // (unsigned int because node_data->len is a guint)
  unsigned int lastUsed = 0;
  for (unsigned int i = 0; i < node_data->len; i++) {

    if (strcmp(g_array_index(node_data, char*, i), "emigrante" ||
        strcmp(g_array_index(node_data, char*, i), "obra" ||
        strcmp(g_array_index(node_data, char*, i), "evento")
    {
      printf("%s [label=\"{", g_array_index(node_data, char*, i+1));
      for (; lastUsed < i; lastUsed++) {

        char* label = g_array_index(node_data, char*, lastUsed);
        // TODOOOOOO
        lastUsed++;
        char* string = g_array_index(node_data, char*, lastUsed);

        printf("%s", g_array_index(node_data, char*, i+1));

      }
    }

    i++;
    printf("%s [label="{", g_array_index(node_data, char*, i));


    // joao [label="{Antonio Joao Joaquim | Partida: 1904-09-13 | Destino: Brasil}", URL="http://google.com"];
  }

  // Print every edge
  for (unsigned int j = 0; j < edge_data->len; j++) {
    printf("%s\n", g_array_index(edge_data, char*, j));
  }

  printf("}\n");

  return 0;
}

int yyerror(char* err) {
  fprintf(stderr,"Error: %s\nyytext: %s\nyylineno: %d\n",err,yytext,yylineno);
  return 0;
}
