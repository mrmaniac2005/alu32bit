package alu_isa_pkg;
    typedef enum logic [3:0] {
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_AND  = 4'b0010,
        ALU_OR   = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_XNOR = 4'b0101,
        ALU_SLL  = 4'b0110,
        ALU_SRL  = 4'b0111,
        ALU_SRA  = 4'b1000,
        ALU_EQ   = 4'b1001,
        ALU_GT   = 4'b1010,
        ALU_LT   = 4'b1011,
        ALU_INC  = 4'b1100,
        ALU_DEC  = 4'b1101,
        ALU_PASSA= 4'b1110,
        ALU_PASSB= 4'b1111
    } alu_opcode_e;

endpackage
