%{
#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <string.h>

#define DEBUG /* for debuging: print tokens and their line numbers */
#define USR_VARS_MAX_CNT 32
#define USR_VARS_MAX_LEN 32

char* handle_op(char *left, char *operation, char *right);
void handle_var(char *var, char* exp);
void handle_if(char *cond_expression);
void handle_else(char *expression);


int lineNum = 1;
void yyerror(char *ps, ...) { /* need this to avoid link problem */
	printf("%s\n", ps);
}

int if_flag = 0; // flag to fix printing variables and using multiple in one operation

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
	| '(' exp ')' '?' { 
		handle_if($2); 
		} 
		
		'(' exp ')' {
		$$ = $7;
	}
	;

%%
char* handle_op(char *left, char *operation, char *right) {
	#ifdef DEBUG
    printf("handle_op()\n");
    #endif
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
	#ifdef DEBUG
    printf("handle_var()\n");
    #endif
	// search if variable already exists in list of variables
	// TODO

	fprintf(out_file, "%s = %s;\n", var, exp);

	strcpy(user_vars[user_vars_count++], var);

	if (if_flag) {
		handle_else(var);
	}

	return;

}

// a little confused on how this is described in lab instructions but did my best
void handle_if(char *cond_expression) {
	#ifdef DEBUG
    printf("handle_if()\n");
    #endif
	if_flag = 1;

	fprintf(out_file, "if (%s) {\n", cond_expression);

	return;
}

void handle_else(char *expression) {
	#ifdef DEBUG
    printf("handle_else()\n");
    #endif
	fprintf(out_file, "}\nelse {\n%s = 0;\n}\n", expression);

	return;
}

int main(int argc, char *argv[]) {
	#ifdef DEBUG
    printf("main()\n");
    #endif
	// take an input file
	yyin = fopen(argv[1], "r");
	out_file = fopen(argv[2], "w");
	
	if (!yyin) {
		return -1;
	}

	yyparse();


}
