LIBS=`pkg-config --cflags --libs glib-2.0`

emigrantes: y.tab.o lex.yy.o
	gcc -D_XOPEN_SOURCE=700 -std=c99 -o emigrantes y.tab.o lex.yy.o -ll -lm -lfl $(LIBS)

y.tab.o: y.tab.c
	gcc -D_XOPEN_SOURCE=700 -std=c99 -c y.tab.c $(LIBS)

lex.yy.o: lex.yy.c
	gcc -D_XOPEN_SOURCE=700 -std=c99 -c lex.yy.c $(LIBS)

y.tab.c y.tab.h: emigrantes.y
	yacc -d emigrantes.y

lex.yy.c: emigrantes.l y.tab.h
	flex emigrantes.l
