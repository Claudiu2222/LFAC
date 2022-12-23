output:
	yacc -d language.y;
	lex language.l;
	gcc lex.yy.c y.tab.c -o output;

clean:
	rm -f lex.yy.c y.tab.c y.tab.h output