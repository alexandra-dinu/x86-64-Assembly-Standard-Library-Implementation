# x86-64 Assembly Standard Library Implementation 

## Overview
This repository contains a collection of low-level system utilities, data structures, and algorithms implemented entirely in **x86-64 Assembly (NASM)**. 

The project bypasses high-level language abstractions to interact directly with memory and CPU registers. It demonstrates strict adherence to the **System V AMD64 ABI**, manual stack frame management, dynamic heap allocation, and bitwise hardware-level data manipulation.

## Core Features & Architecture

### 1. Custom Variadic `printf` Implementation (`my_printf.asm`)
An implementation of the standard C `printf` function, relying only on the external `putc` system call.
*   **Variadic Argument Handling:** Manually parses format strings (`%s`, `%c`, `%lu`) and dynamically retrieves arguments from CPU registers (RSI, RDX, RCX, R8, R9).
*   **Deep Stack Frame Navigation:** For variable arguments exceeding the 6-register calling convention limit, the function dynamically calculates stack offsets (e.g., `[rbp + (index-5) * 8 + 16]`) to retrieve data directly from the caller's stack frame.
*   **In-Place Integer to String Conversion:** Implements native integer-to-ASCII conversion utilizing repeated division (`div`) and raw stack buffer manipulation.

### 2. Dynamic Memory Vector (`my_vector.asm`)
A dynamically resizing, heap-allocated array (similar to `std::vector` in C++), implemented completely in assembly.
*   **Heap Management:** Directly interfaces with `malloc`, `realloc`, and `free` to manage dynamic memory blocks.
*   **Algorithmic Resizing:** Automatically scales memory capacity up (x2) or down (x0.5) based on real-time data ingestion, strictly enforcing 4-byte (32-bit integer) alignment architectures.
*   **Memory Safety:** Integrates strict bounds checking for pointer arithmetic to prevent segmentation faults during arbitrary read/write access (`set_element`, `get_element`).

### 3. Native Stack Calculator / RPN Evaluator (`reverse_polish_notation.asm`)
An algorithm that parses and evaluates Reverse Polish Notation (postfix) expressions.
*   **Hardware Stack Utilization:** Bypasses software arrays by utilizing a custom `.bss` section stack (`resq 128`) to push and pop operands during string parsing.
*   **64-bit ALU Operations:** Executes native `idiv`, `imul`, `add`, and `sub` directly on the registers for 64-bit integer processing.

### 4. Firmware-Level Bitwise Operations (`firmware_utils.asm`)
Functions mimicking embedded firmware routines for raw hardware sensor data decoding.
*   **Bitwise Data Extraction:** Validates the Most Significant Bit (MSB), extracts isolated bytes using bit shifts (`shr`), applies bitmasks (`and 0xFF`), and concatenates them back into 16-bit payload registers using logical OR operations.
*   **Memory Flattening:** Traverses simulated 2D matrix arrays mapped in contiguous 1D memory spaces using CPU-optimized `i * n + j` pointer arithmetic.

### 4. Recursive Backtracking in Native Assembly (`langford.asm`)
A complete implementation of a recursive backtracking algorithm used to generate Langford Sequences, proving advanced control over the CPU's call stack.
*   **Manual Stack Frame Management:** Handles deep recursion natively by strictly preserving callee-saved registers (`r12`-`r15`, `rbx`) across nested `call` instructions, preventing state corruption during the backtracking unwinding phase.
*   **Dynamic Memory Matrix Generation:** Dynamically allocates multi-dimensional result arrays on the heap at runtime based on the sequence order $n$, strictly enforcing memory deallocation upon algorithm completion.
*   **Assembly-Level Custom Sorting:** Interfaces seamlessly with the standard C library's `qsort` by passing a native Assembly function pointer (`lea rcx, [rel compare]`) to lexicographically sort the dynamically generated multidimensional arrays.

## Build & Run Instructions

This project is built using `nasm` and linked via `gcc`. A standard `Makefile` is provided.

**Dependencies:**
*   `nasm` (Netwide Assembler)
*   `gcc` (GNU Compiler Collection for linking standard libraries like `malloc` and `putc`)

**Build the executable:**
```bash
make
```

## Usage as a Static Library

This repository is designed as a standalone system library rather than an executable application. Running `make` compiles the assembly files and archives them into a static library (`libasmutils.a`).

To use these utilities in your own C/C++ projects, link the compiled static library against your source code.

**Example `main.c` integration:**
```c
#include <stdio.h>

// External declarations for the assembly routines
extern int my_printf(const char *format, ...);
extern void heavy(int number);

int main() {
    // Calling the custom variadic printf implemented in my_printf.asm
    my_printf("Testing ASM printf: String -> %s, Number -> %lu\n", "Hello System!", 4096);
    
    // Testing the bitwise MSB extraction from firmware_utils.asm
    heavy(0x80000100); 

    return 0;
}