
def sign_extend_12_to_32(imm12):
    if imm12 & (1<<11):
        return imm12 | ~((1<<12)-1)
    return imm12 & (0xFFF)

def alu_compute(a,b,alu_ctrl):
    a=a & 0xFFFFFFFF
    b=b & 0xFFFFFFFF

    if alu_ctrl==0b0010:
        res=(a+b) & (0xFFFFFFFF)
    elif alu_ctrl==0b0110:
        res=(a-b) & (0xFFFFFFFF)
    elif alu_ctrl==0b0000:
        res=(a & b) & 0xFFFFFFFF
    elif alu_ctrl==0b0001:
        res=(a | b) & 0xFFFFFFFF
    else:
        res=0
    zero=1 if res==0 else 0
    return res,zero


def run_datapath_step(inst,reg_file,alu_src,reg_write,alu_ctrl):
    rs1=(inst>>15)&(0x1F)
    rs2=(inst>>20)&(0x1F)
    rd=(inst>>7)&(0x1F)
    imm12=(inst>>20)&(0xFFF)

    rdata1=reg_file[rs1]
    rdata2=reg_file[rs2]
    imm32=sign_extend_12_to_32(imm12)

    operand_b=imm32 if alu_src==1 else rdata2
    result,zero=alu_compute(rdata1,operand_b,alu_ctrl)

    if reg_write & rd!=0:
        reg_file[rd]=result

    return result,zero,reg_file


regs=[0]*32
regs[6]=0x10
regs[7]=0x05

res,z,regs=run_datapath_step(0xFFC30293,regs,alu_src=1,reg_write=1,alu_ctrl=0b0010)
print(f"ADDI Result :0x{res:08X} (Expected :0x0000000C), x5=0x{regs[5]:08X}")