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
%token TYPE BEGIN END CONSTANT IF ELSE WHILE FOR CLASS ACESSMODIFIER BOOLEANVALUE LESSTHAN LESSOREQUALTHAN GREATERTHAN GREATEROREQUALTHAN AND OR NEGATION PLUS MINUS MULTYPELICATION DIVISION ID ASSIGN CHAR STRING NUMBER FLOAT LEFTBRACKET RIGHTBRACKET EVAL TYPEOF PRINT
%start progr
%%
progr: declaratii bloc {printf("program corect sintactic\n");}
     ;

declaratii :  declaratie ';'
	   | declaratii declaratie ';'
	   ;
declaratie : TYPE ID 
           | TYPE ID '(' lista_param ')'
           | TYPE ID '(' ')'
           ;
lista_param : param
            | lista_param ','  param 
            ;
            
param : TYPE ID
      ; 
      
/* bloc */
bloc : BEGIN list END  
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