%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line;
extern void add_lex(char*);
%}

%%

"int"       { add_lex("int -> TOKEN(INT)"); return INT; }
"float"     { add_lex("float -> TOKEN(FLOAT)"); return FLOAT; }
"if"        { add_lex("if -> TOKEN(IF)"); return IF; }
"else"      { add_lex("else -> TOKEN(ELSE)"); return ELSE; }
"while"     { add_lex("while -> TOKEN(WHILE)"); return WHILE; }

[0-9]+"."[0-9]+ {
    char buf[100];
    sprintf(buf,"%s -> TOKEN(FLOAT_NUM)",yytext);
    add_lex(buf);
    yylval.fnum = atof(yytext);
    return FLOAT_NUM;
}

[0-9]+ {
    char buf[100];
    sprintf(buf,"%s -> TOKEN(INT_NUM)",yytext);
    add_lex(buf);
    yylval.inum = atoi(yytext);
    return INT_NUM;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    char buf[100];
    sprintf(buf,"%s -> TOKEN(ID)",yytext);
    add_lex(buf);
    yylval.id = strdup(yytext);
    return ID;
}

"=="        { add_lex("== -> TOKEN(EQ)"); return EQ; }
"!="        { add_lex("!= -> TOKEN(NE)"); return NE; }
"<="        { add_lex("<= -> TOKEN(LE)"); return LE; }
">="        { add_lex(">= -> TOKEN(GE)"); return GE; }
"<"         { add_lex("< -> TOKEN(LT)"); return LT; }
">"         { add_lex("> -> TOKEN(GT)"); return GT; }

"="         { add_lex("= -> TOKEN(ASSIGN)"); return '='; }
"+"         { add_lex("+ -> TOKEN(PLUS)"); return '+'; }
"-"         { add_lex("- -> TOKEN(MINUS)"); return '-'; }
""         { add_lex(" -> TOKEN(MUL)"); return '*'; }
"/"         { add_lex("/ -> TOKEN(DIV)"); return '/'; }

"("         { add_lex("( -> TOKEN(LPAREN)"); return '('; }
")"         { add_lex(") -> TOKEN(RPAREN)"); return ')'; }
"{"         { add_lex("{ -> TOKEN(LBRACE)"); return '{'; }
"}"         { add_lex("} -> TOKEN(RBRACE)"); return '}'; }
";"         { add_lex("; -> TOKEN(SEMI)"); return ';'; }

\n          { line++; }
[ \t\r]+    ;

.           { add_lex("UNKNOWN TOKEN"); }

%%

int yywrap() {
    return 1;
}
