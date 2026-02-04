# ARM Assembly: Control Flow & Functions

Continuing the [Olive Stem ARM Assembly tutorial series](https://www.youtube.com/watch?v=in-UY_EyI14&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn) (tutorials 6-10), covering branching, loops, conditional execution, functions, and the stack.

!!! tip "Try it yourself"
    Open the [ARM Emulator](https://cpulator.01xz.net/?sys=arm-de1soc) and paste any code example below to run it.

---

## 1. Comparisons & Branching

[:material-youtube: Watch Tutorial 6](https://www.youtube.com/watch?v=CStAFC2yTMo&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=8){ .md-button }

`CMP` compares two values by subtracting them and setting the CPSR flags — but it **discards the result**. Branch instructions then check those flags to decide whether to jump.

```asm
.global _start
_start:
    MOV R0, #1
    MOV R1, #2

    CMP R0, R1           @ Computes R0 - R1, sets flags, discards result

    BGT greater          @ Branch if R0 > R1 (signed: Z=0 and N=V)

    BAL default          @ Branch always (unconditional jump)

greater:
    MOV R2, #1

default:
    MOV R2, #2
```

This is the ARM equivalent of an if/else in C:

```c
// C equivalent
if (R0 > R1) {
    R2 = 1;       // greater
} else {
    R2 = 2;       // default
}
```

### Branch Conditions

| Instruction | Meaning | Flags Checked | C Equivalent |
|-------------|---------|---------------|--------------|
| `BGT` | Branch if Greater Than | Z=0 and N=V | `if (a > b)` |
| `BGE` | Branch if Greater or Equal | N=V | `if (a >= b)` |
| `BLT` | Branch if Less Than | N!=V | `if (a < b)` |
| `BLE` | Branch if Less or Equal | Z=1 or N!=V | `if (a <= b)` |
| `BEQ` | Branch if Equal | Z=1 | `if (a == b)` |
| `BNE` | Branch if Not Equal | Z=0 | `if (a != b)` |
| `BAL` | Branch Always | (none) | `goto label` |

!!! note "CMP is just subtraction"
    `CMP R0, R1` is identical to `SUBS`, except the result is thrown away. Only the flags matter. This is why you need the `S` suffix on arithmetic instructions if you want to branch based on results — without flags, branches have nothing to check.

**Try it:** Change the values of R0 and R1 and predict which branch will be taken. Verify in the emulator by stepping through.

---

## 2. Loops

[:material-youtube: Watch Tutorial 7](https://www.youtube.com/watch?v=ftyEZDMWdVE&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=9){ .md-button }

Loops in assembly are just branches that jump backwards. The pattern is: do work, check a condition, branch back to the top if not done.

### Example: Summing a List

Here are three versions of the same program, each handling the end-of-list check differently.

#### Version 1 — Using `.equ` constant and explicit endlist in memory

```asm
.global _start
.equ endlist_value, 0xaaaaaaaa   @ Define a constant for end-of-list marker

_start:
    LDR R0, =list          @ R0 = pointer to start of list
    LDR R3, =endlist        @ R3 = pointer to endlist marker in memory
    LDR R3, [R3]            @ R3 = value of endlist marker (0xaaaaaaaa)
    LDR R1, [R0]            @ R1 = first element
    MOV R2, #0              @ R2 = sum (initialized to 0)
    ADD R2, R2, R1          @ Add first element to sum

loop:
    LDR R1, [R0, #4]!      @ Advance pointer, load next element
    CMP R1, R3              @ Is it the end marker?
    BEQ exit                @ If yes, we're done
    ADD R2, R2, R1          @ Otherwise, add to sum
    BAL loop                @ Repeat

exit:

.data
list:
    .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

endlist:
    .word endlist_value     @ End marker stored in memory
```

#### Version 2 — Using `.equ` directly (no endlist in .data)

```asm
.global _start
.equ endlist, 0xaaaaaaaa    @ End marker as assembler constant

_start:
    LDR R0, =list
    LDR R3, =endlist        @ R3 = 0xaaaaaaaa (loaded directly)
    LDR R1, [R0]
    ADD R2, R2, R1

loop:
    LDR R1, [R0, #4]!
    CMP R1, R3
    BEQ exit
    ADD R2, R2, R1
    BAL loop

exit:

.data
list:
    .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
```

#### Version 3 — Endlist explicitly in memory (no `.equ`)

```asm
.global _start

_start:
    LDR R0, =list
    LDR R3, =endlist        @ R3 = address of endlist
    LDR R3, [R3]            @ R3 = value at endlist (0xaaaaaaaa)
    LDR R1, [R0]
    MOV R2, #0
    ADD R2, R2, R1

loop:
    LDR R1, [R0, #4]!
    CMP R1, R3
    BEQ exit
    ADD R2, R2, R1
    BAL loop

exit:

.data
list:
    .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

endlist:
    .word 0xaaaaaaaa
```

### The Loop Pattern

All three versions follow the same structure, which maps to a C `while` loop:

```c
// C equivalent
int list[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
int sum = 0;
int *ptr = list;
while (*ptr != SENTINEL) {
    sum += *ptr;
    ptr++;
}
```

!!! note "Sentinel values"
    The value `0xAAAAAAAA` is used as an end-of-list sentinel because uninitialized memory in the emulator defaults to this value. In a real program, you'd typically use the list length instead. The `.equ` directive creates a named constant at assembly time — similar to `#define` in C.

**Try it:** Add more numbers to the list and verify the sum in R2. Try removing the endlist marker — what happens?

---

## 3. Conditional Execution

[:material-youtube: Watch Tutorial 8](https://www.youtube.com/watch?v=FLBUMMPPcvA&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=10){ .md-button }

ARM has a feature that most architectures don't: you can make **any instruction** conditional by adding a condition suffix. This avoids the overhead of branching for simple if/else logic.

### The Old Way (with branches)

```asm
.global _start
_start:
    MOV R0, #2
    MOV R1, #4
    CMP R0, R1

    BLT addR2            @ Branch if R0 < R1
    BAL exit

addR2:
    ADD R2, #1

exit:
```

### The Better Way (conditional execution)

```asm
.global _start
_start:
    MOV R0, #2
    MOV R1, #4
    CMP R0, R1

    ADDLT R2, #1         @ Add 1 to R2 ONLY IF R0 < R1
```

### Another Example

```asm
.global _start
_start:
    MOV R0, #6
    MOV R1, #4
    CMP R0, R1

    MOVGE R2, #5         @ Move 5 into R2 ONLY IF R0 >= R1
```

### Why ARM Can Do This

Every ARM instruction has a 4-bit condition field in its encoding. This is called **predicated execution**. Instead of branching (which flushes the pipeline and costs cycles), the CPU simply skips the instruction if the condition isn't met. For short if/else blocks, this is more efficient.

| Suffix | Meaning | Example |
|--------|---------|---------|
| `LT` | Less than | `ADDLT R2, #1` — add only if less than |
| `GE` | Greater or equal | `MOVGE R2, #5` — move only if greater or equal |
| `EQ` | Equal | `MOVEQ R2, #0` — move only if equal |
| `NE` | Not equal | `ADDNE R3, R3, #1` — add only if not equal |
| `GT` | Greater than | `SUBGT R4, R4, #1` — subtract only if greater |
| `LE` | Less or equal | `MOVLE R5, #0` — move only if less or equal |

!!! tip "When to use conditional execution vs branches"
    Use conditional suffixes for **1-2 instructions** (simple if/else). Use branches for **longer blocks** or loops. Conditional execution saves pipeline flushes but clutters the code if overused.

**Try it:** Rewrite the "old way" example using conditional execution. Then try the reverse: implement `MOVGE` using branches instead.

---

## 4. Functions & the Link Register

[:material-youtube: Watch Tutorial 9](https://www.youtube.com/watch?v=Hr2qYfq3sTo&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=11){ .md-button }

`BL` (Branch with Link) is how you call a function. It works like `BAL` (branch always) but also saves the **return address** in the **Link Register (LR)**. The function returns by branching back to LR with `BX LR`.

```asm
.global _start
_start:
    MOV R0, #1
    MOV R1, #3
    BL add2              @ Call function: saves return address in LR

    MOV R3, #4           @ This executes AFTER add2 returns

add2:
    ADD R2, R0, R1       @ R2 = R0 + R1 = 4
    BX LR                @ Return to caller (address stored in LR)
```

### How It Maps to C

```c
// C equivalent
int add2(int a, int b) {
    return a + b;
}

int main() {
    int result = add2(1, 3);  // BL add2
    int x = 4;                // MOV R3, #4
}
```

| ARM | x86 | Meaning |
|-----|-----|---------|
| `BL label` | `CALL label` | Call function, save return address |
| `BX LR` | `RET` | Return to caller |
| `LR` (R14) | Stack | Where the return address is stored |

!!! warning "LR gets overwritten"
    If your function calls another function with `BL`, the second `BL` overwrites LR. You'll lose your return address! The solution: save LR to the stack before making nested calls (covered in the next section).

**Try it:** Step through the code and watch LR update when `BL` executes. Note the address it stores — it's the instruction right after `BL`.

---

## 5. Stack Memory

[:material-youtube: Watch Tutorial 10](https://www.youtube.com/watch?v=nixhFJJY4_Y&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=12){ .md-button }

The stack is how you preserve register values across function calls. `PUSH` saves registers onto the stack (decrements SP), and `POP` restores them (increments SP). The stack **grows downward** — pushing moves SP to a lower address.

```asm
.global _start
_start:
    MOV R0, #1           @ R0 = 1
    MOV R1, #3           @ R1 = 3

    PUSH {R0, R1}        @ Save R0 and R1 onto the stack

    BL get_value          @ Call function (overwrites R0, R1)

    POP {R0, R1}         @ Restore original R0 and R1

    B end                @ Jump to end

get_value:
    MOV R0, #5           @ R0 = 5 (overwrites the caller's value)
    MOV R1, #7           @ R1 = 7
    ADD R2, R0, R1       @ R2 = 12 (this is the "return value")
    BX LR                @ Return to caller

end:
```

### What Happens Step by Step

| Step | SP | R0 | R1 | R2 | Stack Contents |
|------|----|----|----|----|----------------|
| After MOV instructions | 0 | 1 | 3 | 0 | (empty) |
| After PUSH | SP-8 | 1 | 3 | 0 | [R0=1, R1=3] |
| Inside get_value | SP-8 | 5 | 7 | 12 | [R0=1, R1=3] |
| After POP | 0 | 1 | 3 | 12 | (stale data remains) |

### The Full Function Call Pattern

This is the standard pattern for calling functions in ARM — and it's essentially what the C compiler generates:

```asm
@ Caller side:
PUSH {R0, R1}        @ 1. Save registers you need to preserve
BL function           @ 2. Call function (sets LR)
POP {R0, R1}         @ 3. Restore registers after function returns

@ Function side:
function:
    PUSH {LR}        @ Save return address (if making nested calls)
    @ ... do work ...
    POP {LR}         @ Restore return address
    BX LR            @ Return to caller
```

!!! note "C calling convention connection"
    In the ARM calling convention (AAPCS), R0-R3 are used for passing arguments and return values, while R4-R11 are "callee-saved" — if a function uses them, it must PUSH them first and POP them before returning. This is exactly the pattern above, just standardized.

**Try it:** Step through the code and watch the Stack Pointer (SP) change. After `PUSH`, check the memory at the SP address — you'll see R0 and R1's values stored there. After `POP`, note that the old data is still in memory — it's just considered "garbage" now.

---

## 6. Going Further

These tutorials continue the series but don't have detailed notes yet. Watch the videos to explore these topics.

### Tutorial 11 — Hardware Interactions

[:material-youtube: Watch Tutorial 11](https://www.youtube.com/watch?v=pgRuvOhZ3xM&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=13){ .md-button }

Interacting with hardware peripherals through memory-mapped I/O.

---

### Tutorial 12 — Setting up QEMU for ARM

[:material-youtube: Watch Tutorial 12](https://www.youtube.com/watch?v=WubAuz4hPpY&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=14){ .md-button }

Running ARM assembly on your local machine using QEMU emulation.

---

### Tutorial 13 — Printing Strings to Terminal

[:material-youtube: Watch Tutorial 13](https://www.youtube.com/watch?v=hvJhtql7Yyo&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=15){ .md-button }

Using syscalls to output strings — the ARM equivalent of `printf`.

---

### Tutorial 14 — Debugging with GDB

[:material-youtube: Watch Tutorial 14](https://www.youtube.com/watch?v=lOA3S1ZgG2I&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn&index=16){ .md-button }

Setting breakpoints, inspecting registers, and stepping through ARM assembly with GDB.

---

## 7. Quick Reference

### Condition Codes

| Suffix | Meaning | Flags | Signed/Unsigned |
|--------|---------|-------|-----------------|
| `EQ` | Equal | Z=1 | Either |
| `NE` | Not equal | Z=0 | Either |
| `GT` | Greater than | Z=0, N=V | Signed |
| `GE` | Greater or equal | N=V | Signed |
| `LT` | Less than | N!=V | Signed |
| `LE` | Less or equal | Z=1 or N!=V | Signed |
| `HI` | Higher | C=1, Z=0 | Unsigned |
| `LS` | Lower or same | C=0 or Z=1 | Unsigned |
| `AL` | Always | (none) | Either |

### Common Patterns

**If/else:**
```asm
    CMP R0, R1
    BGT if_true
    @ else block
    BAL end_if
if_true:
    @ if block
end_if:
```

**Loop (while-style):**
```asm
loop:
    @ ... do work ...
    CMP R0, R1
    BNE loop             @ Keep looping if not equal
```

**Function call with register preservation:**
```asm
    PUSH {R4-R6, LR}    @ Save callee-saved registers and return address
    @ ... function body ...
    POP {R4-R6, LR}     @ Restore everything
    BX LR                @ Return
```

### Instructions Covered in Part 2

| Instruction | Syntax | Description |
|------------|--------|-------------|
| `CMP` | `CMP Rn, Rm` | Compare (subtract without storing result) |
| `B` | `B label` | Unconditional branch |
| `BAL` | `BAL label` | Branch always (same as B) |
| `BEQ` | `BEQ label` | Branch if equal |
| `BNE` | `BNE label` | Branch if not equal |
| `BGT` | `BGT label` | Branch if greater than |
| `BGE` | `BGE label` | Branch if greater or equal |
| `BLT` | `BLT label` | Branch if less than |
| `BLE` | `BLE label` | Branch if less or equal |
| `BL` | `BL label` | Branch with link (function call) |
| `BX` | `BX LR` | Branch to address in register (return) |
| `PUSH` | `PUSH {R0, R1}` | Save registers to stack |
| `POP` | `POP {R0, R1}` | Restore registers from stack |

### Resources

- [ARM Emulator (CPUlator)](https://cpulator.01xz.net/?sys=arm-de1soc)
- [Azeria Labs — Writing ARM Assembly](https://azeria-labs.com/writing-arm-assembly-part-1/)
- [ARM ASM Basics](https://armasm.com/docs/getting-to-hello-world/basics/)
- [Olive Stem YouTube Playlist](https://www.youtube.com/watch?v=in-UY_EyI14&list=PL2EF13wm-hWAlQe87UB2HV0SVhBXFpXbn)
