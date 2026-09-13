import alu_isa_pkg::*;

module alu_tb #(parameter int WIDTH = 32);
    typedef struct packed {
        logic [WIDTH-1:0] a,b;
        alu_opcode_e opcode;
        logic [WIDTH-1:0] result;
        logic carry, overflow, zero, negative, comp, sicomp;
    } io_set_t;

    io_set_t io_tb;

    alu_netlist alu_instance (
        .a(io_tb.a),
        .b(io_tb.b),
        .opcode(io_tb.opcode),
        .result(io_tb.result),
        .carry(io_tb.carry),
        .overflow(io_tb.overflow),
        .zero(io_tb.zero),
        .negative(io_tb.negative),
        .comp(io_tb.comp),
        .sicomp(io_tb.sicomp)
    );
    logic [WIDTH-1:0] corner_vals[5];

    covergroup cg;
        cp_a: coverpoint io_tb.a {
            bins seg[] = {
            '0,
            '1,
            {{WIDTH-1{1'b0}},1'b1},
            {1'b0,{WIDTH-1{1'b1}}},
            {1'b1,{WIDTH-1{1'b0}}}
            };
        }
        cp_b: coverpoint io_tb.b {
            bins seg[] = {
            '0,
            '1,
            {{WIDTH-1{1'b0}},1'b1},
            {1'b0,{WIDTH-1{1'b1}}},
            {1'b1,{WIDTH-1{1'b0}}}
            };
        }
        cp_opcode: coverpoint io_tb.opcode;
        cp_carry: coverpoint io_tb.carry;
        cp_overflow: coverpoint io_tb.overflow;
        cp_zero: coverpoint io_tb.zero;
        cp_neg: coverpoint io_tb.negative;
        cp_sicomp: coverpoint io_tb.sicomp;
        cp_comp: coverpoint io_tb.comp;

        cp_a_sign: coverpoint io_tb.a[WIDTH-1];
        cp_b_sign: coverpoint io_tb.b[WIDTH-1];


        cp_add_sub_opcode: coverpoint io_tb.opcode {
            bins add_sub[] = {ALU_ADD, ALU_SUB};
        }

        cp_overflow_conditions: cross cp_add_sub_opcode, cp_a_sign, cp_b_sign, cp_overflow {
            // ADD: (+,-) can never overflow
            ignore_bins add_pos_neg =
            binsof(cp_add_sub_opcode) intersect {ALU_ADD} &&
            binsof(cp_a_sign) intersect {0} &&
            binsof(cp_b_sign) intersect {1} &&
            binsof(cp_overflow) intersect {1};

            // ADD: (-,+) can never overflow
            ignore_bins add_neg_pos =
            binsof(cp_add_sub_opcode) intersect {ALU_ADD} &&
            binsof(cp_a_sign) intersect {1} &&
            binsof(cp_b_sign) intersect {0} &&
            binsof(cp_overflow) intersect {1};

            // SUB: (+,+) can never overflow
            ignore_bins sub_pos_pos =
            binsof(cp_add_sub_opcode) intersect {ALU_SUB} &&
            binsof(cp_a_sign) intersect {0} &&
            binsof(cp_b_sign) intersect {0} &&
            binsof(cp_overflow) intersect {1};

            // SUB: (-,-) can never overflow
            ignore_bins sub_neg_neg =
            binsof(cp_add_sub_opcode) intersect {ALU_SUB} &&
            binsof(cp_a_sign) intersect {1} &&
            binsof(cp_b_sign) intersect {1} &&
            binsof(cp_overflow) intersect {1};
        }
        cp_signs_opcode: cross cp_opcode, cp_a_sign, cp_b_sign;
    endgroup
    cg cov = new();

    function automatic io_set_t golden_compute(input logic [WIDTH-1:0] a, input logic [WIDTH-1:0] b, input alu_opcode_e opcode);
        begin
            io_set_t temp;
            {temp.a, temp.b, temp.opcode, temp.result, temp.carry, temp.overflow, temp.zero, temp.negative, temp.comp, temp.sicomp} = '0;
            temp.a = a;
            temp.b = b;
            temp.opcode = opcode;
            case (temp.opcode)
                ALU_ADD : begin
                    {temp.carry,temp.result} = temp.a + temp.b;
                    temp.overflow = (~temp.a[WIDTH-1] & ~temp.b[WIDTH-1] & temp.result[WIDTH-1]) | (temp.a[WIDTH-1] & temp.b[WIDTH-1] & ~temp.result[WIDTH-1]);
                end
                ALU_SUB : begin
                    {temp.carry,temp.result} = temp.a - temp.b;
                    temp.overflow = (~temp.a[WIDTH-1] & temp.b[WIDTH-1] & temp.result[WIDTH-1]) | (temp.a[WIDTH-1] & ~temp.b[WIDTH-1] & ~temp.result[WIDTH-1]);
                end
                ALU_AND : begin
                    temp.result = temp.a & temp.b;
                end
                ALU_OR : begin
                    temp.result = temp.a | temp.b;
                end
                ALU_XOR : begin
                    temp.result = temp.a ^ temp.b;
                end
                ALU_XNOR : begin
                    temp.result = ~(temp.a ^ temp.b);
                end
                ALU_SLL : begin
                    temp.result = temp.a << 1;
                end
                ALU_SRL : begin
                    temp.result = temp.a >> 1;
                end
                ALU_SRA : begin
                    temp.result = $signed(temp.a) >>> 1;
                end
                ALU_EQ : begin
                    temp.comp = (temp.a == temp.b);
                    temp.sicomp = ($signed(temp.a) == $signed(temp.b));
                end
                ALU_GT : begin
                    temp.comp = (temp.a > temp.b);
                    temp.sicomp = ($signed(temp.a) > $signed(temp.b));
                end
                ALU_LT : begin
                    temp.comp = (temp.a < temp.b);
                    temp.sicomp = ($signed(temp.a) < $signed(temp.b));
                end
                ALU_INC : begin
                    {temp.carry,temp.result} = temp.a + 1;
                    temp.overflow = (~temp.a[WIDTH-1] & temp.result[WIDTH-1]);
                end
                ALU_DEC : begin
                    {temp.carry,temp.result} = temp.a - 1;
                    temp.overflow = (temp.a[WIDTH-1] & ~temp.result[WIDTH-1]);
                end
                ALU_PASSA : begin
                    temp.result = temp.a;
                end
                ALU_PASSB : begin
                    temp.result = temp.b;
                end
                default : begin
                    {temp.carry,temp.result, temp.comp, temp.sicomp, temp.overflow, temp.zero, temp.negative} = '0;
                end
            endcase
            temp.negative = temp.result[WIDTH-1];
            temp.zero = (temp.result == '0);
            return temp;
        end
    endfunction


    task automatic test_base(input logic [WIDTH-1:0] a, b, input alu_opcode_e opcode);
        begin
            io_set_t exp;
            {exp.a, exp.b, exp.opcode} = {a, b, opcode};
            exp = golden_compute(a, b, opcode);
            {exp.a, exp.b, exp.opcode} = {a, b, opcode};
            {io_tb.a, io_tb.b, io_tb.opcode} = {a, b, opcode};
            #10;
            cov.sample();
            assert(io_tb.result == exp.result)
            else
            $fatal(
                1,
                "Result mismatch: a=%0d b=%0d opcode=%0b expected=%0d got=%0d",
                io_tb.a,
                io_tb.b,
                io_tb.opcode,
                exp.result,
                io_tb.result
            );
            assert(io_tb.carry == exp.carry) else $fatal(1, "Carry mismatch: a=%0d, b=%0d, opcode=%0b, expected carry=%0b, got carry=%0b", io_tb.a, io_tb.b, io_tb.opcode, exp.carry, io_tb.carry);
            assert(io_tb.overflow == exp.overflow) else $fatal(1, "Overflow mismatch: a=%0d, b=%0d, opcode=%0b, expected overflow=%0b, got overflow=%0b", io_tb.a, io_tb.b, io_tb.opcode, exp.overflow, io_tb.overflow);
            assert(io_tb.zero == exp.zero) else $fatal(1, "Zero mismatch: a=%0d, b=%0d, opcode=%0b, expected zero=%0b, got zero=%0b", io_tb.a, io_tb.b, io_tb.opcode, exp.zero, io_tb.zero);
            assert(io_tb.negative == exp.negative) else $fatal(1, "Negative mismatch: a=%0d, b=%0d, opcode=%0b, expected negative=%0b, got negative=%0b", io_tb.a, io_tb.b, io_tb.opcode, exp.negative, io_tb.negative);
            assert(io_tb.comp == exp.comp) else $fatal(1, "Comp mismatch: a=%0d, b=%0d, opcode=%0b, expected comp=%0b, got comp=%0b", io_tb.a, io_tb.b, io_tb.opcode, exp.comp, io_tb.comp);
            assert(io_tb.sicomp == exp.sicomp) else $fatal(1, "Sicomp mismatch: a=%0d, b=%0d, opcode=%0b, expected sicomp=%0b, got sicomp=%0b", io_tb.a, io_tb.b, io_tb.opcode, exp.sicomp, io_tb.sicomp);
        end
    endtask

    class test_sequence;
        rand logic [WIDTH-1:0] a, b;
        rand alu_opcode_e opcode;
    endclass

    test_sequence ts;

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
        process::self().srandom($urandom);
        $monitor("time=%0t, a=%0b, b=%0b, opcode=%0b, result=%0b, carry=%0b, overflow=%0b, zero=%0b, negative=%0b, comp=%0b, sicomp=%0b", $time, io_tb.a, io_tb.b, io_tb.opcode, io_tb.result, io_tb.carry, io_tb.overflow, io_tb.zero, io_tb.negative, io_tb.comp, io_tb.sicomp);
        ts = new();
        corner_vals = '{ '0, '1, {{WIDTH-1{1'b0}},1'b1}, {1'b0,{WIDTH-1{1'b1}}}, {1'b1,{WIDTH-1{1'b0}}} };
        for (int i = 0; i < 5; i++) begin
            for (int j = 0; j < 5; j++) begin
                test_base(corner_vals[i], corner_vals[j], ALU_ADD);
            end
        end
        for (int i = 0; i < 5; i++) begin
            for (int j = 0; j < 5; j++) begin
                test_base(corner_vals[i], corner_vals[j], ALU_SUB);
            end
        end
        while (cov.get_coverage() < 100.0) begin
            assert(ts.randomize()) else $fatal(1, "Randomization failed");
            test_base(ts.a, ts.b, ts.opcode);
        end

        $display("Coverage report: %0.2f%%", cov.get_coverage());
        $display("Coverage cp_a: %0.2f%%", cov.cp_a.get_coverage());
        $display("Coverage cp_b: %0.2f%%", cov.cp_b.get_coverage());
        $display("Coverage cp_opcode: %0.2f%%", cov.cp_opcode.get_coverage());
        $display("Coverage cp_carry: %0.2f%%", cov.cp_carry.get_coverage());
        $display("Coverage cp_overflow: %0.2f%%", cov.cp_overflow.get_coverage());
        $display("Coverage cp_zero: %0.2f%%", cov.cp_zero.get_coverage());
        $display("Coverage cp_neg: %0.2f%%", cov.cp_neg.get_coverage());
        $display("Coverage cp_sicomp: %0.2f%%", cov.cp_sicomp.get_coverage());
        $display("Coverage cp_comp: %0.2f%%", cov.cp_comp.get_coverage());
        $display("Coverage cp_a_sign: %0.2f%%", cov.cp_a_sign.get_coverage());
        $display("Coverage cp_b_sign: %0.2f%%", cov.cp_b_sign.get_coverage());
        $display("Coverage cp_signs_opcode: %0.2f%%", cov.cp_signs_opcode.get_coverage());
        $display("Coverage cp_add_sub_opcode: %0.2f%%", cov.cp_add_sub_opcode.get_coverage());
        // $display("Coverage cp_overflow_conditions: %0.2f%%", cov.cp_overflow_conditions.get_coverage());
        $finish;
    end
endmodule
