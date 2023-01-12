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
     char boolVal[7];
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

int scope = 0;
int last_scope = -1;
int diffScope = 0;
char* scopeStack[MAXSYMBOLS];
char* globalStack[MAXSYMBOLS];
int symbolTableIndex = 0;

int inFunction;
char currentFunction[50];
int currentFunctionIndex;

int currentParameterIndex;
struct symbol* calledFunction;
void verifyParameter(struct information* parameter);

int inControlStatement = 0;

void addParameterToFunction(struct symbol* functie, struct parameter* param);
void addFunctionToTable(char* type, char *name,  int scope);
void addVariableToTable(char *name, char* type, int scope, int isConstant, struct informations *info );
void addVariableFromSymToTable(char *name, char* type, int scope, int isConstant, const char* symbol_name);
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
void showStack();
void updateVariable(const char* name, struct informations* info);
struct symbol* lookUpElement(const char* name);
// Scope System
void initGlobalStack();
void initScopeStack();
void pushGlobalStack(const char* name);
void pushScopeStack();
void deleteElementsFromScopeStack();
void changeScope();
void revertScope();
void printStackValues();
void test(const char* name);
int wasDefinedInGlobalScope(const char* name);
int wasDefinedInCurrentScope(const char* name);
// ---- 
struct informations* getInformationFromTable(const char* name);
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
%token BEGIN_PR END_PR ELIF RETURN CONSTANT IF ELSE WHILE FOR CLASS LESSTHAN LESSOREQUALTHAN GREATERTHAN EQUAL GREATEROREQUALTHAN AND OR NEGATION PLUS MINUS MULTIPLICATION DIVISION ASSIGN LEFTBRACKET RIGHTBRACKET EVAL TYPEOF PRINT

%token <strVal>TYPE
%token <intVal>NUMBER
%token <boolVal>BOOLEANVALUE
%token <floatVal>FLOAT
%token <charVal>CHAR
%token <strVal>STRING

%token <strVal>ID 
%type<info>expresii
%type<param>parametru
%type<info>returnedvalue

%start progr

%left OR
%left AND
%left LESSTHAN LESSOREQUALTHAN GREATERTHAN GREATEROREQUALTHAN EQUAL
%left PLUS MINUS
%left MULTIPLICATION DIVISION
%left NEGATION


%%
progr: declaratii bloc  {printf("program corect sintactic\n");}
     ;
 
declaratii : declaratii declaratie
           | declaratie
           | /*empty*/
           ;


leftbracket: LEFTBRACKET {changeScope();}
           ;
rightbracket: RIGHTBRACKET {revertScope();}
            ;

declaratie : declaratii_comune {printf("ies din declaratie\n");}
           | TYPE ID {addFunctionToTable($1, $2, scope); strcpy(currentFunction, $2); currentFunctionIndex=symbolTableIndex--;} '(' {changeScope();} lista_parametri ')'  LEFTBRACKET list RETURN returnedvalue NEGATION {if (strcmp($11->type,$1)!=0){yyerror("[!] Returned value does not match function's type");} updateVariable($2,$11); free($11);} rightbracket //function
           | CLASS ID leftbracket list rightbracket {printf(" %s \n", $2);}    
           ;

