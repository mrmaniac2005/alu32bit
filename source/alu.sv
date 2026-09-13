module alu
    
#(
    parameter int WIDTH = 32
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  alu_isa_pkg::alu_opcode_e opcode,
    output logic [WIDTH-1:0] result,
    output logic carry,
    output logic overflow,
    output logic zero,
    output logic negative,
    output logic comp,
    output logic sicomp
);
    always_comb begin
        result = '0;
        {sicomp, carry, overflow, zero, negative, comp} = 0;
        case (opcode)
            alu_isa_pkg::ALU_ADD: begin
                {carry, result} = a + b;
                overflow = (~a[WIDTH-1] & ~b[WIDTH-1] & result[WIDTH-1]) | (a[WIDTH-1] & b[WIDTH-1] & ~result[WIDTH-1]);

            end
            alu_isa_pkg::ALU_SUB: begin
                {carry, result} = a-b;
                overflow = (a[WIDTH-1] != b[WIDTH-1] && result[WIDTH-1] != a[WIDTH-1]);
            end
            alu_isa_pkg::ALU_AND: begin
                result = a & b;
            end
            alu_isa_pkg::ALU_OR: begin
                result = a | b;
            end
            alu_isa_pkg::ALU_XOR: begin
                result = a ^ b;
            end
            alu_isa_pkg::ALU_XNOR: begin
                result = ~(a ^ b);
            end
            alu_isa_pkg::ALU_SLL: begin
                result = a << 1;
            end
            alu_isa_pkg::ALU_SRL: begin
                result = a >> 1;
            end
            alu_isa_pkg::ALU_SRA: begin
                result = $signed(a) >>> 1;
            end
            alu_isa_pkg::ALU_EQ: begin
                comp = (a == b);
                sicomp = ($signed(a) == $signed(b));
            end
            alu_isa_pkg::ALU_GT: begin
                comp = (a > b);
                sicomp = ($signed(a) > $signed(b));
            end
            alu_isa_pkg::ALU_LT: begin
                comp = (a < b);
                sicomp = ($signed(a) < $signed(b));
            end
            alu_isa_pkg::ALU_INC:begin
                {carry, result} = a + 1;
                overflow = (~a[WIDTH-1] & result[WIDTH-1]);
            end
            alu_isa_pkg::ALU_DEC:begin
                {carry, result} = a - 1;
                overflow = (a[WIDTH-1] & ~result[WIDTH-1]);
            end
            alu_isa_pkg::ALU_PASSA: result = a;
            alu_isa_pkg::ALU_PASSB: result = b;
            default begin
                result = '0;
                {carry, overflow} = 0;
            end
        endcase
        negative = result[WIDTH-1];
        zero = (result == '0);
    end



endmodule
