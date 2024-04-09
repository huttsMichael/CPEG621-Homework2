#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE_LENGTH 100
#define MAX_VAR_COUNT 50

// Function to check if a variable is already in the list
int inVarList(char varList[][10], int varCount, char *var) {
    for (int i = 0; i < varCount; i++) {
        if (strcmp(varList[i], var) == 0) {
            return 1;
        }
    }
    return 0;
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

    while (fgets(line, MAX_LINE_LENGTH, infile) != NULL) {
        char op1[10], op[3], op2[10], result[10];
        if (sscanf(line, "%[^ ] = %[^;];", result, op1) == 2) {
            // Simple assignment or unary operation
            if (!inVarList(varList, varCount, result)) {
                printf("    int %s;\n", result);
                strcpy(varList[varCount++], result);
            }
            printf("    S%d: %s = %s;\n", labelCounter++, result, op1);
        } else if (sscanf(line, "%[^ ] = %[^+]+%[^;];", result, op1, op2) == 3 ||
                   sscanf(line, "%[^ ] = %[^-]-%[^;];", result, op1, op2) == 3) {
            // Binary operation
            if (!inVarList(varList, varCount, result)) {
                printf("    int %s;\n", result);
                strcpy(varList[varCount++], result);
            }
            printf("    S%d: %s = %s %s %s;\n", labelCounter++, result, op1, op[0] == '+' ? "+" : "-", op2);
        } else if (strncmp(line, "if", 2) == 0) {
            // Conditional statement
            char condition[10];
            sscanf(line, "if (%[^)]) {", condition);
            printf("    S%d: if (%s) {\n", labelCounter++, condition);
        } else if (strncmp(line, "}", 1) == 0) {
            printf("    }\n");
        } else if (strncmp(line, "else", 4) == 0) {
            printf("    else {\n");
        }
    }

    printf("\n");
    for (int i = 0; i < varCount; i++) {
        printf("    printf(\"%%d\\n\", %s);\n", varList[i]);
    }
    printf("    return 0;\n");
    printf("}\n");

    fclose(infile);
    return 0;
}
