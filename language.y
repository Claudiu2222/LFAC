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

#define LITERAL 0
#define VARIABLE 1
#define FUNCTION 2
#define _CLASS_ 3
#define CLASSMEMBER 4

#define OBJECT 5
#define ARRAY 6


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
#define MAXARRAYSIZE 100
#define MAXSYMBOLS 200
#define GLOBAL 0

#define PRIVATE 0
#define PUBLIC 1
#define PROTECTED 2

extern int yylex();
void yyerror(char * s);

// Type const chars * 
const char* _int = "int";
const char* _float = "float";
const char* _char = "char";
const char* _string = "string";
const char* _bool = "bool";


struct information{
     int intVal;
     char boolVal[7];
     char strVal[50];
     float floatVal;
     char charVal;
     char type[10];
};
struct parameter{
     char name[50];
     struct information info;
};

struct objval {
     char name[50];      // 
     char type[30];      // 
     int isConstant;     //

     char charValue;
     int intVal;
     char** boolValue;
     float floatValue;
     char *stringValue;
     int *integerVector;
     char *characterVector;
	char **stringVector;
     int vectorSize;
     
     struct parameter parameters[MAXPARAMETERS];
     int numberOfParameters;
};



struct symbol{
     char name[50]; // 
     char type[30];     //
     int scope;    // 
     int isConstant; //
     int typeOfObject; // 1 var, 2 functie, 3 clasa, 4 membru de clasa, 5 array
     char parrentClass[50];
     int accessModifier;
     char charValue;
     int intVal;
     char* boolValue;
     float floatValue;
     char *stringValue;
     
     int *integerVector;
     char *characterVector;
	char **stringVector;
     float *floatVector;
     char **booleanVector;
     int vectorSize;
     
     struct parameter parameters[MAXPARAMETERS];
     int numberOfParameters;

     struct objval objValues[MAXSYMBOLS];
     int numberOfObjValues;


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
void verifyArgument(struct information* argument, int typeOfArgument, char* name);

int inControlStatement = 0;

int inClass = 0;
char currentClass[50];
char accesModifier[10];

struct information* arrayValueAtIndex(const char* name, int index);

void addParameterToFunction(struct symbol* functie, struct parameter* param);
void addFunctionToTable(char* type, char *name,  int scope);
void addVariableToTable(char *name, char* type, int scope, int isConstant, struct information *info );
void addArrayToTable(const char* type, int numberOfElements, const char* name, int scope);
void addVariableFromSymToTable(char *name, char* type, int scope, int isConstant, const char* symbol_name);
void printInfo();
void initializeStack();
void pushScope();
void popScope();
void add(struct information* finalExp, struct information* leftExp, struct information* rightExp);
void subtract(struct information* finalExp, struct information* leftExp, struct information* rightExp);
void multiply(struct information* finalExp, struct information* leftExp, struct information* rightExp);
void divide(struct information* finalExp, struct information* leftExp, struct information* rightExp);
void calculate(struct information* finalExp, struct information* leftExp, struct information* rightExp, int typeOfOperation);
void eval(struct information* expression);
void verifyTypes(struct information* finalExp, struct information* leftExp, struct information* rightExp);
void showStack();
void updateVariable(const char* name, struct information* info);
void updateVariableToInstance(const char* name, const char* className, struct information* info);
struct symbol* lookUpElement(const char* name);
int returnTypeOfObject(const char* name);
void addClass(const char* name);
void verifyIfSymbolNameIsAVariable(const char* name);
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
void updateArrayValue(const char* name, int index, struct information* info);
// ---- 
struct information* getInformationFromTable(const char* name);
void addInstanceToTable(const char* name, const char* className);
struct information* getInformationFromInstance(const char* name, const char* prop);
void addFunctionToTableFromClass(const char* name, const char* parrentClass);
void addFunctionToInstantce(const char* name, const char* instance);
%}

%union {
  char* strVal;
  int intVal;
  double floatVal;
  char* boolVal;
  char charVal;

  struct information *info;
  struct parameter *param;

}
%token BEGIN_PR END_PR INSTANCEOF ELIF RETURN CONSTANT IF ELSE WHILE FOR CLASS LESSTHAN LESSOREQUALTHAN GREATERTHAN EQUAL GREATEROREQUALTHAN AND OR NEGATION PLUS MINUS MULTIPLICATION DIVISION ASSIGN LEFTBRACKET RIGHTBRACKET EVAL TYPEOF PRINT

%token <strVal>TYPE
%token <intVal>NUMBER
%token <boolVal>BOOLEANVALUE
%token <floatVal>FLOAT
%token <charVal>CHAR
%token <strVal>STRING
%token <strVal>ACCESSMODIFIER

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
           | TYPE ID {inFunction=1; addFunctionToTable($1, $2, scope); strcpy(currentFunction, $2); currentFunctionIndex=symbolTableIndex-1;} '(' {changeScope();} lista_parametri ')'  LEFTBRACKET list RETURN returnedvalue NEGATION {if (strcmp($11->type,$1)!=0){yyerror("[!] Returned value does not match function's type");} updateVariable($2,$11); free($11);inFunction=0;} rightbracket //function
           | CLASS ID {strcpy(currentClass, $2); inClass = 1;} leftbracket class_decs rightbracket {addClass($2); inClass = 0;}   
           ; 

