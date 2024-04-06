%{
#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <string.h>

#define USR_VARS_MAX_CNT 32
#define USR_VARS_MAX_LEN 32

char* handle_op(char *left, char *operation, char *right);
void handle_var(char *var, char* exp);


int lineNum = 1;
void yyerror(char *ps, ...) { /* need this to avoid link problem */
	printf("%s\n", ps);
}

int equals_flag = 0; // flag to fix printing variables and using multiple in one operation

char user_vars[USR_VARS_MAX_CNT][USR_VARS_MAX_LEN]; // enough space to store all variables

int tmp_vars_count = 0;
int user_vars_count = 0;

FILE *yyin; // yacc input file
FILE *out_file; // three 
%}

%union {
int d; // Union type for semantic value
char *str;
}

// need to choose token type from union above
%token <str> NUMBER VAR // Define token type for numbers
%token '(' ')' // Define token types for '(' and ')'
%token INC DEC POW
%left '=' // Specify left associativity for addition and subtraction
%left '+' '-' // Specify left associativity for addition and subtraction
%left '*' '/' // Specify left associativity for multiplication and division
%right POW // Specify right associativity for exponents (had to google this property)
%right INC DEC // Specify right associativity for unary operators
%type <str> exp // Specify types of non-terminal symbols
%start cal // Specify starting symbol for parsing

%%
cal: 
	exp '\n' { 
		// printf("=%s\n", $1); 
	}
	| cal exp '\n' { 
		// printf("=%s\n", $1); 
	}	
    ;


exp:
	NUMBER
	| VAR { $$ = $1;  }
	| VAR '=' exp {
		handle_var($1, $3);
	}
	| exp '+' exp { $$ = handle_op($1, "+", $3); }
	| exp '-' exp { $$ = handle_op($1, "-", $3); }
	| exp '*' exp { $$ = handle_op($1, "*", $3); }
	| exp '/' exp { $$ = handle_op($1, "/", $3); }
	| exp POW exp { $$ = handle_op($1, "**", $3); }
	| exp INC { $$ = handle_op($1, "++", ""); }
	| exp DEC { $$ = handle_op($1, "--", ""); }
	| '(' exp ')' { $$ = $2; }
	| '(' exp ')' '?' '(' exp ')' {
		printf("%s %s", $2, $6);
	}
	;

%%
char* handle_op(char *left, char *operation, char *right) {
	char tmp_var[USR_VARS_MAX_LEN];

	sprintf(tmp_var, "tmp_%d", tmp_vars_count++);

	printf("tmp_var: %s\n", tmp_var);
	printf("left: %s\n", left);
	printf("operation: %s\n", operation);
	printf("right: %s\n", right);
	/* printf("left/operation/right: %s/%s/%s\n", left, operation, right); */

	fprintf(out_file, "%s = %s%s%s;\n", tmp_var, left, operation, right);

	return strdup(tmp_var);
}

void handle_var(char *var, char* exp) {
	// search if variable already exists in list of variables
	// TODO

	fprintf(out_file, "%s = %s;\n", var, exp);

	strcpy(user_vars[user_vars_count++], var);

	return;

}

int main(int argc, char *argv[]) {
	// take an input file
	yyin = fopen(argv[1], "r");
	out_file = fopen(argv[2], "w");
	
	if (!yyin) {
		return -1;
	}

	yyparse();


}
