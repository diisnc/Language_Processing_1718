%{
#include <stdio.h>
#include "y.tab.h"
%}

isodate [0-9]{4}-[0-9]{2}-[0-9]{2}
number [0-9]+
string .+"

%x READING_STRING

%%
emigrante[ ]  begin READING_STRING;
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
