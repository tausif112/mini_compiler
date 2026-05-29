# 🔧 Mini Compiler using Flex & Bison
<div align="center">
     
![Language](https://img.shields.io/badge/Language-C-blue)
![Flex](https://img.shields.io/badge/Flex-Lexical%20Analyzer-green)
![Bison](https://img.shields.io/badge/Bison-Parser-orange)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%2024.04-red)
![License](https://img.shields.io/badge/License-MIT-yellow)

</div>
A lightweight **Mini Compiler** built using **Flex (Lex)**, **Bison (YACC)**, and **C**. The project demonstrates the fundamental phases of compiler construction, including lexical analysis, syntax analysis, parsing, symbol table generation, and intermediate instruction generation.

---

## 🚀 Features

* ✅ Lexical Analysis using Flex
* ✅ Syntax Analysis using Bison
* ✅ Token Recognition
* ✅ Parsing and Grammar Validation
* ✅ Symbol Table Generation
* ✅ Intermediate Instruction Generation
* ✅ Error Detection and Reporting
* ✅ Command-Line Based Compiler Workflow

---

## 🏗 Compiler Architecture

```text
Source Code
     │
     ▼
Lexical Analyzer (Flex)
     │
     ▼
Token Stream
     │
     ▼
Parser (Bison)
     │
     ▼
Syntax Tree / Validation
     │
     ▼
Symbol Table Generation
     │
     ▼
Intermediate Instructions
```

---

## 🛠 Technologies Used

| Technology        | Purpose                   |
| ----------------- | ------------------------- |
| C                 | Core Implementation       |
| Flex (Lex)        | Lexical Analysis          |
| Bison (YACC)      | Syntax Analysis & Parsing |
| GCC               | Compilation               |
| Ubuntu 24.04      | Development Environment   |
| Oracle VirtualBox | Virtualized Environment   |
| Git & GitHub      | Version Control           |

---

## 📂 Project Structure

```text
mini_compiler/
│
├── lexer.l
├── parser.y
├── input.txt
├── input2.txt
├── compiler
├── README.md
├── LICENSE
└── .gitignore
```

---

## ⚙️ Installation

### Install Required Packages

```bash
sudo apt update
sudo apt install flex bison gcc make git -y
```

---

## 🔨 Build Instructions

Generate lexer and parser files:

```bash
flex lexer.l
bison -d parser.y
```

Compile the compiler:

```bash
gcc lex.yy.c parser.tab.c -o compiler -lfl
```

---

## ▶️ Running the Compiler

### Test Input 1

```bash
./compiler < input.txt
```

### Test Input 2

```bash
./compiler < input2.txt
```

---

## 🧪 Sample Source Code

```c
int a;

a = 10;

if (a > 5) {

    int b;
    b = a + 2;

    while (b > 0) {

        int c;
        c = b - 1;

        b = b - 1;
    }
}
```

---

## 📚 Supported Language Elements

| Category               | Supported Elements   |
| ---------------------- | -------------------- |
| Data Types             | int, float           |
| Conditional Statements | if, else             |
| Loops                  | while                |
| Arithmetic Operators   | +, -, *, /           |
| Relational Operators   | ==, !=, <, >, <=, >= |
| Delimiters             | ;                    |
| Brackets               | (), {}               |
| Variable Declarations  | Supported            |
| Assignments            | Supported            |

---

## 📈 Learning Outcomes

Through this project, the following compiler design concepts were explored:

* Compiler Construction Fundamentals
* Lexical Analysis
* Syntax Analysis
* Parsing Techniques
* Context-Free Grammars
* Symbol Table Management
* Intermediate Code Representation
* Flex & Bison Integration
* Linux-Based Development Workflow

---

## 🎓 Academic Relevance

This project was developed as part of Compiler Design coursework and serves as a practical demonstration of how programming language source code is analyzed and processed during compilation.

---

## 🔮 Future Improvements

* Semantic Analysis
* Abstract Syntax Tree (AST) Generation
* Type Checking
* Optimization Passes
* Three-Address Code Generation
* Assembly Code Generation
* Enhanced Error Recovery

---

## 👨‍💻 Author

**Md. Tausif Uddin**  
Department of Computer Science & Engineering  
University of Asia Pacific

GitHub: **@tausif112**

---

## 📜 License

This project is licensed under the MIT License.



