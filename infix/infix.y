%{
#include <stdio.h>
#include <ctype.h>
#include <math.h>
int lineNum = 1;
void yyerror(char *ps, ...) { /* need this to avoid link problem */
	printf("%s\n", ps);
}

int sym[26]; // enough space to store all variables
int equals_flag = 0; // flag to fix printing variables and using multiple in one operation
%}

%union {
int d; // Union type for semantic value
}

// need to choose token type from union above
%token <d> NUMBER VAR // Define token type for numbers
%token '(' ')' // Define token types for '(' and ')'
%token INC DEC POW
%left '=' // Specify left associativity for addition and subtraction
%left '+' '-' // Specify left associativity for addition and subtraction
%left '*' '/' // Specify left associativity for multiplication and division
%right POW // Specify right associativity for exponents (had to google this property)
%right INC DEC // Specify right associativity for unary operators
%type <d> exp // Specify types of non-terminal symbols
%start cal // Specify starting symbol for parsing

%%
cal: 
	exp '\n' { 
		if (equals_flag) {
			printf("=%d\n", sym[$1]); 
			equals_flag=0; 
		}
		else {
			printf("=%d\n", $1); 
		}
	}
	| cal exp '\n' { 
		if (equals_flag) {
			printf("=%d\n", sym[$2]); 
			equals_flag=0; 
		}
		else {
			printf("=%d\n", $2); 
		}
	}	
    ;


exp:
	NUMBER
	| VAR { $$ = sym[$1]; }
	| VAR '=' exp {
		if (equals_flag) {
			sym[$1] = sym[$3]; 
		}
		else {
			sym[$1] = $3;
		}
		equals_flag=1; 
	}
	| exp '+' exp { $$ = $1 + $3; }
	| exp '-' exp { $$ = $1 - $3; }
	| exp '*' exp { $$ = $1 * $3; }
	| exp '/' exp { $$ = $1 / $3; }
	| exp POW exp { $$ = (int)(pow($1,$3)); }
	| exp INC { $$ = $1 + 1; }
	| exp DEC { $$ = $1 - 1; }
	| '(' exp ')' { $$ = $2; }
	;

%%
int main() {
    yyparse();
    return 0;
}
