with open("outfile_2.txt", "r") as file:
    tac_lines = file.readlines()

class Instruction:
    def __init__(self, line):
        self.line = line.strip().replace(";", "")
        self.parse_line()
        
    def parse_line(self):
        parts = self.line.split(" ")
        self.operation = None
        self.targets = []
        self.sources = []
        
        if "=" in self.line:
            self.targets.append(parts[0])
            # Arithmetic operation
            if len(parts) > 3:  
                self.operation = parts[3]
                self.sources.extend([parts[2], parts[4]])
            # Simple assignment
            else:  
                self.sources.append(parts[2])
        # Conditional statement
        elif "if" in self.line:  
            self.operation = "if"
            self.sources.append(parts[1].strip("()"))
        # Else statement (no operation, just control flow)
        elif "else" in self.line:  
            self.operation = "else"
        
    def __repr__(self):
        return f"{self.line} (Operation: {self.operation}, Sources: {self.sources}, Targets: {self.targets})"


instructions = [Instruction(line) for line in tac_lines]

class DDG:
    def __init__(self, instructions):
        self.instructions = instructions
        self.graph = {i: [] for i in range(len(instructions))}
        self.build_ddg()

    def add_edge(self, from_node, to_node):
        if to_node not in self.graph[from_node]:
            self.graph[from_node].append(to_node)

    def build_ddg(self):
        for i, instruction in enumerate(self.instructions):
            for j in range(i + 1, len(self.instructions)):
                if any(target in self.instructions[j].sources for target in instruction.targets):
                    self.add_edge(i, j)

# Construct the DDG based on the parsed instructions
ddg = DDG(instructions)

class Scheduler:
    def __init__(self, ddg, instructions):
        self.ddg = ddg.graph
        self.instructions = instructions
        self.latencies = {'+': 1, '-': 1, '*': 4, '/': 4, '=': 2, 'if': 2}
        self.schedule = []
        self.execute()

    def get_latency(self, instruction):
        if instruction.operation in self.latencies:
            return self.latencies[instruction.operation]
        # Default latency for operations not listed (e.g., else)
        return 1  

    def execute(self):
        # Instructions with no dependencies
        ready = [i for i in self.ddg if not self.ddg[i]]  
        time = 0
        while len(self.schedule) < len(self.instructions):
            for i in list(ready):
                instr_latency = self.get_latency(self.instructions[i])
                # Schedule instruction i to start at current time
                self.schedule.append((i, time))  
                # Increment time by the latency of the scheduled instruction
                time += instr_latency  
                ready.remove(i)
                # Add successors of the current instruction to the ready list if all their dependencies are scheduled
                for succ in self.ddg:
                    if i in self.ddg[succ]:
                        # Remove the current instruction from successor's dependencies
                        self.ddg[succ].remove(i)  
                        # If no more dependencies, add to ready list
                        if not self.ddg[succ]:  
                            ready.append(succ)

    def total_latency(self):
        return max(start + self.get_latency(self.instructions[i]) for i, start in self.schedule)

# Initialize and run the scheduler
scheduler = Scheduler(ddg, instructions)

# Calculate and print the total latency
total_latency = scheduler.total_latency()
print(f"Total Latency: {total_latency} cycles")