declaratii_comune: TYPE ID ';' 
                    {addVariableToTable($2, $1, scope, NONCONSTANT , 0);}//variable

                 | TYPE ID ASSIGN  expresii ';' 
                    {addVariableToTable($2, $1, scope, NONCONSTANT , $4); free($4); } //variable or array - assign

                 | TYPE '[' NUMBER ']' ID ';' // array
                 | ID ASSIGN expresii ';' { updateVariable($1, $3); free($3); } //variable or array - assign -> la fel, dar fara type -> trb verificat daca a fost declarata inainte
                 | ID '[' NUMBER ']' ASSIGN expresii ';' {free($6);}// array at index NUMBER = assignedValue
                 | CONSTANT TYPE ID ASSIGN expresii ';' {addVariableToTable($3, $2, scope, CCONSTANT , $5); free($5); }//variable // const id = 2 + 3;
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
          | FLOAT  {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); temp->floatVal=$1; strcpy(temp->type,_float); $$=temp;} 
          | CHAR  {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); temp->charVal=$1; strcpy(temp->type,_char); $$=temp;} 
          | STRING  {struct informations *temp=(struct informations*)malloc(sizeof(struct informations));strcpy(temp->strVal,$1); strcpy(temp->type,_string); $$=temp;} 
          | BOOLEANVALUE {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); strcpy(temp->boolVal,$1); strcpy(temp->type,_bool); $$=temp;} 
          | ID '(' lista_argumente ')'   {currentParameterIndex=0; calledFunction=lookUpElement($1); if(currentFunction == NULL){yyerror("[!] Function does not exist");} }    // PT FUNCTION CALL
          | ID '.' ID '(' lista_argumente ')'  //method call
          | ID '[' NUMBER ']'  {printf(" %s IN EXPR[array] ", $1);} // array at index NUMBER
          | ID '.' ID   // class attribute
          | ID      {struct informations *temp = getInformationFromTable($1); test($1); $$=temp;} 

          ;


returnedvalue: ID { struct informations *temp = getInformationFromTable($1); $$=temp;}
               | NUMBER {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); temp->intVal=$1; strcpy(temp->type,_int); $$=temp;}
               | FLOAT {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); temp->floatVal=$1; strcpy(temp->type,_float); $$=temp;}
               | BOOLEANVALUE {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); strcpy(temp->boolVal,$1); strcpy(temp->type,_bool); $$=temp;}
               | STRING {struct informations *temp=(struct informations*)malloc(sizeof(struct informations));strcpy(temp->strVal,$1); strcpy(temp->type,_string); $$=temp;}
               | CHAR {struct informations *temp=(struct informations*)malloc(sizeof(struct informations)); temp->charVal=$1; strcpy(temp->type,_char); $$=temp;}
               | ID '[' NUMBER ']' // array at index NUMBER
               ;

lista_parametri : /*epsilon*/ 
            | parametru {addParameterToFunction(&symbolTable[symbolTableIndex-1], $1);}
            | lista_parametri ',' parametru {addParameterToFunction(&symbolTable[symbolTableIndex-1], $3);}
            ;
parametru : TYPE ID {struct parameter* temp = (struct parameter*)malloc(sizeof(struct parameter)); strcpy(temp->name,$2); strcpy(temp->info.type,$1); $$=temp;}
          ;            

lista_argumente: /*epsilon*/ {if(currentParameterIndex != calledFunction->numberOfParameters){yyerror("[!] Wrong number of parameters");}}
               | lista_argumente ',' arg 
               | arg
               ;
arg: ID {struct informations *temp = getInformationFromTable($1); /* verifyParameter(temp);*/ free(temp); }
    | NUMBER //{}
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
bloc : BEGIN_PR leftbracket list rightbracket  
     ;
     
if_statement: ELIF {inControlStatement++;} '('  expresii ')' leftbracket list rightbracket {inControlStatement--;} ELSE {inControlStatement++;} leftbracket list rightbracket {inControlStatement--;}  
           | IF {inControlStatement++;} '('  expresii ')' leftbracket list rightbracket {inControlStatement--;} 
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
initGlobalStack();
initScopeStack();
yyin=fopen(argv[1],"r");
yyparse();
printInfo();
} 

// -- Functions --
struct informations* getInformationFromTable(const char* name) {
  //   printf(" %s IN GETINFO ", name);
     
     struct symbol* temp = lookUpElement(name);
     
     struct informations* temp2 = (struct informations*)malloc(sizeof(struct informations));
     if (temp != NULL) {
          strcpy(temp2->type, temp->type);
          temp2->intVal = temp->intVal;
          temp2->floatVal = temp->floatValue;
          temp2->charVal = temp->charValue;
          if (temp->stringValue != NULL) strcpy(temp2->strVal, temp->stringValue);
          if (temp->boolValue != NULL) strcpy(temp2->boolVal, temp->boolValue);
          return temp2;
     }
     // If nu exista variabila ;)
     char error_message[100];
     sprintf(error_message, "[!] Variable %s was not declared", name);
     yyerror(error_message);
     return NULL;
}

