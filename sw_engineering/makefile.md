
---
marp: true
theme: gaia
paginate: true
title: Makefile Crash Course
author: 
---

# Slide 1: Introduction to Makefile

## 1. History of Makefile

- **Developed in 1976** to automate build processes for Unix systems.
- Addressed the **need to manage complex builds**, especially for C/C++ projects.
- Ensures that only updated parts of a project are rebuilt.

```makefile
# Example:
all: main.o utils.o
	$(CC) -o my_program main.o utils.o
```

---

# Why Make is Still Relevant

## Key Advantages
- **Widely compatible** across systems (Linux, macOS, Windows).
- Flexible and efficient for **incremental builds**.
- Easily integrates with **CI/CD pipelines**.
  
---

# Slide 2: Alternatives to Make

| Tool       | Pros                                    | Cons                               |
|------------|----------------------------------------|------------------------------------|
| CMake      | Cross-platform, supports multiple compilers | Complex syntax                    |
| Ninja      | Fast, optimized for parallel builds     | Limited to Ninja file generation   |
| Bazel      | High performance, scalable              | Requires learning custom language  |
| Gradle     | Good for Java/Kotlin builds             | Overhead for non-Java projects     |

---

# Slide 3: Writing a Simple Makefile

## Basic Syntax
- Define **targets** and **commands**.
- Targets usually depend on files or other targets.

```makefile
# Basic Makefile Example
my_program: main.o utils.o
	$(CC) -o my_program main.o utils.o

main.o: main.c
	$(CC) -c main.c

utils.o: utils.c
	$(CC) -c utils.c
```

---

# Slide 4: `make clean` and Specific Targets

## `make` with Specific Targets
- Define a **clean** target to remove compiled files.
- Use `make clean` to clean up project files.

```makefile
.PHONY: clean
clean:
	rm -f *.o my_program
```

```shell
$ make clean  # Removes all `.o` files and `my_program`
```

---

# Slide 5: Variables and Automating Commands

## Defining Variables

- Variables make the Makefile flexible.
- Commonly used for compilers, flags, and directories.

```makefile
CC := gcc
CFLAGS := -Wall -g

my_program: main.o utils.o
	$(CC) $(CFLAGS) -o my_program main.o utils.o
```

---

# Slide 6: Dependency Chain, Special Symbols, and `make all`

## Dependency Chain and `make all`

- Chain targets to control the build sequence.
- `all` is a common target to build everything.

```makefile
# Define `all` as the main target
all: my_program

# Pattern rule to create .o files from .c files
%.o: %.c
	$(CC) -c $< -o $@

# Define the final executable target
my_program: main.o utils.o
	$(CC) -o $@ $^
```

### Special Symbols
- `$@`: Target name
- `$<`: First prerequisite
- `$^`: All prerequisites

---

# Slide 7: PHONY Targets, Directory Management, and Recursive Make Calls

## `.PHONY` Targets
- `.PHONY` tells `make` that the target is **not a file**.

```makefile
.PHONY: clean all
clean:
	rm -f *.o my_program
```

## Directory Management
- Create directories as needed.

```makefile
build:
	mkdir -p build
```

---

## Recursive Makefile Calls in a Directory Tree

### Example Structure

- **Root Makefile** calls **subdirectory Makefiles**, which handle specific parts of the project.
- Leaves of the tree (lower-level Makefiles) do the actual compilation or heavy work.

### Root `Makefile`

```makefile
.PHONY: all subdir

all: subdir
	@echo "Building from root Makefile..."

subdir:
	$(MAKE) -C src    # Calls Makefile in src/
	$(MAKE) -C tests  # Calls Makefile in tests/
```

### `src/Makefile` (Leaf Node)

```makefile
.PHONY: all

all: main.o utils.o
	$(CC) -o app main.o utils.o
```

```shell
# Run `make` from the root to initiate recursive builds
$ make -C root_directory
```

In this example:

- The **root Makefile** calls `make` on subdirectories `src` and `tests`, each with its own Makefile.
- `src/Makefile` (leaf node) defines actual build rules for generating object files and linking.
- **Command**: `make -C root_directory` initiates the recursive build process from the root.