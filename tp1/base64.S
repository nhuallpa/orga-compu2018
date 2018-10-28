#include <mips/regdef.h>
#include <sys/syscall.h>

# STACKFRAME: ABA(16) + LA(24) + SRA(16)

#define ENCODE_FDOUT            60
#define ENCODE_FDIN             56
#define ENCODE_STACK_SIZE       56
#define ENCODE_VAR_RA           48
#define ENCODE_VAR_FP           44
#define ENCODE_VAR_GP           40
#define ENCODE_FILLER           36
#define ENCODE_CODRETORNO       32
#define ENCODE_INDICE           28
#define ENCODE_ACTUAL           24
#define ENCODE_PREVIO           20
#define ENCODE_CASO             16

    .text
    .abicalls
    .align 2
    .globl base64_encode 
    .ent base64_encode
base64_encode:
    .frame      $fp, ENCODE_STACK_SIZE, ra  
    .set        noreorder
    .cpload     t9
    .set        reorder
    subu        sp, sp, ENCODE_STACK_SIZE      
    .cprestore  ENCODE_VAR_GP
    sw          ra, ENCODE_VAR_RA(sp)       #save ra      
    sw          $fp, ENCODE_VAR_FP(sp)      #save $fp
    move        $fp, sp
    sw          zero, ENCODE_ACTUAL($fp)
    sw          zero, ENCODE_PREVIO($fp)
    sw          zero, ENCODE_CASO($fp)

leer_siguiente:
    sw          a0, ENCODE_FDIN($fp)
    sw          a1, ENCODE_FDOUT($fp) 
    lw          t0, ENCODE_FDIN($fp)
    move        a0, t0
    la          a1, byte_leido 
    li          a2, 1
    lw          v0, SYS_read
    syscall
    bnez        a3, error_lectura_encode
    beqz        v0, ultimo_paso             # es EOF, vamos al ultimo paso

    # calculamos indice
    lb		    a0, ENCODE_PREVIO($fp)	
    lb          a1, ENCODE_ACTUAL($fp)
    lw          a2, ENCODE_CASO($fp)
    jal         calc_indice
    sw		    v0, ENCODE_INDICE($fp)	   # guardo indice calculado
    
    lw          t0, ENCODE_INDICE($fp)
    la          t1, tabla
    addu        t1, t1, v0                 # posiciono en tabla[indice]   
    lb          t2, 0(t1)                  # tengo el valor de tabla[indice]
    la          t3, buffer_escribir
    sb          t2, 0(t3)                  # guardo el valor a escribir el buffer

    ## escribimos
    la          a0, buffer_escribir
    lw          a1, ENCODE_FDOUT($fp)
    jal         escribir_byte
    bnez        v0, error_escritura_encode

    # Actualizo el numero de caso
    lw          t0, ENCODE_CASO($fp)
    addiu       t0, t0, 1                  # caso++
    sw          t0, ENCODE_CASO($fp)

    lw          t0, ENCODE_CASO($fp)
    li          t1, 3
    bne        t0, t1, preparar_leer     # salto si no estoy en CASO:3

    # calculamos indice EN CASO 3
    lb		    a0, ENCODE_PREVIO($fp)	
    lb          a1, ENCODE_ACTUAL($fp)
    lw          a2, ENCODE_CASO($fp)
    jal         calc_indice
    sw		    v0, ENCODE_INDICE($fp)	   # guardo indice calculado
    
    ## escribimos EN CASO 3
    la          a0, buffer_escribir
    lw          a1, ENCODE_FDOUT($fp)
    jal         escribir_byte
    bnez        v0, error_escritura_encode

    sw          zero, ENCODE_CASO($fp)    # reiniciamos el contador de caso

preparar_leer:
    lb          t0, ENCODE_ACTUAL($fp)
    sb          t0, ENCODE_PREVIO($fp)
    j           leer_siguiente

error_escritura_encode:
    li          t0, 4
    sw          t0, ENCODE_CODRETORNO($fp)
    j           retornar_encode
error_lectura_encode:
    li          t0, 3
    sw          t0, ENCODE_CODRETORNO($fp)
    j           retornar_encode

ultimo_paso:
    ## llamar a escrib_faltantes
    lb          a0, ENCODE_PREVIO($fp)
    lw          a1, ENCODE_CASO($fp)
    lw          a2, ENCODE_FDOUT($fp)
    jal         escrib_faltantes
    bnez        v0, error_escritura_encode

retornar_encode:
    lw          v0, ENCODE_CODRETORNO($fp)
    move          sp, $fp
    lw          gp, ENCODE_VAR_GP(sp)
    lw          $fp, ENCODE_VAR_FP(sp)
    lw          ra, ENCODE_VAR_RA(sp)
    addu        sp, sp, ENCODE_STACK_SIZE
    jr          ra
    .end          base64_encode