class_decs : class_decs class_dec
           | class_dec
           ;

class_dec : ACCESSMODIFIER TYPE ID ';' {strcpy(accesModifier, $1); addVariableToTable($3, $2, scope, NONCONSTANT , 0);}//variable
          | ACCESSMODIFIER TYPE ID ASSIGN expresii ';' {strcpy(accesModifier, $1); addVariableToTable($3, $2, scope, NONCONSTANT , $5); free($5);}//variable
          | ACCESSMODIFIER TYPE '[' NUMBER ']' ID ';' // array
          | ACCESSMODIFIER TYPE ID '[' NUMBER ']' ASSIGN expresii ';' {free($8);}// array at index NUMBER = assignedValue
          | ACCESSMODIFIER CONSTANT TYPE ID ASSIGN expresii ';' {strcpy(accesModifier, $1); addVariableToTable($4, $3, scope, CCONSTANT , $6); free($6);}
          //| ACCESSMODIFIER TYPE ID '(' lista_parametri ')' leftbracket list RETURN returnedvalue NEGATION rightbracket {addFunctionToTable($2, $3, scope); strcpy(currentFunction, $3); currentFunctionIndex=symbolTableIndex-1; inFunction=0;} //function
          | ACCESSMODIFIER TYPE ID {inFunction=1; strcpy(accesModifier, $1); addFunctionToTable($2, $3, scope); strcpy(currentFunction, $3); currentFunctionIndex=symbolTableIndex-1;} '(' {changeScope();} lista_parametri ')'  LEFTBRACKET list RETURN returnedvalue NEGATION {if (strcmp($12->type,$2)!=0){yyerror("[!] Returned value does not match function's type");} updateVariable($3,$12); free($12);inFunction=0;} rightbracket //function
          ;

declaratii_comune: TYPE ID ';' 
                    {addVariableToTable($2, $1, scope, NONCONSTANT , 0);}//variable

                 | TYPE ID ASSIGN  expresii ';' 
                    {addVariableToTable($2, $1, scope, NONCONSTANT , $4); free($4); } //variable or array - assign

                 | TYPE '[' NUMBER ']' ID ';' {addArrayToTable($1, $3, $5, scope);} // array
                 | ID ASSIGN expresii ';' { updateVariable($1, $3);  free($3); } //variable or array - assign -> la fel, dar fara type -> trb verificat daca a fost declarata inainte
                 | ID '[' NUMBER ']' ASSIGN expresii ';' { updateArrayValue($1, $3, $6); free($6);}// array at index NUMBER = assignedValue
                 | ID '.' ID ASSIGN expresii ';' {updateVariableToInstance($3, $1, $5); free($5);}
                 | CONSTANT TYPE ID ASSIGN expresii ';' {addVariableToTable($3, $2, scope, CCONSTANT , $5); free($5); }//variable // const id = 2 + 3;
                 | ID INSTANCEOF ID ';' {addInstanceToTable($1, $3);} // obj => Foo;
                 ;

expresii:  expresii MULTIPLICATION expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $1, $3, OP_MULTIPLICATION); free($1); free($3); $$=temp;}
          | expresii DIVISION expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $1, $3, OP_DIVISION); free($1); free($3); $$=temp;}
          | expresii AND expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $1, $3, OP_AND); free($1);free($3); $$=temp;}
          | expresii OR expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $1, $3, OP_OR); free($1);free($3); $$=temp;}
          | expresii LESSTHAN expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $1, $3, OP_LESSTHAN); free($1);free($3); $$=temp;}
          | expresii LESSOREQUALTHAN expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $1, $3, OP_LESSOREQUALTHAN); free($1);free($3); $$=temp;}
          | expresii GREATERTHAN expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $1, $3, OP_GREATERTHAN); free($1);free($3); $$=temp;}
          | expresii GREATEROREQUALTHAN expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $1, $3, OP_GREATEROREQUALTHAN); free($1);free($3); $$=temp;}
          | expresii EQUAL expresii {struct information *temp=(struct information*)malloc(sizeof(struct information));calculate(temp, $1, $3, OP_EQUAL); free($1);free($3); $$=temp;}
          | NEGATION expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $2, NULL, OP_NEGATION); free($2); $$=temp;}
          | expresii PLUS expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $1, $3, OP_PLUS); free($1);free($3); $$=temp;}
          | expresii MINUS expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $1, $3, OP_MINUS); free($1);free($3); $$=temp;}
          | '(' expresii ')' {$$=$2;}
          | MINUS expresii {struct information *temp=(struct information*)malloc(sizeof(struct information)); calculate(temp, $2, NULL,OP_UNARYMINUS); free($2); $$=temp;}
          | NUMBER {struct information *temp=(struct information*)malloc(sizeof(struct information)); temp->intVal=$1; strcpy(temp->type,_int); $$=temp;} 
          | FLOAT  {struct information *temp=(struct information*)malloc(sizeof(struct information)); temp->floatVal=$1; strcpy(temp->type,_float); $$=temp;} 
          | CHAR  {struct information *temp=(struct information*)malloc(sizeof(struct information)); temp->charVal=$1; strcpy(temp->type,_char); $$=temp;} 
          | STRING  {struct information *temp=(struct information*)malloc(sizeof(struct information));strcpy(temp->strVal,$1); strcpy(temp->type,_string); $$=temp;} 
          | BOOLEANVALUE {struct information *temp=(struct information*)malloc(sizeof(struct information)); strcpy(temp->boolVal,$1); strcpy(temp->type,_bool); $$=temp;} 
          | ID '.' ID {struct information *temp = getInformationFromInstance($1, $3); $$=temp;} 
          | ID  {currentParameterIndex=0; calledFunction=lookUpElement($1); if(calledFunction == NULL){yyerror("[!] Function does not exist");} } '(' lista_argumente ')' { if(currentParameterIndex < calledFunction->numberOfParameters){yyerror("[!] Not enough parameters");}struct information *temp=getInformationFromTable($1); $$=temp;}      // aici am adaugat cam tot pt function calls, in prima parte imi cauta acel function si il salveaza in calledFunction  si in a doua parte ii  verific sa aiba verifica sa nu depaseasca nr de argumente + trimite mai departe acel pointer ca sa pot ii verific in regulile de erau undeva mai sus ca TIPUL RETURNAT DE FUNCTIE SA FIE EGAL CU TIPUL VARIABILEI MELE, si de asemenea se face un assign :) cum vezi in exemplu se face in fact atribuirea in variabila a stringului in primul exemplu din input.txt 
          | ID '.' ID '(' lista_argumente ')'  //method call
          | ID '[' NUMBER ']'  {struct information *temp= arrayValueAtIndex($1, $3); $$=temp;} // array at index NUMBER 
          | ID      {struct information *temp = getInformationFromTable($1);  verifyIfSymbolNameIsAVariable($1); $$=temp;} 

          ;
