from logic_gates import AND,OR,NOT,NAND,NOR,XOR,XNOR


A=[0,1]
B=[0,1]

dict={"AND":AND,"OR":OR,"NOT":NOT,"NAND":NAND,"NOR":NOR,"XOR":XOR,"XNOR":XNOR}

for key in dict:
    if key=="NOT":
        print("A",'|',key)

        for a in A:
            val=dict[key]
            print(a,'|',val(a))    
        print("\n")

    else:
          print('A',' ','B','|',key)

          for a in A:
            for b in B:
                val=dict[key]
                print(a,' ',b,"|",val(a,b))
          print("\n")     



        