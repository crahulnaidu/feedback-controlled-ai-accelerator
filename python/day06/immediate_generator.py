def sign_extend(value,bits):
    sign_bit=1<<(bits-1)

    if value & sign_bit:
        return value-(1<<bits)
    
    return value


