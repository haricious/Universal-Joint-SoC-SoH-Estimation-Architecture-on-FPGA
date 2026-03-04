# Universal Joint SoC–SoH Estimation Architecture on FPGA
### Reconfigurable EKF + Adaptive Coulomb Counting for Multi-Chemistry BMS

---

## Overview

Batteries do not fail abruptly.
They degrade gradually.

Whether it is Lithium-Ion or Lead-Acid, capacity fades, internal resistance increases, and estimation models that once worked start drifting away from reality. Most Battery Management Systems (BMS) are hard-coded for a single chemistry, forcing a complete redesign when the energy storage technology changes.

This project takes a different approach.

It implements a **Universal, Parameter-Driven SoC and SoH estimation architecture on FPGA**, where the estimation engine is separated from the battery personality. By configuring efficiency factors and OCV curves, a single hardware core can track **Li-Ion, Pb-Acid, or NiMH** cells while actively correcting for aging in real time.

This is a hardware-first, customizable system designed for versatile automotive and industrial applications.

---

## System Objective

- **Universal Compatibility:** Estimate SoC accurately for different chemistries by swapping model parameters.
- **Joint Estimation:** Track SoC while concurrently monitoring SoH (Resistance & Capacity).
- **Adaptive Feedback:** Dynamically update the model parameters (like $R_0$) to prevent aging drift.
- **Deterministic Latency:** Guarantee real-time performance (<10ms) using parallel FPGA logic.
- **Numerical Robustness:** Maintain stability across varying voltage domains (3V to 48V) using Q8.8 fixed-point arithmetic.

The goal is not just algorithmic complexity.
The goal is **one architecture, any battery.**

---

## Estimation Strategy

### State-of-Charge (SoC)

SoC estimation is performed using a **Universal Triple-Hybrid** approach:

1. **Adaptive Coulomb Counting (ACC)**
   Provides real-time tracking with a **programmable efficiency factor ($\eta$)** to handle charge losses in Lead-Acid vs. high efficiency in Li-Ion.

2. **Extended Kalman Filter (EKF)**
   A generic matrix engine that corrects integration drift using voltage measurements, independent of the specific cell chemistry.

3. **Configurable OCV Lookup**
   A multi-bank memory architecture that allows the system to switch between different **Open Circuit Voltage** profiles (e.g., Flat Li-Ion vs. Sloped Pb-Acid) on the fly.

Each method compensates for the weaknesses of the others.

---

### State-of-Health (SoH)

SoH is estimated by tracking:

- **Impedance Growth:** The universal indicator of aging (SEI growth in Li-Ion, Sulfation in Pb-Acid).
- **Capacity Fade:** Effective energy storage reduction.

These parameters are not just reported.
They are **actively injected back into the SoC estimation loop**, allowing the universal model to "learn" the specific battery it is managing.

---

## Why FPGA?

Microcontroller-based implementations suffer from:

- Sequential execution latency
- Difficulty handling multiple time-domains (fast current vs. slow aging)
- Rigid software that requires recompilation for new batteries

FPGA enables:

- **Parallel Execution:** Run the EKF and SoH observer simultaneously.
- **Reconfigurability:** Store battery parameters in registers/BRAM, allowing "hot-swapping" of profiles.
- **Timing Determinism:** Critical for safety standards (ISO 26262).

This design treats estimation as a **configurable hardware engine**, not a static software routine.

---

> **Key principle:**
> The math is universal.
> Only the parameters change.

---

## Implementation Flow

1. **Golden Model Development (MATLAB / Simulink)**
   - "Twin-Plant" modeling (Li-Ion & Pb-Acid)
   - Validation of the generic algorithm across both chemistries
   - Generation of distinct test vectors

2. **Fixed-Point Validation**
   - Adoption of **Q8.8 Format** (Range: 0–255V) for universal voltage support
   - Quantization noise analysis for flat-curve (Li-Ion) detection

3. **RTL Development (Verilog HDL)**
   - Modular `lut_manager` for OCV curve selection
   - Parameter-driven `coulomb_counter`
   - Generic `matrix_math` engine

4. **Verification**
   - Multi-scenario simulation (Scenario A: Li-Ion DST, Scenario B: Pb-Acid Discharge)
   - RMSE comparison against the Universal Golden Model

5. **FPGA Synthesis**
   - Resource utilization analysis (LUTs/DSPs)
   - Timing closure for automotive clock speeds

---

## Design Philosophy

- Flexibility over rigidity.
- Stability over mathematical elegance.
- Fixed-point first, floating-point only as reference.
- Every register must serve the universal purpose.
- If a block cannot handle a parameter change, it is not robust enough.

---

## Intended Applications

- Hybrid Energy Storage Systems (HESS)
- Automotive BMS (EV and SLI Batteries)
- Retrofit Monitoring Systems for Legacy Infrastructure

---

## What This Project Is Not

- Not a single-chemistry optimization.
- Not a black-box AI model.
- Not a software tutorial.

This design prioritizes **adaptability and correctness across any battery's lifecycle.**

---

## Closing Note

Most systems estimate SoC and hope the battery matches the code.

This one adjusts the code to match the battery.

That difference is the entire point.
