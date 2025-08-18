# Problem 4 – Master–Slave Handshake FSMs

## 📌 Goal
Implement **two FSMs (Master + Slave)** that communicate using a **4-phase request/acknowledge (req/ack) handshake** with an 8-bit data bus.  
The master sends **4 bytes** (`A0, A1, A2, A3`) to the slave.  

---

## ⚙️ Handshake Protocol
1. **Master** drives data, asserts `req = 1`.
2. **Slave** latches data when `req = 1`, asserts `ack = 1` (holds for 2 cycles).
3. **Master** detects `ack = 1`, drops `req = 0`.
4. **Slave** detects `req = 0`, drops `ack = 0`.
5. Repeat for **4 total transfers**.
6. After the final transfer, **Master asserts `done = 1` for 1 cycle**.

---