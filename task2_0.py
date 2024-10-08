import re
from collections import defaultdict
from pprint import pprint

# Define regex patterns for parsing different types of instructions
patterns = {
    'operation': re.compile(r'(\w+)\s*=\s*(\w+)\s*([\+\-\*\/])\s*(\w+);'),
    'assignment': re.compile(r'(\w+)\s*=\s*(\w+);'),
    'conditional': re.compile(r'if\s*\((\w+)\)\s*\{'),
}

# Define latencies for different operations
latency = {'+': 1, '-': 1, '*': 4, '/': 4, '**': 8, '=': 2, 'if': 2}

# Parse instructions, ignoring lines that don't match expected patterns
def parse_instructions(file_content):
    id = 0
    instructions = []
    for line in file_content:
        line = line.strip()
        for type, pattern in patterns.items():
            if match := pattern.match(line):
                if type == 'operation':
                    instructions.append({'id': id, 'type': type, 'target': match.group(1), 'operands': [match.group(2), match.group(4)], 'operator': match.group(3), 'latency': latency[match.group(3)]})
                elif type == 'assignment':
                    instructions.append({'id': id, 'type': type, 'target': match.group(1), 'operands': [match.group(2)], 'operator': '=', 'latency': latency['=']})
                elif type == 'conditional':
                    instructions.append({'id': id, 'type': type, 'condition': match.group(1), 'latency': latency['if']})
                id += 1
                break
    return instructions


def simulate_execution(instructions: list, max_cycles=50):
    cycle = 0
    in_progress = [] # track currently executing instruction
    completed = [] # track completed instructions
    ready_queue = [] # track instructions that have been processed but are waiting on dependencies
    busy_vars = [] # track variables that are currenlty being used
    pipeline_max = 2
    pipeline_counter = 0


    instruction_queue = instructions.copy()


    print(f"instructions: {instructions}")


    while cycle < max_cycles and len(completed) < len(instructions):
        cycle += 1
        print(f"CYCLE NUMBER: {cycle}")

        for instr in in_progress.copy():
            print(f"in_progress: {in_progress}")
            instr['latency'] =- 1
            if instr['latency'] <= 0:
                print(f"complete: {instr}")
                completed.append(instr)
                in_progress.remove(instr)
                busy_vars.remove(instr['target'])
                pipeline_counter -= 1
            else:
                print(f"more cycles to go: {instr}")

        # tackle ready queue before moving to other instructions
        for instr in ready_queue:
            print(f"ready_queue: {ready_queue}")
            if instr['latency'] <= 0:
                continue
            
            # compromise to handle overcomplicated far-ahead situations
            if pipeline_counter >= pipeline_max:
                print("pipeline full")
                break

            print(f"processing: {instr}")
            
            safe_operation = 1
            for operand in instr['operands']:
                if operand in busy_vars:
                    print(f"operand {operand} busy, instruction unsafe")
                    safe_operation = 0
                else:
                    print(f"{operand} not in busy vars")

            if safe_operation:
                in_progress.append(instr)
                print(f"{instr} added to in_progress")
                busy_vars.append(instr['target'])
                print(f"{instr['target']} added to busy_vars")
                pipeline_counter += 1

            try:
                ready_queue.remove(instr)
            except:
                print(f"ERROR, ready_queue: {ready_queue}\ninstr: {instr}")
                
        for instr in instructions.copy():
            if instr['latency'] <= 0:
                continue
            
            # compromise to handle overcomplicated far-ahead situations
            if pipeline_counter >= pipeline_max:
                print("pipeline full")
                break


            print(f"processing: {instr}")
            
            safe_operation = 1
            if instr['type'] == 'assignment' or instr['type'] == 'operation':
                for operand in instr['operands']:
                    if not operand.isnumeric():
                        if operand in busy_vars:
                            print(f"operand {operand} busy, instruction unsafe")
                            safe_operation = 0
                        else:
                            print(f"{operand} not in busy vars")
                    else:
                        print(f"{operand} is a number")


                if instr['target'] in busy_vars:
                    print(f"target {instr['target']} busy, instruction unsafe")
                    continue
                else:
                    print(f"{instr['target']} not in busy vars")


                if safe_operation:
                    in_progress.append(instr)
                    print(f"{instr} added to in_progress")
                    busy_vars.append(instr['target'])
                    print(f"{instr['target']} added to busy_vars")
                    pipeline_counter += 1
                else:
                    ready_queue.append(instr)
                    print(f"{instr} added to ready_queue")

                try:
                    instruction_queue.remove(instr)
                except:
                    print(f"ERROR, instruction_queue: {instruction_queue}\ninstr: {instr}")
            elif instr['type'] == 'conditional': 
                try:
                    completed.append(instr)
                    instruction_queue.remove(instr)
                except:
                    print(f"ERROR, instruction_queue: {instruction_queue}\ninstr: {instr}")

        print("cycle complete")
        # print(f"instructions: {instructions}")
        print(f"instruction_queue: {instruction_queue}")
        print(f"in_progress: {in_progress}")
        print(f"ready_queue: {ready_queue}")
        print(f"busy_vars: {busy_vars}\n\n")


    return cycle if len(completed) == len(instructions) else "Simulation did not complete"


# Temporarily using non-file for this test
with open("outfile_3.txt", "r") as file:
    file_content = file.readlines()
    print(file_content)

# Parse instructions
print("Getting instructions")
instructions = parse_instructions(file_content)

# Simulate execution
print("Simulating execution")
total_cycles = simulate_execution(instructions)
print(f"Total runtime: {total_cycles} cycles")
