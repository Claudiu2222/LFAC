%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool" {yylval.strVal = strdup(yytext); return TYPE;}
"begin_progr" {return BEGIN_PR;}
"end_progr" {return END_PR;}
"const" {return CONSTANT;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"for" {return FOR;}
"class" {return CLASS;}

"true"|"false" {return BOOLEANVALUE;}
"<" {return LESSTHAN;}
"<=" {return LESSOREQUALTHAN;}
">" {return GREATERTHAN;}
">=" {return GREATEROREQUALTHAN;}
"&&" {return AND;}
"||" {return OR;}
"!" {return NEGATION;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MULTIPLICATION;}
"/" {return DIVISION;}
@[_a-zA-Z][_a-zA-Z0-9]* {yylval.strVal = strdup(yytext); return ID;}
":=" {return ASSIGN;}
\'.\' {yylval.strVal = strdup(yytext);return CHAR;}
\".*\" {yylval.strVal = strdup(yytext);return STRING;}
[-]?[1-9][0-9]*|0 {yylval.intVal = atoi(yytext); return NUMBER;}
[-]?[1-9][0-9]*[.][0-9]+|0[.][0-9]+ {yylval.strVal = strdup(yytext);return FLOAT;}
"{" {return LEFTBRACKET;}
"}" {return RIGHTBRACKET;}
EVAL {return EVAL;}
TYPEOF {return TYPEOF;}
PRINT {return PRINT;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
