# Day 3 - Adders and Combinatorial Arithmetic

## Topics
-Half adder
-Full adder
-Ripple carry/Parallel adder
-Carry propogation

## Half Adder.

It is used to add two 1 bit numbers.It produces a sum and a carry.

A   B  |  S  C
1   0  |  1  0
0   1  |  1  0
1   1  |  0  1
0   0  |  0  0

From the truth table the expressions for S and C are-
S=A XOR B
C=A AND B

## Full Adder.

A Full Adder has 3 inputs A,B and carry in.

It is made by combining 2 half adders.

A  B  C_in  |  S  C
0  0  0     |  0  0
1  0  0     |  1  0
0  1  0     |  1  0
0  0  1     |  1  0
1  0  1     |  0  1
1  1  0     |  0  1
0  1  1     |  0  1
1  1  1     |  1  1

From the Truth Table the expressions for S and C are-
S=A XOR B XOR C_in
C=(A AND B) OR (C_in AND(A XOR B))

## Ripple Carry Adder.

It is formed by combining stack of FA's together, such that the carry out of the previous adder is the carry in of the next adder.It is named as such because the carrry ripples across the adders like the waves when a stone is thrown into a lake.

## Hardware Insight.

Carry propogation determines the amount of time taken for the operation to be completed.For the ALU it determines whether different functional units can operate seamlessely or not.For ex-an ALU performs addition not only for arithmetic but to calculate memory addresses for load/store.If this operation takes time then the no of clock cycles required would be huge,leading to severe performance degradation.

## Connection to AI Accelerator.

For the accelerator the MAC unit determines how many FLOPs can be performed in a second.The MAC in turn is made up of many adder,multiply circuits ,which run in parallel.

## Difficult Concepts.

RISC-V Datapath Design for a simple instruction set.

## Questions.

How does RISC-V combines all arithmetic and logic operations into one unit and how does it control it.

