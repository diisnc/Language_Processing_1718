%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>

int codigos[100] = {0};
int i = 0;

extern int yylex();
int yyerror(char* erro);
void validaCodigos(int);
%}


%token BRIEF CODIGO TAREFAS AGENDA BAIXA MEDIA ALTA ID STR NUM ERR

%union{
    char* str;
    int num;
}

%type<num> NUM


%%

SECRETARIA : LISTA_FUNCIONARIOS
             LISTA_TAREFAS
           ;

LISTA_FUNCIONARIOS : BRIEF ':' '[' TRIPLOS_FUNC ']'
                   ;

TRIPLOS_FUNC : TRIPLOS_FUNC ',' TRIPLO_FUNC
             | TRIPLO_FUNC
             ;

TRIPLO_FUNC : STR ',' NUM ',' STR { codigos[i++] = $3;};

LISTA_TAREFAS : AGENDA ':' '{' GRUPOS_TAREFAS '}'
              ;

GRUPOS_TAREFAS : GRUPOS_TAREFAS ',' TAREFA_FUNC
               | TAREFA_FUNC
               ;

TAREFA_FUNC : '{' CODIGO ':' NUM ',' { validaCodigos($4); }
                  TAREFAS ':' '{'
                                ESCPS_TAREFA
                              '}'
              '}'
              ;

ESCPS_TAREFA : ESCPS_TAREFA_CHEIO
             |
             ;

ESCPS_TAREFA_CHEIO : ESCPS_TAREFA_CHEIO ',' ESCP_TAREFA
                   | ESCP_TAREFA
             ;
ESCP_TAREFA : '{' NUM ',' NUM ',' PRIO ',' STR '}';
            ;
PRIO : ALTA
     | MEDIA
     | BAIXA
     ;
%%

void validaCodigos(int num) {
    int match = 0;

    for (int j = 0; j < i && match==0; j++) {
        if (codigos[j] == num) {
            match = 1;
        }
    }

    if (!match) {
        printf("ERRO! Id %d não existe.\n",num);
        exit(0);
    }

}

int yyerror(char* erro) {
     printf("%s\n",erro);
     return 0;
}

int main() {
    yyparse();
    return 0;
}
