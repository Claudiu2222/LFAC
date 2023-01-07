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
%token BEGIN_PR END_PR CONSTANT IF ELSE WHILE FOR CLASS BOOLEANVALUE LESSTHAN LESSOREQUALTHAN GREATERTHAN GREATEROREQUALTHAN AND OR NEGATION PLUS MINUS MULTIPLICATION DIVISION ASSIGN CHAR STRING FLOAT LEFTBRACKET RIGHTBRACKET EVAL TYPEOF PRINT

%token <strVal>TYPE
%token <strVal>ID 
%token <intVal>NUMBER
%start progr
%left '+' '-'
%left '*' '/'
%%
progr: declaratii bloc {printf("program corect sintactic\n");}
     ;
 
declaratii :  declaratie 
	   | declaratii declaratie 
	   ;
leftbracket: LEFTBRACKET // add scope stuff
           ;
rightbracket: RIGHTBRACKET // add scope stuff
               ;
declaratie : TYPE ID ';' {printf("%s", yyval.strVal);}//variable 
           | TYPE ID ASSIGN NUMBER ';' //variable
           | TYPE ID '(' lista_param ')' leftbracket declaratii_functii rightbracket //function
           | TYPE '[' NUMBER ']' ID ';' // array
           | CLASS ID leftbracket declaratii_clasa rightbracket
           ;


declaratii_functii: declaratii_functii declaratie_functie ';'
                  | declaratie_functie ';'
                  ;
declaratie_functie:  TYPE '[' NUMBER ']' ID ';' // array
               | TYPE ID ';' //variable
               | TYPE ID ASSIGN NUMBER ';' //variable
               ;

lista_param : param
            | lista_param ','  param 
            ;
           
declaratii_clasa : 
               | declaratii_clasa declaratie_clasa
               | declaratie_clasa
               ;
declaratie_clasa : TYPE ID ';'
                 | TYPE ID '(' lista_param ')' ';'
                 | TYPE ID '(' ')' ';'
                 ;
param : TYPE ID
      ; 
      
/* bloc */
bloc : BEGIN_PR list END_PR  
     ;
     
/* lista instructiuni */
list :  statement 
     | list statement 
     ;

/* instructiune */
statement: ID ASSIGN ID ';'
         | ID ASSIGN NUMBER  ';'		 
         | ID '(' lista_apel ')' ';'
         | TYPE ID ';'
         | TYPE ID ASSIGN NUMBER ';'
         | TYPE ID ASSIGN ID ';'
         ;
        
lista_apel : NUMBER
           | lista_apel ',' NUMBER
           ;
%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
printf("current token: %s\n",yytext);

}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 