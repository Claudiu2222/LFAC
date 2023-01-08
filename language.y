%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;

#define FALSE 0
#define TRUE 1

#define CHARACTERVAL 1
#define BOOLEANVAL 2
#define INTEGERVAL 3
#define FLOATVAL 4
#define STRINGVAL 5

#define GLOBAL 0

extern int yylex();
void yyerror(char * s);
struct symbol{
     char name[50];
     int type;
     int scope;
     int isConstant;
     int isFunction;
     int isClass;
     char charValue;
     int boolValue;
     float floatValue;
     char *stringValue;
     int *integerVector;
     char *characterVector;
	char **stringVector;
     int vectorSize;


}symbolTable[100];

int scope=0;

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
 
declaratii :  /*#epsilon#*/
        | declaratie 
	   | declaratii declaratie 
	   ;
leftbracket: LEFTBRACKET // add scope stuff
           ;
rightbracket: RIGHTBRACKET // add scope stuff
            ;
declaratie : TYPE ID ';' {printf("%s ", $1);}//variable 
           | TYPE ID ASSIGN NUMBER ';' //variable
           | TYPE ID '(' lista_param ')' leftbracket declaratii_functii rightbracket  {printf ("FUNCTIE %s\n", $2);}//function
           | TYPE '[' NUMBER ']' ID ';' // array
           | CLASS ID leftbracket declaratii_clasa rightbracket {printf(" %s \n", $2);}
           ;


declaratii_functii: declaratii_functii declaratie_functie 
                  | declaratie_functie 
                  ;
declaratie_functie:  TYPE '[' NUMBER ']' ID ';' // array
               | TYPE ID ';' //variable
               | TYPE ID ASSIGN NUMBER ';' //variable
               ; // add more

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
                 // add more
                 ;
param : TYPE ID
      ; 
      
/* bloc main */
bloc : BEGIN_PR list END_PR  
     ;
     
/* lista instructiuni (pt main)*/
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
void yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
printf("current token: %s\n",yytext);

}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 