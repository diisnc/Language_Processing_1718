%{
#include <stdio.h>
#include "y.tab.h"
%}

posint    [0-9]+

%%
wordsize    return WORDSIZE;
push        return PUSH;
pop         return POP;
print       return PRINT;
unload      return UNLOAD;
top         return TOP;
sum         return SUM;
\n          return '\n';
{posint}    { yylval.num = atoi(yytext); return INT; }
[ \t]       ;
(.|\n)      return ERR;
%%
