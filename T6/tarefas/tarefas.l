%{
#include "y.tab.h"
%}

id      [a-z]+
string  \"[^"]+\"
num     [0-9]+


%%

[ \t\n]             ;
[\[\]\{\}\:,]       { return yytext[0]; }
brief               { return BRIEF; }
codigo              { return CODIGO; }
tarefas             { return TAREFAS; }
agenda              { return AGENDA; }
baixa               { return BAIXA; }
media               { return MEDIA; }
alta                { return ALTA; }
{id}                { yylval.str = yytext; return ID; }
{string}            { yylval.str = yytext; return STR; }
{num}               { yylval.num = atoi(yytext); return NUM; }
.                   { return ERR; }
