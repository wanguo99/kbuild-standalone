# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a standalone Kbuild build framework extracted from the Linux kernel. It provides a production-grade build system for C/C++ projects supporting:
- Static libraries (lib-y)
- Shared libraries (so-y)
- Executable binaries (bin-y)
- Kernel modules (obj-m)

The framework includes complete dependency tracking via the fixdep tool, out-of-tree builds, cross-compilation support, and parallel builds.

## Build Commands

### Basic Build
```bash
make                    # Build all targets (silent mode)
make V=1                # Verbose build (shows full commands)
make -j$(nproc)         # Parallel build using all CPU cores
```

### Cleaning
```bash
make clean              # Remove build artifacts
make mrproper           # Complete clean including generated files
```

### Out-of-tree Build
```bash
make O=/tmp/build       # Build in separate directory
```

### Cross-compilation
```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
```

### Building Specific Targets
```bash
make examples/lib/      # Build only the lib example
make examples/tools/    # Build only the tools example
```

## Architecture

### Core Build System

The build system is organized around recursive make with these key components:

**Top-level Makefile** (`/Makefile`):
- Entry point handling out-of-tree builds (O=dir)
- Toolchain configuration (CC, AR, LD, etc.)
- Global flags (KBUILD_CFLAGS, KBUILD_LDFLAGS)
- Output directory setup (bin/, lib/, ko/)

**scripts/Kbuild.include**:
- Core helper functions used throughout the build
- `if_changed`: Rebuilds only when command or dependencies change
- `if_changed_dep`: Like if_changed but with dependency tracking via fixdep
- `build` and `clean`: Variables for recursive make invocations

**scripts/Makefile.build**:
- The recursive build engine invoked for each directory
- Processes obj-y, obj-m, lib-y, so-y, bin-y variables
- Handles variable expansion (e.g., mylib-y := file1.o file2.o)
- Generates build rules for compilation and linking
- Lines 514-547 contain lib/so/bin linking rules

**scripts/Makefile.lib**:
- Variable expansion and manipulation functions
- `suffix-search`, `multi-search`, `real-search`: Expand composite objects
- Compilation flag computation (ccflags-y, asflags-y, etc.)

**scripts/basic/fixdep**:
- Dependency tracking tool (compiled from fixdep.c)
- Parses .d files from gcc -MD
- Tracks CONFIG_* variable dependencies
- Generates .cmd files with saved commands

### Build Flow

1. Top-level Makefile sets up environment and toolchain
2. Builds scripts/basic/fixdep first (scripts_basic target)
3. Recursively invokes `$(MAKE) $(build)=<dir>` for each subdirectory
4. Each directory's Makefile defines lib-y, so-y, bin-y, or obj-y variables
5. scripts/Makefile.build expands variables and generates build rules
6. Compilation uses fixdep for dependency tracking
7. Linking produces final artifacts in bin/, lib/, or ko/ directories

### Variable Expansion Mechanism

The build system supports composite objects:

```makefile
# In examples/lib/Makefile
lib-y += example                    # Declares library "example"
example-y := string_utils.o math_utils.o list.o  # Lists object files

# Makefile.build expands this to:
# - multi-lib-y identifies "example" as composite
# - real-lib-y expands to actual .o files
# - Generates: lib/libexample.a from string_utils.o math_utils.o list.o
```

### Output Directories

- `bin/` - Executable binaries from bin-y
- `lib/` - Static (.a) and shared (.so) libraries from lib-y and so-y
- `ko/` - Kernel modules from obj-m

## Makefile Syntax

### Static Library
```makefile
lib-y += mylib                      # Library name (produces libmylib.a)
mylib-y := file1.o file2.o file3.o  # Source files
ccflags-y := -I$(src)/include       # Compilation flags
```

### Shared Library
```makefile
so-y += mylib                       # Library name (produces libmylib.so)
mylib-y := api.o impl.o             # Source files
LDFLAGS_libmylib.so := -Wl,-soname,libmylib.so.1  # Linker flags
LDLIBS_libmylib.so := -lpthread     # Link libraries
```

### Executable Binary
```makefile
bin-y += myapp                      # Binary name
myapp-y := main.o logic.o           # Source files
ccflags-y := -I$(srctree)/include   # Compilation flags
LDLIBS_myapp := -L$(LIB_DIR) -lmylib -lm  # Link libraries
```

### Conditional Compilation
```makefile
mylib-$(CONFIG_FEATURE_A) += feature_a.o  # Conditional object
ccflags-$(CONFIG_DEBUG) += -DDEBUG        # Conditional flag
```

### Subdirectory Recursion
```makefile
obj-y += subdir/                    # Always recurse into subdir/
obj-$(CONFIG_FEATURE) += feature/   # Conditional recursion
```

## Key Variables

### Path Variables
- `$(srctree)` - Source tree root (may differ from objtree in out-of-tree builds)
- `$(objtree)` - Object tree root (where build artifacts go)
- `$(src)` - Current source directory
- `$(obj)` - Current object directory
- `$(LIB_DIR)` - Library output directory (objtree/lib)
- `$(BIN_DIR)` - Binary output directory (objtree/bin)
- `$(KO_DIR)` - Kernel module output directory (objtree/ko)

### Compilation Flags
- `ccflags-y` - C compilation flags for current directory
- `asflags-y` - Assembly flags for current directory
- `ldflags-y` - Linker flags for current directory
- `CFLAGS_file.o` - Per-file compilation flags
- `LDFLAGS_target` - Per-target linker flags
- `LDLIBS_target` - Per-target link libraries

## Development Notes

### When Modifying Build Scripts

The core build scripts (scripts/Kbuild.include, scripts/Makefile.build, scripts/Makefile.lib) are extracted from the Linux kernel and use advanced make features. Key patterns:

- Use `$(call if_changed,cmd)` for commands that should only run when inputs change
- Use `$(call if_changed_dep,cmd)` when dependency tracking is needed
- Define commands as `quiet_cmd_name` and `cmd_name` pairs
- The `$(real-prereqs)` variable contains actual prerequisites (not FORCE)

### Dependency Tracking

The fixdep tool ensures accurate incremental builds:
- Compiler generates .d files with `-MD -MF`
- fixdep parses .d files and generates .cmd files
- .cmd files contain saved command lines and dependencies
- Changing a header file or compilation flag triggers rebuild

### Testing Changes

After modifying build scripts:
```bash
make clean              # Clean to ensure fresh build
make V=1                # Verbose to see actual commands
make -j$(nproc)         # Test parallel build
make O=/tmp/test        # Test out-of-tree build
```

### Adding New Build Types

To add support for new artifact types, modify scripts/Makefile.build:
1. Add variable initialization (e.g., `newtype-y :=`)
2. Add expansion logic using `multi-search` and `real-search`
3. Define `quiet_cmd_` and `cmd_` for the build command
4. Add build rules with `$(call if_changed,cmd)`
5. Update targets list to include new artifacts

## Project Status

The framework is ~85% complete:
- Core build infrastructure is fully functional
- fixdep dependency tracking works
- lib-y, so-y, bin-y linking rules are implemented (lines 514-547 in Makefile.build)
- Examples demonstrate usage patterns
- Out-of-tree builds, cross-compilation, and parallel builds work

The examples in `examples/lib/` and `examples/tools/` demonstrate the syntax and can be used as templates for new projects.
