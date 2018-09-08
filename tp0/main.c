#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

#define ERROR_CODIFICANDO  2
#define ERROR_DECODIFICANDO  3

static const char basis_64[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

static char* ENCODE = "encode";
static char* DECODE = "decode";

typedef struct {
       char* accion;
       char* entrada;
       char* salida;
} Parametro;


Parametro manejarArgumentosEntrada(int argc, char** argv)
{
	int siguiente_opcion;
	int option_index;

    /* Una cadena que lista las opciones cortas validas */
    const char* const op_cortas = "hva:i:o:"; /* "hva::i:o:" */

    /* Una estructura de varios arrays describiendo los valores largos */
    const struct option op_largas[] =
	{
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

    while (1)
    {
        siguiente_opcion = getopt_long (argc, argv, op_cortas, op_largas, &option_index);
        
        if (siguiente_opcion == -1) 
        	break;
        
        switch (siguiente_opcion)
        {
            case 'h' :
            
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
                exit(0);
	            break;

            case 'v' :
                printf("Tp0:Version_0.1:Grupo: Nestor Huallpa, Ariel Martinez, Pablo Sivori \n");
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
        }
    }
    
    return parametro;

}

int main(int argc, char** argv) {

	int returnCode = 0;

	Parametro p = manejarArgumentosEntrada(argc, argv);
	
    int isEntradaArchivo = strcmp(p.entrada,"");
	int isSalidaArchivo = strcmp(p.salida,"");

	//Si la entrada esta vacia lee stdin (teclado)
	FILE* archivoEntrada = (isEntradaArchivo!=0)?fopen(p.entrada, "rb"):stdin; 
	//Si la salida esta vacia escribe stdout (pantalla)
	FILE* archivoSalida = (isSalidaArchivo!=0)?fopen ( p.salida, "w" ):stdout; 

	if ( strcmp(p.accion, ENCODE) == 0 ) {
		fprintf(stdout, "CODIFICAR");
	} else if ( strcmp(p.accion, DECODE) == 0 ) {
		fprintf(stdout, "DECODIFICAR");
	} else {
		fprintf(stderr, "ERROR: SE DEBE INGRESAR UN ARGUMENTO CORRECTO PARA LA OPCION i.\n");
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

