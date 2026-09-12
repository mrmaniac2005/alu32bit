# Parameterized SystemVerilog ALU

A parameterized arithmetic and logic unit written in SystemVerilog, with a self-checking simulation testbench and functional coverage.

## Features

- Configurable data width through the `WIDTH` parameter (default: 32 bits in the DUT).
- Arithmetic: add, subtract, increment, and decrement.
- Logic: AND, OR, XOR, and XNOR.
- Shifts: logical left, logical right, and arithmetic right.
- Comparisons: unsigned and signed equal, greater-than, and less-than.
- Pass-through operations for either input.
- Status outputs for carry, signed overflow, zero, negative, unsigned comparison, and signed comparison.

## Repository Layout

```text
source/              ALU RTL and opcode package
simulation/          Self-checking testbench and coverage model
scripts/             Vivado project and simulation Tcl scripts
simulator/           Generated Vivado project files
waves/               Generated VCD waveforms
```

## ALU Interface

The `alu` module accepts two `WIDTH`-bit operands and a 4-bit `alu_opcode_e` opcode:

| Opcode | Operation |
| --- | --- |
| `ALU_ADD` | `a + b` |
| `ALU_SUB` | `a - b` |
| `ALU_AND` | `a & b` |
| `ALU_OR` | `a \| b` |
| `ALU_XOR` | `a ^ b` |
| `ALU_XNOR` | `~(a ^ b)` |
| `ALU_SLL` | `a << 1` |
| `ALU_SRL` | `a >> 1` |
| `ALU_SRA` | Signed `a >>> 1` |
| `ALU_EQ` | Compare equality |
| `ALU_GT` | Compare greater-than |
| `ALU_LT` | Compare less-than |
| `ALU_INC` | `a + 1` |
| `ALU_DEC` | `a - 1` |
| `ALU_PASSA` | Pass `a` |
| `ALU_PASSB` | Pass `b` |

For comparison operations, `comp` contains the unsigned result and `sicomp` contains the signed result. `zero` and `negative` are derived from `result`.

## Vivado Usage

Run these commands from the repository root in Vivado's Tcl console or with Vivado in batch mode:

```tcl
source scripts/create_project.tcl
# Supply a project name when prompted, for example: alu_project
source scripts/add_files.tcl
source scripts/run.tcl
```

The scripts take arguments in this order:

```text
create_project.tcl <project_name>
add_files.tcl <project_name>
run.tcl <project_name> <testbench_name>
```

For example, from a shell:

```bash
vivado -mode batch -source scripts/create_project.tcl -tclargs alu_project
vivado -mode batch -source scripts/add_files.tcl -tclargs alu_project
vivado -mode batch -source scripts/run.tcl -tclargs alu_project alu_tb
```

The testbench uses `WIDTH=16`, checks the ALU against a reference model, randomizes inputs until coverage reaches 100%, and writes the waveform to `waves/alu_tb.vcd`. Vivado coverage reports are written to `coverage_reports/` when the simulator license supports coverage export.

## Requirements

- Vivado with SystemVerilog simulation support.
- A simulator that supports the SystemVerilog constructs used by the testbench, including assertions, constrained randomization, and coverage.

Generated Vivado files, coverage reports, and waveforms are ignored by Git; source RTL, scripts, and the testbench are tracked.
