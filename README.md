# Parameterized SystemVerilog ALU

A parameterized 32-bit arithmetic and logic unit written in SystemVerilog with self-checking simulation, comprehensive functional coverage, and support for both Vivado and Yosys synthesis flows.

## Features

- **Parameterized width**: Default 32 bits (configurable via `WIDTH` parameter)
- **Arithmetic**: ADD, SUB, INC, DEC with carry and overflow detection
- **Logic**: AND, OR, XOR, XNOR
- **Shifts**: logical left (SLL), logical right (SRL), arithmetic right (SRA)
- **Comparisons**: EQ, GT, LT with both unsigned (`comp`) and signed (`sicomp`) results
- **Pass-through**: PASSA (pass `a`), PASSB (pass `b`)
- **Status flags**: carry, overflow, zero, negative

## Repository Structure

```
source/              RTL source and ISA definition
  ├── alu.sv         Parameterized ALU implementation
  └── alu_isa_pkg.sv ALU opcode enum (16 operations)
simulation/          Testbench and coverage
  └── alu_tb.sv      Self-checking testbench with coverage model
scripts/             Automation scripts
  ├── create_project.tcl    Create Vivado project
  ├── add_files.tcl         Add RTL and testbench to project
  ├── run.tcl               Execute simulation and coverage
  ├── synth_asic.ys         Yosys ASIC synthesis script
  ├── equiv.ys              Yosys equivalence checking (RTL vs. netlist)
  └── view_files.tcl        (Vivado IDE helper)
simulator/           Generated Vivado project
synthesized/         ASIC netlist output (alu_netlist.v)
waves/               VCD waveform files
  ├── alu_tb.vcd
  └── mux8to4_tb.vcd
coverage_reports/    Vivado coverage exports (text format)
formal_reports/      Equivalence checking results
  └── equiv.txt
```

## ALU Interface

The `alu` module in [source/alu.sv](source/alu.sv) has the following interface:

```systemverilog
module alu #(parameter int WIDTH = 32) (
    input  logic [WIDTH-1:0] a, b,
    input  alu_isa_pkg::alu_opcode_e opcode,
    output logic [WIDTH-1:0] result,
    output logic carry, overflow, zero, negative, comp, sicomp
);
```

### Opcodes

| Opcode   | Encoding | Operation | Notes |
|----------|----------|-----------|-------|
| ALU_ADD  | 0x0 | `{carry, result} = a + b` | Carry detects unsigned overflow |
| ALU_SUB  | 0x1 | `{carry, result} = a - b` | Carry detect on borrow |
| ALU_AND  | 0x2 | `result = a & b` | Bitwise AND |
| ALU_OR   | 0x3 | `result = a \| b` | Bitwise OR |
| ALU_XOR  | 0x4 | `result = a ^ b` | Bitwise XOR |
| ALU_XNOR | 0x5 | `result = ~(a ^ b)` | Bitwise XNOR |
| ALU_SLL  | 0x6 | `result = a << 1` | Shift left logical by 1 |
| ALU_SRL  | 0x7 | `result = a >> 1` | Shift right logical by 1 |
| ALU_SRA  | 0x8 | `result = $signed(a) >>> 1` | Shift right arithmetic by 1 |
| ALU_EQ   | 0x9 | Compare equality | `comp` = unsigned, `sicomp` = signed |
| ALU_GT   | 0xA | Compare greater-than | `comp` = unsigned, `sicomp` = signed |
| ALU_LT   | 0xB | Compare less-than | `comp` = unsigned, `sicomp` = signed |
| ALU_INC  | 0xC | `{carry, result} = a + 1` | Increment `a` |
| ALU_DEC  | 0xD | `{carry, result} = a - 1` | Decrement `a` |
| ALU_PASSA| 0xE | `result = a` | Pass-through operand `a` |
| ALU_PASSB| 0xF | `result = b` | Pass-through operand `b` |

### Status Flags

