def decimal_to_binary(n):
    if n==0:
        return "0"
    s=""

    while(n!=1):
        s+=str(n%2)
        n=n//2
    s+=str(1)
    return s[::-1]
    pass

def binary_to_decimal(n):
    num=0
    i=0

    for s in n[::-1]:
        num+=(1<<i)*int(s)
        i+=1

    return num    


def decimal_to_hex(n):
    map=['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F']
    s=""
    while(n>0):
        s+=map[n%16]
        n=n//16

    return s[::-1]    


def two_complement(binary):
    seen = False
    binary=list(binary[::-1])
    for i in range(len(binary)):
        if not seen:
            if binary[i]=="1":
                seen=True
        else:
            if binary[i]=="1":
                binary[i]="0"
            else:
                binary[i]="1"            

    return "".join(binary)[::-1]                    


def binary_add(a,b):
    # Assuming the sum never exceeds 4 bits and the operands are of the same no of bits.

    c = ""
    carry=0

    for i in range(len(a)):
        sum=0
        sum+=int(a[len(a)-i-1])+int(b[len(b)-i-1])+carry

        if(sum<2):
            c+=str(sum%2)
            carry=0
        else:
            c+=str(sum%2)
            carry=1   

    if len(c)>3:
        return c[::-1]
    else:
        if carry==1:
            c+="1"
            return c[::-1]
        else:
            return c[::-1]        


print(binary_add("111","110"))
