%{
#include <stdio.h>
#include "y.tab.h"
#include<string.h>
#include <stdlib.h>
%}
%option noyywrap
%%
"const" {return CONSTANT;}
"int"|"float"|"char"|"string"|"bool" {yylval.strVal = strdup(yytext); return TYPE;}
"begin_progr" {return BEGIN_PR;}
"end_progr" {return END_PR;}
"if" {return IF;}
"elif" {return ELIF;}
"else" {return ELSE;}
"while" {return WHILE;}
"for" {return FOR;}
"class" {return CLASS;}
"return" {return RETURN;}
"true"|"false" {yylval.boolVal=strdup(yytext); return BOOLEANVALUE;}
"<" {return LESSTHAN;}
"<=" {return LESSOREQUALTHAN;}
">" {return GREATERTHAN;}
">=" {return GREATEROREQUALTHAN;}
"==" {return EQUAL;}
"&&" {return AND;}
"||" {return OR;}
"!" {return NEGATION;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MULTIPLICATION;}
"/" {return DIVISION;}
EVAL {return EVAL;} 
TYPEOF {return TYPEOF;}
PRINT {return PRINT;}
[_a-zA-Z][_a-zA-Z0-9]* {yylval.strVal = strdup(yytext); return ID;}
"=" {return ASSIGN;}
\'.\' {yylval.charVal = yytext[1];return CHAR;}
\".+\" {yylval.strVal = strdup(yytext); yylval.strVal=strtok(yylval.strVal,"\""); /*printf("====\n%s\n====",yylval.strVal);*/return STRING;}
[1-9][0-9]*|0 {yylval.intVal = atoi(yytext); return NUMBER;}
[1-9][0-9]*[.][0-9]+|0[.][0-9]+ {yylval.floatVal = atof(yytext);return FLOAT;}
"{" {return LEFTBRACKET;}
"}" {return RIGHTBRACKET;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

