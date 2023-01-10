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

#define VARIABLE 1
#define FUNCTION 2
#define CLASS_ 3
#define OBJECT 4
#define ARRAY 5


#define MAXSYMBOLS 200
#define GLOBAL 0

extern int yylex();
void yyerror(char * s);
struct symbol{
     char name[50]; // 
     char type[30];     //
     int scope;    // 
     int isConstant; //
     int typeOfObject; //
     char charValue;
     int intVal;
     char* boolValue;
     float floatValue;
     char *stringValue;
     int *integerVector;
     char *characterVector;
	char **stringVector;
     int vectorSize;
     int isPrivate;
     


}symbolTable[MAXSYMBOLS];
struct informatii{
     int intVal;
     char boolVal[5];
     char strVal[256];
     float floatVal;
     char charVal;
     int type;
};
int scope=0;
int scopeStack[MAXSYMBOLS];
int stackIndex=0;
int symbolTableIndex=0;
void addVariableToTable(char *name, char* type, int scope, int isConstant, struct informatii *info ){
     strcpy(symbolTable[symbolTableIndex].name,name);
     strcpy(symbolTable[symbolTableIndex].type,type);
     symbolTable[symbolTableIndex].scope=scope;
     symbolTable[symbolTableIndex].isConstant=isConstant;
     symbolTable[symbolTableIndex].typeOfObject=VARIABLE;
     if(info!=NULL)
     {
          if(info->type!=type)
               yyerror("Type mismatch");
          if(info->type==CHARACTERVAL)
          {
               symbolTable[symbolTableIndex].charValue=info->charVal;
          }
          else if(info->type==BOOLEANVAL)
          {
               strcpy(symbolTable[symbolTableIndex].boolValue,info->boolVal);
          }
          else if(info->type==INTEGERVAL)
          {
               symbolTable[symbolTableIndex].intVal=info->intVal;
          }
          else if(info->type==FLOATVAL)
          {
               symbolTable[symbolTableIndex].floatValue=info->floatVal;
          }
          else if(info->type==STRINGVAL)
          {
               strcpy(symbolTable[symbolTableIndex].stringValue,info->strVal);
          }
     }
}
void printInfo()
{
     for( int i=0;i<=symbolTableIndex;i++)
     {
          printf("Name of symbol[%d]:%s\n",i,symbolTable[i].name);
          printf("Type of symbol[%d]:%s\n",i,symbolTable[i].type);
          printf("Scope of symbol[%d]:%d\n",i,symbolTable[i].scope);
          printf("Is constant of symbol[%d]:%d\n",i,symbolTable[i].isConstant);
          printf("Type of object of symbol[%d]:%d\n",i,symbolTable[i].typeOfObject);
          if(symbolTable[i].typeOfObject==VARIABLE)
          {
               if(symbolTable[i].type==CHARACTERVAL)
               {
                    printf("Value of symbol[%d]:%c\n",i,symbolTable[i].charValue);
               }
               else if(symbolTable[i].type==BOOLEANVAL)
               {
                    printf("Value of symbol[%d]:%s\n",i,symbolTable[i].boolValue);
               }
               else if(symbolTable[i].type==INTEGERVAL)
               {
                    printf("Value of symbol[%d]:%d\n",i,symbolTable[i].intVal);
               }
               else if(symbolTable[i].type==FLOATVAL)
               {
                    printf("Value of symbol[%d]:%f\n",i,symbolTable[i].floatValue);
               }
               else if(symbolTable[i].type==STRINGVAL)
               {
                    printf("Value of symbol[%d]:%s\n",i,symbolTable[i].stringValue);
               }
          }
          
}}



void initializeStack(){
     int i;
     for(i=0;i<MAXSYMBOLS;i++){
          scopeStack[i]=-1;
     }
     scopeStack[GLOBAL]=0;
}
void pushScope(){
     stackIndex++;
     scope++;
     if(stackIndex>=MAXSYMBOLS)
          yyerror("Stack overflow");
     scopeStack[stackIndex]=scope;
}
void popScope(){
     scopeStack[stackIndex]=-1;
     stackIndex--;
     
}

%}
%union {
  char* strVal;
  int intVal;
  double floatVal;
  char* boolVal;
  char charVal;

  struct informatii *info;
}
%token BEGIN_PR END_PR CONSTANT IF ELSE WHILE FOR CLASS LESSTHAN LESSOREQUALTHAN GREATERTHAN EQUAL GREATEROREQUALTHAN AND OR NEGATION PLUS MINUS MULTIPLICATION DIVISION ASSIGN LEFTBRACKET RIGHTBRACKET EVAL TYPEOF PRINT

%token <strVal>TYPE
%token <strVal>ID 
%token <intVal>NUMBER
%token <boolVal>BOOLEANVALUE
%token <floatVal>FLOAT
%token <charVal>CHAR
%token <strVal>STRING

%type<info>expresii

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
leftbracket: LEFTBRACKET {pushScope();}// add scope stuff
           ;
