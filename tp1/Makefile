# Build version
VERSION = 0

# Compiler and env set up
CC=gcc
CFLAGS=-Wall -O0
RM=rm -f

# Rules
default: clean bin
tp0: main.c codec.c

bin: 
	$(CC) $(CFLAGS) -o tp1 main.c base64.S

clean:
	$(RM) tp1
