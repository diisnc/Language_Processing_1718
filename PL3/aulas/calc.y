%{
#include <stdio.h>
#include <math.h>
extern int yylex();
extern char *yytext;
extern int yylineno;
void yyerror(char*);
double tab[26];
int contaCiclos = 0;
%}

%union{
  char id;
  int num;
}

%type <id> ID
%type <num> NUM Factor Termo Exp

%token ID NUM ERRO REPETE FIM PRINT READ
%token ENQUANTO OR AND NOT EQ NEQ GE GT LE LT

%%
Calc : { printf("\tpushn 26\n"); 
         printf("\tpushn 10\n"); /* Controlo de ciclos */
         printf("start\n"); 
       }
       ComList { printf("fim: stop\n");} ;

ComList : ComList Comando  
       | 
       ;

Comando : Atrib
        | Escrita
        | Leitura
        | RepeteN
        | Enquanto
        | Se
        ;

Se : SE '(' Cond ')'
     {/* salto para o senão */}
     '{' ComList '}'
      Senao;

Senao: SENAO 
       {/* gera a label senao */}
       '{' ComList '}'
       {/* gera label fse */}
       ;

Enquanto: ENQUANTO
          {
            contaCiclos++;         
            printf("enquanto%d: ", contaCiclos);
          }
          '(' Cond ')'
          {
            printf("\tjz fenquanto%d\n", contaCiclos);
          }
          '{' ComList '}' 
          {
            printf("\tjump enquanto%d\n", contaCiclos);
            printf("fenquanto%d:\n", contaCiclos);
          }
          ;

RepeteN : REPETE '(' Exp ')'
          { contaCiclos++;
            printf("\tstoreg %d\n", 25+contaCiclos);          
            printf("repete%d: ", contaCiclos);
            printf("\tpushg %d\n", 25+contaCiclos);
            printf("\tjz frepete%d\n", contaCiclos);
          }
          ComList FIM 
          { printf("\tpushg %d\n", 25+contaCiclos);
            printf("\tpushi 1\n");
            printf("\tsub\n");
            printf("\tstoreg %d\n", 25+contaCiclos);
            printf("\tjump repete%d\n", contaCiclos);
            printf("frepete%d:\n", contaCiclos);
          }; 

Atrib : ID '=' Exp {tab[$1-'a'] = $3; printf("\tstoreg %d\n", $1-'a');};

Escrita : PRINT Exp {printf("\twritei\n");};
 
Leitura : READ ID { printf("\tpushs \"?\"\n");
		   printf("\twrites\n");
                   printf("\tread\n");
                   printf("\tatoi\n");
                   printf("\tstoreg %d\n", $2-'a');
                 };

Cond : Cond OR Cond2 {printf("\tadd\n");}
     | Cond2
     ;

Cond2 : Cond2 AND Cond3 {printf("\tmul\n");}
      | Cond3
      ;

Cond3 : '(' Cond ')'
      | NOT Cond 
      | CondRel
      ;

CondRel : Exp
        | Exp EQ Exp  {printf("\tequal\n");}
        | Exp NEQ Exp {printf("\tsub\n");}
        | Exp GE Exp  {printf("\tinfeq\n");}
        | Exp LE Exp  {printf("\tsupeq\n");}
        | Exp LT Exp  {printf("\tsup\n");}
        | Exp GT Exp  {printf("\tinf\n");}
        ;

Exp : Exp '+' Termo {$$ = $1 + $3; printf("\tadd\n");}
    | Exp '-' Termo {$$ = $1 - $3; printf("\tsub\n");}
    | Termo {$$ = $1;}
    ;

Termo : Termo '*' Factor { printf("\tmul\n");}
      | Termo '/' Factor { if($3) 
                             printf("\tdiv\n");
                           else{
                             printf("\terr \"ERRO: divisão por 0...\"\n");
                             printf("\tjump fim\n");
                           }
                         }
      | Factor 
      ;

Factor : '(' Exp ')' {$$ = $2;}
       | Factor '^' Factor {$$ = pow($1, $3);}
       | ID  {printf("\tpushg %d\n", $1-'a'); $$ = $1 - 'a';}
       | NUM {printf("\tpushi %d\n", $1); $$ = $1;}
       ;
%%
int main()
{
  yyparse();
  return 0;
}

void yyerror(char *erro)
{
  fprintf(stderr, "%s, %s, %d \n", erro, yytext, yylineno);
}

