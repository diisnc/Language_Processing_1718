%{
  int acc = 0;
%}

%s ADD MUL

%%

acc off     { printf("%d", acc); acc = 0; BEGIN INITIAL; }
mul on      { BEGIN MUL; }
add on      { BEGIN ADD; }
<MUL>[0-9]+ { acc += atoi(yytext); }
<ADD>[0-9]+ { acc *= atoi(yytext); }

%%
