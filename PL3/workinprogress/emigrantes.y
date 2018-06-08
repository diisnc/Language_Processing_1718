%{
#include <stdio.h>
#include "y.tab.h"

extern int yylineno;
extern char* yytext;
extern int yylex();
int yyerror(char*);
%}

%token OBJECT_TYPE STR FEZ PARTICIPOU ERR

%union{
  char* str;
}

%type <str> STR OBJECT_TYPE

%start OBJECTS

%right STR

%%

OBJECTS : OBJECTS OBJECT
        | OBJECTS CONNECTION
        |
        ;

OBJECT : OBJECT_TYPE STR FIELDS     { printf("object with type: %s and id: %s\n", $1, $2); }
       ;

FIELDS : FIELDS FIELD
       | FIELD
       ;

FIELD : STR STR                  { printf("field: %s <==> %s\n", $1, $2); }
      ;

CONNECTION : STR FEZ STR         { printf("%s fez obra %s\n", $1, $3); }
           | STR PARTICIPOU STR  { printf("%s participou em %s\n", $1, $3 ); }
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
