%{
#include <stdlib.h> /* for atoi call */
#include "prefix.tab.h" 

// #define DEBUG /* for debuging: print tokens and their line numbers */

extern int lineNum; /* line number from cal.tab.c */

%}

%%
[ \t]+ {} // Ignore whitespace characters

[\n] { lineNum++; return '\n'; } // Increment line number and return newline token


"(" {
	#ifdef DEBUG
	printf("token '(' at line %d\n", lineNum); 
	#endif
	return '('; 
}

")" {
	#ifdef DEBUG
	printf("token ')' at line %d\n", lineNum); 
	#endif
	return ')'; 
}

"+" {
	#ifdef DEBUG
	printf("token '+' at line %d\n", lineNum); 
	#endif
	return '+'; 
}

"*" {
	#ifdef DEBUG
	printf("token '*' at line %d\n", lineNum); 
	#endif
	return '*'; 
}

"-" {
	#ifdef DEBUG
	printf("token '-' at line %d\n", lineNum); 
	#endif
	return '-'; 
}

"/" {
	#ifdef DEBUG
	printf("token '/' at line %d\n", lineNum); 
	#endif
	return '/'; 
}
 
"++" {
    #ifdef DEBUG
    printf("token '++' at line %d\n", lineNum);
    #endif
    return INC;
}

"--" {
    #ifdef DEBUG
    printf("token '--' at line %d\n", lineNum);
    #endif
    return DEC;
}

"**" {
    #ifdef DEBUG
    printf("token '**' at line %d\n", lineNum);
    #endif
    return POW;
}

"=" {
    #ifdef DEBUG
    printf("token '=' at line %d\n", lineNum);
    #endif
    return '=';
}

[a-z]+ {
	#ifdef DEBUG
	printf("token %s at line %d\n", yytext, lineNum); 
	#endif
	yylval.d = *yytext - 'a';
	return VAR;
}

[0-9]+ {
	#ifdef DEBUG
	printf("token %s at line %d\n", yytext, lineNum); 
	#endif
	yylval.d = atoi(yytext);
	return NUMBER;
}

%%
int yywrap() { /* need this to avoid link problem */
	return 1;
}
