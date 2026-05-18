# May 6 2026:
**working on: Program Counter**

Today is the first day working on the CPU. 

The main problem I had was remembering the notation for setting vectors to numbers, i.e: `a = 32'h0` (Note that 'h (hexadecimal) vs 'd (decimal)). Another thing to remember is that the reset should be asynchronous for this application.


# May 8 2026:
**working on: Program Counter Test Bench**

The methodology I had for the testbench was to think of all the reasonable configurations that the PC could end up in and then run all of them, whether that be through a for loop or in the case of the reset just the one test.

Some things I learned, when writing testbenches `module pc_tb;` uses a semicolon but doesnt need contents, which is differenct from the actual code. 

**Problem:** forever block made code last forever for the clock set up

**Fix:** use an always block `always #(CLK_PERIOD/2) clk = ~clk;` 

**Problem:** Simulation ran for 150k seconds

**Fix:** Missing `$finish` at end of initial block
![Signal diagram for the PC testbench](image.png)

# May 9 2026:
**working on: Imem, Imem tb, regFile, regFile tb**

Now that I'm getting in the flow of things, it is all going faster, I was able to write 4 scripts today.

**Problem:** most of the problems today were syntax based, like using semicolons instead of commas in the logic of module declarations and using `@(posedge clk); #1;` instead of `#(posedge clk); #1;`
![Signal diagram for the regFile testbench](image-1.png)