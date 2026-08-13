from day03.adders import full_adder



def rip_carry_adder_4bit(a,b):
    C_in=0

    Sum=""

    C_out=0


    for i in range(4):
        S,C_out=full_adder(int(a[len(a)-i-1]),int(b[len(b)-i-1]),C_in)
        Sum=str(S)+Sum

        C_in=C_out


    print("Sum is:",Sum)
    print("Carry is:",C_out)



rip_carry_adder_4bit("1001","1010")


