import re

# Define latency dictionary
latency = {
    '+': 1,
    '-': 1,
    '=': 2,
    '?': 2,
    '*': 4,
    '/': 4,
    '**': 8,
    'if': 2  # Latency for if-else blocks
}

# Data structure to track dependencies
dependencies = {}

# Function to parse three-address code instructions
def parse_instruction(instruction):
    match = re.match(r'^(\w+)\s*=\s*(\w+)\s*([\+\-\*/\*\*]?)\s*(\w+)?;?$', instruction)
    if match:
        target = match.group(1)
        operator = match.group(3)
        operands = [match.group(2)]
        if match.group(4):
            operands.append(match.group(4))
        return target, operator, operands
    elif re.match(r'^if\s*\((\w+)\)\s*{', instruction):
        return None, 'if', [re.match(r'^if\s*\((\w+)\)\s*{', instruction).group(1)]
    elif re.match(r'^}', instruction):
        return None, 'end_if', []
    else:
        return None, None, None

# Function to calculate total runtime
def calculate_runtime(instructions):
    cycle = 1
    for instruction in instructions:
        target, operator, operands = instruction
        max_dependency_cycle = cycle
        for operand in operands:
            if operand in dependencies:
                max_dependency_cycle = max(max_dependency_cycle, dependencies[operand])
        cycle = max_dependency_cycle + latency.get(operator, 0)  # Calculate cycle for the current operation
        if target:
            dependencies[target] = cycle  # Update dependency for target variable
        else:
            # If it's an if-else block, consider it as a single operation
            cycle += latency.get(operator, 0)
        print(f"Cycle {cycle}: Executing {instruction}")
        print(f"Current state of dependencies: {dependencies}")
    return cycle

# Main function
def main(file_path):
    instructions = []
    with open(file_path, 'r') as file:
        for line in file:
            instruction = parse_instruction(line.strip())
            if instruction:
                instructions.append(instruction)
    
    total_cycles = calculate_runtime(instructions)
    print(f"Total runtime: {total_cycles} cycles")

# Run the main function
main("../outfile_1.txt")