int wasDefinedInGlobalScope(const char* name){
     for(int i=0; i < MAXSYMBOLS; i++) {
          if(strcmp(globalStack[i], name) == 0)
               return 1;
          if(strcmp(globalStack[i], "-1") == 0)
               return 0;
     } 
     return 0;
}


     
int wasDefinedInCurrentScope(const char* name) {
     
     for(int i=0; i < MAXSYMBOLS; i++) {
          if(strcmp(scopeStack[i], name) == 0)
               // Cautam scopeStack[i] in symbolTable
               {
                    for (int j = 0; j < symbolTableIndex; j++) {
                         if(strcmp(symbolTable[j].name, scopeStack[i]) == 0 ) {
                              
                              if(symbolTable[j].scope >= diffScope)
                              {
                                   if (inControlStatement > 0) {
                                        return 1;
                                   } else return 0;
                              }
                         }
                    }
               }
               
          if(strcmp(scopeStack[i], "-1") == 0)
               return 0;
     } 
     if(inFunction == 1)
     {
          for(int i=0; i < symbolTable[currentFunctionIndex].numberOfParameters; i++)
               if(strcmp(symbolTable[currentFunctionIndex].parameters[i].name, name) == 0)
                    return 1;
     }
     return 0;
}

void addVariableToTable(char *name, char* type, int scope, int isConstant, struct informations *info ){
    
     // Print the symbol data
     //printf("name : %s\n", name);
     //printf("type : %s]\n", type);
     //printf("scope : %d\n", scope);
     //printf("isConstant : %d\n", isConstant);
     //printf("info type : %s\n", info->type);
     //printf("info boolVal: %s\n", info->boolVal);
     //printf("info charVal: %s\n", info->charVal);
     

     // Verificam daca variabila nu se afla in unul din scope-urile parinte
     char error_message[100];

     if (scope == 0) {
          if(wasDefinedInGlobalScope(name) == 1)
          {
               sprintf(error_message, "[!]Variable already defined in global scope : %s  -> ", name);
               yyerror(error_message);
          }
     }
 
     if (scope != 0) {
          if(wasDefinedInCurrentScope(name) == 1){
               sprintf(error_message, "[!]Variable already defined in current scope : %s  -> ", name);
               yyerror(error_message);
          }
          else if (wasDefinedInGlobalScope(name) == 1){
               sprintf(error_message, "[!]Variable already defined in global scope : %s  -> ", name);
               yyerror(error_message);
          }
     }

     // continuam cu adaugarea in tabela de simboluri
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
     symbolTableIndex++;

     if (scope == 0) {
          pushGlobalStack(name);
     } else {
          pushScopeStack(name);
     }

          //printf("new simbol added to table\n===\n");
          //// Print the symbol data
          //printf("name : %s\n", symbolTable[symbolTableIndex-1].name);
          //printf("type : %s\n", symbolTable[symbolTableIndex-1].type);
          //printf("scope : %d\n", symbolTable[symbolTableIndex-1].scope);
          //printf("isConstant : %d\n", symbolTable[symbolTableIndex-1].isConstant);
          //printf("int value : %d\n", symbolTable[symbolTableIndex-1].intVal);
          //printf("float value : %f\n", symbolTable[symbolTableIndex-1].floatValue);
          //printf("char value : %s\n", symbolTable[symbolTableIndex-1].charValue);
          //printf("bool value : %s\n", symbolTable[symbolTableIndex-1].boolValue);
          //printf("string value : %s\n", symbolTable[symbolTableIndex-1].stringValue);

}
void addFunctionToTable( char* functionType, char *functionName, int scope){
     
     // Vefificam daca functia exista in global scope
     char error_message[100];
     if (scope == 0) {
          if(wasDefinedInGlobalScope(functionName) == 1)
          {
               sprintf(error_message, "[!]Function already defined in global scope : %s  -> ", functionName);
               yyerror(error_message);
          }
     }
     strcpy(symbolTable[symbolTableIndex].name, functionName);
     strcpy(symbolTable[symbolTableIndex].type, functionType);
     symbolTable[symbolTableIndex].scope=scope;
     symbolTable[symbolTableIndex].typeOfObject=FUNCTION;
     symbolTable[symbolTableIndex].numberOfParameters=0;
     symbolTableIndex++;
     pushGlobalStack(functionName); // pana cand doar in global scope
}

