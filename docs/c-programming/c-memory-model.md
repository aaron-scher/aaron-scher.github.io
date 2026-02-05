# The C Memory Model: Objects, Pointers & the Danger Zone

A C variable isn't a name for a value — it's a name for a **place in memory**. In assembly you manipulated memory addresses directly with `LDR` and `STR`. C does the same thing — it just hides the addresses behind variable names. Understanding this is the key to understanding C.

!!! tip "Try it yourself"
    Paste any code example into [Compiler Explorer (godbolt.org)](https://godbolt.org/) to see the generated assembly, or [OnlineGDB](https://www.onlinegdb.com/online_c_compiler) to compile and run.

---

## 1. What Is an "Object" in C?

Not the OOP kind. In C, an **object** is a region of storage that can hold a value. That's it.

Consider this declaration:

```c
const static uint8_t a = 5;
```

This single line specifies six properties of the object:

| Property | Value | What it means |
|----------|-------|---------------|
| **Name** | `a` | How you refer to it in source code |
| **Type** | `uint8_t` | Size (1 byte) and legal operations |
| **Address** | (assigned by compiler) | Where it lives in memory |
| **Storage duration** | `static` | Exists for the entire program |
| **Linkage** | internal | Only visible in this file |
| **Mutability** | `const` | Cannot be modified after initialization |

!!! note "The mailbox analogy"
    Think of memory as a giant row of mailboxes. Each object gets some number of consecutive mailboxes. The variable name is the label on the first mailbox. The type tells you how many mailboxes this object uses and how to interpret what's inside.

---

## 2. Byte Addressing & Endianness

Every memory address identifies **one byte**. A `uint32_t` occupies 4 consecutive bytes. The "address" of a multi-byte object is always its **lowest byte address**.

The question is: which byte goes at the lowest address?

| Byte order | Lowest address holds | Used by |
|------------|---------------------|---------|
| **Little-endian** | Least significant byte (LSB) | ARM, x86 |
| **Big-endian** | Most significant byte (MSB) | Network protocols, some PowerPC |

You can prove which byte order your system uses:

```c
#include <stdio.h>
#include <stdint.h>

int main() {
    uint32_t a = 0x12345678;
    uint8_t *p = (uint8_t *)&a;
    printf("First byte: 0x%x\n", *p);
    // Prints 0x78 on little-endian (ARM, x86)
    // Prints 0x12 on big-endian
    return 0;
}
```

This works because C lets you reinterpret memory through different pointer types — casting `&a` to a `uint8_t *` lets you read individual bytes of a 4-byte integer. That's powerful and dangerous.

---

## 3. Pointers: The Bridge from Assembly to C

A pointer **is** an address. That's literally all it is. If you understood `LDR` and `STR` in the ARM tutorials, you already understand pointers.

| ARM Assembly | C | Meaning |
|---|---|---|
| `LDR R0, =list` | `int *ptr = list;` | Get the address of something |
| `LDR R1, [R0]` | `x = *ptr;` | **Dereference** — read the value at that address |
| `LDR R2, [R0, #4]` | `x = *(ptr + 1);` | **Offset** — read from address + offset |
| `STR R1, [R0]` | `*ptr = x;` | **Store** — write a value to that address |

The `*` operator in C is just `LDR`/`STR` in disguise. The `&` operator gives you the address — what `LDR R0, =label` does.

```c
#include <stdio.h>

int main() {
    int x = 42;
    int *ptr = &x;      // ptr holds the address of x
    printf("%d\n", *ptr); // dereference: read the value at that address → 42
    *ptr = 99;           // store: write 99 to that address
    printf("%d\n", x);   // x is now 99
    return 0;
}
```

---

## 4. Arrays Aren't What You Think

Arrays are **not** first-class in C. You can't assign one array to another, pass an array to a function, or return an array. When you try, C silently converts the array to a **pointer to element 0**. This is called **decay**.

```c
#include <stdio.h>

void print_size(int arr[]) {
    // arr has decayed to a pointer — sizeof gives pointer size, not array size!
    printf("Inside function: %lu\n", sizeof(arr));  // 8 (pointer size on 64-bit)
}

int main() {
    int data[] = {1, 2, 3, 4, 5};
    printf("In main: %lu\n", sizeof(data));  // 20 (5 ints × 4 bytes)
    print_size(data);
    return 0;
}
```

The indexing operator `arr[i]` is literally defined as `*(arr + i)` — pointer arithmetic with syntactic sugar. This even means `arr[3]` and `3[arr]` are the same thing (though please don't write it that way).

!!! warning "sizeof trap"
    `sizeof(arr)` gives the total array size **only** when `arr` is a real array (not a decayed pointer). Inside a function that receives an array parameter, `sizeof` gives you the pointer size. This is one of the most common C bugs.

---

## 5. Structs & the Arrow Operator

Unlike arrays, structs **are** first-class — you can assign, pass, and return them.

```c
#include <stdio.h>

typedef struct {
    int x;
    int y;
} Point;

void print_point(Point *p) {
    // p->x is shorthand for (*p).x — dereference, then access member
    printf("(%d, %d)\n", p->x, p->y);
}

int main() {
    Point a = {3, 7};
    Point b = a;         // struct assignment: copies all fields
    b.x = 10;
    print_point(&a);     // (3, 7) — a is unchanged
    print_point(&b);     // (10, 7)
    return 0;
}
```

The arrow operator `->` is shorthand for "dereference the pointer, then access the member":

| Syntax | Meaning | When to use |
|--------|---------|-------------|
| `point.x` | Access member directly | When you have the struct itself |
| `p->x` | Same as `(*p).x` | When you have a **pointer** to the struct |

---

## 6. Why C Is Dangerous

C operates outside the sandbox. There is no runtime checking, no garbage collector, no bounds checking. You are one abstraction level above the hardware:

- **You can read/write any memory address** — buffer overflows and dangling pointers are trivially easy
- **You can forget to free heap memory** — memory leaks accumulate silently
- **Behavior depends on compiler and architecture** — endianness, struct padding, and optimization level can all change program behavior
- **The compiler won't catch out-of-bounds access or uninitialized reads** — these are undefined behavior, not compile errors

!!! note "This isn't a flaw — it's a design choice"
    C was built to be a "portable assembler." The danger is the point: you're one abstraction level above the hardware. Every guardrail would cost performance. Languages like Rust add safety guarantees, but at the cost of complexity. C trusts you — for better or worse.

### Resources

- [Compiler Explorer (godbolt.org)](https://godbolt.org/) — see generated assembly for any C code
- [OnlineGDB C Compiler](https://www.onlinegdb.com/online_c_compiler) — compile and run C online
- [ARM Assembly: Fundamentals](../arm-assembly/arm-assembly-fundamentals.md) — the `LDR`/`STR` instructions behind every pointer operation
- [ARM Assembly: Control Flow & Functions](../arm-assembly/arm-assembly-control-flow.md) — stack and function calls that C generates for you
