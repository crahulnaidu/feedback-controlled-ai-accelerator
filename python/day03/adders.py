

from day02.logic_gates import AND,OR,XOR


def half_adder(a,b):
    Sum=XOR(a,b)
    C=AND(a,b)

    print("\nSum:",Sum)
    print("Carry:",C)



def full_adder(a,b,C_in):
    Sum=XOR(C_in,XOR(a,b))
    C=OR(AND(a,b),AND(C_in,XOR(a,b)))

    return Sum,C




