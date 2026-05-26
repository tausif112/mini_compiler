# Mini Compiler using Flex and Bison

A simple mini compiler developed using **Flex**, **Bison**, and **C** in **Ubuntu 24.04 on Oracle VirtualBox**.  
This project demonstrates core compiler phases such as lexical analysis, syntax analysis, parsing, symbol handling, and error detection.

## Features

Lexical analysis using Flex
Syntax analysis using Bison/YACC
Supports int and float declarations
Supports assignment statements
Supports arithmetic operations: +, -, *, /
Supports relational operators: ==, !=, <, >, <=, >=
Supports if, else, and while
Tracks line numbers
Displays lexical/token information
Detects syntax and unknown-token errors

## Technologies Used

C Programming Language
Flex
Bison/YACC
GCC
Ubuntu 24.04
Oracle VirtualBox

## Project Structure

```text
Mini_Compiler_Updated/
├── lexer.l
├── parser.y
├── input.txt
├── input2.txt
├── README.md
├── LICENSE
├── .gitignore
