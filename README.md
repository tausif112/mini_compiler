# 🔧 Mini Compiler using Flex & Bison

A compiler design lab project developed using **Flex**, **Bison/YACC**, and **C programming** on **Ubuntu 24.04 (Oracle VirtualBox)**.

This project demonstrates:
Lexical Analysis
Syntax Analysis
Parsing
Symbol Table Generation
Intermediate Instructions
Compilation Workflow

---

# 🛠 Technologies Used

C Programming
Flex (Lex)
Bison (YACC)
GCC Compiler
Ubuntu 24.04
Oracle VirtualBox

---

# 📁 Project Structure

text
Mini_Compiler_Updated/
├── lexer.l
├── parser.y
├── input.txt
├── input2.txt
├── README.md
└── compiler



---

# ⚙️ Installation


bash
sudo apt update
sudo apt install flex bison gcc make git -y



---

# ▶️ Build Instructions


bash
flex lexer.l
bison -d parser.y
gcc lex.yy.c parser.tab.c -o compiler -lfl



---

# ▶️ Run Instructions

Run first input:


bash
./compiler < input.txt



Run second input:


bash
./compiler < input2.txt



---

# 🧪 Sample Input


c
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



---

# 📚 Supported Language Elements

| Type | Supported |
|---|---|
| Data Types | int, float |
| Control Statements | if, else, while |
| Operators | +, -, *, / |
| Relational Operators | ==, !=, <, >, <=, >= |
| Brackets | (), {} |
| Statement Ending | ; |

---

# 📸 Screenshots

Add compiler screenshots here later.

Example:


markdown
![Compiler Output](screenshots/compiler_output.png)



---

# 🎯 Learning Outcomes

This project helped in understanding:
Compiler phases
Lexical analysis
Parsing techniques
Symbol tables
Flex and Bison integration
Basic compiler workflow

---

# 👨‍💻 Author

**Md. Tausif Uddin**  
Department of CSE  
University of Asia Pacific

---

# 📜 License

MIT License
