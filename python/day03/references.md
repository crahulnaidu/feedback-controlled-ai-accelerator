# Day 3 References

## Books

### Digital Design — M. Morris Mano

Topics:
- Combinational Logic
- Arithmetic Circuits
- Adders

### Computer Organization and Design — RISC-V Edition

Topics:
- Datapath
- Arithmetic Operations
- Processor Organization

## Additional Resources

None for today.





1.A Full adder adds 3 bits A,B,C_in and outputs a sum and carry.
It's Truth table is given by -
A  B  C_in  |  S  C
0  0  0     |  0  0
1  0  0     |  1  0
0  1  0     |  1  0
0  0  1     |  1  0
1  0  1     |  0  1
1  1  0     |  0  1
0  1  1     |  0  1
1  1  1     |  1  1


Based on the table the expression for Sum can be obtained by ORing the terms where S is 1 i.e
S=AB'C_in'+A'BC_in'+A'B'C_in+ABC_in

simplifying this we get 
S=A xor B xor C_in.

Similarly for C
C=A and B and C_in' Or C_in and (A or B)

For S the first xor calculates A xor B.The output from the first xor is input to the 2nd xor with another input C_in which produces S.

The carry from the first sum A,B whic is A and B is ORed with the and between C_in and (A or B).

If we include xor gates, the total no of gates is -2 xor gates,2 and gates,2 or gates.


2.Fundamentally addition involves bit by bit addition and carry propagation.The next Full adder requires the carry produces by the previous Full adder.This creates a dependency between consecutive Full adders leading to some propagation delays 


3.Since each Full adder takes 2ns of propagation delay, the total delay would be 32*2=64ns.

Because 64ns delay is a lot for today's processors as they have clock cycle times of 1 to 2 ns,faster adder circuits exist to mitigate these delays.


4.Firstly 1024 MAC units would require 1024 adders.Now In order to perforn fast additions the propogation delay must be really low ,which mandates fast addition circuits than ripple carry adders.Since an n bit adder has n 1 bit adders, the size and propogation delay of each adder is really important in the final design of the accelerator as it determines the cost,power,area and final delay for the circuit.So it is highly crucial to design the adder circuits such that all of these parameters reach an acceptable threshold.


5.Given the 2 architectures ,it would be efficient to use them such that one compensates for the other.For a MAC unit ,it multiplies and then adds it to the previous result.For the multiply part ,since it is shifting and adding and involves greater no of addition operations,it should be performed by Accelerator A for speed and the accumulation additions be performed by Accelerator B for energy efficiency.


Bonus Question.

From the RISC-V instruction ,it goes to the CPU datapath where the instruction is decoded and the op code and the operands are identified.

They are then loaded via the bus into appropriate Accelerator registers ,which is then used by the ADD/MAC hardware to perform the addition.The result is then written to a result register ,which is then read by RISC-V.


