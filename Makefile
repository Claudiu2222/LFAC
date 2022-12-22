output:
	yacc -d language.y;
	lex language.l;
	gcc lex.yy.c y.tab.c -o output;