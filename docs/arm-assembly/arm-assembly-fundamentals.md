# ARM Assembly: Fundamentals

These notes follow the [Olive Stem ARM Assembly tutorial series](https://www.youtube.com/watch?v=in-UY_EyI14&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn) on YouTube (tutorials 1-5). They're designed as a quick-review reference with runnable code examples.

!!! tip "Try it yourself"
    Open the [ARM Emulator](https://cpulator.01xz.net/?sys=arm-de1soc) and paste any code example below to run it.

---

## 1. Your First Program

[:material-youtube: Watch Tutorial 1](https://www.youtube.com/watch?v=in-UY_EyI14&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn){ .md-button }

Every ARM assembly program needs a **`_start` label** — this is where execution begins. The `.global` directive makes `_start` visible to the linker so it knows where to begin. This is analogous to `int main()` in C: the linker needs an entry point, and `.global _start` is how you provide one.

```asm
.global _start
_start:
    MOV R0, #30      @ Load the value 30 into register R0

    MOV R7, #1       @ Syscall number 1 = exit
    SWI 0            @ Trigger the syscall (Software Interrupt)
```

**What's happening:**

| Instruction | Meaning |
|-------------|---------|
| `.global _start` | Export `_start` so the linker can find the entry point |
| `_start:` | Label marking where execution begins |
| `MOV R0, #30` | Move the immediate value 30 into register R0 |
| `MOV R7, #1` | Load syscall number 1 (exit) into R7 |
| `SWI 0` | Execute the syscall — program exits with code 30 |

!!! note "Why `SWI 0`?"
    ARM uses software interrupts to make system calls. `R7` holds the syscall number (1 = exit), and `R0` holds the return value. This is how your assembly program talks to the operating system.

**Try it:** Change `#30` to a different value and check the exit code. In the emulator, step through each instruction and watch the registers update.

---

## 2. Memory & Addressing Modes

[:material-youtube: Watch Tutorial 2](https://www.youtube.com/watch?v=3ZXfWYQSulA&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=3){ .md-button }

ARM is a **load/store architecture** — you can't operate on memory directly. You must first load data into registers, work on it, then store it back. The `LDR` instruction is how you get data from memory into a register.

### The `.data` Section

The `.data` section holds your program's variables and constants. The `.word` directive allocates 32-bit integers in memory, stored sequentially.

### Addressing Modes

```asm
.global _start

_start:
    LDR R0, =list       @ R0 = address of 'list' (pointer to the array)

    LDR R1, [R0]        @ R1 = *R0 (load value at address in R0)

    LDR R2, [R0, #4]    @ R2 = *(R0 + 4) (offset: skip 4 bytes = 1 word)

    LDR R3, [R0, #4]!   @ Pre-increment: R0 += 4, then R3 = *R0

    LDR R0, =list       @ Reset R0 to start of list

    LDR R4, [R0], #4    @ Post-increment: R4 = *R0, then R0 += 4

    MOV R7, #1
    SWI 0

.data
list:
    .word 4, 5, -9, 1, 0, 2, -3
```

### Addressing Modes Summary

| Mode | Syntax | Effect | C Equivalent |
|------|--------|--------|-------------|
| **Register indirect** | `[R0]` | Load from address in R0 | `*ptr` |
| **Offset** | `[R0, #4]` | Load from R0 + 4 (R0 unchanged) | `*(ptr + 1)` |
| **Pre-increment** | `[R0, #4]!` | R0 += 4, then load from R0 | `*++ptr` |
| **Post-increment** | `[R0], #4` | Load from R0, then R0 += 4 | `*ptr++` |

!!! note "Why offsets are multiples of 4"
    Each `.word` is 32 bits = 4 bytes. To access the second element, offset by 4. Third element: offset by 8. This is just like pointer arithmetic in C where `ptr + 1` on an `int*` advances by `sizeof(int)`.

**Try it:** Step through the code in the emulator. After each `LDR`, check both the destination register and R0 — notice how pre-increment and post-increment change R0 at different times.

---

## 3. Arithmetic & CPSR Flags

[:material-youtube: Watch Tutorial 3](https://www.youtube.com/watch?v=CG2UZGFhXLo&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=4){ .md-button }

ARM has two versions of arithmetic instructions: with and without the **`S` suffix**. The `S` suffix tells the CPU to update the **CPSR** (Current Program Status Register) flags based on the result. Without `S`, the flags are untouched.

```asm
.global _start
_start:
    MOV R0, #5
    MOV R1, #7

    ADD R2, R0, R1       @ R2 = R0 + R1 = 12. No flags updated.

    SUBS R2, R0, R1      @ R2 = R0 - R1 = -2. Flags updated!
                         @ N flag set (result is negative)

    ADDS R3, R2, R2      @ R3 = R2 + R2 = -4. Flags updated!
                         @ Check V flag for signed overflow
```

### CPSR Flags

| Flag | Name | Set When |
|------|------|----------|
| **N** | Negative | Result is negative (bit 31 = 1) |
| **Z** | Zero | Result is exactly zero |
| **C** | Carry | Unsigned operation overflowed (carry out of bit 31) |
| **V** | Overflow | Signed operation overflowed (result doesn't fit in 32 bits) |

!!! warning "ADD vs ADDS"
    `ADD` performs addition but **does not** update flags. `ADDS` performs the same addition **and** updates flags. This matters because branching instructions (covered in Part 2) check these flags. If you forget the `S`, your branches won't work as expected.

**Try it:** Run the code and inspect the CPSR register after each instruction. Try `SUBS R2, R0, R0` — you should see the Z flag set.

---

## 4. Logical Operations

[:material-youtube: Watch Tutorial 4](https://www.youtube.com/watch?v=Zyulp52YFm0&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=5){ .md-button }

Bitwise operations work on individual bits of a value. These are essential for working with hardware registers, flags, and bit manipulation.

```asm
.global _start
_start:
    MOV R0, #0xFF         @ R0 = 0xFF (binary: 11111111)
    MOV R1, #22           @ R1 = 22  (binary: 00010110)

    AND R2, R1, R0        @ Bitwise AND: keep bits that are 1 in both
    ORR R3, R1, R0        @ Bitwise OR: set bits that are 1 in either
    EOR R4, R1, R0        @ Exclusive OR: set bits that differ

    MVN R0, R0            @ Move Negation: flip all bits (~R0)
    AND R0, R0, #0x000000FF   @ Bit mask: keep only lowest 8 bits
```

### Logical Operations Truth Table

| A | B | AND | ORR | EOR |
|---|---|-----|-----|-----|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 | 1 |
| 1 | 0 | 0 | 1 | 1 |
| 1 | 1 | 1 | 1 | 0 |

!!! tip "Bit Masking Pattern"
    `AND` with a mask keeps only the bits you want. For example, `AND R0, R0, #0xFF` zeroes out everything except the lowest 8 bits. This is how you extract specific fields from a hardware register or protocol word — the same idea as `value & 0xFF` in C.

**Try it:** Change `R1` to different values and predict the results of each operation before stepping through. Verify `MVN` flips every bit.

---

## 5. Shifts & Rotations

[:material-youtube: Watch Tutorial 5](https://www.youtube.com/watch?v=cye4fDE1czY&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=7){ .md-button }

Shifting bits left or right is equivalent to multiplying or dividing by powers of 2 — and it's much faster than actual multiplication.

```asm
.global _start
_start:
    @ Simple shifts
    MOV R0, #10          @ R0 = 10 (binary: 1010)
    LSL R0, #1           @ Shift left by 1 = multiply by 2. R0 = 20
    LSR R0, #2           @ Shift right by 2 = divide by 4. R0 = 5

    @ Move and shift (preserves original)
    MOV R1, #10          @ R1 = 10
    MOV R2, R1, LSL #1   @ R2 = R1 << 1 = 20 (R1 stays 10)

    @ Rotation vs shift
    MOV R3, #15          @ R3 = 15 (binary: ...0000 1111)
    ROR R3, #1           @ Rotate right: bits wrap around
                         @ Result: 0x80000007 (MSB gets the shifted-out bit)

    MOV R4, #15          @ R4 = 15
    LSR R4, #1           @ Logical shift right: bits fall off
                         @ Result: 0x00000007 (shifted-out bit is lost)
```

### Final Register Values

| Register | Value | Explanation |
|----------|-------|-------------|
| R0 | `0x00000005` | 10 << 1 = 20, then 20 >> 2 = 5 |
| R1 | `0x0000000A` | Unchanged (10) |
| R2 | `0x00000014` | 10 << 1 = 20 |
| R3 | `0x80000007` | 15 rotated right 1 — bit wraps to MSB |
| R4 | `0x00000007` | 15 shifted right 1 — bit lost |

### Shifts vs Rotation

| Operation | What Happens to Shifted-Out Bits | Use Case |
|-----------|----------------------------------|----------|
| `LSL #n` | Discarded (zeros fill from right) | Multiply by 2^n |
| `LSR #n` | Discarded (zeros fill from left) | Unsigned divide by 2^n |
| `ROR #n` | Wrap around to the other side | Cryptography, checksums |

!!! note "No ROL instruction"
    ARM has `ROR` (rotate right) but no rotate-left instruction. This is intentional — to minimize the instruction set. You can achieve a left rotation by rotating right by (32 - n). For example, rotating left by 4 is the same as `ROR #28`.

**Try it:** Experiment with `ROR` on different values. Watch how bits that "fall off" the right side reappear on the left — like pac-man wrapping around the screen.

---

## 6. Quick Reference

### Instructions Covered

| Instruction | Syntax | Description |
|------------|--------|-------------|
| `MOV` | `MOV Rd, #imm` / `MOV Rd, Rs` | Move value into register |
| `LDR` | `LDR Rd, =label` | Load address of label into register |
| `LDR` | `LDR Rd, [Rn]` | Load value from memory address |
| `LDR` | `LDR Rd, [Rn, #off]` | Load with offset |
| `LDR` | `LDR Rd, [Rn, #off]!` | Load with pre-increment |
| `LDR` | `LDR Rd, [Rn], #off` | Load with post-increment |
| `ADD` | `ADD Rd, Rn, Rm` | Rd = Rn + Rm |
| `SUB` | `SUB Rd, Rn, Rm` | Rd = Rn - Rm |
| `AND` | `AND Rd, Rn, Rm` | Bitwise AND |
| `ORR` | `ORR Rd, Rn, Rm` | Bitwise OR |
| `EOR` | `EOR Rd, Rn, Rm` | Bitwise XOR |
| `MVN` | `MVN Rd, Rs` | Bitwise NOT (move negated) |
| `LSL` | `LSL Rd, #n` | Logical shift left (multiply by 2^n) |
| `LSR` | `LSR Rd, #n` | Logical shift right (divide by 2^n) |
| `ROR` | `ROR Rd, #n` | Rotate right |
| `SWI` | `SWI 0` | Software interrupt (syscall) |

### Key Concepts

| Concept | Meaning |
|---------|---------|
| `.global _start` | Makes entry point visible to linker |
| `.data` | Section for variables and constants |
| `.word` | Allocates 32-bit integers |
| `S` suffix | Updates CPSR flags (e.g., `ADDS`, `SUBS`) |
| CPSR | Holds N, Z, C, V flags after `S`-suffixed instructions |

### Resources

- [ARM Emulator (CPUlator)](https://cpulator.01xz.net/?sys=arm-de1soc)
- [Azeria Labs — Writing ARM Assembly](https://azeria-labs.com/writing-arm-assembly-part-1/)
- [ARM ASM Basics](https://armasm.com/docs/getting-to-hello-world/basics/)
