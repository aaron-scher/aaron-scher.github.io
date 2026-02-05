# Organizing C Programs: Scope, Linkage & Storage Duration

> "The real insight into C is understanding these three attributes: scope, linkage, and storage duration." — Dan Saks

When you write assembly, every label and every piece of data is visible to the whole program. C adds rules about *who can see what* and *how long things last*. These rules are what `static`, `extern`, and header files are really about.

!!! tip "Try it yourself"
    Paste any code example into [Compiler Explorer (godbolt.org)](https://godbolt.org/) to see the generated assembly, or [OnlineGDB](https://www.onlinegdb.com/online_c_compiler) to compile and run.

[:material-youtube: Dan Saks — Storage Duration and Linkage](https://www.youtube.com/watch?v=0kgTuWkyorc){ .md-button }

---

## 1. The Three Attributes

Every named entity in C has up to three attributes:

| Attribute | Question it answers | Analogy |
|-----------|-------------------|---------|
| **Scope** | Where in the source code can you use this name? | Which rooms in the building can you enter |
| **Linkage** | Can other files refer to this same entity? | Whether people in other buildings know your name |
| **Storage duration** | How long does the memory exist? | Your employment contract length |

Scope is visibility to the **compiler**. Linkage is visibility to the **linker**. Storage duration is the object's **lifetime** at runtime.

---

## 2. Scope: Block vs File

C has two levels of scope:

| Scope | Where declared | Visible to |
|-------|---------------|------------|
| **Block** | Inside `{}` | Only code within that block |
| **File** | Outside any function | Code from the declaration to end of file |

```c
int count = 0;          // file scope — visible from here to end of file

void increment() {
    int step = 1;       // block scope — only visible inside this function
    count += step;
}

// step is NOT accessible here
// count IS accessible here
```

!!! warning "There is no \"global scope\" in C"
    File scope is the biggest it gets. What people call "global variables" are really file-scope variables with external linkage. The mechanism for sharing across files is linkage, not scope.

---

## 3. Storage Duration

Storage duration determines **when memory is allocated and freed**:

| Duration | Lifetime | Where it lives | How you get it |
|----------|----------|---------------|----------------|
| **Automatic** | Function entry → function exit | Stack | Local variables (default) |
| **Static** | Program start → program end | Data segment | `static` keyword, or file-scope variables |
| **Dynamic** | `malloc()` → `free()` | Heap | You manage it manually |

```c
#include <stdio.h>
#include <stdlib.h>

int global = 100;               // static duration (file scope)

void demo() {
    int local = 1;              // automatic — destroyed when demo() returns
    static int persistent = 0;  // static — survives across calls
    int *heap = malloc(sizeof(int));  // dynamic — lives until you free() it

    persistent++;
    printf("call #%d\n", persistent);

    free(heap);
}

int main() {
    demo();  // prints "call #1"
    demo();  // prints "call #2" — persistent survived!
    return 0;
}
```

!!! note "Connection to ARM tutorials"
    Automatic storage is the **same stack** you saw in [ARM Tutorial 10](../arm-assembly/arm-assembly-control-flow.md#5-stack-memory). When the compiler generates `PUSH {R4-R6, LR}` at the start of a function, it's allocating automatic storage. `POP` at the end deallocates it.

---

## 4. Linkage: The Linker's Perspective

Linkage determines whether the **linker** can match a name across files:

| Linkage | Who can see it | Default for | ARM assembly equivalent |
|---------|---------------|-------------|------------------------|
| **External** | Any file in the program | Functions, file-scope variables | `.global _start` |
| **Internal** | Only this translation unit | `static` file-scope declarations | Labels without `.global` |
| **None** | Not the linker's business | Local variables | Stack variables |

!!! note "You already know this"
    In your ARM assembly, `.global _start` gave `_start` external linkage — the linker could see it. Without `.global`, labels had internal linkage. Same concept — C just has keywords for it.

---

## 5. What `extern` and `static` Actually Do

Here's the part most C tutorials get wrong: `static` and `extern` do **not** affect scope. They affect **linkage** and **storage duration**. Where you declare something determines scope.

| Where declared | Specifier | Scope | Linkage | Storage Duration |
|---|---|---|---|---|
| Outside function | *(none)* | file | external | static |
| Outside function | `static` | file | **internal** | static |
| Outside function | `extern` | file | external | static |
| Inside function | *(none)* | block | none | **automatic** |
| Inside function | `static` | block | none | **static** |
| Inside function | `extern` | block | **external** | static |

Read the table row by row. Notice:

- `static` outside a function changes linkage from external to **internal** (hides it from other files)
- `static` inside a function changes storage from automatic to **static** (persists across calls)
- `extern` inside a function gives a local name **external** linkage (lets you reference something from another file)

!!! tip "Rule of thumb"
    `static` means "restrict visibility." Outside a function: restrict to this file. Inside a function: restrict the lifetime to... the whole program (counterintuitive, but that's the keyword C chose).

---

## 6. Declarations, Definitions & Header Files

| Term | Meaning | Example |
|------|---------|---------|
| **Declaration** | "This exists somewhere" | `int sum_array(int arr[], int n);` |
| **Definition** | "This exists right here" | `int sum_array(int arr[], int n) { ... }` |
| **Translation unit** | One `.c` file with all its `#include`s pasted in | What the compiler actually sees |

All definitions are declarations. Not all declarations are definitions.

Header files exist to **share declarations**. They give other files the references (the `U` symbols from `nm`) so the linker can match them to definitions (the `T` symbols).

```c
// --- math_utils.h (declarations only) ---
#ifndef MATH_UTILS_H    // header guard: prevent double-inclusion
#define MATH_UTILS_H

int sum_array(int arr[], int n);    // declaration — no body
int max_array(int arr[], int n);    // declaration — no body

#endif
```

```c
// --- math_utils.c (definitions) ---
#include "math_utils.h"

int sum_array(int arr[], int n) {   // definition — has a body
    int sum = 0;
    for (int i = 0; i < n; i++) sum += arr[i];
    return sum;
}

int max_array(int arr[], int n) {   // definition — has a body
    int max = arr[0];
    for (int i = 1; i < n; i++) {
        if (arr[i] > max) max = arr[i];
    }
    return max;
}
```

```c
// --- main.c ---
#include <stdio.h>
#include "math_utils.h"            // paste declarations so compiler knows the types

int main() {
    int data[] = {3, 7, 2, 9, 1};
    printf("Sum: %d\n", sum_array(data, 5));   // linker matches this to math_utils.o
    printf("Max: %d\n", max_array(data, 5));
    return 0;
}
```

Build with: `clang main.c math_utils.c -o program`

!!! note "The restaurant analogy"
    A header file is like a restaurant menu — it tells you what's available (declarations) but doesn't contain the food (definitions). The `.c` file is the kitchen.

**Header guards** (`#ifndef` / `#define` / `#endif` or `#pragma once`) prevent the same declarations from being pasted in twice when multiple files include the same header.

---

## 7. Quick Reference

### The Dan Saks Table

| Where declared | Specifier | Scope | Linkage | Storage Duration |
|---|---|---|---|---|
| Outside function | *(none)* | file | external | static |
| Outside function | `static` | file | internal | static |
| Outside function | `extern` | file | external | static |
| Inside function | *(none)* | block | none | automatic |
| Inside function | `static` | block | none | static |
| Inside function | `extern` | block | external | static |

### Key Definitions

| Term | One-line definition |
|------|-------------------|
| **Scope** | Where in source code a name is visible (block or file) |
| **Linkage** | Whether the linker can match a name across files (external, internal, none) |
| **Storage duration** | How long an object's memory exists (automatic, static, dynamic) |
| **Declaration** | Introduces a name — "this exists somewhere" |
| **Definition** | Creates the entity — "this exists right here, and here's the memory / code" |
| **Translation unit** | One `.c` file after preprocessing (all `#include`s expanded) |

### Resources

- [:material-youtube: Dan Saks — Storage Duration and Linkage](https://www.youtube.com/watch?v=0kgTuWkyorc) — the talk this page is based on
- [Compiler Explorer (godbolt.org)](https://godbolt.org/) — see generated assembly for any C code
- [OnlineGDB C Compiler](https://www.onlinegdb.com/online_c_compiler) — compile and run C online
- [ARM Assembly: Fundamentals](../arm-assembly/arm-assembly-fundamentals.md) — `.global` is external linkage
- [ARM Assembly: Control Flow & Functions](../arm-assembly/arm-assembly-control-flow.md) — the stack is automatic storage
