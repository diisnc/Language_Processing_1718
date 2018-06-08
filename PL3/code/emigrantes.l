%{
#include <stdio.h>
#include "y.tab.h"
%}

id       [a-zA-Z0-9]+
number   [0-9]+
string   [^"\r\n]+
wspace   [ \r\n]*
newline  (\r\n|\n)

%x object_id field field_value connection

%%
(emigrante|obra|evento)                 { printf("flex: Object type: %s\n", yytext);             BEGIN object_id; yylval.str = strdup(yytext); return OBJECT_TYPE; }
{id}                                    { printf("flex: Link ID: %s\n", yytext);                 BEGIN connection; yylval.str = strdup(yytext); return OBJECT_ID; }
<object_id>[ ]                          { /* Eating the space between object type and its ID */ }
<object_id>{id}                         { printf("flex: Object ID: %s\n", yytext);               yylval.str = strdup(yytext); return OBJECT_ID; }
<object_id>:{wspace}                    {                                                        BEGIN field; }
<field>{id}                             { printf("flex: Field ID: %s\n", yytext);                yylval.str = strdup(yytext); return FIELD_ID; }
<field>\:{wspace}\"                     {                                                        BEGIN field_value; }
<field_value>{string}                   { printf("flex: String: %s\n", yytext);                  yylval.str = strdup(yytext); return STRING; }
<field_value>\"[ ]*{newline}{2,}         { printf("flex: Two newlines after field value\n");      BEGIN INITIAL; }
<field_value>\"{wspace}                 { printf("flex: End of string (not two newlines)\n");    BEGIN field; }
<connection>{wspace}fez{wspace}         { printf("flex: fez\n");                                 return FEZ; }
<connection>{wspace}participou{wspace}  { printf("flex: participou\n");                          return PARTICIPOU; }
<connection>{id}                        { printf("flex: Link ID string: %s\n", yytext);          yylval.str = strdup(yytext); return OBJECT_ID; }
<connection>[ ]*{newline}               { printf("flex: End of connection\n");                   BEGIN INITIAL; }
{newline}                               { printf("flex: Eating newline.\n");                     yylineno++; }
.                                       { printf("flex: Unexpected character (return ERR).\n");  return ERR; }
%%
