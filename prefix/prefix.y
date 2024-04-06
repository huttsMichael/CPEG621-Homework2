%{
#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <string.h>

#define STACK_SIZE 80
#define LINE_SIZE 80
int lineNum = 1;
void yyerror(char *ps, ...) { /* need this to avoid link problem */
	printf("%s\n", ps);
}

int sym[26]; // enough space to store all variables
int first_op = 1;
char stack[LINE_SIZE][STACK_SIZE];
int stack_index = 0;
int jumped = 0;
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
		for (int i = stack_index-1; i >= 0; i--) {
			printf("%s ", stack[i]);
			memset(stack[i], '\0', STACK_SIZE);
		}
		stack_index = 0;
		first_op = 1;
		jumped = 0;
		printf("\n");
	}
	| cal exp '\n' { 
		for (int i = stack_index-1; i >= 0; i--) {
			printf("%s ", stack[i]);
			memset(stack[i], '\0', STACK_SIZE);
		}
		stack_index = 0;
		first_op = 1;
		jumped = 0;
		printf("\n");
	}	
    ;


exp:
	NUMBER
	| VAR { $$ = sym[$1]; }
	| VAR '=' exp {
		sprintf(stack[stack_index++], "= %c %d", $1 + 'a', $3);
	}
	| exp '+' exp { 
		if (first_op) {
			sprintf(stack[stack_index++], "+ %d %d", $1, $3);
		}
		else {
			if (jumped) {
				sprintf(stack[stack_index++], "+ %d", $1);
				jumped = 0;
			}
			else {
				sprintf(stack[stack_index++], "+ %d", $3);
			}
		}
		first_op = 0;
	}
	| exp '-' exp { 
		if (first_op) {
			sprintf(stack[stack_index++], "- %d %d", $1, $3);
		}
		else {
			if (jumped) {
				sprintf(stack[stack_index++], "- %d", $1);
				jumped = 0;
			}
			else {
				sprintf(stack[stack_index++], "- %d", $3);
			}
		}
		first_op = 0;
	}
	| exp '*' exp { 
		if (first_op) {
			sprintf(stack[stack_index++], "* %d %d", $1, $3);
			jumped = 1;
		}
		else {
			sprintf(stack[stack_index++], "* %d", $3);
		}
		first_op = 0;
	}
	| exp '/' exp { 
		if (first_op) {
			sprintf(stack[stack_index++], "/ %d %d", $1, $3);
			jumped = 1;
		}
		else {
			sprintf(stack[stack_index++], "/ %d", $3);
		}
		first_op = 0;
	}
	| exp POW exp { 
		if (first_op) {
			sprintf(stack[stack_index++], "** %d %d", $1, $3);
			jumped = 1;
		}
		else {
			sprintf(stack[stack_index++], "** %d", $3);
		}
		first_op = 0;
	}
	| exp INC { 
		if (first_op) {
			sprintf(stack[stack_index++], "++ %d", $1);
			jumped = 1;
		}
		else {
			sprintf(stack[stack_index++], "++ ");
		}
		first_op = 0;
	}
	| exp DEC { 
		if (first_op) {
			sprintf(stack[stack_index++], "-- %d", $1);
			jumped = 1;
		}
		else {
			sprintf(stack[stack_index++], "-- ");
		}
		first_op = 0;
	}
	| '(' exp ')' { $$ = $2; }
	;

%%
int main() {
    yyparse();
    return 0;
}