# funcion calc_indice es una funcion leaf,
# o sea que no requiere seccion ABA,
# No requiere guardar RA

# STACKFRAME: SRA(8)

#define CAL_IDX_CASO        16
#define CAL_IDX_ACTUAL        12
#define CAL_IDX_PREVIO        8
#define CAL_IDX_FRAME_SIZE  8
#define CAL_IDX_VAR_SP      4
#define CAL_IDX_VAR_GP      0

    .text
    .align 2
    .globl calc_indice
    .ent calc_indice
calc_indice:
    .frame      $fp, CAL_IDX_FRAME_SIZE, ra  
    .set        noreorder
    .cpload     t9
    .set        reorder
    subu        sp, sp, CAL_IDX_FRAME_SIZE
    .cprestore  CAL_IDX_VAR_GP
    sw          $fp, 4(sp)
    move        $fp, sp
    sw          a0, CAL_IDX_PREVIO($fp)  # byteleido_previo
    sw          a1, CAL_IDX_ACTUAL($fp)  # byteleido_actual
    sw          a2, CAL_IDX_CASO($fp)  # caso
    li          t0, 3
    bne		    a2, t0, caso012	        # if caso != 3 then caso012
    la          t1, mascaraactual
    lb		    t2, 3(t1)		        # leo mascaraactual[3]
    move        t3, a1
    and        v0, t3, t2
    j		    retornar_indice			# jump to retornar_indice
caso012:
    la          t1, mascaraactual
    addu        t1, t1, a2
    lb          t2, 0(t1)               # t2 := mascaraactual[caso]
    la          t1, mascaraprevio
    addu        t1, t1, a2
    lb          t3, 0(t1)               # t3 := mascaraprevio[caso]
    la          t1, deltaactual
    addu        t1, t1, a2
    lb          t4, 0(t1)               # t4 := deltaactual[caso]
    la          t1, deltaprevio
    addu        t1, t1, a2
    lb          t5, 0(t1)               # t5 := deltaprevio[caso]
    and         t6, a0, t3
    sll         t6, t6, t5              # t6 := (byteleido_previo & mascaraprevio[caso]) << deltaprevio[caso]
    and         t7, a1, t2
    srl         t7, t7, t4              # t7 := (byteleido_actual & mascaraactual[caso]) >> deltaactual[caso] 
    or          v0, t6, t7
retornar_indice:
    move        sp, $fp
    lw		    gp, 0(sp)		
    lw          $fp, 4(sp)
    addu        sp, sp, CAL_IDX_FRAME_SIZE
    jr		    ra					# jump to $ra
    .end        calc_indice 


# escribir caracteres faltantes
# es una funcion no-leaf

#STACKFRAME: ABA(16) + LA(8) + SRA(16)

#define         FALTANTES_FDOUT         48
#define         FALTANTES_CASO          44
#define         FALTANTES_PREVIO        40
#define         FALTANTES_FRAME_SIZE    40
#define         FALTANTES_RA            32
#define         FALTANTES_FP            28
#define         FALTANTES_GP            24
#define         FALTANTES_FALTAN        20
#define         FALTANTES_K             16


    .text
    .align      2
    .abicalls
    .globl      escrib_faltantes
    .ent        escrib_faltantes
escrib_faltantes:
    .frame      $fp, FALTANTES_FRAME_SIZE, ra  
    .set        noreorder
    .cpload     t9
    .set        reorder
    subu        sp, sp, FALTANTES_FRAME_SIZE
    .cprestore  FALTANTES_GP	
    sw		    $fp, FALTANTES_FP(sp)
    sw		    ra, FALTANTES_RA(sp)		
    move		$fp, sp
    sw          a0, FALTANTES_PREVIO($fp)   # a0: byteleido_previo
    sw          a1, FALTANTES_CASO($fp)     # a1: caso
    sw          a2, FALTANTES_FDOUT($fp)    # a2: file descriptor output
    la          t1, faltantes
    sll         t2, t2, a1                  # calculo indice para array de word
    addu        t1, t1, t2
    lw		    t1, 0(t1)		            # t1 : faltann = faltantes[caso] 
    sw		    t1, FALTANTES_FALTAN($fp)
    li          t2, 1
    bne         t1, t2, faltan2
    andi        t3, a0, 0x0f
    sll         t3, t3, 2               # t3: indice = (byteleido_previo & 0x0f) << 2
    la	        t4, tabla		         
    addu        t4, t4, t3              # *tabla + indice  apunto al byte que esta en la posicion indice
    lb          a0, 0(t4)               # a0 := tabla[indice] 
    jal		    escribir_byte				# jump to target and save position to $ra
    bnez        v0, error_escritura_faltantes

