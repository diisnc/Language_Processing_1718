%{
#include <stdio.h>
#include "y.tab.h"
#include "stack.h"

extern int yylineno;
extern char* yytext;
extern int yylex();
int yyerror(char*);

int unloadAndPrint();
int sumStack(int levels);

Stack* stack;
%}

%token WORDSIZE PUSH POP UNLOAD PRINT TOP SUM ERR INT

%union{
    int num;
}

%type <num> INT

%start INSTRUCTIONS

%%

INSTRUCTIONS : INSTRUCTIONS INSTRUCTION '\n'
             |
             ;

INSTRUCTION : PUSH INT  { stackPush(stack,$2); }
            | POP       { stackPop(stack); }
            | PRINT TOP { printf("top: %d\n",stackTop(stack)); }
            | UNLOAD    { unloadAndPrint(); }
            | SUM INT   { printf("sum: %d\n",sumStack($2)); }
            ;
%%

int unloadAndPrint () {
    printf("Unloading stack\n");
    while (!stackIsEmpty(stack)) {
        printf("- %d\n",stackPop(stack));
    }
}

int sumStack (int levels) {
    int sum = 0;

    for (int i = 0; i < levels; i++, sum += stackPop(stack));

    return sum;

}

int main() {
    stack = stackCreate();
    yyparse();
    stackDestroy(stack);
    return 0;
}

int yyerror(char* err) {
    fprintf(stderr,"%s, %s, %d\n",err,yytext,yylineno);
    return 0;
}
