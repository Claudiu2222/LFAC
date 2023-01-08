all: y.tab.o lex.yy.o
	gcc y.tab.o lex.yy.o -o output;
	rm -f lex.yy.c y.tab.c y.tab.h y.tab.o lex.yy.o;
	clear;

y.tab.o: language.y 
	yacc -d language.y
	gcc -c y.tab.c

lex.yy.o: language.l
	lex language.l
	gcc -c lex.yy.c

run: all
	clear;
	./output input.txt


clean:
	rm -f lex.yy.c y.tab.c y.tab.h output