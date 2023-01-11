%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
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

#define NONCONSTANT 0
#define CCONSTANT 1

#define VARIABLE 1
#define FUNCTION 2
#define CLASS_ 3
#define OBJECT 4
#define ARRAY 5

#define OP_OR 1
#define OP_AND 2 
#define OP_LESSTHAN 3
#define OP_LESSOREQUALTHAN 4
#define OP_GREATERTHAN 5
#define OP_GREATEROREQUALTHAN 6
#define OP_EQUAL 7 
#define OP_PLUS 8 
#define OP_MINUS 9
#define OP_MULTIPLICATION 10
#define OP_DIVISION 11
#define OP_NEGATION 12
#define OP_UNARYMINUS 13

#define MAXPARAMETERS 100
#define MAXSYMBOLS 200
#define GLOBAL 0

extern int yylex();
void yyerror(char * s);

// Type const chars * 
const char* _int = "int";
const char* _float = "float";
const char* _char = "char";
const char* _string = "string";
const char* _bool = "bool";


struct informations{
     int intVal;
     char boolVal[6];
     char strVal[256];
     float floatVal;
     char charVal;
     char type[10];
};
struct parameter{
     char name[50];
     struct informations info;
};
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
     
     struct parameter parameters[MAXPARAMETERS];
     int numberOfParameters;


}symbolTable[MAXSYMBOLS];

int scope=0;
int scopeStack[MAXSYMBOLS];
int stackIndex=0;
int symbolTableIndex=0;

