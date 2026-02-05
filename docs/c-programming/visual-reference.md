# Visual Reference: C, Assembly & How Computers Work

MCU-first mental models, with RTOS and Linux as extensions of the same ideas. Each diagram teaches one core insight.

---

## The One Mental Model (start here)

```
C PROGRAM
    │
    ▼
ASSEMBLY  →  REGISTERS  →  STACK / HEAP / DATA
    │
    ▼
LINKER  →  FLASH + RAM LAYOUT
    │
    ▼
BARE METAL MCU          RTOS MCU              LINUX
(main loop + ISRs)      (tasks + scheduler)   (processes + virtual memory)
```

**Insight:** Same ideas everywhere. What changes is who controls memory and scheduling.

---

## Big Picture — Where Computation Happens

```
FLASH (non-volatile)                CPU                          RAM (volatile)
┌─────────────────────┐        ┌──────────────────┐        ┌─────────────────────┐
│ .text   (code)      │──fetch─►│ REGISTERS + ALU  │◄─LDR──►│ .data (init globals)│
│ .rodata (consts)    │        │ R0..R12 SP LR PC │──STR──►│ .bss  (zero globals)│
│ .data_init (values) │        └──────────────────┘        │ heap  (malloc) ↑    │
└─────────────────────┘         computation HERE           │ stack (locals) ↓    │
                                                           └─────────────────────┘
                                                            storage HERE
```

**Insight:** Compute in registers. RAM is storage. Flash holds code + initial values.

---

## Program Memory Layout

```
High addresses
┌─────────────────────┐
│       STACK         │  ← locals + return addresses
│         ↓           │    grows DOWN
│                     │
│      (unused)       │
│                     │
│         ↑           │    grows UP
│        HEAP         │  ← malloc / free
├─────────────────────┤
│        BSS          │  ← zeroed globals
├─────────────────────┤
│       DATA          │  ← initialized globals
├─────────────────────┤
│       TEXT          │  ← code (in FLASH on MCU)
└─────────────────────┘
Low addresses
```

**Insight:** Stack and heap grow toward each other. If they meet → crash.

---

## How C Becomes Assembly

```c
int x = 5;
int y = x + 3;
```

```asm
mov  r0, #5       ; x lives in a register first
add  r1, r0, #3   ; y computed in a register

; RAM only if needed:
str  r0, [sp, #0] ; spill x to stack
str  r1, [sp, #4] ; spill y to stack
```

**Insight:** Variables live in REGISTERS first, RAM second.

---

## Stack Frames (what a function really is)

```
call foo()
─────────────────────────────
push {r4, lr}      ; save context
sub  sp, #8        ; room for locals

SP → ┌──────────────┐
     │   local[1]   │
     ├──────────────┤
     │   local[0]   │
     ├──────────────┤
     │   saved r4   │
     ├──────────────┤
     │   saved LR   │  ← return address
     └──────────────┘

add  sp, #8        ; free locals
pop  {r4, pc}      ; restore & return
```

**Insight:** Stack frame = locals + saved registers + return address. That's it.

---

## Arrays = Memory Offsets

```
int arr[4] = {10, 20, 30, 40};

Memory:
addr →  +0    +4    +8    +12
       ┌─────┬─────┬─────┬─────┐
       │ 10  │ 20  │ 30  │ 40  │
       └─────┴─────┴─────┴─────┘

arr[2] == *(arr + 2) == memory at (addr + 8) == 30
```

---

## Pointers vs Values

```
int x = 10;
int *p = &x;

RAM:
0x2000 → ┌──────┐
         │  10  │  ← x (the value)
         └──────┘
0x2004 → ┌──────┐
         │ 2000 │  ← p (holds ADDRESS of x)
         └──────┘

 x  = 10        the value itself
&x  = 0x2000    address of x
 p  = 0x2000    p stores that address
*p  = 10        follow the address → get 10
```

---

## Endianness

```
uint32_t x = 0x12345678;

Little-endian (ARM, x86):         Big-endian (network):
addr →  +0   +1   +2   +3         addr →  +0   +1   +2   +3
       ┌────┬────┬────┬────┐             ┌────┬────┬────┬────┐
       │ 78 │ 56 │ 34 │ 12 │             │ 12 │ 34 │ 56 │ 78 │
       └────┴────┴────┴────┘             └────┴────┴────┴────┘
        LSB first                         MSB first
```

---

## Memory-Mapped I/O

```c
#define GPIO_OUT (*(volatile uint32_t*)0x40001000)

GPIO_OUT = 1;   // turn on LED
```

```
CPU writes to 0x40001000
          │
          ▼
┌─────────────────┐
│ GPIO peripheral │ ──► LED lights
└─────────────────┘
```

**Insight:** Hardware registers are just special addresses. Pointers = hardware control.

---

## Why `volatile` Matters

```c
volatile int flag;

while(flag == 0) {
   // spin
}
```

```
Without volatile:              With volatile:
compiler reads flag ONCE       compiler MUST re-read
→ infinite loop                every iteration

Use volatile for:
• Hardware registers
• ISR-shared variables
• Multi-threaded shared data
```

---

## Bare Metal — Main Loop vs ISRs

```
Time ─────────────────────────────────────────────────►

Main:  │ work │ work │ work │ work │ work │ work │

ISR:          ▲           ▲               ▲
              │           │               │
           TIMER       UART RX         BUTTON
```

**Insight:** Main runs most of the time. ISRs preempt briefly, then return.

