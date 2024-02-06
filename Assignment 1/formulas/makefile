# 313132318 Nir Hadar 318868312 Noam Lahmani
# Makefile

CC=gcc
AS=as
CFLAGS=-g
ASMFLAGS=-g
AVXFLAGS=-msse4.2 -mavx -mfma
LDFLAGS=-lm

TARGET=part2

OBJ=main.o formula1.o formula2.o

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

main.o: main.c
	$(CC) $(CFLAGS) -c -o $@ $<

formula1.o: formula1.c
	$(CC) $(CFLAGS) $(AVXFLAGS) -c -o $@ $<

formula2.o: formula2.s
	$(AS) $(ASMFLAGS) -o $@ $<

clean:
	rm -f $(TARGET) $(OBJ)

.PHONY: all clean