//ifStatement


returnedvalue: ID { struct information *temp = getInformationFromTable($1); $$=temp;}
               | NUMBER {struct information *temp=(struct information*)malloc(sizeof(struct information)); temp->intVal=$1; strcpy(temp->type,_int); $$=temp;}
               | FLOAT {struct information *temp=(struct information*)malloc(sizeof(struct information)); temp->floatVal=$1; strcpy(temp->type,_float); $$=temp;}
               | BOOLEANVALUE {struct information *temp=(struct information*)malloc(sizeof(struct information)); strcpy(temp->boolVal,$1); strcpy(temp->type,_bool); $$=temp;}
               | STRING {struct information *temp=(struct information*)malloc(sizeof(struct information));strcpy(temp->strVal,$1); strcpy(temp->type,_string); $$=temp;}
               | CHAR {struct information *temp=(struct information*)malloc(sizeof(struct information)); temp->charVal=$1; strcpy(temp->type,_char); $$=temp;}
               | ID '[' NUMBER ']' // array at index NUMBER
               ;

lista_parametri : /*epsilon*/ 
            | parametru {addParameterToFunction(&symbolTable[symbolTableIndex-1], $1);}
            | lista_parametri ',' parametru {addParameterToFunction(&symbolTable[symbolTableIndex-1], $3);}
            ;
parametru : TYPE ID {struct parameter* temp = (struct parameter*)malloc(sizeof(struct parameter)); strcpy(temp->name,$2); strcpy(temp->info.type,$1); $$=temp;}
          ;            

lista_argumente: /*epsilon*/ 
               | lista_argumente ',' arg 
               | arg
               ;
arg:  ID {verifyIfSymbolNameIsAVariable($1); if(currentParameterIndex  >= calledFunction->numberOfParameters){yyerror("[!] Too many arguments");}; struct information *temp = getInformationFromTable($1); verifyArgument(temp, VARIABLE, $1);currentParameterIndex++; free(temp); } // aici se face un verify sa nu am prea putine argumente, pt fiecare argument se verifica in verifyArgument daca coincide sau nu cu tipul parametrului cu care corespunde. Vezi functia verifyArgument 
    | NUMBER {struct information *temp=(struct information*)malloc(sizeof(struct information)); temp->intVal=$1; strcpy(temp->type,_int); verifyArgument(temp, LITERAL, NULL);currentParameterIndex++; free(temp);} 
    | FLOAT {struct information *temp=(struct information*)malloc(sizeof(struct information)); temp->floatVal=$1; strcpy(temp->type,_float); verifyArgument(temp, LITERAL, NULL);currentParameterIndex++; free(temp);} 
    | BOOLEANVALUE {struct information *temp=(struct information*)malloc(sizeof(struct information)); strcpy(temp->boolVal,$1); strcpy(temp->type,_bool); verifyArgument(temp, LITERAL, NULL);currentParameterIndex++; free(temp);} 
    | STRING {struct information *temp=(struct information*)malloc(sizeof(struct information)); strcpy(temp->strVal,$1); strcpy(temp->type,_string); verifyArgument(temp, LITERAL, NULL);currentParameterIndex++; free(temp);}
    | CHAR {struct information *temp=(struct information*)malloc(sizeof(struct information)); temp->charVal=$1; strcpy(temp->type,_char); verifyArgument(temp, LITERAL, NULL); currentParameterIndex++;free(temp);} 
    | ID {if(returnTypeOfObject($1) == VARIABLE){yyerror("[!] This is a variable, not a function");} struct information *temp = getInformationFromTable($1); verifyArgument(temp, FUNCTION, $1); free(temp);}'(' lista_argumente ')' { struct information *temp=getInformationFromTable($1); }  // segmentation fault pt apeluri de functii ca argument.. Nu stiu dc is prea obosit sa mai verific . EDIT: SEG FAULT PT ORICE ARGUMENT CE NU A FOST DECLARAT BEFORE (si variabile si functii)
    | ID '.' ID '(' lista_argumente ')' {currentParameterIndex++;}// todo when classes are done
    | ID '[' NUMBER ']' { struct information *temp = getInformationFromTable($1); verifyArgument(temp, ARRAY, $1);currentParameterIndex++;}// todo when arrays are done
    | ID '.' ID // todo when classes are done
    
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
         | TYPEOF '(' expresii ')' ';' { printf("The type of the expression you have written is: %s\n",$3->type);free($3);}
         | EVAL '(' expresii ')' ';' {eval($3); free($3);}
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
struct information* getInformationFromTable(const char* name) {
  //   printf(" %s IN GETINFO ", name);
     
