%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%union {
  char* strVal;
  int intVal;
  float floatVal;
}
%token TYPE BEGIN_PR END_PR CONSTANT IF ELSE WHILE FOR CLASS BOOLEANVALUE LESSTHAN LESSOREQUALTHAN GREATERTHAN GREATEROREQUALTHAN AND OR NEGATION PLUS MINUS MULTIPLICATION DIVISION ID ASSIGN CHAR STRING NUMBER FLOAT LEFTBRACKET RIGHTBRACKET EVAL TYPEOF PRINT
%start progr
%left '+' '-'
%left '*' '/'
%%
progr: declaratii bloc {printf("program corect sintactic\n");}
     ;

declaratii :  declaratie ';'
	   | declaratii declaratie ';'
	   ;
declaratie : TYPE ID 
           | TYPE ID '(' lista_param ')'
           | TYPE ID '(' ')'
           | CLASS ID '{' declaratii '}'
           ;
lista_param : param
            | lista_param ','  param 
            ;
            
param : TYPE ID
      ; 
      
/* bloc */
bloc : BEGIN_PR list END_PR  
     ;
     
/* lista instructiuni */
list :  statement ';' 
     | list statement ';'
     ;

/* instructiune */
statement: ID ASSIGN ID
         | ID ASSIGN NUMBER  		 
         | ID '(' lista_apel ')'
         ;
        
lista_apel : NUMBER
           | lista_apel ',' NUMBER
           ;
%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 