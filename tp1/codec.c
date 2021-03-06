#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include "codec.h"

void escribir (int c, FILE *salida)
{
	if (fputc (c, salida) == EOF) {
		fprintf (stderr, "%s\n", strerror (errno));
		exit (1);
	}
}

/*
 * Ejemplo de entrada dividida en bloques de 6 bits: xxxxxxOO OOOOxxxx xxOOOOOO xxxxxxOO OOOOxxxx
 *
 *	    |     mascaras			    | deltas | Faltan (=)
 * caso	| previo   actual		    | <<  >> |
 * 0	| 00000000 xxxxxx00	00 fc	|  0  2	 | 2
 * 1	| 000000xx xxxx0000	03 f0	|  4  4  | 1
 * 2	| 0000xxxx xx000000	0f c0	|  2  6  | 0
 * Se leyo que falta para el previo y el actual completo:
 * 3	| 00000000 00xxxxxx	00 3f	|  0  0  | 0
 * luego repite
 */	

const char *tabla = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

const int mascaraprevio[4] = {0x00, 0x03, 0x0f, 0x00};
const int mascaraactual[4] = {0xfc, 0xf0, 0xc0, 0x3f};
const int deltaprevio[4] = {0, 4, 2, 0};
const int deltaactual[4] = {2, 4, 6, 0};
const int faltantes[3] = {0, 2, 1};

int calcular_indice(int byteleido_previo, int byteleido_actual , int caso) {
	int indice = -1;
	if (caso == 3) {
		indice = (byteleido_actual & mascaraactual[caso]);
	} else {
		indice = ((byteleido_previo & mascaraprevio[caso]) << deltaprevio[caso]) |
				((byteleido_actual & mascaraactual[caso]) >> deltaactual[caso]);
	}
	return indice;
}

int escribir_faltantes(int byteleido_previo, int caso, FILE* salida) {
	int faltan = faltantes[caso];
	if (faltan == 1) {
		int indice = (byteleido_previo & 0x0f) << 2;
		escribir (tabla[indice], salida);
	} else if (faltan == 2) {
		int indice = (byteleido_previo & 0x03) << 4;
		escribir (tabla[indice], salida);
	}
	int k = 0;
	for (k = 0; k < faltan; k++) {
		escribir ('=', salida);
	}	
	return 1;
}

void codificar (FILE *entrada, FILE *salida) {	
	int byteleido_previo = 0;
	int byteleido_actual = 0;
	int caso = 0;
	byteleido_actual = fgetc(entrada);
	
	while (byteleido_actual != EOF) {
		
		int indice = calcular_indice(byteleido_previo, byteleido_actual,caso);
		escribir (tabla[indice], salida);
		
		caso++;
		if (caso == 3) {
			indice = calcular_indice(byteleido_previo, byteleido_actual,caso);
			escribir (tabla[indice], salida);
			caso = 0;
		}
		
		byteleido_previo = byteleido_actual;
		byteleido_actual = fgetc(entrada);
	}

	escribir_faltantes(byteleido_previo, caso, salida);	
}

void crear_tabla_de_decodificacion ()
{
	const char *tabla_codificacion = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

	const int largo = 256;
	char tabla[largo];
	int i=0;
	for (i = 0; i < largo; i++) {
		tabla[i] = -1;
	}
	unsigned char c;
	i = 0;
	while ((c = tabla_codificacion[i]) != '\0') {
		tabla[c] = i++;
	}
	for (i = 0; i < largo; i++) {
		if ( i % 16 == 0 ) fprintf (stderr, "\n");
		fprintf (stderr, "0x%02x, ", tabla[i]);
	}
	fprintf (stderr, "\n");
}

void resolver (char *b, int largo)
{
	const char tabla[] = {
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x3e, 0xff, 0xff, 0xff, 0x3f, 
		0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 
		0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 
		0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
		0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
	};
	int i = 0;
	for (i = 0; i < largo; i++) {
		unsigned char c = b[i];
		if (b[i] == -1) {
			fprintf (stderr, "Error: Caracter '%c' ilegal en la entrada\n", c);
			exit (1);
		}
		b[i] = tabla[c];
	}
}

void decodificar_finales (char * b, int finales, FILE *salida)
{
	if (finales == 1) {
		resolver (b, 2);
		escribir (((b[0] & 0x3f) << 2) | ((b[1] & 0x30) >> 4), salida);
	} else if (finales == 2) {
		resolver (b, 3);
		escribir (((b[0] & 0x3f) << 2) | ((b[1] & 0x30) >> 4), salida);
		escribir (((b[1] & 0x0f) << 4) | ((b[2] & 0x3c) >> 2), salida);

	} else if (finales == 3) {
		resolver (b, 4);
		escribir (((b[0] & 0x3f) << 2) | ((b[1] & 0x30) >> 4), salida);
		escribir (((b[1] & 0x0f) << 4) | ((b[2] & 0x3c) >> 2), salida);
		escribir (((b[2] & 0x03) << 6) | (b[3] & 0x3f), salida);
	}
}

void decodificar (FILE *entrada, FILE *salida)
{
	char b[5];
	int leidos;
	if ((leidos = fread (b, 1, 5, entrada)) == 5) {
		do {
			resolver (b, 4);
			escribir (((b[0] & 0x3f) << 2) | ((b[1] & 0x30) >> 4), salida);
			escribir (((b[1] & 0x0f) << 4) | ((b[2] & 0x3c) >> 2), salida);
			escribir (((b[2] & 0x03) << 6) | (b[3] & 0x3f), salida);
			b[0] = b[4];
		} while ((leidos = fread (b+1, 1, 4, entrada)) == 4);
		leidos += 1;
	}
	if (leidos) {
		int finales ;
		if (leidos == 4) {
			finales = b[3] == '=' ? (b[2] == '=' ? 1 : 2) : 3;
		} else if (leidos == 3) {
			fprintf (stderr, "Error: Faltan 1 caracter de relleno\n");
			finales = b[2] == '=' ? 1 : 2;
		} else if (leidos == 2) {
			fprintf (stderr, "Error: Faltan 2 caracteres de relleno\n");
			finales = 1;
		} else {
			fprintf (stderr, "Error: Faltan 2 caracteres de relleno\n");
			fprintf (stderr, "Error: Faltan 1 caracter de informacion\n");
			return ;
		}
		decodificar_finales (b, finales, salida);
	}
}