int wasDefinedInCurrentScope(char* name);
void addParameterToFunction(struct symbol* functie, struct parameter* param);
void addFunctionToTable(char* type, char *name,  int scope);
void addVariableToTable(char *name, char* type, int scope, int isConstant, struct informations *info );
void printInfo();
void initializeStack();
void pushScope();
void popScope();
void add(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp);
void subtract(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp);
void multiply(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp);
void divide(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp);
void calculate(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp, int typeOfOperation);
void verifyTypes(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp);
%}
%union {
  char* strVal;
  int intVal;
  double floatVal;
  char* boolVal;
  char charVal;

  struct informations *info;
  struct parameter *param;
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
%type<param>parametru

%start progr

%left OR
%left AND
%left LESSTHAN LESSOREQUALTHAN GREATERTHAN GREATEROREQUALTHAN EQUAL
%left PLUS MINUS
%left MULTIPLICATION DIVISION
%left NEGATION


%%
progr: declaratii bloc {printf("program corect sintactic\n");}
     ;
 
declaratii :  /*#epsilon#*/
        | declaratie 
	   | declaratii declaratie 
	   ;
leftbracket: LEFTBRACKET {pushScope();}
           ;
rightbracket: RIGHTBRACKET {popScope();}
            ;
declaratie : declaratii_comune
           | TYPE ID {addFunctionToTable($1, $2, scope);}'(' lista_parametri ')'  leftbracket declaratii_functii rightbracket //function
           | CLASS ID leftbracket declaratii_clasa rightbracket {printf(" %s \n", $2);}    
           ;
declaratii_comune: TYPE ID ';' {addVariableToTable($2, $1, scope, NONCONSTANT , 0);}//variable
                 | TYPE ID ASSIGN  expresii ';' {addVariableToTable($2, $1, scope, NONCONSTANT , $4); free($4); } //variable or array - assign
                 | TYPE '[' NUMBER ']' ID ';' // array
                 | TYPE '[' NUMBER ']' ID ASSIGN ID';' // array int[50] arra1 = array2;
                 | ID ASSIGN expresii ';' {free($3);} //variable or array - assign -> la fel, dar fara type -> trb verificat daca a fost declarata inainte
                 | ID '[' NUMBER ']' ASSIGN expresii ';' {free($6);}// array at index NUMBER = assignedValue
                 | CONSTANT TYPE ID ASSIGN expresii ';' {addVariableToTable($3, $2, scope, CCONSTANT , 0); printInfo();}//variable // const id = 2 + 3;
                 | CONSTANT TYPE ID ASSIGN ID ';' { addVariableToTable($3, $2, scope, CCONSTANT , 0); printInfo();}//variable// const id = di;
                 ;

expresii:  expresii MULTIPLICATION expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $1, $3, OP_MULTIPLICATION); free($1); free($3); $$=temp;}
          | expresii DIVISION expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $1, $3, OP_DIVISION); free($1); free($3); $$=temp;}
          | expresii AND expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $1, $3, OP_AND); free($1);free($3); $$=temp;}
          | expresii OR expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $1, $3, OP_OR); free($1);free($3); $$=temp;}
          | expresii LESSTHAN expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $1, $3, OP_LESSTHAN); free($1);free($3); $$=temp;}
          | expresii LESSOREQUALTHAN expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $1, $3, OP_LESSOREQUALTHAN); free($1);free($3); $$=temp;}
          | expresii GREATERTHAN expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $1, $3, OP_GREATERTHAN); free($1);free($3); $$=temp;}
          | expresii GREATEROREQUALTHAN expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $1, $3, OP_GREATEROREQUALTHAN); free($1);free($3); $$=temp;}
          | expresii EQUAL expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations));calculate(temp, $1, $3, OP_EQUAL); free($1);free($3); $$=temp;}
          | NEGATION expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $2, NULL, OP_NEGATION); free($2); $$=temp;}
          | expresii PLUS expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $1, $3, OP_PLUS); free($1);free($3); $$=temp;}
          | expresii MINUS expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $1, $3, OP_MINUS); free($1);free($3); $$=temp;}
          | '(' expresii ')' {$$=$2;}
          | MINUS expresii {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); calculate(temp, $2, NULL,OP_UNARYMINUS); free($2); $$=temp;}
          | NUMBER {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); temp->intVal=$1; strcpy(temp->type,_int); $$=temp;} 
          | ID      {printf(" %s IN EXPR", $1);} 
          | FLOAT  {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); temp->floatVal=$1; strcpy(temp->type,_float); $$=temp;} 
          | CHAR  {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); temp->charVal=$1; strcpy(temp->type,_char); $$=temp;} 
          | STRING  {struct informations *temp=(struct informations*)malloc(sizeof(struct informations));printf("Acest compiler este retardat"); strcpy(temp->strVal,$1); strcpy(temp->type,_string); $$=temp;} 
          | BOOLEANVALUE {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); strcpy(temp->boolVal,$1); strcpy(temp->type,_bool); $$=temp;} 
          | ID '(' lista_argumente ')'        // PT FUNCTION CALL
          | ID '.' ID '(' lista_argumente ')'  //method call
          | ID '[' NUMBER ']'  {printf(" %s IN EXPR", $1);} // array at index NUMBER
          | ID '.' ID   // class attribute

          ;
//ifStatement
declaratii_functii: declaratii_functii declaratie_functie 
                  | declaratie_functie 
                  ;
declaratie_functie: declaratii_comune
                  | if_statement
                  ; // add more



lista_parametri : /*epsilon*/ 
            | parametru {addParameterToFunction(&symbolTable[symbolTableIndex-1], $1);}
            | lista_parametri ',' parametru {addParameterToFunction(&symbolTable[symbolTableIndex-1], $3);}
            ;
parametru : TYPE ID {struct parameter* temp = (struct parameter*)malloc(sizeof(struct parameter)); strcpy(temp->name,$2); strcpy(temp->info.type,$1); $$=temp;}
          ;            
declaratii_clasa : 
               | declaratii_clasa declaratie_clasa
               | declaratie_clasa
               ;
declaratie_clasa : declaratii_comune
                 | TYPE ID '(' lista_argumente ')' ';' //function call
                
                 // add more
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
bloc : BEGIN_PR leftbracket list rightbracket END_PR  
     ;
     
