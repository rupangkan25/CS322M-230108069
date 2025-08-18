# Problem 2 – Sequence Detector (FSM)

### 📌 Goal
Design a Moore FSM that detects the sequence **“1011”** on a serial input stream.  
- When the sequence is detected, the FSM asserts `z = 1` for one cycle.  
- Overlapping sequences must be detected (e.g., input `10111` should detect twice).  
- Reset is synchronous and active-high.  

---

### ⚙️ FSM Description
- **States**: `S0` (reset), `S1` (saw `1`), `S2` (saw `10`), `S3` (saw `101`), `S4` (sequence detected).  
- **Output**:  
  - `z = 1` only in `S4`.  
- **Transitions**:  
  - Advance on correct bits, fallback on mismatch.

---
