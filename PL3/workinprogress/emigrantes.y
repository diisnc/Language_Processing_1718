%{
#include <stdio.h>
#include <glib.h>
#include <string.h>
#include <ctype.h>
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

    // Look for emigrante, obra, or evento
    if (strcmp(g_array_index(node_data, char*, i), "emigrante") == 0 ||
        strcmp(g_array_index(node_data, char*, i), "obra") == 0 ||
        strcmp(g_array_index(node_data, char*, i), "evento") == 0
    ) {
      // Found!
      // Now pick back up on the "lastUsed" index and create the node

      // Start node
      printf("%s [label=\"{", g_array_index(node_data, char*, i+1));
      char* label;
      char* string;
      int startedWriting = 0;
      for (; lastUsed < i; lastUsed++) {

        label = g_array_index(node_data, char*, lastUsed);
        label[0] = toupper(label[0]); // Uppercase first char of label

        lastUsed++; // Go to next node_data token

        string = g_array_index(node_data, char*, lastUsed);

        if (strcmp(label, "Url") == 0) {
          break;
        }

        if (startedWriting) {
          printf(" | ");
        } else {
          startedWriting = 1;
        }

        printf("%s: %s", label, string);
      }

      // Finished wrting node
      // Print URL if we stopped on that field,
      // or just close the node if no URL found at the end
      if (strcmp(label, "Url") == 0) {
        printf("}\", URL=\"%s\"];\n", string);
        lastUsed += 3; // Move lastUsed 3 steps forward because we stopped at url
      } else {
        printf("}\"];\n");
        lastUsed += 2; // Move lastUsed 2 steps forward
      }
    }
  }

  // Print every edge
  for (unsigned int j = 0; j < edge_data->len; j++) {
    char* doer = g_array_index(edge_data, char*, j);
    j++;
    char* done = g_array_index(edge_data, char*, j);
    j++;
    char* action = g_array_index(edge_data, char*, j);

    printf("%s -> %s[label=\"%s\"]\n", doer, done, action);
  }

  // Close graph
  printf("}\n");

  return 0;
}

int yyerror(char* err) {
  fprintf(stderr,"Error: %s\nyytext: %s\nyylineno: %d\n",err,yytext,yylineno);
  return 0;
}
