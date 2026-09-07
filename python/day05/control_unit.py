R_type={"ADD","SUB","AND","OR"}



def control_unit(opcode):
    control_signals={"ALUSrc":0,"RegWrite":0,"MemRead":0,"MemWrite":0,"Branch":0}
    if opcode in R_type:
        control_signals["RegWrite"]=1
    elif opcode=="ld":
        control_signals["ALUSrc"]=1
        control_signals['RegWrite']=1
        control_signals["MemRead"]=1
    elif opcode=="sd":
        control_signals["ALUSrc"]=1
        control_signals["MemWrite"]=1
    elif opcode=="beq":
        control_signals["Branch"]=1
    else:
        raise ValueError("Unknown Opcode")    

    return control_signals



