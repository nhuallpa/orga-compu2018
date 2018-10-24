#include <mips/regdef.h>
#include <sys/syscall.h>

# STACKFRAME: ABA(16) + LA(16) + SRA(16)

#define ENCODE_A1               52
#define ENCODE_A0               48
#define ENCODE_STACK_SIZE       48
#define ENCODE_VAR_RA           40
#define ENCODE_VAR_FP           36
#define ENCODE_VAR_GP           32
#define ENCODE_ACTUAL           24
#define ENCODE_PREVIO           20
#define ENCODE_CASO             16


    .text
    .abicalls
    .align 2
    .globl base64_encode 
    .ent base64_encode
base64_encode:
    .frame        $fp, ENCODE_STACK_SIZE, ra  
    .set          noreorder
    .cpload       t9
    .set          reorder
    subu          sp, sp, ENCODE_STACK_SIZE      
    .cprestore    ENCODE_VAR_GP
    sw            ra, ENCODE_VAR_RA(sp)       #save ra      
    sw            $fp, ENCODE_VAR_FP(sp)      #save $fp
    move          $fp, sp
    sw            $zero, ENCODE_ACTUAL($fp)
    sw            $zero, ENCODE_PREVIO($fp)
    sw            $zero, ENCODE_CASO($fp)
    


    .end          base64_encode

# funcion calcular_indice es una funcion leaf,
# o sea que no requiere seccion ABA,
# No requiere guardar RA

# STACKFRAME: SRA(8)

#define CAL_IDX_ARG2        16
#define CAL_IDX_ARG1        12
#define CAL_IDX_ARG0        8
#define CAL_IDX_FRAME_SIZE  8
#define CAL_IDX_VAR_SP      4
#define CAL_IDX_VAR_GP      0

    .text
    .align 2
    .globl calcular_indice
    .ent calcular_indice
calcular_indice:
    subu        sp, sp, CAL_IDX_FRAME_SIZE
    sw          gp, 0(sp)
    sw          $fp, 4(sp)
    mv          $fp, sp
    sw          a0, CAL_IDX_ARG0($fp)  # byteleido_previo
    sw          a1, CAL_IDX_ARG1($fp)  # byteleido_actual
    sw          a2, CAL_IDX_ARG2($fp)  # caso
    li          t0, 3
    bne		    a2, t0, caso012	        # if caso != 3 then caso012
    la          t1, mascaraactual
    lb		    t2, 3(t1)		        # leo mascaraactual[3]
    lb          t3, a1
    andu        v0, t3, t2
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
    andu        t6, a0, t3
    sll         t6, t6, t5              # t6 := (byteleido_previo & mascaraprevio[caso]) << deltaprevio[caso]
    andu        t7, a1, t2
    srl         t7, t7, t4              # t7 := (byteleido_actual & mascaraactual[caso]) >> deltaactual[caso] 
    or          v0, t6, t7
retornar_indice:
    move        sp, $fp
    lw		    $gp, 0(sp)		
    lw          $fp, 4(sp)
    addu        sp, sp, CAL_IDX_FRAME_SIZE
    jr		    $ra					# jump to $ra
    .end        calcular_indice 


# escribir caracteres faltantes
# es una funcion no-leaf

#STACKFRAME: ABA(16) + SRA(16)

#define         FALTANTES_A2            40
#define         FALTANTES_A1            36
#define         FALTANTES_A0            32
#define         FALTANTES_FRAME_SIZE    32
#define         FALTANTES_RA            24
#define         FALTANTES_FP            20
#define         FALTANTES_GP            16

    .text
    .align      2
    .globl      escribir_faltantes
    .ent        escribir_faltantes
escribir_faltantes:
    subu        sp, sp, FALTANTES_FRAME_SIZE
    sw		    gp, FALTANTES_GP(sp)	
    sw		    $fp, FALTANTES_FP(sp)
    sw		    ra, FALTANTES_RA(sp)		
    move		$fp, sp
    sw          a0, FALTANTES_A0($fp)   # a0: byteleido_previo
    sw          a1, FALTANTES_A1($fp)   # a1: caso
    sw          a2, FALTANTES_A2($fp)   # a2: file descriptor output
    la          t1, faltantes
    sll         t2, t2, a1              # calculo indice para array de word
    addu        t1, t1, t2
    lw		    t1, 0(t1)		        # t1 : faltann = faltantes[caso] 
    li          t2, 1
    bneq        t1, t2, faltan2
    andi        t3, a0, 0x0f
    sll         t3, t3, 2               # t3: indice = (byteleido_previo & 0x0f) << 2
    la	        t4, tabla		         
    addu        t4, t4, t3              # *tabla + indice  apunto al byte que esta en la posicion indice
    lb          a0, 0(t4)               # a0 := tabla[indice] 
    jal		    escribir				# jump to target and save position to $ra
faltan2:
    li          t2, 2
    bneq        t1, t2, retornar_estado
    andi        t3, a0, 0x03
    sll         t3, t3, 4               # t3: indice = (byteleido_previo & 0x0f) << 2
    la	        t4, tabla		         
    addu        t4, t4, t3              # *tabla + indice  apunto al byte que esta en la posicion indice
    lb          a0, 0(t4)               # a0 := tabla[indice] 
    jal		    escribir				# jump to target and save position to $ra
fork:
    continuar por aca    

retornar_estado:
    move        sp, $fp
    lw		    gp, FALTANTES_GP(sp)
    lw          $fp, FALTANTES_FP(sp)
    lw          ra, FALTANTES_RA(sp)
    addu        sp, sp FALTANTES_FRAME_SIZE
    jr		    $ra					# jump to $ra
    .end        escribir_faltantes




#STACKFRAME: ABA(16) + SRA(16)

#define         ESCRIBIR_A1             36
#define         ESCRIBIR_A0             32
#define         ESCRIBIR_FRAME_SIZE     32
#define         ESCRIBIR_RA             24
#define         ESCRIBIR_FP             20
#define         ESCRIBIR_GP             16

    .text
    .align      2
    .globl      escribir
    .ent        escribir
escribir:
    subu        sp, sp, ESCRIBIR_FRAME_SIZE
    sw          gp, ESCRIBIR_GP(sp)
    sw          $fp, ESCRIBIR_FP(sp)
    sw          ra, ESCRIBIR_RA(sp)
    move        $fp, sp
    sw          a0, ESCRIBIR_A0($fp)
    sw          a1, ESCRIBIR_A1($fp)
    la          t0, buffer_escribir
    sb          a0, 0(t0)
    mv          a0, a1
    mv          a1, t0
    li          a2, 1
    li          v0, SYS_write
    syscall
    bnez        a3, error_escritura
    move        v0, 0
    j		    retornar_escribir				# jump to retornar_escribir
error_escritura:
    move        v0, 1
retornar_escribir:
    move        sp, $fp
    lw          gp, ESCRIBIR_GP(sp)
    lw          $fp, ESCRIBIR_FP(sp)
    lw          ra, ESCRIBIR_RA(sp)
    addu        sp, sp, ESCRIBIR_FRAME_SIZE
    jr          ra
    .end        escribir



.data
.align 2
buffer_escribir:   .byte  0x00  
.rdata
.align 2
mascaraactual:     .byte  0xfc, 0xf0, 0xc0, 0x3f
mascaraprevio:     .byte  0x00, 0x03, 0x0f, 0x00
deltaprevio:       .byte  0, 4, 2, 0
deltaactual:       .byte  2, 4, 6, 0
faltantes:         .word  0, 2, 1
.align 2
tabla:             .asciiz   "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"