# Build version
VERSION = 0

# Compiler and env set up
CC=gcc
CFLAGS  = -Wall -O0

# Rules
default: clean bin

bin: 
	$(CC) $(CFLAGS) -o tp0 main.c -D_VERSION_=\"$(VERSION)\"

clean:
	$(RM) tp0