if_statement: IF '(' expresii ')' leftbracket declaratii_if rightbracket
            | IF '(' expresii ')' leftbracket declaratii_if rightbracket ELSE leftbracket declaratii_if rightbracket
            ;
declaratii_if: declaratii_if declaratie_if
             | declaratie_if
             ;
declaratie_if: declaratii_comune
               | if_statement
               ;
/* lista instructiuni (pt main)*/
list :  statement 
     | list statement 
     ;

/* instructiune */
statement: declaratii_comune		 
         | ID '(' lista_apel ')' ';'
         | if_statement
         ;
        
lista_apel : NUMBER
           | lista_apel ',' NUMBER
           ;
%%
void yyerror(char * s){
printf("\n%s at line:%d\n",s,yylineno);
printf("current token: %s\n",yytext);
exit(1);
}

int main(int argc, char** argv){
initializeStack();
yyin=fopen(argv[1],"r");
yyparse();
printInfo();
} 

// -- Functions --

int wasDefinedInCurrentScope(char* name){

     for(int i=0; i <= stackIndex; i++){
          for(int j=0; j < symbolTableIndex; j++) // nu-mi place ca verific toate simbolurile, sa le fi verificat doar pe cele de la 
             {                                     //scopurile respective ar fi trb un hash table sau ceva pe langa ce avem ca sa aiba pt fiecare 
                                                  // in care pt fiecare nivel sa am liste inlantuite pt scopul respecitv gen la hashTable[0] sa gasesc
                                                  // toate simbolurile de la nivelul 0, la hashTable[1] toate simbolurile de la nivelul 1 etc
                                                  // si sa le accesez cu hashTable[0]->next ( fiecare pointeaza la un struct symbol)
                                                  //dar era mai mult spatiu necesar, plus ca sunt prea obosit sa mai implementez asta acum
                                                  //asa ca voi sacrifica din performanta. E cam hard coded ce e mai jos
               
               if(strcmp(symbolTable[j].name, name) == 0 && symbolTable[j].scope == scopeStack[i])
                    return 1;
                    
               if(symbolTable[j].typeOfObject == FUNCTION && symbolTable[j].scope==scope-1) //pt chestii inside functions
                    for(int k=0; k < symbolTable[j].numberOfParameters; k++)
                         if(strcmp(symbolTable[j].parameters[k].name, name) == 0)
                              return 1;}
     }
     return 0;
}
void addVariableToTable(char *name, char* type, int scope, int isConstant, struct informations *info ){
    
     if(wasDefinedInCurrentScope(name) == 0){
     strcpy(symbolTable[symbolTableIndex].name,name);
     strcpy(symbolTable[symbolTableIndex].type,type);
     symbolTable[symbolTableIndex].scope=scope;
     symbolTable[symbolTableIndex].isConstant=isConstant;
     symbolTable[symbolTableIndex].typeOfObject=VARIABLE;
     if(info!=NULL)
     {
          if(strcmp(info->type, type) != 0)
               yyerror("[!]Type mismatch");

          if(strcmp(info->type, "char") == 0)
          {
               symbolTable[symbolTableIndex].charValue=info->charVal;
          }
          else if(strcmp(info->type, "bool") == 0)
          {
               symbolTable[symbolTableIndex].boolValue = (char*)malloc(sizeof(char)*strlen(info->boolVal));
               strcpy(symbolTable[symbolTableIndex].boolValue,info->boolVal);
              
          }
          else if(strcmp(info->type, "int") == 0)
          {
               symbolTable[symbolTableIndex].intVal=info->intVal;
          }
          else if(strcmp(info->type, "float") == 0)
          {
               symbolTable[symbolTableIndex].floatValue=info->floatVal;
          }
          else if(strcmp(info->type, "string") == 0)
          {
               symbolTable[symbolTableIndex].stringValue = (char*)malloc(sizeof(char)*strlen(info->strVal));
               strcpy(symbolTable[symbolTableIndex].stringValue,info->strVal);
               
          }
     }
     symbolTableIndex++;}
     else
          yyerror("[!]ID already exists in current scope");
}
void addFunctionToTable( char* functionType, char *functionName, int scope){
     
     if(wasDefinedInCurrentScope(functionName) == 0){
     strcpy(symbolTable[symbolTableIndex].name, functionName);
     strcpy(symbolTable[symbolTableIndex].type, functionType);
     symbolTable[symbolTableIndex].scope=scope;
     symbolTable[symbolTableIndex].typeOfObject=FUNCTION;
     symbolTable[symbolTableIndex].numberOfParameters=0;
     symbolTableIndex++;}
     else
          yyerror("[!]ID already exists in current scope");
     
}
void addParameterToFunction(struct symbol *functie, struct parameter* param){

     if(functie->numberOfParameters > MAXPARAMETERS)
          {    free(param);
               yyerror("[!]Parameter limit exceeded");}
     strcpy(functie->parameters[functie->numberOfParameters].name, param->name);
     strcpy(functie->parameters[functie->numberOfParameters].info.type, param->info.type);
     functie->numberOfParameters++;
     free(param);
}
void printInfo()
{
     for( int i=0;i < symbolTableIndex;i++)
     {
          printf("=================================\n");
          printf("Name of symbol[%d]:%s\n", i, symbolTable[i].name);
          printf("Type of symbol[%d]:%s\n", i, symbolTable[i].type);
          printf("Scope of symbol[%d]:%d\n", i, symbolTable[i].scope);
        
          printf("Type of object of symbol[%d]:%d\n", i, symbolTable[i].typeOfObject);
          if(symbolTable[i].typeOfObject == VARIABLE)
          {  
               printf("Is constant of symbol[%d]:%d\n", i, symbolTable[i].isConstant);
               if(strcmp(symbolTable[i].type, "char") == 0)
               {
                    printf("Value of symbol[%d]:%c\n", i, symbolTable[i].charValue);
               }
               else if(strcmp(symbolTable[i].type, "bool") == 0)
               {
                    printf("Value of symbol[%d]:%s\n", i, symbolTable[i].boolValue);
               }
               else if(strcmp(symbolTable[i].type, "int") == 0)
               {
                    printf("Value of symbol[%d]:%d\n", i, symbolTable[i].intVal);
               }
               else if(strcmp(symbolTable[i].type, "float") == 0)
               {
                    printf("Value of symbol[%d]:%f\n", i, symbolTable[i].floatValue);
               }
               else if(strcmp(symbolTable[i].type, "string") == 0)
               {
                    printf("Value of symbol[%d]:%s\n", i, symbolTable[i].stringValue);
               }
          }
          else if(symbolTable[i].typeOfObject == FUNCTION)
          {
               printf("Number of parameters of symbol[%d]:%d\n", i, symbolTable[i].numberOfParameters);
               for(int j=0; j<symbolTable[i].numberOfParameters; j++)
               {
                    printf("---Name of parameter[%d]:%s\n", j, symbolTable[i].parameters[j].name);
                    printf("---Type of parameter[%d]:%s\n", j, symbolTable[i].parameters[j].info.type);
               }
          }
          
     }
}


