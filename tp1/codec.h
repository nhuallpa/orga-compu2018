#ifndef CODEC_H
#define CODEC_H

#include <stdio.h>

void codificar (FILE *entrada, FILE *salida);
void decodificar (FILE *entrada, FILE *salida);

int calcular_indice(int byteleido_previo, int byteleido_actual , int caso);
int escribir_faltantes(int byteleido_previo, int caso, FILE* salida);
#endif

