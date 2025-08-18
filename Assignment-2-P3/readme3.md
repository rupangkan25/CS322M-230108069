# Problem 3 – Traffic Light Controller FSM

## 📌 Goal
Design a FSM-based traffic light controller for a **2-way intersection**:
- Default: **Main Road = Green**, **Side Road = Red**
- When a car is detected on the Side Road:
  - Main → Yellow → Red
  - Side → Green → Yellow → Red
  - Then return to Main = Green

Reset is synchronous and active-high.

---

## ⚙️ FSM Description
- **Inputs**
  - `car` : 1 when a vehicle is waiting on Side Road
- **Outputs**
  - `main_light` : {Green, Yellow, Red}
  - `side_light` : {Green, Yellow, Red}
- **States**
  - `MainGreen`
  - `MainYellow`
  - `SideGreen`
  - `SideYellow`
- **Timing**
  - Each light state is held for a fixed number of cycles (parameterized in the FSM)

---
