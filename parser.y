%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

int line = 1;
int syntax_error = 0;
int semantic_error = 0;

/* ===== LEXICAL STORAGE ===== */
char lex_output[500][100];
int lex_i = 0;

void add_lex(char *s) {
    sprintf(lex_output[lex_i++], "[Line %d] %s", line, s);
}

/* ===== PARSE TREE ===== */
typedef struct Node {
    char label[50];
    struct Node *left;
    struct Node *mid;
    struct Node *right;
} Node;

Node *root = NULL;

Node* makeNode(char *label, Node *left, Node *mid, Node *right) {
    Node *n = (Node*)malloc(sizeof(Node));
    strcpy(n->label, label);
    n->left = left;
    n->mid = mid;
    n->right = right;
    return n;
}

void printTree(Node *root, int level) {
    if(root == NULL) return;

    for(int i = 0; i < level; i++) printf("   ");
    printf("|-- %s\n", root->label);

    printTree(root->left, level + 1);
    printTree(root->mid, level + 1);
    printTree(root->right, level + 1);
}

/* ===== EXPRESSION INFO ===== */
typedef struct Expr {
    char place[30];
    char type[10];
    double value;
    Node *node;
} Expr;

Expr* makeExpr(char *place, char *type, double value, Node *node) {
    Expr *e = (Expr*)malloc(sizeof(Expr));
    strcpy(e->place, place);
    strcpy(e->type, type);
    e->value = value;
    e->node = node;
    return e;
}

/* ===== SYMBOL TABLE ===== */
typedef struct {
    char name[20];
    char type[10];
    double value;
    int line;
    int scope;
    int memory;
} Symbol;

Symbol table[100];
int count = 0;
int mem = 1000;
int currentScope = 0;

void enterScope() {
    currentScope++;
}

void exitScope() {
    currentScope--;
}

