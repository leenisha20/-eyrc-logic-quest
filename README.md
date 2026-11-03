# e-Yantra Logic Quest (eYRC 2026-27)

Verilog designs for FPGA, written for the e-Yantra Robotics Competition, Logic Quest theme. Tasks 1a, 1b, 1c, 2a and 2b were designed and implemented by me. The Quartus projects target Intel FPGAs.

## Tasks

| Folder | Task | Contents |
|---|---|---|
| `task1a_fs_pwm/` | 1a | PWM generator with frequency scaling (`pwm_generator.v`, `frequency_scaling.v`, top-level block design) |
| `task1b_riscv_cpu/` | 1b | RISC-V CPU project |
| `task1c_riscv_cpu/` | 1c | RISC-V CPU project |
| `task2a_spi/` | 2a | SPI interface (`t2a_spi.v`) |
| `task2b_pl_riscv_cpu/` | 2b | RISC-V CPU with instruction and data memory, an RV32I test program (`rv32i_test.s`, `rv32i_test.hex`) and an architecture diagram (`assets/architecture.pdf`) |

## Repository layout
Each folder contains:
- `code/` Verilog source files
- `.qpf` and `.qsf` Quartus project and settings files

## How to open a task
1. Install Intel Quartus Prime.
2. Open the `.qpf` file in the task folder.
3. Compile the project and run the simulation from Quartus.

Quartus build output (`db/`, `incremental_db/`, `output_files/`) is not included because it is regenerated when the project is compiled.

## Related project
[cordic-verilog](https://github.com/leenisha20/cordic-verilog): a fixed-point CORDIC core in Verilog (sin, cos, magnitude and angle) with self-checking tests.