void initializeStack(){
     int i;
     for(i=0; i < MAXSYMBOLS; i++){
          scopeStack[i] = -1;
     }
     scopeStack[GLOBAL] = 0;
}
void pushScope(){
     stackIndex++;
     scope++;
     if(stackIndex >= MAXSYMBOLS)
          yyerror("[!]Stack overflow");
     scopeStack[stackIndex] = scope;
}
void popScope(){
     scopeStack[stackIndex] = -1;
     stackIndex--;
     
}

void add(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     if(strcmp(leftExp->type, "int") == 0)
     {
          finalExp->intVal = leftExp->intVal + rightExp->intVal;
          strcpy(finalExp->type, "int");
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          finalExp->floatVal = leftExp->floatVal + rightExp->floatVal;
          strcpy(finalExp->type, "float");
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          yyerror("[!]Illegal character operation");
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          yyerror("[!]Illegal boolean operation");
     }
}
void subtract(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     if(strcmp(leftExp->type, "int") == 0)
     {
          finalExp->intVal = leftExp->intVal - rightExp->intVal;
          strcpy(finalExp->type, "int");
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          finalExp->floatVal = leftExp->floatVal - rightExp->floatVal;
          strcpy(finalExp->type, "float");
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          yyerror("[!]Illegal character operation");
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          yyerror("[!]Illegal boolean operation");
     }
}
void multiply(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     if(strcmp(leftExp->type, "int") == 0)
     {
          finalExp->intVal = leftExp->intVal * rightExp->intVal;
          strcpy(finalExp->type, "int");
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          finalExp->floatVal = leftExp->floatVal * rightExp->floatVal;
          strcpy(finalExp->type, "float");
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          yyerror("[!]Illegal character operation");
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          yyerror("[!]Illegal boolean operation");
     }
}

