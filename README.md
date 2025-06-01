# RAM-Bubble-sort
RAM with bubble sort designed and verified in VHDL.

---
## About
- RAM with configurable depth and data width.
- User can write to RAM when internal signal 'rdy' is high (bubble sort is not active), but
when sorting is being performed 'im_block' is writing to RAM.
- Counter 'p' tracks the current number of locations occupied in RAM.

---
## VHDL Simulation Screenshots
Before sorting
<div align="center"> <img src="/bubble_sort_simulation_results/vivado_wavefrom_before_sorting.png"> </div>
After sorting
<div align="center"> <img src="/bubble_sort_simulation_results/vivado_wavefrom_after_sorting.png"> </div>
