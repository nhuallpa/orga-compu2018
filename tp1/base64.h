#ifndef _BASE64_H
#define _BASE64_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


extern const char* errmsg[];
extern int base64_encode(int fileDescriptorEntrada, int fileDescriptorSalida);

#endif