// !INFO: La moment doar adaug parametrul in stacul local, dar ei nu sunt salvati nicaieri
void addParameterToFunction(struct symbol *functie, struct parameter* param){

     //Verificam daca numele parametrului nu este deja folosit
     char error_message[100];
     if (wasDefinedInCurrentScope(param->name) == 1){
          sprintf(error_message, "[!]Parameter already defined in current scope : %s  -> ", param->name);
          free(param);
          yyerror(error_message);
     }
     else if (wasDefinedInGlobalScope(param->name) == 1){
          sprintf(error_message, "[!]Parameter already defined in global scope : %s  -> ", param->name);
          free(param);
          yyerror(error_message);
     }

     if(functie->numberOfParameters > MAXPARAMETERS)
     {    
          free(param);
          yyerror("[!]Parameter limit exceeded");
     }

     strcpy(functie->parameters[functie->numberOfParameters].name, param->name);
     strcpy(functie->parameters[functie->numberOfParameters].info.type, param->info.type);
     functie->numberOfParameters++;

     pushScopeStack(param->name);
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
                if(strcmp(symbolTable[i].type, "char") == 0)
               {
                    printf("Returned value of function[%d]:%c\n", i, symbolTable[i].charValue);
               }
               else if(strcmp(symbolTable[i].type, "bool") == 0)
               {
                    printf("Returned value of function[%d]:%s\n", i, symbolTable[i].boolValue);
               }
               else if(strcmp(symbolTable[i].type, "int") == 0)
               {
                    printf("Returned value of function[%d]:%d\n", i, symbolTable[i].intVal);
               }
               else if(strcmp(symbolTable[i].type, "float") == 0)
               {
                    printf("Returned value of function[%d]:%f\n", i, symbolTable[i].floatValue);
               }
               else if(strcmp(symbolTable[i].type, "string") == 0)
               {
                    printf("Returned value of function[%d]:%s\n", i, symbolTable[i].stringValue);
               }
               for(int j=0; j<symbolTable[i].numberOfParameters; j++)
               {
                    printf("--->Name of parameter[%d]:%s\n", j, symbolTable[i].parameters[j].name);
                    printf("--->Type of parameter[%d]:%s\n", j, symbolTable[i].parameters[j].info.type);
               }
          }
          
     }
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
struct symbol* lookUpElement(const char* name){
     // Check daca este in global dupa in local stack
     struct symbol* temp = NULL;
     for(int i=0; i < MAXSYMBOLS; i++) {
          if(strcmp(globalStack[i], name) == 0)
               { 
                    for(int j=0; j < MAXSYMBOLS; j++){
                         if(strcmp(symbolTable[j].name, name) == 0 && symbolTable[j].scope == 0)
                              {temp = &symbolTable[j];
                              return temp;}
                     }
               }
          if(strcmp(globalStack[i], "-1") == 0)
               break;
     } 
     for(int i=0; i < MAXSYMBOLS; i++) {
          if(strcmp(scopeStack[i], name) == 0)
               { 
                    for(int j=0; j < MAXSYMBOLS; j++){
                         if(strcmp(symbolTable[j].name, name) == 0 && symbolTable[j].scope >= diffScope)
                              {temp = &symbolTable[j];
                              return temp;}
                     }
               }
          if(strcmp(scopeStack[i], "-1") == 0)
               break;
     }  
     return NULL;
     
}
/* void verifyParameter(struct information* parameter){
     char error_message[100];
     for(int i = 0; i <= calledFunction->numberOfParameters; i++)
     {
          if(strcmp(parameter->type, calledFunction->parameters[i].type) != 0)
               {// sprintf(error_message, "[!]Argument %s not declared  -> ", name);
                  //  yyerror(error_message);}
     }   
} */
void test(const char* name)
{
     struct symbol* temp = lookUpElement(name);
     if(temp == NULL)
          yyerror("[!]Variable not declared");
     else
     {
          printf("Name: %s, Type: %s, Value: %d, Scope: %d\n", temp->name, temp->type, temp->intVal, temp->scope);
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
          return;
     }
     else{
          if(typeOfOperation == OP_NEGATION)
          negation(finalExp, leftExp);
          else if(typeOfOperation == OP_UNARYMINUS)
          unaryNegation(finalExp,leftExp);
          return;
     }
     return;
     yyerror("[!]Illegal operation");
     
}

