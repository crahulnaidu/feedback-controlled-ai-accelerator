class RegisterFile:
    def __init__(self):
        self.registers=[0]*32

    def read(self,index):
        return self.registers[index]

    def write(self,index,value):
        if index!=0:
            self.registers[index]=value    