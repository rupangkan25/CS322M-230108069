# Sequence Detector (Mealy FSM)

This project implements a **Mealy Finite State Machine (FSM)** in Verilog to detect a specific input sequence (`1011`). 

---

## 📌 Deliverables
1. **Verilog RTL Code**  
   - `seq_detect_mealy.v`: Implements the sequence detector FSM.
2. **Testbench**  
   - `seq_detect_mealy_tb.v`: Provides stimulus and generates waveforms for simulation.
3. **Simulation Files**  
   - `sim.out`: Compiled simulation output (generated after running Icarus Verilog).
   - `p1.vcd`: Waveform dump file (generated for GTKWave analysis).


---

## ⚙️ Project Description

- **FSM Type**: Mealy  
- **Input**: Serial bit stream (`in_bit`)  
- **Output**: High (`1`) when the sequence `1011` is detected, else `0`.  
- **Reset**: Active-high reset (`reset`).  
- **Clock**: Positive edge-triggered (`clk`).  

Unlike a Moore machine, a Mealy FSM can produce outputs immediately based on the **present state and input**, so it usually requires fewer states.

---

## 🏗️ FSM Design

### States
We use **descriptive state names** for clarity:
- **IDLE** → Initial/reset state (waiting for `1`).  
- **ONE** → Detected `1`.  
- **ONE_ZERO** → Detected `10`.  
- **ONE_ZERO_ONE** → Detected `101`.  
- **DETECTED** → Sequence `1011` has been detected.  