void initGlobalStack(){
     int i;
     for(i=0; i<MAXSYMBOLS; i++){
          globalStack[i] = (char*)malloc(50*sizeof(char));
          strcpy(globalStack[i], "-1");
     }
}

void pushGlobalStack(const char* name){
     int i;
     for(i=0; i<MAXSYMBOLS; i++){
          if(strcmp(globalStack[i], "-1") == 0){
               strcpy(globalStack[i], name);
               break;
          }
     }
}

void initScopeStack(){
     if (scopeStack[0] == NULL){
          int i;
          for(i=0; i<MAXSYMBOLS; i++){
               scopeStack[i] = (char*)malloc(50*sizeof(char));
               strcpy(scopeStack[i], "-1");
          }
     } else {
          for (int i=0; i<MAXSYMBOLS; i++){
               strcpy(scopeStack[i], "-1");
          }
     }
}

void pushScopeStack(const char* name){
     int i;
     for(i=0; i<MAXSYMBOLS; i++){
          if(strcmp(scopeStack[i], "-1") == 0){
               strcpy(scopeStack[i], name);
               break;
          }
    }
     
}

void changeScope() 
{
     if (scope == 0) {
          scope = last_scope + 2;
          diffScope = scope;
          inFunction=1;
     } else {
          scope = scope + 1;
          
     }
}

void printStackValues(){ // for testing
     printf("STACK VALUES: ");
     for(int i=0; i<MAXPARAMETERS;i++)
     printf("%s,",scopeStack[i]);
}
void revertScope()
{
     if (scope - diffScope == 0) {
          last_scope = scope;
          diffScope = 0;
          scope = 0;
          inFunction=0;
          initScopeStack();
     } else {
          scope = scope - 1;
     }
}

void updateVariable(const char* name, struct informations* info) {
     struct symbol* temp = lookUpElement(name);
  
     char error_message[100]; 
     if(temp == NULL){
          sprintf(error_message, "[!]Variable %s not declared  -> ", name);
          yyerror(error_message);
     }
    
    if (temp->isConstant == 1) {
          sprintf(error_message, "[!]Variable %s is constant -> ", name);
          yyerror(error_message);
     }
  
     if(strcmp(temp->type, info->type) != 0) {
          sprintf(error_message, "[!]Type mismatch for variable %s -> ", name);
          yyerror(error_message);
     }

  
          temp->intVal = info->intVal;
          temp->floatValue = info->floatVal;
          temp->charValue = info->charVal;
          
          

          if (info->strVal != NULL)
          {    if(temp->stringValue == NULL)
                    temp->stringValue = (char*)malloc(256*sizeof(char));
               strcpy(temp->stringValue, info->strVal);}
          if (info->boolVal != NULL) 
          {    if(temp->boolValue == NULL)
                    temp->boolValue = (char*)malloc(7*sizeof(char));
               strcpy(temp->boolValue, info->boolVal);}


     
     
}