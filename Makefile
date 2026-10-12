.PHONY: clean all

CC = gcc
ASM = nasm
AR = ar

CFLAGS = -Wall -g -Wpointer-arith
ASMFLAGS = -f elf64 -g

TARGET_LIB = libasmutils.a

ASM_SRCS = $(wildcard *.asm)
ASM_OBJS = $(ASM_SRCS:.asm=.o)

all: $(TARGET_LIB)

$(TARGET_LIB): $(ASM_OBJS)
	$(AR) rcs $@ $(ASM_OBJS)

%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	$(RM) *.o $(TARGET_LIB)