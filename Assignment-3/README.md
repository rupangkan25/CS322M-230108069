# RVX10 – Custom Extension to RV32I Single-Cycle Core

This project extends the base RV32I single-cycle processor with **10 new single-cycle instructions** (RVX10) using the reserved `CUSTOM-0` opcode space (0x0B).  
All instructions are ALU-type (R-format) and are implemented in the RTL, documented, and tested with a self-checking program.

---

## Contents

- `src/riscvsingle.sv`  
  Modified single-cycle RISC-V processor with decode + ALU logic for the 10 RVX10 instructions.

- `docs/ENCODINGS.md`  
  Instruction encodings (opcode, funct7, funct3) with worked-out examples in hex.

- `docs/TESTPLAN.md`  
  Test vectors, expected results, and edge cases for each of the 10 new instructions.

- `tests/rvx10.hex`  
  Memory image generated from the assembly program. Loadable with `$readmemh` in your Verilog testbench.

---

## The 10 RVX10 Instructions

| Name  | Semantics                                  |
|-------|---------------------------------------------|
| ANDN  | `rd = rs1 & ~rs2`                          |
| ORN   | `rd = rs1 | ~rs2`                          |
| XNOR  | `rd = ~(rs1 ^ rs2)`                        |
| MIN   | `rd = min(rs1, rs2)` (signed)              |
| MAX   | `rd = max(rs1, rs2)` (signed)              |
| MINU  | `rd = min(rs1, rs2)` (unsigned)            |
| MAXU  | `rd = max(rs1, rs2)` (unsigned)            |
| ROL   | `rd = (rs1 << s) | (rs1 >> (32-s))`       |
| ROR   | `rd = (rs1 >> s) | (rs1 << (32-s))`       |
| ABS   | `rd = |rs1|` (rs2 ignored, encode as x0)   |

---

## How to Run

### 1. RTL Simulation
1. Place `tests/rvx10.hex` in your simulation directory.
2. Ensure your Verilog testbench loads it into instruction memory:

```verilog
initial begin
  $readmemh("tests/rvx10.hex", imem);
end

### 2. Run Simulation

- **Success:** Memory address `100` will contain value `25`.
- **Failure:** Memory address `100` will contain `0`.

---

### 3. Rebuilding `rvx10.hex` (Optional)

If you modify `tests/rvx10.S`, regenerate `rvx10.hex`:


#### Using RARS (GUI/CLI)

1. Open `tests/rvx10.S` in RARS.
2. Assemble and run.
3. Use the Dump Memory function to export memory as hex.
4. Save as `tests/rvx10.hex`.

---

### 4. Success Criterion

- All **13 tests** (10 instructions + 3 edge cases) must pass.
- The testbench should print `"Simulation succeeded"` when `memory[100] == 25`.

---

### 5. Notes

- **ROL/ROR by 0:** Must return `rs1` unchanged (no 32-bit shift).
- **ABS(INT_MIN):** Must return `0x80000000` (wrap-around, no trap).
- **Writes to x0:** Must be ignored.
- The final success indicator is `sw x29, 100(x0)` with `x29 = 25`.


