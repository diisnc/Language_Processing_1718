tarefas: y.tab.o lex.yy.o
	gcc -o tarefas y.tab.o lex.yy.o -ll -lm

y.tab.o: y.tab.c
	gcc -c y.tab.c

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

y.tab.c y.tab.h: tarefas.y
	yacc -d tarefas.y

lex.yy.c: tarefas.l y.tab.h
	flex tarefas.l
