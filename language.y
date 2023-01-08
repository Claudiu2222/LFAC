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
  double floatVal;
  char* boolVal;
  char charVal;
}
%token BEGIN_PR END_PR CONSTANT IF ELSE WHILE FOR CLASS LESSTHAN LESSOREQUALTHAN GREATERTHAN EQUAL GREATEROREQUALTHAN AND OR NEGATION PLUS MINUS MULTIPLICATION DIVISION ASSIGN LEFTBRACKET RIGHTBRACKET EVAL TYPEOF PRINT

%token <strVal>TYPE
%token <strVal>ID 
%token <intVal>NUMBER
%token <boolVal>BOOLEANVALUE
%token <floatVal>FLOAT
%token <charVal>CHAR
%token <strVal>STRING
%start progr

%left LESSTHAN LESSOREQUALTHAN GREATERTHAN GREATEROREQUALTHAN EQUAL
%left PLUS MINUS
%left MULTIPLICATION DIVISION
%left NEGATION
%left AND
%left OR


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
declaratie : declaratii_comune
           | TYPE ID '(' lista_param ')' leftbracket declaratii_functii rightbracket  {printf ("FUNCTIE %s\n", $2);}//function
           | CLASS ID leftbracket declaratii_clasa rightbracket {printf(" %s \n", $2);}    
           ;
declaratii_comune: TYPE ID ';' //{printf("%s ", $2);}//variable 
                 | TYPE ID ASSIGN {scope=1; } assignedValue ';' //variable or array - assign
                 | TYPE '[' NUMBER ']' ID ';' // array
                 | TYPE '[' NUMBER ']' ID ASSIGN ID';' // array int[50] arra1 = array2;
                 | ID ASSIGN {scope=1; } assignedValue ';' //variable or array - assign -> la fel, dar fara type -> trb verificat daca a fost declarata inainte
                 | ID '[' NUMBER ']' ASSIGN {scope=1; } assignedValue ';' // array at index NUMBER = assignedValue

assignedValue:  expresii  
                |NUMBER {if(scope==1) {printf(" %d ", $1);}}
                | ID {if(scope==1) {printf("AICI VA FI O VARIABILA");}}
                | FLOAT {if(scope==1) {printf(" %f flt ", $1);}}
                | CHAR {if(scope==1) {printf(" %c ddddd", $1);}}
                | STRING {if(scope==1) {printf("|%s|", $1);}}
                | ID '(' lista_argumente ')' {if(scope==1) {printf("\n AICI VA FI UN APEL DE FUNCTIE \n");}} // PT FUNCTION CALL
                | ID '.' ID '(' lista_argumente ')'{ printf("\n AICI E UN METHOD CALL \n");} //method call
                | ID '[' NUMBER ']'{ printf("\n NOT IN EXPR \n");} 
                ;
expresii: //exista conflicte cu NUMBER ID FLOAT etc din assignedVAlue, dar le ia pe cele din assignedValue intai
           // ceea ce e bine, dar nush dc. Daca de ex le scoti din assignedValue o sa le ia pe alea din expresii( wrong)
           // dar ma gandeam oricum cum ar merge fixat conflictul, nu stiu daca e o idee buna sa il fixam ca la mn cel putin nu apar probleme le ia mereu corect
           // spun sa lasam asa momentan
           expresii MULTIPLICATION expresii {printf(" * \n");}
          | expresii DIVISION expresii {printf(" / \n");}
          | expresii AND expresii {printf(" && \n");}
          | expresii OR expresii {printf(" || \n");}
          | expresii LESSTHAN expresii {printf(" < \n");}
          | expresii LESSOREQUALTHAN expresii {printf(" <= \n");}
          | expresii GREATERTHAN expresii {printf(" > \n");}
          | expresii GREATEROREQUALTHAN expresii {printf(" >= \n");}
          | expresii EQUAL expresii {printf(" == \n");}
          | NEGATION expresii {printf(" ! \n");}
          |expresii PLUS expresii {printf(" + \n");}
          | expresii MINUS expresii {printf(" - \n");}
          | '(' expresii ')' {printf(" ( ) \n");}
          | NUMBER {printf(" %d  IN EXPR", $1);}
          | ID      {printf(" %s IN EXPR", $1);}
          | FLOAT  {printf(" %f IN EXPR", $1);}
          | CHAR  {printf(" %c IN EXPR", $1);}
          | STRING  {printf(" %s IN EXPR", $1);}
          | ID '(' lista_argumente ')'        // PT FUNCTION CALL
          | ID '.' ID '(' lista_argumente ')'  //method call
          | BOOLEANVALUE {printf(" %s IN EXPR", $1);}
          | ID '[' NUMBER ']'  {printf(" %s IN EXPR", $1);} // array at index NUMBER
          | ID '.' ID   //method call

          ;
         
declaratii_functii: declaratii_functii declaratie_functie 
                  | declaratie_functie 
                  ;
declaratie_functie:  declaratii_comune
               ; // add more

lista_param : param
            | lista_param ','  param 
            ;
           
declaratii_clasa : 
               | declaratii_clasa declaratie_clasa
               | declaratie_clasa
               ;
declaratie_clasa : declaratii_comune
                 | TYPE ID '(' lista_argumente ')' ';' //function call
                
                 // add more
                 ;
param : TYPE ID
      ; 
lista_argumente: /*epsilon*/
               | lista_argumente ',' arg 
               | arg
               ;
arg: ID
    | NUMBER
    | FLOAT
    | BOOLEANVALUE
    | STRING
    | CHAR
    | ID '(' lista_argumente ')'
    ;
/* bloc main */
bloc : BEGIN_PR list END_PR  
     ;
     
/* lista instructiuni (pt main)*/
list :  statement 
     | list statement 
     ;

/* instructiune */
statement: declaratii_comune		 
         | ID '(' lista_apel ')' ';'
    
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