faltan2:
    li          t2, 2
    lw          t1, FALTANTES_FALTAN($fp)
    bne         t1, t2, retornar_faltantes
    andi        t3, a0, 0x03
    sll         t3, t3, 4               # t3: indice = (byteleido_previo & 0x0f) << 2
    la	        t4, tabla		         
    addu        t4, t4, t3              # *tabla + indice  apunto al byte que esta en la posicion indice
    lb          a0, 0(t4)               # a0 := tabla[indice] 
    jal		    escribir_byte				# jump to target and save position to $ra
    bnez        v0, error_escritura_faltantes
for_k:
    lw          t0, FALTANTES_K($fp)
    lw          t1, FALTANTES_FALTAN($fp)
    bge		    t0, t1, retornar_faltantes;
    la          a0, CHAR_IGUAL
    lw          a1, FALTANTES_FDOUT($fp)
    bnez        v0, error_escritura_faltantes
    lw          t0, FALTANTES_K($fp)
    addiu       t0, t0, 1
    sw          t0, FALTANTES_K($fp)
    j		    for_k				# jump to for_k
    
error_escritura_faltantes:
    li          v0, 4
    j           retornar_faltantes
retornar_faltantes:
    move        sp, $fp
    lw		    gp, FALTANTES_GP(sp)
    lw          $fp, FALTANTES_FP(sp)
    lw          ra, FALTANTES_RA(sp)
    addu        sp, sp, FALTANTES_FRAME_SIZE
    jr		    ra		      
    .end        escrib_faltantes


#STACKFRAME: ABA(16) + SRA(16)

#define         ESCRIBIR_A1             36
#define         ESCRIBIR_A0             32
#define         ESCRIBIR_FRAME_SIZE     32
#define         ESCRIBIR_RA             24
#define         ESCRIBIR_FP             20
#define         ESCRIBIR_GP             16

    .text
    .abicalls
    .align      2
    .globl      escribir_byte
    .ent        escribir_byte
escribir_byte:
    .frame      $fp, ESCRIBIR_FRAME_SIZE, ra  
    .set        noreorder
    .cpload     t9
    .set        reorder
    subu        sp, sp, ESCRIBIR_FRAME_SIZE
    .cprestore  ESCRIBIR_FRAME_SIZE
    sw          gp, ESCRIBIR_GP(sp)
    sw          $fp, ESCRIBIR_FP(sp)
    sw          ra, ESCRIBIR_RA(sp)
    move        $fp, sp
    sw          a0, ESCRIBIR_A0($fp)
    sw          a1, ESCRIBIR_A1($fp)
    la          t0, buffer_escribir
    sb          a0, 0(t0)
    move        a0, a1
    move        a1, t0
    li          a2, 1
    li          v0, SYS_write
    syscall
    bnez        a3, error_escritura
    li          v0, 0
    j		    retornar_escribir				# jump to retornar_escribir
error_escritura:
    li          v0, 1
retornar_escribir:
    move        sp, $fp
    lw          gp, ESCRIBIR_GP(sp)
    lw          $fp, ESCRIBIR_FP(sp)
    lw          ra, ESCRIBIR_RA(sp)
    addu        sp, sp, ESCRIBIR_FRAME_SIZE
    jr          ra
    .end        escribir_byte



.data
.align 2
buffer_escribir:   .byte  0x00  
.align 2
byte_leido:        .byte  0
.rdata
.align 2
mascaraactual:     .byte  0xfc, 0xf0, 0xc0, 0x3f
mascaraprevio:     .byte  0x00, 0x03, 0x0f, 0x00
deltaprevio:       .byte  0, 4, 2, 0
deltaactual:       .byte  2, 4, 6, 0
faltantes:         .word  0, 2, 1
.align 2
CHAR_IGUAL:        .asciiz "="
.globl errmsg
.align 2
errmsg: .word msg_error_lectura_decodif, msg_error_escritura_decodif, msg_error_lectura_codif, msg_error_escritura_codif
.align 2
msg_error_ninguno: .asciiz "No hubo errores."
msg_error_lectura_decodif: .asciiz "Hubo un error en la lectura del archivo a decodificar."
msg_error_escritura_decodif: .asciiz "Hubo un error en la escritura del archivo para la decodificacion."
msg_error_lectura_codif: .asciiz "Hubo un error en la lectura del archivo para codificar."
msg_error_escritura_codif: .asciiz "Hubo un error en la escritura del archivo cuando codificamos"

.align 2
tabla:             .asciiz   "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
