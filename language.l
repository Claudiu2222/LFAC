%{
#include <stdio.h>
#include "y.tab.h"
%}
/* write me a lexer for int float char string bool types */


%%
"int"|"float"|"char"|"string"|"bool" {yylval.strval = strdup(yytext); return TYPE;}
"begin_progr" {return BEGIN;}
"end_progr" {return END;}
"constant" {return CONSTANT;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"for" {return FOR;}
"class" {return CLASS;}
"private"|"protected"|"public" {return ACESSMODIFIER;}
"true"|"false" {return BOOLEANVALUE;}
"<" {return LESSTHAN;}
"<=" {return LESSOREQUALTHAN;}
">" {return GREATERTHAN;}
">=" {return GREATEROREQUALTHAN;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MULTIPLICATION;}
"/" {return DIVISION;}
"&&" {return AND;}
"||" {return OR;}
"!" {return NEGATION;}
@[_a-zA-Z][_a-zA-Z0-9]* {yylval.strval = strdup(yytext); return ID;}
":=" {return ASSIGN;}
[1-9]+[0-9]* {yylval.val = atoi(yytext); return NR; }
0+[0-9]* {yylval.strval = strdup(yytext);return FLT;}
0 {yylval.val = atoi(yytext);return NR;}
"{" {return LEFTBRACKET;}
"}" {return RIGHTBRACKET;}
EVAL {return EVAL;}
PRINT {return PRINT;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}