int lookup(char *name) {
    for(int i = count - 1; i >= 0; i--) {
        if(strcmp(table[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

void insert(char *name, char *type, int line_no) {
    for(int i = 0; i < count; i++) {
        if(strcmp(table[i].name, name) == 0 && table[i].scope == currentScope) {
            printf("Semantic Error: %s already declared at line %d\n", name, line_no);
            semantic_error = 1;
            return;
        }
    }

    strcpy(table[count].name, name);
    strcpy(table[count].type, type);
    table[count].value = 0;
    table[count].line = line_no;
    table[count].scope = currentScope;
    table[count].memory = mem;

    mem += 4;
    count++;
}

/* ===== TAC AND ASSEMBLY ===== */
char tac[300][100];
char asmcode[300][100];
int tac_i = 0;
int asm_i = 0;
int temp_i = 0;
int label_i = 0;

char* newTemp() {
    char *t = malloc(10);
    sprintf(t, "t%d", temp_i++);
    return t;
}

char* newLabel() {
    char *l = malloc(10);
    sprintf(l, "L%d", label_i++);
    return l;
}

void addTAC(char *s) {
    strcpy(tac[tac_i++], s);
}

void addASM(char *s) {
    strcpy(asmcode[asm_i++], s);
}

void generateArithmeticASM(char *op, char *left, char *right, char *result) {
    char buf[100];

    sprintf(buf, "LOAD %s", left);
    addASM(buf);

    sprintf(buf, "%s %s", op, right);
    addASM(buf);

    sprintf(buf, "STORE %s", result);
    addASM(buf);
}

%}

%union {
    int inum;
    double fnum;
    char *id;
    struct Expr *expr;
    struct Node *node;
}

%token INT FLOAT IF ELSE WHILE
%token <inum> INT_NUM
%token <fnum> FLOAT_NUM
%token <id> ID
%token EQ NE LE GE LT GT

%left '+' '-'
%left '*' '/'
%nonassoc EQ NE LT GT LE GE
%nonassoc IFX
%nonassoc ELSE
%type <id> type relop
%type <expr> expr condition
%type <node> program stmt_list stmt block declaration assignment if_stmt while_stmt

%%

program:
    stmt_list {
        root = makeNode("PROGRAM", $1, NULL, NULL);
    }
;

stmt_list:
    stmt_list stmt {
        $$ = makeNode("STMT_LIST", $1, $2, NULL);
    }
    |
    stmt {
        $$ = makeNode("STMT_LIST", $1, NULL, NULL);
    }
;

stmt:
    declaration { $$ = $1; }
    |
    assignment { $$ = $1; }
    |
    if_stmt { $$ = $1; }
    |
    while_stmt { $$ = $1; }
    |
    block { $$ = $1; }
;

block:
    '{' {
        enterScope();
    }
    stmt_list '}' {
        $$ = makeNode("BLOCK", $3, NULL, NULL);
        exitScope();
    }
;

declaration:
    type ID ';' {
        insert($2, $1, line);

        char label[50];
        sprintf(label, "DECLARE %s %s", $1, $2);

        $$ = makeNode(label, NULL, NULL, NULL);
    }
;

type:
    INT {
        $$ = "int";
    }
    |
    FLOAT {
        $$ = "float";
    }
;

assignment:
    ID '=' expr ';' {
        int idx = lookup($1);

        if(idx == -1) {
            printf("Semantic Error: %s not declared at line %d\n", $1, line);
            semantic_error = 1;
        } else {
            table[idx].value = $3->value;
        }

        char buf[100];

        sprintf(buf, "%s = %s", $1, $3->place);
        addTAC(buf);

        sprintf(buf, "LOAD %s", $3->place);
        addASM(buf);

        sprintf(buf, "STORE %s", $1);
        addASM(buf);

        char label[50];
        sprintf(label, "ASSIGN %s", $1);

        $$ = makeNode(label, $3->node, NULL, NULL);
    }
;

if_stmt:
    IF '(' condition ')' stmt %prec IFX {

        char *Lend = newLabel();
        char buf[100];

        sprintf(buf, "IF_FALSE %s GOTO %s", $3->place, Lend);
        addTAC(buf);

        sprintf(buf, "JZ %s", Lend);
        addASM(buf);

        sprintf(buf, "%s:", Lend);
        addTAC(buf);
        addASM(buf);
        $$ = makeNode("IF", $3->node, $5, NULL);
    }
    |
    IF '(' condition ')' stmt ELSE stmt {
        char *Lelse = newLabel();
        char *Lend = newLabel();
        char buf[100];

        sprintf(buf, "IF_FALSE %s GOTO %s", $3->place, Lelse);
        addTAC(buf);

        sprintf(buf, "JZ %s", Lelse);
        addASM(buf);

        sprintf(buf, "GOTO %s", Lend);
        addTAC(buf);

        sprintf(buf, "JMP %s", Lend);
        addASM(buf);

        sprintf(buf, "%s:", Lelse);
        addTAC(buf);
        addASM(buf);

        sprintf(buf, "%s:", Lend);
        addTAC(buf);
        addASM(buf);

        $$ = makeNode("IF_ELSE", $3->node, $5, $7);
    }
;

while_stmt:
    WHILE '(' condition ')' stmt {
        char *Lstart = newLabel();
        char *Lend = newLabel();
        char buf[100];

        sprintf(buf, "%s:", Lstart);
        addTAC(buf);
        addASM(buf);

        sprintf(buf, "IF_FALSE %s GOTO %s", $3->place, Lend);
        addTAC(buf);

        sprintf(buf, "JZ %s", Lend);
        addASM(buf);

        sprintf(buf, "GOTO %s", Lstart);
        addTAC(buf);

        sprintf(buf, "JMP %s", Lstart);
        addASM(buf);

        sprintf(buf, "%s:", Lend);
        addTAC(buf);
        addASM(buf);

        $$ = makeNode("WHILE", $3->node, $5, NULL);
    }
;

condition:
    expr relop expr {
        char *t = newTemp();
        char buf[100];

        sprintf(buf, "%s = %s %s %s", t, $1->place, $2, $3->place);
        addTAC(buf);

        sprintf(buf, "LOAD %s", $1->place);
        addASM(buf);

        sprintf(buf, "CMP %s", $3->place);
        addASM(buf);

        sprintf(buf, "STORE %s", t);
        addASM(buf);

        char label[50];
        sprintf(label, "COND %s", $2);

        $$ = makeExpr(t, "bool", 0, makeNode(label, $1->node, $3->node, NULL));
    }
;

relop:
    EQ { $$ = "=="; }
    |
    NE { $$ = "!="; }
    |
    LT { $$ = "<"; }
    |
    GT { $$ = ">"; }
    |
    LE { $$ = "<="; }
    |
    GE { $$ = ">="; }
;

expr:
    expr '+' expr {
        char *t = newTemp();
        char type[10];
        double val = $1->value + $3->value;

        if(strcmp($1->type, "float") == 0 || strcmp($3->type, "float") == 0)
            strcpy(type, "float");
        else
            strcpy(type, "int");

        char buf[100];
        sprintf(buf, "%s = %s + %s", t, $1->place, $3->place);
        addTAC(buf);

        generateArithmeticASM("ADD", $1->place, $3->place, t);

        $$ = makeExpr(t, type, val, makeNode("+", $1->node, $3->node, NULL));
    }
    |
    expr '-' expr {
        char *t = newTemp();
        char type[10];
        double val = $1->value - $3->value;

        if(strcmp($1->type, "float") == 0 || strcmp($3->type, "float") == 0)
            strcpy(type, "float");
        else
            strcpy(type, "int");

        char buf[100];
        sprintf(buf, "%s = %s - %s", t, $1->place, $3->place);
        addTAC(buf);

        generateArithmeticASM("SUB", $1->place, $3->place, t);

        $$ = makeExpr(t, type, val, makeNode("-", $1->node, $3->node, NULL));
    }
    |
    expr '*' expr {
        char *t = newTemp();
        char type[10];
        double val = $1->value * $3->value;

        if(strcmp($1->type, "float") == 0 || strcmp($3->type, "float") == 0)
            strcpy(type, "float");
        else
            strcpy(type, "int");

        char buf[100];
        sprintf(buf, "%s = %s * %s", t, $1->place, $3->place);
        addTAC(buf);

        generateArithmeticASM("MUL", $1->place, $3->place, t);

        $$ = makeExpr(t, type, val, makeNode("*", $1->node, $3->node, NULL));
    }
    |
    expr '/' expr {
        char *t = newTemp();
        char type[10];
        double val = 0;

        if($3->value == 0) {
            printf("Semantic Error: Division by zero at line %d\n", line);
            semantic_error = 1;
        } else {
            val = $1->value / $3->value;
        }

        strcpy(type, "float");

        char buf[100];
        sprintf(buf, "%s = %s / %s", t, $1->place, $3->place);
        addTAC(buf);

        generateArithmeticASM("DIV", $1->place, $3->place, t);

        $$ = makeExpr(t, type, val, makeNode("/", $1->node, $3->node, NULL));
    }
    |
    '(' expr ')' {
        $$ = $2;
    }
    |
    INT_NUM {
        char p[30];
        sprintf(p, "%d", $1);

        char label[50];
        sprintf(label, "INT_NUM %d", $1);

        $$ = makeExpr(p, "int", $1, makeNode(label, NULL, NULL, NULL));
    }
    |
    FLOAT_NUM {
        char p[30];
        sprintf(p, "%.2f", $1);

        char label[50];
        sprintf(label, "FLOAT_NUM %.2f", $1);

        $$ = makeExpr(p, "float", $1, makeNode(label, NULL, NULL, NULL));
    }
    |
    ID {
        int idx = lookup($1);

        if(idx == -1) {
            printf("Semantic Error: %s not declared at line %d\n", $1, line);
            semantic_error = 1;
            $$ = makeExpr($1, "int", 0, makeNode($1, NULL, NULL, NULL));
        } else {
            $$ = makeExpr($1, table[idx].type, table[idx].value, makeNode($1, NULL, NULL, NULL));
        }
    }
;

%%

void yyerror(const char *s) {
    syntax_error = 1;
    printf("SYNTAX ERROR at line %d\n", line);
}

int main() {
    printf("================ MINI COMPILER START ================\n");

    yyparse();

    printf("\n================ LEXICAL ANALYSIS ================\n");
    for(int i = 0; i < lex_i; i++) {
        printf("%s\n", lex_output[i]);
    }

    printf("\n================ SYNTAX ANALYSIS ================\n");
    if(syntax_error)
        printf("Syntax analysis failed\n");
    else
        printf("Syntax analysis completed successfully\n");

    printf("\n================ PARSE TREE ================\n");
    printTree(root, 0);

    printf("\n================ SEMANTIC ANALYSIS ================\n");
    if(semantic_error)
        printf("Semantic errors found\n");
    else
        printf("Semantic analysis completed successfully\n");

    printf("\n================ INTERMEDIATE CODE TAC ================\n");
    for(int i = 0; i < tac_i; i++) {
        printf("%s\n", tac[i]);
    }

    printf("\n================ TARGET CODE ASSEMBLY ================\n");
    for(int i = 0; i < asm_i; i++) {
        printf("%s\n", asmcode[i]);
    }

    printf("\n================ SYMBOL TABLE ================\n");
    printf("---------------------------------------------------------------------\n");
    printf("| Name | Type  | Value    | Scope | Line | Memory |\n");
    printf("---------------------------------------------------------------------\n");

    for(int i = 0; i < count; i++) {
        printf("| %-4s | %-5s | %-8.2f | %-5d | %-4d | %-6d |\n",
            table[i].name,
            table[i].type,
            table[i].value,
            table[i].scope,
            table[i].line,
            table[i].memory);
    }

    printf("---------------------------------------------------------------------\n");

    printf("\n================ COMPILATION SUMMARY ================\n");

    if(syntax_error || semantic_error)
        printf("STATUS: COMPILATION FAILED\n");
    else
        printf("STATUS: COMPILATION SUCCESSFUL\n");

    return 0;
}