void divide(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     if(strcmp(leftExp->type, "int") == 0)
     {
          if(rightExp->intVal == 0)
          {
               yyerror("[!]Division by zero");
          }
          finalExp->intVal = leftExp->intVal / rightExp->intVal;
          strcpy(finalExp->type, "int");
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          if(rightExp->floatVal == 0)
          {
               yyerror("[!]Division by zero");
          }
          finalExp->floatVal = leftExp->floatVal / rightExp->floatVal;
          strcpy(finalExp->type, "float");
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          yyerror("[!]Illegal character operation");
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          yyerror("[!]Illegal boolean operation");
     }
}

void equal(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     strcpy(finalExp->type, "bool");
     if(strcmp(leftExp->type, "int") == 0)
     {
          if(leftExp->intVal == rightExp->intVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
          
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          if(leftExp->floatVal == rightExp->floatVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
      
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
       
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          if(leftExp->charVal == rightExp->charVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
  
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          if(strcmp(leftExp->boolVal, rightExp->boolVal) == 0)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
 
     }
}
void lessThan(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     strcpy(finalExp->type, "bool");
     if(strcmp(leftExp->type, "int") == 0)
     {
          if(leftExp->intVal < rightExp->intVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
          
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          if(leftExp->floatVal < rightExp->floatVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
      
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
       
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          if(leftExp->charVal < rightExp->charVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
  
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          yyerror("[!]Illegal boolean operation");
     }
}
void lessOrEqualThan(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     strcpy(finalExp->type, "bool");
     if(strcmp(leftExp->type, "int") == 0)
     {
          if(leftExp->intVal <= rightExp->intVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
          
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          if(leftExp->floatVal <= rightExp->floatVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
      
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
       
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          if(leftExp->charVal <= rightExp->charVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
  
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          yyerror("[!]Illegal boolean operation");
     }
}
void greaterThan(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     strcpy(finalExp->type, "bool");
     if(strcmp(leftExp->type, "int") == 0)
     {
          if(leftExp->intVal > rightExp->intVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
          
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          if(leftExp->floatVal > rightExp->floatVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
      
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
       
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          if(leftExp->charVal > rightExp->charVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
  
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          yyerror("[!]Illegal boolean operation");
     }
}
void greaterOrEqualThan(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     strcpy(finalExp->type, "bool");
     if(strcmp(leftExp->type, "int") == 0)
     {
          if(leftExp->intVal >= rightExp->intVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
          
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          if(leftExp->floatVal >= rightExp->floatVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
      
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
       
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          if(leftExp->charVal >= rightExp->charVal)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
  
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          yyerror("[!]Illegal boolean operation");
     }
}
void or(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     strcpy(finalExp->type, "bool");
     if(strcmp(leftExp->type, "int") == 0)
     {
          yyerror("[!]Illegal int operation");
          
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          yyerror("[!]Illegal float operation");
      
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
       
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          yyerror("[!]Illegal char operation");
  
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          if(strcmp(leftExp->boolVal, "true") == 0 || strcmp(rightExp->boolVal, "true") == 0)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
     }
}
void and(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp)
{
     strcpy(finalExp->type, "bool");
     if(strcmp(leftExp->type, "int") == 0)
     {
          yyerror("[!]Illegal int operation");
          
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          yyerror("[!]Illegal float operation");
      
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
       
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          yyerror("[!]Illegal char operation");
  
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          if(strcmp(leftExp->boolVal, "true") == 0 && strcmp(rightExp->boolVal, "true") == 0)
               strcpy(finalExp->boolVal, "true");
          else
               strcpy(finalExp->boolVal, "false");
     }
}
void negation(struct informations* finalExp, struct informations* leftExp)
{
     strcpy(finalExp->type, "bool");
     if(strcmp(leftExp->type, "int") == 0)
     {
          yyerror("[!]Illegal int operation");
          
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          yyerror("[!]Illegal float operation");
      
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
       
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          yyerror("[!]Illegal char operation");
  
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          if(strcmp(leftExp->boolVal, "true") == 0)
               strcpy(finalExp->boolVal, "false");
          else
               strcpy(finalExp->boolVal, "true");
     }
 
}
void unaryNegation(struct informations* finalExp, struct informations* leftExp)
{
     
     if(strcmp(leftExp->type, "int") == 0)
     {
          finalExp->intVal=-leftExp->intVal;
          strcpy(finalExp->type, "int");
     }
     else if(strcmp(leftExp->type, "float") == 0)
     {
          finalExp->floatVal=-leftExp->floatVal;
          strcpy(finalExp->type, "float");
     }
     else if(strcmp(leftExp->type, "string") == 0)
     {
          yyerror("[!]Illegal string operation");
       
     }
     else if(strcmp(leftExp->type, "char") == 0)
     {
          yyerror("[!]Illegal char operation");
  
     }
     else if(strcmp(leftExp->type, "bool") == 0)
     {
          yyerror("[!]Illegal boolean operation");
     }
}
void calculate(struct informations* finalExp, struct informations* leftExp, struct informations* rightExp, int typeOfOperation)
{
     if(rightExp!=NULL)
     {if(strcmp(leftExp->type, rightExp->type) != 0)
          {    free(finalExp);
               free(leftExp);
               free(rightExp);
               yyerror("[!]Type mismatch");}
     if(typeOfOperation == OP_PLUS)
          add(finalExp, leftExp, rightExp);
     else if(typeOfOperation == OP_MINUS)
          subtract(finalExp, leftExp, rightExp);
     else if(typeOfOperation == OP_MULTIPLICATION)
          multiply(finalExp, leftExp, rightExp);
     else if(typeOfOperation == OP_DIVISION)
          divide(finalExp, leftExp, rightExp);
     else if(typeOfOperation == OP_EQUAL)
          equal(finalExp, leftExp, rightExp);
     else if(typeOfOperation == OP_LESSTHAN)
          lessThan(finalExp, leftExp, rightExp);
     else if(typeOfOperation == OP_LESSOREQUALTHAN)
          lessOrEqualThan(finalExp, leftExp, rightExp);
     else if(typeOfOperation == OP_GREATERTHAN)
          greaterThan(finalExp, leftExp, rightExp);
     else if(typeOfOperation == OP_GREATEROREQUALTHAN)
          greaterOrEqualThan(finalExp, leftExp, rightExp);
     else if(typeOfOperation == OP_AND)
          and(finalExp, leftExp, rightExp);
     else if(typeOfOperation == OP_OR)
          or(finalExp, leftExp, rightExp);
     }
     else{
          if(typeOfOperation == OP_NEGATION)
          negation(finalExp, leftExp);
          else if(typeOfOperation == OP_UNARYMINUS)
          unaryNegation(finalExp,leftExp);
     }
     return;
     yyerror("[!]Illegal operation");
     
}

