# 313132318 Nir Hadar 
#318868312 Noam Lahmani 

# Makefile

# Compiler
CC = gcc

# Assembler
AS = as

# Compiler flags
CFLAGS = -g -mavx2 -msse4.1 

# Source files
SOURCES = main.c b64.c

# Assembly source files
ASMSOURCES = hamming.s

# Object files
OBJECTS = $(SOURCES:.c=.o)

# Object files from ASM sources
ASMOBJECTS = $(ASMSOURCES:.s=.o)

# All object files
ALL_OBJECTS = $(OBJECTS) $(ASMOBJECTS)

# Executable name
EXECUTABLE = part1

all: $(EXECUTABLE)

$(EXECUTABLE): $(ALL_OBJECTS)
	$(CC) $(ALL_OBJECTS) -o $@ $(CFLAGS)

%.o: %.c
	$(CC) -c $< -o $@ $(CFLAGS)

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f $(OBJECTS) $(EXECUTABLE)

.PHONY: all clean
