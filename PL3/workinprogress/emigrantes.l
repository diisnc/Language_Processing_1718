%{
#include <stdio.h>
#include "y.tab.h"
%}

id       [a-zA-Z0-9]+
number   [0-9]+
string   [^"\r\n]+
wspace   [ \r\n]*
newline  (\r\n|\n)

%x OBJECT_ID FIELD STRING LINK

%%
(emigrante|obra|evento)[ ]        { printf("flex: Object type: %s\n", yytext);             BEGIN OBJECT_ID;}
{id}                              { printf("flex: Link ID: %s\n", yytext);                 BEGIN LINK;}
<OBJECT_ID>{id}                   { printf("flex: Object ID: %s\n", yytext);               }
<OBJECT_ID>:{wspace}              { printf("flex: Object ID whitespace\n");                BEGIN FIELD;}
<FIELD>{id}                       { printf("flex: Field ID: %s\n", yytext);                }
<FIELD>:{wspace}\"                { printf("flex: Field ID whitespace\n");                 BEGIN STR;}
<STRING>{string}                  { printf("flex: String: %s\n", yytext);                  }
<STRING>\"[ ]*{newline}{2}        { printf("flex: Two newlines after string\n");           BEGIN INITIAL;}
<STRING>\"{wspace}                { printf("flex: End of string (not two newlines)\n");    BEGIN FIELD;}
<LINK>{wspace}fez{wspace}         { printf("flex: fez\n");                                 }
<LINK>{wspace}participou{wspace}  { printf("flex: participou\n");                          }
<LINK>{id}                        { printf("flex: Link ID string: %s\n", yytext);          }
<LINK>[ ]*\n                      { printf("flex: End of link\n");                         BEGIN INITIAL;}
\n                                { printf("flex: Eating newline.\n");                     }
.                                 { printf("flex: Unexpected character (return ERR).\n");  }
%%