---

## Startup Sequence (what happens on reset)

```
RESET
  │
  ▼
1) Set SP to top of RAM
  │
  ▼
2) Copy .data_init from FLASH → RAM
  │
  ▼
3) Zero out .bss in RAM
  │
  ▼
4) Call main()
```

---

## The Build Process

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ hello.c  │────►│ hello.s  │────►│ hello.o  │────►│  hello   │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
   source         assembly         object          executable
                 (clang -S)       (clang -c)       (clang -o)
```

---

## Linking Multiple Files

```
  main.c              utils.c             math.c
  ──────────          ──────────          ──────────
  #include "h"        #include "h"        #include "h"
  void main();        int add();          int mul();
      │                   │                   │
      ▼                   ▼                   ▼
   main.o              utils.o             math.o
      │                   │                   │
      └───────────────────┼───────────────────┘
                          ▼
                       LINKER
                          ▼
                     program.elf
```

---

## Scope, Linkage & Storage (Dan Saks Table)

```
┌───────────────────┬───────────┬───────┬──────────┬───────────┐
│ Where declared    │ Specifier │ Scope │ Linkage  │ Storage   │
├───────────────────┼───────────┼───────┼──────────┼───────────┤
│ Outside function  │ (none)    │ file  │ external │ static    │
│ Outside function  │ static    │ file  │ INTERNAL │ static    │
│ Outside function  │ extern    │ file  │ external │ static    │
├───────────────────┼───────────┼───────┼──────────┼───────────┤
│ Inside function   │ (none)    │ block │ none     │ AUTOMATIC │
│ Inside function   │ static    │ block │ none     │ STATIC    │
│ Inside function   │ extern    │ block │ EXTERNAL │ static    │
└───────────────────┴───────────┴───────┴──────────┴───────────┘

static outside = hide from other files
static inside  = persist across calls
```

---

## RTOS — Bare Metal vs Tasks

```
BARE METAL                          RTOS
────────────────────────            ────────────────────────────
while(1) {                          Task A: sensors   (HIGH)
   do_sensors();                    Task B: comms     (MEDIUM)
   do_comm();                       Task C: control   (LOW)
   do_control();
}                                   Time →
                                    A | A | A | A | A | A
Problem: one slow function               B    B        B
blocks everything.                            C        C
```

**Insight:** RTOS replaces one big loop with many tasks + a scheduler.

---

## Context Switch

```
Before switch:
R0..LR, SP = Task A state

Kernel saves:
[ Task A stack ]  ← all registers stored

Kernel loads:
[ Task B stack ]  ← all registers restored

CPU now runs Task B
```

**Insight:** Context switch = save one stack + load another.

---

## MCU vs Linux

```
MCU (bare metal / RTOS)        LINUX
──────────────────────────     ─────────────────────────────
• single program               • many programs (processes)
• one address space            • virtual memory per process
• direct hardware access       • drivers + syscalls
• deterministic timing         • high throughput, less deterministic
```

---

## Linux Process Memory

```
Linux process memory (simplified)

High addresses
┌────────────────────────────┐
│ Kernel memory (not yours)  │
├────────────────────────────┤
│       STACK                │
├────────────────────────────┤
│       HEAP                 │
├────────────────────────────┤
│     .data / .bss           │
├────────────────────────────┤
│       .text                │
└────────────────────────────┘
Low addresses
```

**Insight:** Same layout as MCU, but isolated per process via virtual memory.

---

## 16 vs 32 vs 64 bit

**Word size:**

```
16-bit register:  ┌──────────────┐  up to 65,535
32-bit register:  ┌────────────────────────────┐  up to ~4 billion
64-bit register:  ┌────────────────────────────────────────────────┐  ~18 quintillion
```

**Address space:**

```
16-bit:  64 KB
32-bit:  4 GB
64-bit:  terabytes+
```

**Work per cycle:**

```
Processing 64 bits:
16-bit CPU:  [====][====][====][====]  4 cycles
32-bit CPU:  [========][========]      2 cycles
64-bit CPU:  [================]        1 cycle
```

**Why embedded uses 32-bit:**

```
Cortex-M4 (32-bit)           Desktop x86-64
─────────────────────        ─────────────────
✓ fast enough                ✓ huge RAM
✓ low power                  ✓ heavy compute
✓ small & cheap              ✗ power hungry

32-bit = embedded sweet spot
64-bit = desktop sweet spot
```

---

## ARM ↔ C Pointer Operations

```
ARM Assembly              C                    Meaning
──────────────            ──────────           ───────────────
LDR R0, =list             int *p = list;      get address
LDR R1, [R0]              x = *p;             dereference (read)
STR R1, [R0]              *p = x;             dereference (write)
LDR R2, [R0, #4]          x = *(p + 1);       offset access
LDR R3, [R0], #4          x = *p++;           post-increment
LDR R4, [R0, #4]!         x = *++p;           pre-increment
```

---

## Final Mental Map

```
C PROGRAM
    │
    ▼
ASSEMBLY  →  REGISTERS  →  STACK / HEAP / DATA
    │
    ▼
LINKER  →  FLASH + RAM LAYOUT
    │
    ▼
┌─────────────────┬─────────────────┬─────────────────┐
│  BARE METAL     │     RTOS        │     LINUX       │
│  main + ISRs    │  tasks + sched  │ processes + VM  │
└─────────────────┴─────────────────┴─────────────────┘
```
