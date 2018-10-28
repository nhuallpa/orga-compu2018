# Build version
VERSION = 0

# Compiler and env set up
CC=gcc
CFLAGS  = -Wall -O0

# Rules
default: clean bin
tp0: main.c codec.c

bin: 
	$(CC) $(CFLAGS) -o tp1  main.c codec.c -D_VERSION_=\"$(VERSION)\"

clean:
	$(RM) tp1