rightbracket: RIGHTBRACKET {popScope();}// add scope stuff
            ;
declaratie : declaratii_comune
           | TYPE ID '(' lista_param ')' leftbracket declaratii_functii rightbracket  {printf ("FUNCTIE %s\n", $2);}//function
           | CLASS ID leftbracket declaratii_clasa rightbracket {printf(" %s \n", $2);}    
           ;
declaratii_comune: TYPE ID ';' {addVariableToTable($2, $1, VARIABLE, 0 , 0); printf("==== %s====",$1); printInfo();}//variable
                 | TYPE ID ASSIGN {scope=1; } expresii ';' {addVariableToTable($2, $1, VARIABLE, 0 , $5); free($5); } //variable or array - assign
                 | TYPE '[' NUMBER ']' ID ';' // array
                 | TYPE '[' NUMBER ']' ID ASSIGN ID';' // array int[50] arra1 = array2;
                 | ID ASSIGN {scope=1; } expresii ';' {free($4);} //variable or array - assign -> la fel, dar fara type -> trb verificat daca a fost declarata inainte
                 | ID '[' NUMBER ']' ASSIGN {scope=1; } expresii ';' {free($7);}// array at index NUMBER = assignedValue
               ;

expresii:  expresii MULTIPLICATION expresii {struct informatii *temp=(struct informatii*)malloc(sizeof(struct informatii)); printf(" just checking : %d \n",$1->intVal * $3->intVal);temp->type=INTEGERVAL; temp->intVal=$1->intVal * $3->intVal;free($1);free($3); $$=temp;}
          | expresii DIVISION expresii {struct informatii *temp=(struct informatii*)malloc(sizeof(struct informatii)); printf(" just checking : %d \n",$1->intVal / $3->intVal);temp->intVal=$1->intVal / $3->intVal;free($1);free($3); $$=temp;}
          | expresii AND expresii {printf(" && \n"); struct informatii *temp=(struct informatii*)malloc(sizeof(struct informatii)); printf(" Got to add checking functions soon");free($1);free($3); $$=temp;}
          | expresii OR expresii {printf(" || \n"); struct informatii *temp=(struct informatii*)malloc(sizeof(struct informatii)); printf(" Got to add checking functions soon");free($1);free($3); $$=temp;}
          | expresii LESSTHAN expresii {printf(" < \n"); struct informatii *temp=(struct informatii*)malloc(sizeof(struct informatii)); printf(" Got to add checking functions soon");free($1);free($3); $$=temp;}
          | expresii LESSOREQUALTHAN expresii {printf(" <= \n");}
          | expresii GREATERTHAN expresii {printf(" > \n");}
          | expresii GREATEROREQUALTHAN expresii {printf(" >= \n");}
          | expresii EQUAL expresii {printf(" == \n");}
          | NEGATION expresii {printf(" ! \n");}
          | expresii PLUS expresii {printf(" + \n"); ; struct informatii *temp=(struct informatii*)malloc(sizeof(struct informatii)); printf(" just checking : %d \n",$1->intVal + $3->intVal);temp->intVal=$1->intVal + $3->intVal;free($1);free($3); $$=temp;}
          | expresii MINUS expresii {printf(" - \n"); ; struct informatii *temp=(struct informatii*)malloc(sizeof(struct informatii)); printf(" just checking : %d \n",$1->intVal + $3->intVal); temp->intVal=$1->intVal - $3->intVal;free($1);free($3); $$=temp;}
          | '(' expresii ')' {printf(" ( ) \n"); $$=$2;}
          | MINUS expresii {printf(" - ceva \n"); struct informatii *temp=(struct informatii*)malloc(sizeof(struct informatii));temp->intVal=$2->intVal-2*$2->intVal; free($2);$$=temp;}
          | NUMBER {printf(" %d  IN EXPR", $1);struct informatii *temp=(struct informatii*)malloc(sizeof(struct informatii)); temp->intVal=$1;temp->type=INTEGERVAL;$$=temp; } 
          | ID      {printf(" %s IN EXPR", $1);}
          | FLOAT  {printf(" %f IN EXPR", $1);}
          | CHAR  {printf(" %c IN EXPR", $1);}
          | STRING  {printf(" %s IN EXPR", $1);}
          | ID '(' lista_argumente ')'        // PT FUNCTION CALL
          | ID '.' ID '(' lista_argumente ')'  //method call
          | BOOLEANVALUE {printf(" %s IN EXPR", $1);}
          | ID '[' NUMBER ']'  {printf(" %s IN EXPR", $1);} // array at index NUMBER
          | ID '.' ID   // class attribute

          ;
//ifStatement
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
    | ID '.' ID '(' lista_argumente ')'
    | ID '[' NUMBER ']'
    | ID '.' ID
    ;
/* bloc main */
bloc : BEGIN_PR LEFTBRACKET list RIGHTBRACKET END_PR  
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
initializeStack();
yyin=fopen(argv[1],"r");
yyparse();
} 