     struct symbol* temp = lookUpElement(name);
     char error_message[100];
     struct information* temp2 = (struct information*)malloc(sizeof(struct information));
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
     free(temp);
     
     
     sprintf(error_message, "[!] Variable %s was not declared", name);
     yyerror(error_message);
     return NULL;
}

struct information* getInformationFromInstance(const char* name, const char* prop) {
          
     // Search for the instance 
     struct symbol* temp = lookUpElement(name);


     if (temp != NULL) {
          // Cautam in objvals 
          for (int i = 0; i < temp->numberOfObjValues; i++) {
               if (strcmp(temp->objValues[i].name, prop) == 0) {
                    struct information* temp2 = (struct information*)malloc(sizeof(struct information));
                    strcpy(temp2->type, temp->objValues[i].type);
                    temp2->intVal = temp->objValues[i].intVal;
                    temp2->floatVal = temp->objValues[i].floatValue;
                    temp2->charVal = temp->objValues[i].charValue;
                    if (temp->objValues[i].stringValue != NULL) strcpy(temp2->strVal, temp->objValues[i].stringValue);
                    if (temp->objValues[i].boolValue != NULL) strcpy(temp2->boolVal, temp->objValues[i].boolValue);
                    return temp2;
               }
          }
     }


     // If nu exista variabila ;)
     char error_message[100];
     sprintf(error_message, "[!] Variable [%s] is not declared or is not public for [%s]", prop, name);
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


struct information* arrayValueAtIndex(const char* name, int index){
     struct symbol* temp = lookUpElement(name);
     
     if(temp == NULL) {
          char error_message[100];
          sprintf(error_message, "[!] Array %s was not declared", name);
          yyerror(error_message);
          return NULL;
     }

     if(index >= temp->vectorSize) {
          char error_message[100];
          sprintf(error_message, "[!] Index out of bounds");
          yyerror(error_message);
          return NULL;
     }
   
     struct information* temp2 = (struct information*)malloc(sizeof(struct information));
     
