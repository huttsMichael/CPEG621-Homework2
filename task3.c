#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_LINE_LENGTH 128
#define MAX_VAR_COUNT 64

// Function to check if a string is a valid variable name
int isValidVarName(char *str) {
    if (str == NULL || *str == '\0' || isdigit(str[0])) {
        return 0; // Invalid if empty or starts with a digit
    }
    // Ensure all characters are alphanumeric or underscores
    while (*str) {
        if (!isalnum(*str) && *str != '_') {
            return 0;
        }
        str++;
    }
    return 1; // Valid variable name
}

// Function to check if a variable is already in the list
int inVarList(char varList[][10], int varCount, char *var) {
    for (int i = 0; i < varCount; i++) {
        if (strcmp(varList[i], var) == 0) {
            return 1;
        }
    }
    return 0;
}

// Function to check if a string starts with a given prefix
int startsWith(const char *prefix, const char *str) {
    return strncmp(prefix, str, strlen(prefix)) == 0;
}

// Main function to process the three-address code and generate C code
int main() {
    FILE *infile = fopen("outfile_1.txt", "r");
    if (!infile) {
        printf("Error opening file\n");
        return 1;
    }

    char varList[MAX_VAR_COUNT][10];
    int varCount = 0;
    char line[MAX_LINE_LENGTH];
    int labelCounter = 1;

    printf("#include <stdio.h>\n\n");
    printf("int main() {\n");

    // Process each line to generate C code
    while (fgets(line, MAX_LINE_LENGTH, infile) != NULL) {
        char op1[10], op2[10], result[10];
        if (sscanf(line, "%[^ ] = %[^;];", result, op1) == 2 && isValidVarName(result) && !inVarList(varList, varCount, result)) {
            strcpy(varList[varCount++], result);
            printf("    int %s;\n", result);
        }
    }
    rewind(infile);

    // Generate C code for three-address code
    while (fgets(line, MAX_LINE_LENGTH, infile) != NULL) {
        char op1[10], op2[10], result[10];
        if (sscanf(line, "%[^ ] = %[^+]+%[^;];", result, op1, op2) == 3) {
            printf("    S%d: %s = %s + %s;\n", labelCounter++, result, op1, op2);
        } else if (sscanf(line, "%[^ ] = %[^-]-%[^;];", result, op1, op2) == 3) {
            printf("    S%d: %s = %s - %s;\n", labelCounter++, result, op1, op2);
        } else if (sscanf(line, "%[^ ] = %[^;];", result, op1) == 2) {
            printf("    S%d: %s = %s;\n", labelCounter++, result, op1);
        } else if (strstr(line, "if") == line) {
            // Print the 'if' line, adjusting for the 'if' keyword and the first '(' character
            printf("    S%d: if (", labelCounter++);
            // Find the first '(' character and start printing from the next character to avoid duplicating '('
            char *ptr = strchr(line, '(');
            if (ptr && *(++ptr)) {  // Increment ptr to move past the '('
                while (*ptr && *ptr != '{') {
                    if (*ptr == '%' || *ptr == '"') {
                        printf("\\"); // Escape special characters
                    }
                    printf("%c", *ptr++);
                }
            }
            printf(" {\n");
        } else if (strncmp(line, "else", 4) == 0) {
            printf("    else {\n");
        } else if (*line == '}') {
            printf("    }\n");
        }
    }


    // Print final variable values
    printf("\n");
    for (int i = 0; i < varCount; i++) {
        if (!startsWith("tmp_", varList[i])) {  // Skip temporary variables
            printf("    printf(\"%%s=%%d\\n\", \"%s\", %s);\n", varList[i], varList[i]);
        }
    }

    printf("    return 0;\n");
    printf("}\n");

    fclose(infile);
    return 0;
}
