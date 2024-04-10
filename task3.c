#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_LINE_LENGTH 128
#define MAX_VAR_COUNT 64

// function to check if a string is a valid variable name
int is_valid_var_name(char *str) {
    if (str == NULL || *str == '\0' || isdigit(str[0])) {
        return 0; // invalid if empty or starts with a digit
    }
    // ensure all characters are alphanumeric or underscores
    while (*str) {
        if (!isalnum(*str) && *str != '_') {
            return 0;
        }
        str++;
    }
    return 1; // valid variable name
}

// function to check if a variable is already in the list
int in_var_list(char varList[][10], int varCount, char *var) {
    for (int i = 0; i < varCount; i++) {
        if (strcmp(varList[i], var) == 0) {
            return 1;
        }
    }
    return 0;
}

// function to check if a string starts with a given prefix
int starts_with(const char *prefix, const char *str) {
    return strncmp(prefix, str, strlen(prefix)) == 0;
}

// main function to process the three-address code and generate c code
int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    FILE *infile = fopen(argv[1], "r");
    if (!infile) {
        fprintf(stderr, "Error opening file %s\n", argv[1]);
        return 1;
    }

    char varList[MAX_VAR_COUNT][10];
    int varCount = 0;
    char line[MAX_LINE_LENGTH];
    int labelCounter = 1;

    printf("#include <stdio.h>\n\n");
    printf("int main() {\n");

    // process each line to generate c code
    while (fgets(line, MAX_LINE_LENGTH, infile) != NULL) {
        char op1[10], op2[10], result[10];
        if (sscanf(line, "%[^ ] = %[^;];", result, op1) == 2 && is_valid_var_name(result) && !in_var_list(varList, varCount, result)) {
            strcpy(varList[varCount++], result);
            printf("    int %s;\n", result);
        }
    }
    rewind(infile);

    while (fgets(line, MAX_LINE_LENGTH, infile) != NULL) {
        char op1[10], op2[10], result[10];
        if (sscanf(line, "%[^ ] = %[^+]+%[^;];", result, op1, op2) == 3) {
            printf("    S%d: %s = %s + %s;\n", labelCounter++, result, op1, op2);
        }
        else if (sscanf(line, "%[^ ] = %[^-]-%[^;];", result, op1, op2) == 3) {
            printf("    S%d: %s = %s - %s;\n", labelCounter++, result, op1, op2);
        }
        else if (sscanf(line, "%[^ ] = %[^;];", result, op1) == 2) {
            printf("    S%d: %s = %s;\n", labelCounter++, result, op1);
        }
        else if (strstr(line, "if") == line) {
            // print the 'if' line, adjusting for the 'if' keyword and the first '(' character
            printf("    S%d: if (", labelCounter++);
            // find the first '(' character and start printing from the next character to avoid duplicating '('
            char *ptr = strchr(line, '(');
            if (ptr && *(++ptr)) {  // increment ptr to move past the '('
                while (*ptr && *ptr != '{') {
                    if (*ptr == '%' || *ptr == '"') {
                        printf("\\"); // escape special characters
                    }
                    printf("%c", *ptr++);
                }
            }
            printf(" {\n");
        }
    else if (strncmp(line, "else", 4) == 0) {
            printf("    else {\n");
        }
    else if (*line == '}') {
            printf("    }\n");
        }
    }

    // print final variable values
    printf("\n");
    for (int i = 0; i < varCount; i++) {
        if (!starts_with("tmp_", varList[i])) {  // skip temporary variables
            printf("    printf(\"%%s=%%d\\n\", \"%s\", %s);\n", varList[i], varList[i]);
        }
    }

    printf("    return 0;\n");
    printf("}\n");

    fclose(infile);
    return 0;
}