     strcpy(temp2->type, temp->type);
     if(strcmp(temp->type, "int") == 0)
     temp2->intVal = temp->integerVector[index];
     else if(strcmp(temp->type, "float") == 0)
     temp2->floatVal = temp->floatVector[index];
     else if(strcmp(temp->type, "char") == 0)
     temp2->charVal = temp->characterVector[index];
     else if (strcmp(temp->type, "string") == 0)
     if (temp->stringVector[index] != NULL) strcpy(temp2->strVal, temp->stringVector[index]);
     else if(strcmp(temp->type, "bool") == 0)
     if (temp->booleanVector[index] != NULL) strcpy(temp2->boolVal, temp->booleanVector[index]);
     return temp2;
} 
int wasDefinedInCurrentScope(const char* name) {
     if(inFunction == 1)
     {
          for(int i=0; i < symbolTable[currentFunctionIndex].numberOfParameters; i++)
               if(strcmp(symbolTable[currentFunctionIndex].parameters[i].name, name) == 0)
                    return 1;
     }
     for(int i=0; i < MAXSYMBOLS; i++) {
          if(strcmp(scopeStack[i], name) == 0)
               // Cautam scopeStack[i] in symbolTable
               {
                    for (int j = 0; j < symbolTableIndex; j++) {
                         if(strcmp(symbolTable[j].name, scopeStack[i]) == 0 ) {
                              
                              if(symbolTable[j].scope >= diffScope)
                              {
                                   
                                        return 1;
                                   
                                  
                                   
                              } else return 0;
                         }
                    }
               }
               
          if(strcmp(scopeStack[i], "-1") == 0)
               return 0;
     } 
     
     return 0;
}

void addVariableToTable(char *name, char* type, int scope, int isConstant, struct information *info ){
    
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

     if (scope == 0) {
          pushGlobalStack(name);
     } else {
          pushScopeStack(name);
     }

     // If we are in a calss, we need to specify other information precum 
     if (inClass == 1) {
          strcpy(symbolTable[symbolTableIndex].parrentClass, currentClass);
          symbolTable[symbolTableIndex].typeOfObject = CLASSMEMBER;
          if (strcmp(accesModifier, "public") == 0) {
               symbolTable[symbolTableIndex].accessModifier = PUBLIC;
          } else if (strcmp(accesModifier, "private") == 0) {
               symbolTable[symbolTableIndex].accessModifier = PRIVATE;
          } else if (strcmp(accesModifier, "protected") == 0) {
               symbolTable[symbolTableIndex].accessModifier = PROTECTED;
          }
     }
     symbolTableIndex++;
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

     if (inClass == 1) {
          strcpy(symbolTable[symbolTableIndex].parrentClass, currentClass);
          symbolTable[symbolTableIndex].typeOfObject = CLASSMEMBER;
          if (strcmp(accesModifier, "public") == 0) {
               symbolTable[symbolTableIndex].accessModifier = PUBLIC;
          } else if (strcmp(accesModifier, "private") == 0) {
               symbolTable[symbolTableIndex].accessModifier = PRIVATE;
          } else if (strcmp(accesModifier, "protected") == 0) {
               symbolTable[symbolTableIndex].accessModifier = PROTECTED;
          }
     }
     symbolTableIndex++;
     if (scope == 0) {
          pushGlobalStack(functionName);
     } else {
          pushScopeStack(functionName);
     } // pana cand doar in global scope
}
void addFunctionToInstantce(const char* name, const char* instance)
{

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
     /* else if (wasDefinedInGlobalScope(param->name) == 1){
          sprintf(error_message, "[!]Parameter already defined in global scope : %s  -> ", param->name);
          free(param);
          yyerror(error_message);
     } */

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
void updateArrayValue(const char* name, int index, struct information* info)
{
     char error_message[100];
     struct symbol* array = lookUpElement(name);
     if(index >= MAXARRAYSIZE)
     {
          yyerror("[!]Array index out of bounds");
     }if(array == NULL)
     {    sprintf(error_message, "[!]Array %s not defined in current or global scope -> ", name);
          yyerror(error_message);
     }
     if(strcmp(array->type, info->type) != 0)
     {
          sprintf(error_message, "[!]Array %s type and value type do not match -> ", name);
          yyerror(error_message);
     }
     if(strcmp(array->type, "int") == 0)
     {
          array->integerVector[index] = info->intVal;
     }
     else if(strcmp(array->type, "float") == 0)
     {
          array->floatVector[index] = info->floatVal;
     }
     else if(strcmp(array->type, "char") == 0)
     {
          array->characterVector[index] = info->charVal;
     }
     else if(strcmp(array->type, "bool") == 0)
     {
          strcpy(array->booleanVector[index],info->boolVal);
     }
     else if(strcmp(array->type, "string") == 0)
     {
          strcpy(array->stringVector[index],info->strVal);
     }
     
    

}
void addArrayToTable(const char* type, int numberOfElements, const char* name, int scope){
     
     // Vefificam daca array-ul exista in global scope
     char error_message[100];
     if (wasDefinedInCurrentScope(name) == 1){
          sprintf(error_message, "[!]Array already defined in current scope : %s  -> ", name);
          yyerror(error_message);
     }
      else if (wasDefinedInGlobalScope(name) == 1){
          sprintf(error_message, "[!]Array already defined in global scope : %s  -> ", name);
          yyerror(error_message);
     } 

     if(numberOfElements > MAXARRAYSIZE)
     {
          yyerror("[!]Array size is too big");
     }
     strcpy(symbolTable[symbolTableIndex].type, type);
     symbolTable[symbolTableIndex].typeOfObject=ARRAY;
     symbolTable[symbolTableIndex].isConstant=0;
     symbolTable[symbolTableIndex].scope=scope;
     symbolTable[symbolTableIndex].vectorSize = numberOfElements;
     
     strcpy(symbolTable[symbolTableIndex].name, name);
     if(strcmp(type, "char") == 0)
     {    
          symbolTable[symbolTableIndex].characterVector=(char*)malloc(numberOfElements*sizeof(char));
        
          for(int i=0 ;i <numberOfElements; i++)
          {    
               symbolTable[symbolTableIndex].characterVector[i]=' ';
          }
         
     }
     else if(strcmp(type, "int") == 0)
     {
          symbolTable[symbolTableIndex].integerVector=(int*)malloc(numberOfElements*sizeof(int));
          for(int i=0 ;i <numberOfElements; i++)
          {    
               symbolTable[symbolTableIndex].integerVector[i]=0;
          }
          
     }
     else if(strcmp(type, "float") == 0)
     {
          symbolTable[symbolTableIndex].floatVector=(float*)malloc(numberOfElements*sizeof(float));
           for(int i=0 ;i <numberOfElements; i++)
          {    
               symbolTable[symbolTableIndex].floatVector[i]=0.0;
          }
     }
     else if(strcmp(type, "bool") == 0)
     {
          symbolTable[symbolTableIndex].booleanVector=(char**)malloc(numberOfElements*sizeof(char*));
           for(int i=0 ;i <numberOfElements; i++)
          {    
               symbolTable[symbolTableIndex].booleanVector[i]=(char*)malloc(7*sizeof(char));
               strcpy(symbolTable[symbolTableIndex].booleanVector[i],"NULL");
          }
     }
     else if(strcmp(type, "string") == 0)
     {
          symbolTable[symbolTableIndex].stringVector=(char**)malloc(numberOfElements*sizeof(char*));
          for(int i=0 ;i <numberOfElements; i++)
          {    
               symbolTable[symbolTableIndex].stringVector[i]=(char*)malloc(50*sizeof(char));
               strcpy(symbolTable[symbolTableIndex].stringVector[i],"NULL");
          }
     }
          symbolTableIndex++;
          if(scope==0)
          pushGlobalStack(name);
          else
          pushScopeStack(name);
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
          else if (symbolTable[i].typeOfObject == _CLASS_)
          {
               printf("%s is a class! \n", symbolTable[i].name);
          }
          else if (symbolTable[i].typeOfObject == CLASSMEMBER)
          {
               printf("Parrent class of symbol[%s]:%s\n", symbolTable[i].name, symbolTable[i].parrentClass);
               printf("Access modifier of symbol[%s]:%d\n", symbolTable[i].name, symbolTable[i].accessModifier);
                if(strcmp(symbolTable[i].type, "char") == 0)
               {
                    printf("The value of [%s]:%c\n", symbolTable[i].name, symbolTable[i].charValue);
               }
               else if(strcmp(symbolTable[i].type, "bool") == 0)
               {
                    printf("The value of [%s]:%s\n", symbolTable[i].name, symbolTable[i].boolValue);
               }
               else if(strcmp(symbolTable[i].type, "int") == 0)
               {
                    printf("The value of [%s]:%d\n", symbolTable[i].name, symbolTable[i].intVal);
               }
               else if(strcmp(symbolTable[i].type, "float") == 0)
               {
                    printf("The value of [%s]:%f\n", symbolTable[i].name, symbolTable[i].floatValue);
               }
               else if(strcmp(symbolTable[i].type, "string") == 0)
               {
                    printf("The value of [%s]:%s\n", symbolTable[i].name, symbolTable[i].stringValue);
               }
          }
          else if(symbolTable[i].typeOfObject == ARRAY)
          {
               printf("Array elements: ");
               for(int j = 0; j < symbolTable[i].vectorSize; j++)
               {
                    printf("\'");
                    if(strcmp(symbolTable[i].type, "char") == 0)
                         printf("%c",symbolTable[i].characterVector[j]);
                    else if(strcmp(symbolTable[i].type, "bool") == 0)
                         printf("%s",symbolTable[i].booleanVector[j]);
                    else if(strcmp(symbolTable[i].type, "int") == 0)
                         printf("%d",symbolTable[i].integerVector[j]);
                    else if(strcmp(symbolTable[i].type, "float") == 0)
                         printf("%f",symbolTable[i].floatVector[j]);
                    else if(strcmp(symbolTable[i].type, "string") == 0)
                         printf("%s",symbolTable[i].stringVector[j]);
                    
                    printf("\'  ");
               }
          }
          
     }
}


void add(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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
void subtract(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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
void multiply(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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

void divide(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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

void equal(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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
void lessThan(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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
void lessOrEqualThan(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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
void greaterThan(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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
void greaterOrEqualThan(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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
void or(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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
void and(struct information* finalExp, struct information* leftExp, struct information* rightExp)
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
void negation(struct information* finalExp, struct information* leftExp)
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
void unaryNegation(struct information* finalExp, struct information* leftExp)
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
     if(inFunction == 1){
          for(int i=0; i < symbolTable[currentFunctionIndex].numberOfParameters; i++)
          {
               if(strcmp(symbolTable[currentFunctionIndex].parameters[i].name, name) == 0)
                    {temp = &symbolTable[currentFunctionIndex];
                    return temp;}
          }
     }
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
void updateParameterValue(struct information* info, int typeOfArgument)
{
     if(typeOfArgument == LITERAL)
     {
          if(strcmp(info->type,"int")==0)
          {
               calledFunction->parameters[currentParameterIndex-1].info.intVal = info->intVal;
          }
          else if(strcmp(info->type,"char")==0)
          {
              calledFunction->parameters[currentParameterIndex-1].info.charVal = info->charVal;
          }
          else if(strcmp(info->type,"float")==0)
          {
               calledFunction->parameters[currentParameterIndex-1].info.floatVal = info->floatVal;
          }
          else if(strcmp(info->type,"string")==0)
          {
               strcpy(calledFunction->parameters[currentParameterIndex-1].info.strVal, info->strVal);
          }
          else if(strcmp(info->type,"bool")==0)
          {
               strcpy(calledFunction->parameters[currentParameterIndex-1].info.boolVal, info->boolVal);
          }
     }    
}
void verifyIfSymbolNameIsAVariable(const char* name){
     char errorMsg[100];
     struct symbol* temp2=lookUpElement(name);
      if(temp2->typeOfObject == ARRAY || temp2 -> typeOfObject == FUNCTION || temp2 -> typeOfObject == _CLASS_) 
      {   sprintf(errorMsg, "[!]Id [%s] is not a variable", name);
          yyerror(errorMsg);
      }
}
void eval(struct information* expression){
if(strcmp(expression->type,_string) == 0)
{
     printf("The result of the expression you have written is: %s\n",expression->strVal);
}
else if(strcmp(expression->type,_int) == 0)
{
     printf("The result of the expression you have written is: %d\n",expression->intVal);
}
else if(strcmp(expression->type,_float) == 0)
{
     printf("The result of the expression you have written is: %f\n",expression->floatVal);
}
else if(strcmp(expression->type,_char) == 0)
{
     printf("The result of the expression you have written is: %c\n",expression->charVal);
}
else if(strcmp(expression->type,_bool) == 0)
{
     printf("The result of the expression you have written is: %s\n",expression->boolVal);
}
}
void verifyArgument(struct information* argument, int typeOfArgument, char* name){

     char errorMsg[100];
     if(calledFunction->numberOfParameters <= currentParameterIndex)
     {
          sprintf(errorMsg, "[!]Too many arguments for function [%s]", calledFunction->name);
          yyerror(errorMsg);
     }
     if(name != NULL)
     {    //printStackValues();
           if(wasDefinedInCurrentScope(name) == 0 && wasDefinedInGlobalScope(name) == 0) // daca e functie sau var trb sa si verific sa fi fost definite ca puteam sa fac int x = functie(ceva), chiar daca ceva nu era definit before
 
          {    
               if(typeOfArgument == VARIABLE)    
               {
               sprintf(errorMsg, "[!]Variable [%s] was not defined before", name);
               yyerror(errorMsg);
               }
               else if(typeOfArgument == FUNCTION)
               {
               sprintf(errorMsg, "[!]Function [%s] was not defined before", name);
               yyerror(errorMsg);
               }
               else if(typeOfArgument == ARRAY)
               {
               sprintf(errorMsg, "[!]Array [%s] was not defined before", name);
               yyerror(errorMsg);
               }
          }  
     }

     
     if(strcmp(calledFunction->parameters[currentParameterIndex].info.type, argument->type) != 0)
          {
               sprintf(errorMsg, "[!]Argument [%d] has type [%s], but should have type [%s]", currentParameterIndex, argument->type, calledFunction->parameters[currentParameterIndex].info.type);
               yyerror(errorMsg);
          }
     else{
          printf("Argument [%d] is ok\n", currentParameterIndex);
          if(strcmp(argument->type, "int") == 0)
              {
               calledFunction->parameters[currentParameterIndex].info.intVal = argument->intVal;
              }
     }
    
}

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
void calculate(struct information* finalExp, struct information* leftExp, struct information* rightExp, int typeOfOperation)
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
          
          initScopeStack();
     } else {
          scope = scope - 1;
     }
}
int returnTypeOfObject(const char* name){
     char error_message[50];
     struct symbol* temp = lookUpElement(name);
     if(temp==NULL)
     {
          sprintf(error_message, "[!] [%s] was not declared  -> ", name);
          yyerror(error_message);
     }
     int type = temp->typeOfObject;
    
     return type;
}
void updateVariable(const char* name, struct information* info) {
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

void updateVariableToInstance(const char* name, const char* objName, struct information* info) {
     struct symbol* temp = lookUpElement(objName);

     char error_message[100]; 
     if(temp == NULL){
          sprintf(error_message, "[!] Object [%s] does not exist! -> ", objName);
          yyerror(error_message);
     }
     
     // Iteram prin lista de atribute si cautam numele variabilei
     for (int i = 0; i < temp->numberOfObjValues; i++)
     {
          if (strcmp(temp->objValues[i].name, name) == 0)
          {
               if (temp->objValues[i].isConstant == 1) {
                    sprintf(error_message, "[!]Variable [%s] for [%s] is constant -> ", name, objName);
                    yyerror(error_message);
               }
               if (strcmp(temp->objValues[i].type, info->type) != 0)
               {
                    sprintf(error_message, "[!]Type mismatch for variable [%s] of [%s] -> ", name, objName);
                    yyerror(error_message);
               }

               temp->objValues[i].intVal = info->intVal;
               temp->objValues[i].floatValue = info->floatVal;
               temp->objValues[i].charValue = info->charVal;
               if (info->strVal != NULL)
               {    if(temp->objValues[i].stringValue == NULL)
                         temp->objValues[i].stringValue = (char*)malloc(256*sizeof(char));
                    strcpy(temp->objValues[i].stringValue, info->strVal);}
               if (info->boolVal != NULL) 
               {    if(temp->objValues[i].boolValue == NULL)
                         temp->objValues[i].boolValue = (char*)malloc(7*sizeof(char));
                    strcpy(temp->objValues[i].boolValue, info->boolVal);}
               return;
          }
     }

     sprintf(error_message, "[!]Variable [%s] for [%s] does not exist or is not accesible -> ", name, objName);
     yyerror(error_message);
     
}

void addClass(const char* name)
{
     // Cautam daca numele a fost folosi pe global deja 
     if (wasDefinedInGlobalScope(name) == 1) {
          char error_message[100];
          sprintf(error_message, "[!]Class %s already defined in global scope -> ", name);
          yyerror(error_message);
     }

     // Adaugam clasa in symbol table
     strcpy(symbolTable[symbolTableIndex].name, name);
     strcpy(symbolTable[symbolTableIndex].type, "class");
     symbolTable[symbolTableIndex].scope=scope;
     symbolTable[symbolTableIndex].typeOfObject=_CLASS_;
     symbolTableIndex++;
     pushGlobalStack(name);
}

void addInstanceToTable(const char* name, const char* className) {
     // 1. Find className in global stack
     char error_message[100];
     if (wasDefinedInGlobalScope(className) == 0) {
          sprintf(error_message, "[!]Class %s not defined -> ", className);
          yyerror(error_message);
     }

     // 2. Add instance to symbol table
     strcpy(symbolTable[symbolTableIndex].name, name);
     strcpy(symbolTable[symbolTableIndex].type, "instance");
     strcpy(symbolTable[symbolTableIndex].parrentClass, className);
     symbolTable[symbolTableIndex].scope=scope;
     symbolTable[symbolTableIndex].typeOfObject=OBJECT;
     symbolTable[symbolTableIndex].numberOfObjValues=0;
     

     // 2. Daca exista, continuam prin a adauga in .values, variabilele din clasa
     for (int i = 0; i < symbolTableIndex; i++) {

          // Daca gasim un symbol care are parrentClass = className il adaugma in obbjvals
          if (strcmp(symbolTable[i].parrentClass, className) == 0) {
               
               if (symbolTable[i].accessModifier != PUBLIC) continue;

               // Copiem struct symbol in struct objValues
               strcpy(symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].name, symbolTable[i].name);
               strcpy(symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].type, symbolTable[i].type);
               symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].isConstant = symbolTable[i].isConstant;
               symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].charValue = symbolTable[i].charValue;
               symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].intVal = symbolTable[i].intVal;
               symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].floatValue = symbolTable[i].floatValue;

               if (symbolTable[i].stringValue != NULL) {
                    symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].stringValue = (char*)malloc(256*sizeof(char));
                    strcpy(symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].stringValue, symbolTable[i].stringValue);
               }

               if (symbolTable[i].boolValue != NULL) {
                    symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].boolValue = (char*)malloc(7*sizeof(char));
                    strcpy(symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].boolValue, symbolTable[i].boolValue);
               }

               symbolTable[symbolTableIndex].numberOfParameters = symbolTable[i].numberOfParameters;
               for (int j = 0; j < symbolTable[i].numberOfParameters; j++) {
                    strcpy(symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].parameters[j].name, symbolTable[i].parameters[j].name);
                    strcpy(symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].parameters[j].type, symbolTable[i].parameters[j].type);
                    symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].parameters[j].isConstant = symbolTable[i].parameters[j].isConstant;
                    symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].parameters[j].charValue = symbolTable[i].parameters[j].charValue;
                    symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].parameters[j].intVal = symbolTable[i].parameters[j].intVal;
                    symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].parameters[j].floatValue = symbolTable[i].parameters[j].floatValue;

                    if (symbolTable[i].parameters[j].stringValue != NULL) {
                         symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].parameters[j].stringValue = (char*)malloc(256*sizeof(char));
                         strcpy(symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].parameters[j].stringValue, symbolTable[i].parameters[j].stringValue);
                    }

                    if (symbolTable[i].parameters[j].boolValue != NULL) {
                         symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].parameters[j].boolValue = (char*)malloc(7*sizeof(char));
                         strcpy(symbolTable[symbolTableIndex].objValues[symbolTable[symbolTableIndex].numberOfObjValues].parameters[j].boolValue, symbolTable[i].parameters[j].boolValue);
                    }
               }

               


               /*
                    struct objval {
     char name[50];      // 
     char type[30];      // 
     int isConstant;     //

     char charValue;
     int intVal;
     char** boolValue;
     float floatValue;
     char *stringValue;
     int *integerVector;
     char *characterVector;
	char **stringVector;
     int vectorSize;
     
     struct parameter parameters[MAXPARAMETERS];
     int numberOfParameters;
};



struct symbol{
     char name[50]; // 
     char type[30];     //
     int scope;    // 
     int isConstant; //
     int typeOfObject; // 1 var, 2 functie, 3 clasa, 4 membru de clasa, 5 array
     char parrentClass[50];
     int accessModifier;
     char charValue;
     int intVal;
     char* boolValue;
     float floatValue;
     char *stringValue;
     
     int *integerVector;
     char *characterVector;
	char **stringVector;
     float *floatVector;
     char **booleanVector;
     int vectorSize;
     
     struct parameter parameters[MAXPARAMETERS];
     int numberOfParameters;

     struct objval objValues[MAXSYMBOLS];
     int numberOfObjValues;


}symbolTable[MAXSYMBOLS];
               */



               symbolTable[symbolTableIndex].numberOfObjValues++;
          }
     }

     // Incrementam indexul
     symbolTableIndex++;

     // Adaugam in scope
     if (scope == 0) {
          pushGlobalStack(name);
     } else {
          pushScopeStack(name);
     }
}