- **`carry`**: Unsigned overflow on ADD/SUB/INC/DEC; 0 for logic/shift/comparison/pass-through
- **`overflow`**: Signed overflow on ADD/SUB/INC/DEC (2's complement); 0 otherwise
- **`zero`**: Set when result equals 0
- **`negative`**: Set when result MSB is 1 (result is negative in 2's complement)
- **`comp`**: Unsigned comparison result (for EQ/GT/LT only)
- **`sicomp`**: Signed comparison result (for EQ/GT/LT only)

## Testing & Coverage

The testbench [simulation/alu_tb.sv](simulation/alu_tb.sv) employs a **two-phase** verification strategy:

### Phase 1: Corner Cases
Tests all 25 combinations of corner operand values:
- `'0`, `'1`, `{{WIDTH-1{1'b0}},1'b1}` (1), `{1'b0,{WIDTH-1{1'b1}}}` (max positive), `{1'b1,{WIDTH-1{1'b0}}}` (min negative)

For ADD and SUB only, exercises all sign combinations: (+,+), (+,-), (-,+), (-,-)

### Phase 2: Randomized Testing
Generates random operands and opcodes until functional coverage reaches 100%, then terminates.

### Coverage Model

The covergroup includes bins for:
- Operand patterns: zero, all-ones, sign bits, boundary values
- Individual opcodes: all 16 operations
- Flag states: carry, overflow, zero, negative, comp, sicomp
- Sign combinations: all operand sign pairs (2×2 = 4 bins)
- Cross-coverage: overflow conditions filtered by operation (ADD/SUB) and input signs

Coverage ensures overflow impossible cases are properly excluded (e.g., (+) + (+) → negative overflow).

### Assertions & Golden Model

Each test case compares the DUT against a golden model implemented in Verilog. Failures report:
- Input operands, opcode, and expected vs. actual output
- All status flags checked independently
- Test terminates immediately on any mismatch

## Simulation with Vivado

### Setup

From the repository root, create a Vivado project:

```bash
vivado -mode batch -source scripts/create_project.tcl -tclargs my_alu_project
```

Add RTL and testbench files:

```bash
vivado -mode batch -source scripts/add_files.tcl -tclargs my_alu_project
```

### Run Simulation

```bash
vivado -mode batch -source scripts/run.tcl -tclargs my_alu_project alu_tb
```

This script:
1. Opens the Vivado project
2. Sets `alu_tb` as the simulation top module
3. Launches behavioral simulation
4. Runs until `$finish` (100% coverage reached)
5. Exports coverage in text format to `coverage_reports/`
6. Saves VCD waveforms to `waves/`

### Output Files

- **Waveforms**: `waves/alu_tb.vcd` — open in any VCD viewer or Vivado Wave Viewer
- **Coverage**: `coverage_reports/` — text-format coverage report
- **Log**: Vivado console output shows real-time test progress and final coverage percentages

## ASIC Synthesis with Yosys

### RTL Synthesis

```bash
yosys -m ghdl scripts/synth_asic.ys
```

Outputs: `synthesized/alu_netlist.v`

### Equivalence Verification

Verify that the synthesized netlist is functionally equivalent to the RTL:

```bash
yosys -m ghdl scripts/equiv.ys
```

Creates a miter circuit, checks both implementations are identical, and saves results to `formal_reports/equiv.txt`.

## SystemVerilog Requirements

The testbench uses:
- **Packages**: `import alu_isa_pkg::*;`
- **Assertions**: `assert...else $fatal` for test failures
- **Randomization**: Constrained random class `test_sequence`
- **Functional Coverage**: Covergroup with cross-coverage
- **VCD Dump**: `$dumpfile()` and `$dumpvars()`

Any SystemVerilog-capable simulator (Vivado XSIM, ModelSim, VCS, Xcelium, etc.) is supported.

## Files Tracked by Git

- `source/` — RTL and ISA package
- `simulation/` — Testbench
- `scripts/` — Automation
- `README.md` — This file

**Not tracked** (generated):
- `simulator/` — Vivado project and build artifacts
- `synthesized/` — Netlist output
- `waves/` — VCD files
- `coverage_reports/` — Coverage exports
- `formal_reports/` — Equivalence results
