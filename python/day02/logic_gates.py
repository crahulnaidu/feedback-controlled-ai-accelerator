
def AND(a,b):
    return a*b


def OR(a,b):
    if a+b==0:
        return 0
    else:
        return 1
    

def NOT(a):
    return 1-a


def NAND(a,b):
    x=AND(a,b)
    return NOT(x)


def NOR(a,b):
    x=OR(a,b)
    return NOT(x)


def XOR(a,b):
    if a!=b:
        return 1
    else:
        return 0
    

def XNOR(a,b):
    x=XOR(a,b)
    return NOT(x)


