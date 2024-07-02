Computer Organization - Spring 2024

==============================================================

## Iran Univeristy of Science and Technology

## Assignment 1: Assembly code execution on phoeniX RISC-V core

- Name:Amir Mohammad Emam

- Team Members:
  Sara Dadkhoo : 400412058
  Matin Rahmati :400412157

- Student ID:400411144

- Date:1403/04/12

## Report

    *                *********** Second Project ***********                *

-                *********** Assembly.s ***********                *

### Initialization

1. `li sp, 0x3C00`

   - Load the immediate value 0x3C00 into the stack pointer register sp.

2. `addi gp, sp, 392`

   - Add the immediate value 392 to the stack pointer (`sp`) and store the result in the global pointer register gp.

### Loop

The loop label marks the beginning of a loop. The code in this loop performs operations on floating-point numbers.

3. `flw f1, 0(sp)`

   - Load the word from the address in sp (stack pointer) into the floating-point register f1.

4. `flw f2, 4(sp)`

   - Load the word from the address sp + 4 into the floating-point register f2.

5. `fmul.s f10, f1, f1`

   - Multiply the floating-point value in f1 with itself and store the result in f10.

6. `fmul.s f20, f2, f2`

   - Multiply the floating-point value in f2 with itself and store the result in f20.

7. `fadd.s f30, f10, f20`

   - Add the values in f10 and f20 and store the result in f30.

8. `fsqrt.s x3, f30`

   - Compute the square root of the value in f30 and store the result in the integer register x3.

9. `fadd.s f0, f0, f3`

   - Add the value in f3 to f0 and store the result in f0.

10. `addi sp, sp, 8`

    - Increment the stack pointer by 8.

11. `blt sp, gp, loop`

    - Compare sp with gp. If sp is less than gp, branch to the label loop.

### End of Program

12. `ebreak`

    - This is a breakpoint instruction used to halt execution, usually for debugging purposes.

-                *********** Fixed_point_Unit.v ***********                *

### 1. Fixed_Point_Unit Module

This is the main module responsible for executing various operations. The inputs include clock signal (`clk`), reset signal (`reset`), two operands (`operand_1` and `operand_2`), and the operation type (`operation`). The outputs include the result of the operation (`result`) and a signal indicating the result is ready (`ready`).

The operations handled are:

- Addition (`FPU_ADD`)
- Subtraction (`FPU_SUB`)
- Multiplication (`FPU_MUL`)
- Square root (`FPU_SQRT`)

### 2. Square Root Circuit

This circuit calculates the square root of a fixed-point number using a state machine. The state machine has two main states: INITIAL for initialization and SQRT for performing the square root calculations. Internal variables such as root, root_ready, radic, aux_root, aux_result, f_result, iteration, and state1 are used to manage the computations.

### 3. Multiplier Circuit

This circuit is designed to perform multiplication of two fixed-point numbers. It includes internal variables and signals for storing intermediate and final results of the multiplication. The state machine manages the stages of multiplication, including states like INITIALSTATE, FIRSTMUL, SECONDMUL, THIRDMUL, FOURTHMUL, and ADD.

### Multiplier Module

This is a simple multiplier module that performs multiplication between two 16-bit numbers and produces a 32-bit result. The inputs are two 16-bit operands (`operand_1` and `operand_2`), and the output is the 32-bit product (`product`).

These components work together to form a comprehensive and efficient arithmetic unit for fixed-point numbers capable of performing various mathematical operations.
