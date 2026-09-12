import alu_isa_pkg::*;

module alu # (parameter int WIDTH = 32) (
    input logic [WIDTH-1:0] a,b,
    input alu_opcode_e opcode,
    output logic [WIDTH-1:0] result,
    output logic carry, overflow, zero, negative, comp, sicomp
);
    always_comb begin
        result = '0;
        {sicomp, carry, overflow, zero, negative, comp} = 0;
        case (opcode)
            ALU_ADD: begin
                {carry, result} = a + b;
                overflow = (~a[WIDTH-1] & ~b[WIDTH-1] & result[WIDTH-1]) | (a[WIDTH-1] & b[WIDTH-1] & ~result[WIDTH-1]);

            end
            ALU_SUB: begin
                {carry, result} = a-b;
                overflow = (a[WIDTH-1] != b[WIDTH-1] && result[WIDTH-1] != a[WIDTH-1]);
            end
            ALU_AND: begin
                result = a & b;
            end
            ALU_OR: begin
                result = a | b;
            end
            ALU_XOR: begin
                result = a ^ b;
            end
            ALU_XNOR: begin
                result = ~(a ^ b);
            end
            ALU_SLL: begin
                result = a << 1;
            end
            ALU_SRL: begin
                result = a >> 1;
            end
            ALU_SRA: begin
                result = $signed(a) >>> 1;
            end
            ALU_EQ: begin
                comp = (a == b);
                sicomp = ($signed(a) == $signed(b));
            end
            ALU_GT: begin
                comp = (a > b);
                sicomp = ($signed(a) > $signed(b));
            end
            ALU_LT: begin
                comp = (a < b);
                sicomp = ($signed(a) < $signed(b));
            end
            ALU_INC:begin
                {carry, result} = a + 1;
                overflow = (~a[WIDTH-1] & result[WIDTH-1]);
            end
            ALU_DEC:begin
                {carry, result} = a - 1;
                overflow = (a[WIDTH-1] & ~result[WIDTH-1]);
            end
            ALU_PASSA: result = a;
            ALU_PASSB: result = b;
            default begin
                result = '0;
                {carry, overflow} = 0;
            end
        endcase
        negative = result[WIDTH-1];
        zero = (result == '0);
    end



endmodule
