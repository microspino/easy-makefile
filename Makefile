# Variables from conf.mk:
# TARGET: compilation target
#
# TOOLCHAIN: prefix for toolchain: TOOLCHAIN=aarch64-linux-gnu-
# CC: what compiler to use
#
# FILES: list of input files
#     default: all files with extension $(EXT) in $(SRC)
# EXT: file extension
#     default: .c
# SRC: directory with source files (only applies if you don't specify FILES)
#     default: src
#
# FLAGS: general flags
# FLAGS_DBG: flags included only when running $(TARGET)-debug
#     default: -g -o0 -DDEBUG
# FLAGS_NDBG: flags included only when not running $(TARGET)-debug
#
# WARN: warning flags
#     default: all pedantic
# LINK: libraries to link with
# INCLUDE: include directories
#
# DEPS: additional targets to run before the $(TARGET) step
# JUNK: additional files to be cleaned by th clean target

include conf.mk

#
# Defaults
#
ifeq ($(WARN),)
  WARN=all pedantic
endif
ifeq ($(FLAGS_DBG),)
  FLAGS_DBG=-g -o0 -DDEBUG
endif
ifeq ($(EXT),)
  EXT=.c
endif
ifeq ($(SRC),)
  SRC=src
endif
ifeq ($(FILES),)
  FILES=$(shell find $(SRC) -name '*$(EXT)' | sed 's/^.\///')
endif
CC:=$(TOOLCHAIN)$(CC)

#
# Find .o and .d files
#
OFILES=$(patsubst %$(EXT),obj/%.o,$(FILES))
DFILES=$(patsubst %$(EXT),dep/%.d,$(FILES))

#
# Log function for pretty logging
#
col_dim=\e[0;34m
col_bright=\e[1;95m
col_arg=\e[0;92m
col_end=\e[0m
log=bash -c 'echo -e "$(col_dim)[$(col_bright)i$(col_dim)]$(col_end) $(1) $(col_arg)$(2)$(col_end)"'

#
# Create FLAGS based on a bunch of variables
#
FLAGS:=$(FLAGS) \
	$(patsubst %,-W%,$(WARN)) \
	$(patsubst %,-l%,$(LINK)) \
	$(patsubst %,-L%,$(INCLUDE))
ifeq ($(DEBUG),1)
  FLAGS:=$(FLAGS) $(FLAGS_DBG)
else
  FLAGS:=$(FLAGS) $(FLAGS_NDBG)
endif

#
# Compile the binary
#
$(TARGET): $(OFILES) $(DEPS)
	$(CC) -o $(TARGET) $(OFILES)
	@$(call log,"Created",$(TARGET))

#
# Cleanup
#
clean:
	rm -rf obj dep
	rm -f $(TARGET) $(JUNK)

#
# Create .d files
#
dep/%.d: %$(EXT)
	@mkdir -p $(@D)
	@printf $(dir obj/$*) > $@
	@$(CC) -MM $< -o -  >> $@

#
# Create .o files
#
obj/%.o: %$(EXT)
	@mkdir -p $(@D)
	$(CC) $(strip $(FLAGS)) -o $@ -c $<
	@$(call log,"Created",$@)

#
# Include .d files if we're not in make clean
# We're not using a single make.dep file, because we only know the
# source files, not the headers.
#
ifneq ($(MAKECMDGOALS),clean)
  -include $(DFILES)
endif
