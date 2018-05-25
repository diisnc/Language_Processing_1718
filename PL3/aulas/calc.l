%{
#include "y.tab.h"
%}

%option noyywrap

%%
[\t \n]  ;

[=?+\-/\^{}()*]  return *yytext;

escrever return PRINT;
ler      return READ;

repete  return REPETE;
fim     return FIM;

enquanto return ENQUANTO;
"||"     return OR;
"&&"     return AND;
\!       return NOT;
"=="     return EQ;
"!="     return NEQ;
">="     return GE;
"<="     return LE;
\<       return LT;
\>       return GT;

[0-9]+ { yylval.num = atoi(yytext);
                    return NUM; }

[a-z]  { yylval.id = *yytext;
         return ID; }

. return ERRO;
%%

