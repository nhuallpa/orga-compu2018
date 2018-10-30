#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include "codec.h"
#include "base64.h"

#define ERROR_CODIFICANDO  2
#define ERROR_DECODIFICANDO  3


static char* ENCODE = "encode";
static char* DECODE = "decode";

typedef struct {
  char* accion;
  char* entrada;
  char* salida;
} Parametro;

void imprimirAyuda()
{
  printf("Usage:\n");
  printf("\ttp0 -h\n");
  printf("\ttp0 -V\n");
  printf("\ttp0 [ options ]\n");

  printf("Options:\n");
  printf("\t-V, --version       Print version and quit.\n");
  printf("\t-h, --help          Print this information.\n");
  printf("\t-i, --input         Location of the input file.\n");
  printf("\t-o, --output        Location of the output file.\n");
  printf("\t-a, --action        Program action: encode (default) or decode.\n");

  printf("Examples:\n");
  printf("\ttp0 -a encode -i ~/input -o ~/output\n");
  printf("\ttp0 -a encode\n");
}

Parametro manejarArgumentosEntrada(int argc, char** argv)
{
  int siguiente_opcion;
  int option_index;

  /* Una cadena que lista las opciones cortas validas */
  const char* const op_cortas = "hva:i:o:"; /* "hva::i:o:" */

  /* Una estructura de varios arrays describiendo los valores largos */
  const struct option op_largas[] = {
    { "help",    	no_argument,  		0,  'h'},
    { "version",    no_argument,  		0,  'V'},
    { "action",    	required_argument,  0,  'a'}, /*optional_argument*/
    { "input",     	required_argument,  0,  'i'},
    { "output",    	required_argument,  0,  'o'},
    { 0, 0, 0, 0 }
  };

  Parametro parametro;
  parametro.accion 	= ENCODE;
  parametro.entrada 	= "";
  parametro.salida 	= "";
  while (1) {
    siguiente_opcion = getopt_long (argc, argv, op_cortas, op_largas, &option_index);
    if (siguiente_opcion == -1) {
      break;
    }

    switch (siguiente_opcion) {
    case 'h' :
      imprimirAyuda();
      exit(0);
      break;
    case 'v' :
      printf("Tp0:Version_0.1:Grupo: Bárbara Mesones Miret, Nestor Huallpa, Sebastián D'Alessandro Szymanowski\n");
      exit(0);
      break;
    case 'a' :
      if ( optarg )
      parametro.accion = optarg;
      break;
    case 'i' :
      if ( optarg )
      parametro.entrada = optarg;
      break;
    case 'o' :
      if ( optarg )
      parametro.salida = optarg;
      break;
    case '?':
      /* getopt_long already printed an error message. */
      imprimirAyuda();
      exit(0);
      break;
    }
  }
  return parametro;
}

int main (int argc, char** argv) {
  int returnCode = 0;
  Parametro p = manejarArgumentosEntrada(argc, argv);
  int isEntradaArchivo = strcmp(p.entrada,"");
  int isSalidaArchivo = strcmp(p.salida,"");
  int isEntradaEstandar = strcmp(p.entrada,"-");
  int isSalidaEstandar = strcmp(p.salida,"-");
  if (!isEntradaEstandar) {
    isEntradaArchivo = 0;
  }
  if (!isSalidaEstandar) {
    isSalidaArchivo = 0;
  }
  //Si la entrada esta vacia lee stdin (teclado)
  FILE* archivoEntrada = (isEntradaArchivo!=0)?fopen(p.entrada, "rb"):stdin;
  //Si la salida esta vacia escribe stdout (pantalla)
  FILE* archivoSalida = (isSalidaArchivo!=0) ? fopen( p.salida, "w" ):stdout;

  if (!archivoEntrada) {
    fprintf(stderr, "ERROR: EL ARCHIVO DE ENTRADA NO SE ENCUENTRA\n");
    exit(1);
  } else if (!archivoSalida) {
    fprintf(stderr, "ERROR: EL ARCHIVO DE SALIDA NO SE ENCUENTA\n");
    exit(1);
  }
  if (strcmp(p.accion, ENCODE) == 0) {
    int fileDescriptorEntrada = fileno(archivoEntrada);
    int fileDescriptorSalida = fileno(archivoSalida);
		returnCode = base64_encode(fileDescriptorEntrada, fileDescriptorSalida);
		if (returnCode!=0) fprintf(stderr, "Error: %s \n", errmsg[returnCode]);
  } else if (strcmp(p.accion, DECODE) == 0) {
    int infd = fileno(archivoEntrada);
    int outfd = fileno(archivoSalida);
		returnCode = base64_decode(infd, outfd);
    if (returnCode!=0) fprintf(stderr, "Error: %s \n", errmsg[returnCode]);
  } else {
    fprintf(stderr, "ERROR: SE DEBE INGRESAR UN ARGUMENTO CORRECTO PARA LA OPCION\n");
  }

  if (isEntradaArchivo!=0) {
    fclose(archivoEntrada);
  }
  if (isSalidaArchivo!=0) {
    fclose(archivoSalida);
  }
  if(returnCode!=0){
    exit(1);
  }
  return returnCode;
}
