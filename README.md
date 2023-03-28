
# Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [How to use](#how-to-use)




# Introduction

This project was our final project for "Formal Languages, Automata and Compilers". We had to design and implement a new programming language using YACC and Lex. The language includes features such as type declarations, predefined types (int, float, char, string, bool), array types, and user-defined data types, similar to classes in object-oriented languages. The language also supports variable declarations, constant definitions, function definitions, control statements (if, for, while), assignment statements, arithmetic and boolean expressions, and function calls with parameters.


# Features

### Type Declarations
The language supports type declarations, including predefined types (int, float, char, string, bool), array types, and user-defined data types. The syntax for user-defined data types allows for the initialization and use of variables, as well as accessing fields and methods.


### Symbol Table
For every input source file, the language generates a symbol table that includes information regarding variable or constant identifiers (type, value) and information regarding function identifiers (returned type, type and name of each formal parameter). The symbol table is printable in two files: symbol_table.txt and symbol_table_functions.txt (for functions).

### Semantic Analysis
The language is able to do some semantic analysis and checks that variables and functions are defined and not declared more than once (in their current scope). The language also checks that all operands in the right side of an expression have the same type, and the left side of an assignment has the same type as the right side. Additionally, the language checks that the parameters of a function call have the types from the function definition. Detailed error messages are provided if these conditions do not hold. We are able to declare variables inside functions, even though they were declared in the global / parent scope just as in most programming languages.

### Eval and TypeOf
The language includes a predefined function Eval(arg) and a predefined function TypeOf(arg). TypeOf(x + f(y)) causes a semantic error if TypeOf(x) != TypeOf(f(y)).Additionally, for every assignment instruction left_value = expr (left_value is an identifier or element of an array with int type) the value of the expr will be assigned to the left_value.


# How to use

To clone and run this application, you'll need [Git](https://git-scm.com), Yacc and Lex.

```bash
# Clone this repository
$ git clone git@github.com:Claudiu2222/YaccCompiler.git

# Install Yacc
$ sudo apt-get install bison

# Install Flex
$ sudo apt-get install flex

# Go into the repository
$ cd YaccCompiler

# Change the input inside input.txt then run
$ make run
```

