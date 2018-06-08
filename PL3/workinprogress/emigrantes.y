%{
#include <stdio.h>
#include <glib.h>
#include "y.tab.h"

extern int yylineno;
extern char* yytext;
extern int yylex();
int yyerror(char*);
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

OBJECT : OBJECT_TYPE OBJECT_ID FIELDS     { printf("object with type: %s and id: %s\n", $1, $2); }
       ;

FIELDS : FIELDS FIELD
       | FIELD
       ;

FIELD : FIELD_ID STRING                  { printf("field: %s <==> %s\n", $1, $2); }
      ;

CONNECTION : OBJECT_ID FEZ OBJECT_ID         { printf("%s fez obra %s\n", $1, $3); }
           | OBJECT_ID PARTICIPOU OBJECT_ID  { printf("%s participou em %s\n", $1, $3 ); }
           ;
%%

int main() {
    yyparse();
    return 0;
}

int yyerror(char* err) {
    fprintf(stderr,"Error: %s\nyytext: %s\nyylineno: %d\n",err,yytext,yylineno);
    return 0;
}
