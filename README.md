# Easy Makefile

This is a makefile designed to be dropped in to a project and for the most part
"just work" after a little bit of configuration in a `conf.mk` file.

Make is a great tool, but I remember how hard it was to learn. It's very
different from most other build systems. It's my hope that this file can be
useful for someone who's new to C or C++.

If there's anything you'd like to see changed, for example limitations or bad
practices, feel free to create an issue.

## Simple example

Download the Makefile:

```
wget https://raw.githubusercontent.com/mortie/easy-makefile/master/Makefile
```

and create a config file for it:

`conf.mk`:
```
TARGET=example-program
```

Now just run `make`, and all C source files in `src/` will be compiled into a
binary called `example-program`. If you change any header or source file, only
the the necessary files will be recompiled the next time you run `make`.

To compile C++ instead of C:

`conf.mk`:
```
CC=$(CXX)
EXT=.cc
TARGET=example-program
```

Here, we set the file extension to .cc (the UNIX convention for C++ files), and
set the compiler to `$(CXX)`, which is the default C++ compiler (usually g++ on
GNU/Linux systems).

## Variables

### TARGET

`TARGET` is the name of the binary.

### FILES

`FILES` is the list of files to compile.

Default value: `$(shell find $(SRC) -name '*$(EXT)' | sed 's/^.\///)` - Find
all files with the extension you specify with `EXT` in the directory you
specify with `SRC`. The `sed` command is to remove the annoying `./` prefix you
get when setting `SRC` to the current directory (`.`).

### EXT

`EXT` is the filename extension for your source files, generally `.c` for C and `.cc` for
C++.

Default value: `.c`

### SRC

`SRC` is the directory which contains the source files.

Default value: `src`

### CC

`CC` is the compiler. For C, you can leave it as it is. For C++, set it to
`$(CXX)` - the `CXX` variable is predefined by make, and is generally the
preferred C++ compiler.

Default: a C compiler. Which one depends on your system, but it generally means
`cc`, which on GNU/Linux systems is a symlink to `gcc`.

### WARN

`WARN` is a list of warning options.

Default value: `all pedantic` (expands to `-Wall -Wpedantic`)

### LINK

`LINK` is a list of shared libraries to link with. To link with the math
library for example (`libm.so`): `LINK=m` (expands to `-lm`)

### INCLUDE

`INCLUDE` is a list of directories to append to your include search path. To
include a directory called `headers`: `INCLUDE=headers` (expands to
`-Lheaders`)

### FLAGS

`FLAGS` is general compiler flags.

### FLAGS\_DBG

`FLAGS_DBG` is flags which are only applied when compiling in debug mode (aka
`make DEBUG=1`).

Default: `-g -o0 -DDEBUG`

### FLAGS\_NDBG

`FLAGS_NDBG` is flags which are only applied when compiling without debug mode.

### DEPS

`DEPS` is additional targets you want to add as a dependency for `$(TARGET)`.

### JUNK

`JUNK` is additional files to be deleted with a `make clean`.

### TOOLCHAIN

`TOOLCHAIN` is mainly for cross compiling. If you set
`TOOLCHAIN=aarch64-linux-gnu-` and `CC=gcc`, source files will be compiled with
`aarch64-linux-gnu-gcc`, and thus be compiled for 64-bit ARM.
