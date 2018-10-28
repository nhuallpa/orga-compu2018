#include <mips/regdef.h>
#include <sys/syscall.h>


#define ERROR_LECTURA_DECODIF   1
#define ERROR_ESCRITURA_DECODIF 2
#define ERROR_LECTURA_CODIF     3
#define ERROR_ESCRITURA_CODIF   4

# STACKFRAME: ABA(16) + LA(24) + SRA(16)

#define ENCODE_FDOUT            60
#define ENCODE_FDIN             56
#define ENCODE_STACK_SIZE       56
#define ENCODE_VAR_RA           48
#define ENCODE_VAR_FP           44
#define ENCODE_VAR_GP           40
#define ENCODE_BYTE_LEIDO       36
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
    sw          zero, ENCODE_CODRETORNO($fp)
    sw          zero, ENCODE_BYTE_LEIDO($fp)
    sw          a0, ENCODE_FDIN($fp)
    sw          a1, ENCODE_FDOUT($fp) 
    
leer_siguiente:
    lw          a0, ENCODE_FDIN($fp)        # fd para el read 
    la          a1, ENCODE_BYTE_LEIDO($fp)  # dir buffer lectura
    li          a2, 1                       # read size en 1
    li          v0, SYS_read                # leeo un char
    syscall
    bnez        a3, error_lectura_encode    # si hay error retorno
    beqz        v0, ultimo_paso             # es EOF, vamos al ultimo paso

    # calculamos indice
    lb          t0, ENCODE_BYTE_LEIDO($fp)  # cargo el valor byte leido
    sb          t0, ENCODE_ACTUAL($fp)      # guardo el byte leido en ACTUAL
    
    lb		    a0, ENCODE_PREVIO($fp)	    # cargo byte previo
    lb          a1, ENCODE_ACTUAL($fp)      # cargo byte actual
    lw          a2, ENCODE_CASO($fp)        # cargo caso
    jal         calc_indice                 # calculamos indice de tabla
    sw		    v0, ENCODE_INDICE($fp)	    # guardo indice calculado
    
    lw          t0, ENCODE_INDICE($fp)     # busco indice para ir a tabla
    la          t1, tabla                  # t1 con direccion de tabla
    addu        t1, t1, t0                 # posiciono en tabla[indice]   
    lb          t2, 0(t1)                  # tengo el valor de tabla[indice]
    
    # escribimos
    move        a0, t2                     # cargamos valor a escribir
    lw          a1, ENCODE_FDOUT($fp)      # cargamos file descriptor out
    jal         escribir_byte
    bnez        v0, error_escritura_encode # si no es cero, hay error me voy

    
    lw          t0, ENCODE_CASO($fp)       # Actualizo el numero de caso
    addiu       t0, t0, 1                  # caso++
    sw          t0, ENCODE_CASO($fp)       # guardo caso

    lw          t0, ENCODE_CASO($fp)       # leo caso para el caso 3
    li          t1, 3
    bne         t0, t1, preparar_leer      # Evaluo si no estoy en CASO:3

    lb		    a0, ENCODE_PREVIO($fp)     # EN CASO 3: calculamos indice	
    lb          a1, ENCODE_ACTUAL($fp)
    lw          a2, ENCODE_CASO($fp)
    jal         calc_indice                
    sw		    v0, ENCODE_INDICE($fp)	   # guardo indice calculado
    
    lw          t0, ENCODE_INDICE($fp)     # EN CASO 3: busco indice para ir a tabla
    la          t1, tabla                  # t1 con direccion de tabla
    addu        t1, t1, t0                 # posiciono en tabla[indice]   
    lb          t2, 0(t1)                  # tengo el valor de tabla[indice]

    move        a0, t2                     # EN CASO 3: Escribimos
    lw          a1, ENCODE_FDOUT($fp)
    jal         escribir_byte
    bnez        v0, error_escritura_encode

    sw          zero, ENCODE_CASO($fp)     # EN CASO 3: reiniciamos el contador de caso

preparar_leer:
    lb          t0, ENCODE_ACTUAL($fp)     # leo el byte actual
    sb          t0, ENCODE_PREVIO($fp)     # y guardo el actual en previo
    j           leer_siguiente

error_escritura_encode:
    li          t0, ERROR_ESCRITURA_CODIF
    sw          t0, ENCODE_CODRETORNO($fp)
    j           retornar_encode
error_lectura_encode:
    li          t0, ERROR_LECTURA_CODIF
    sw          t0, ENCODE_CODRETORNO($fp)
    j           retornar_encode

ultimo_paso:
    lb          a0, ENCODE_PREVIO($fp)
    lw          a1, ENCODE_CASO($fp)
    lw          a2, ENCODE_FDOUT($fp)
    jal         escrib_faltantes                    ## llamar a escrib_faltantes
    bnez        v0, error_escritura_encode

retornar_encode:
    lw          v0, ENCODE_CODRETORNO($fp)
    move        sp, $fp
    lw          gp, ENCODE_VAR_GP(sp)
    lw          $fp, ENCODE_VAR_FP(sp)
    lw          ra, ENCODE_VAR_RA(sp)
    addu        sp, sp, ENCODE_STACK_SIZE
    jr          ra
    .end        base64_encode

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
    sw          a0, CAL_IDX_PREVIO($fp) # byteleido_previo
    sw          a1, CAL_IDX_ACTUAL($fp) # byteleido_actual
    sw          a2, CAL_IDX_CASO($fp)   # caso
    li          t0, 3
    bne		    a2, t0, caso012	        # if caso != 3 then caso012
    la          t1, mascaraactual
    lb		    t2, 3(t1)		        # leo mascaraactual[3]
    move        t3, a1
    and         v0, t3, t2
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
    sw          zero, FALTANTES_K($fp)
    la          t1, faltantes
    lw          t2, FALTANTES_CASO($fp)
    sll         t2, t2, 2
    addu        t1, t1, t2
    lw		    t1, 0(t1)		              # t1 : faltann = faltantes[caso] 
    sw		    t1, FALTANTES_FALTAN($fp)
    
    lw		    t1, FALTANTES_FALTAN($fp)
    li          t2, 1
    bne         t1, t2, faltan2               # Verifico si falta 1 sino salto a caso 2
    andi        t3, a0, 0x0f                  # CASO faltan = 1
    sll         t3, t3, 2                     # t3: indice = (byteleido_previo & 0x0f) << 2
    la	        t4, tabla		         
    addu        t4, t4, t3                    # *tabla + indice  apunto al byte que esta en la posicion indice
    
    lb          a0, 0(t4)                     # a0 := tabla[indice] 
    lw          a1, FALTANTES_FDOUT($fp)
    jal		    escribir_byte				  # jump to target and save position to $ra
    bnez        v0, error_escritura_faltantes
    j           escribir_simbolo_cierre       # 
faltan2:
    li          t2, 2
    lw          t1, FALTANTES_FALTAN($fp)
    bne         t1, t2, retornar_faltantes
    andi        t3, a0, 0x03                  # CASO faltan = 2
    sll         t3, t3, 4                     # t3: indice = (byteleido_previo & 0x0f) << 2
    la	        t4, tabla		         
    addu        t4, t4, t3                    # *tabla + indice  apunto al byte que esta en la posicion indice
    lb          a0, 0(t4)                     # a0 := tabla[indice] 
    lw          a1, FALTANTES_FDOUT($fp)
    jal		    escribir_byte				  # jump to target and save position to $ra
    bnez        v0, error_escritura_faltantes
escribir_simbolo_cierre:
    lw          t0, FALTANTES_K($fp)
    lw          t1, FALTANTES_FALTAN($fp)
    bge		    t0, t1, retornar_faltantes;
    la          t0, CHAR_IGUAL
    lb          a0, 0(t0)
    lw          a1, FALTANTES_FDOUT($fp)
    jal		    escribir_byte				  # jump to target and save position to $ra
    bnez        v0, error_escritura_faltantes
    lw          t0, FALTANTES_K($fp)
    addiu       t0, t0, 1
    sw          t0, FALTANTES_K($fp)
    j		    escribir_simbolo_cierre       # Escribo otro simbolo
    
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

#define         ESCRIBIR_FDOUT          36
#define         ESCRIBIR_VALOR          32
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
    .cprestore  ESCRIBIR_GP
    sw          $fp, ESCRIBIR_FP(sp)
    sw          ra, ESCRIBIR_RA(sp)
    move        $fp, sp
    sw          a0, ESCRIBIR_VALOR($fp)
    sw          a1, ESCRIBIR_FDOUT($fp)
    lw          a0, ESCRIBIR_FDOUT($fp)         # cargamos fd de escritura
    la          a1, ESCRIBIR_VALOR($fp)         # cargamos dir de valor a escribir
    li          a2, 1                           # cargamos longitud
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
errmsg: .word msg_error_ninguno, msg_error_lectura_decodif, msg_error_escritura_decodif, msg_error_lectura_codif, msg_error_escritura_codif
.align 2
msg_error_ninguno: .asciiz "No hubo errores."
msg_error_lectura_decodif: .asciiz "Hubo un error en la lectura del archivo a decodificar."
msg_error_escritura_decodif: .asciiz "Hubo un error en la escritura del archivo para la decodificacion."
msg_error_lectura_codif: .asciiz "Hubo un error en la lectura del archivo para codificar."
msg_error_escritura_codif: .asciiz "Hubo un error en la escritura del archivo cuando codificamos"

.align 2
tabla:             .asciiz   "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"




#define STDERR			2

#define DECODE_FDOUT		52
#define DECODE_FDIN		48
#define DECODE_STACK_SIZE	48
#define DECODE_VAR_RA		40
#define DECODE_VAR_FP		36
#define DECODE_VAR_GP		32
#define DECODE_BUFFER		24
#define DECODE_FINALES		20
#define DECODE_LEIDOS		16


	.text
	.abicalls
	.align	2
	.globl	base64_decode
	.ent	base64_decode
base64_decode:
	# sra: 12, fra: 0, lta: 13, aba: 8
	.frame		$fp, DECODE_STACK_SIZE, ra
	.set		noreorder
	.cpload		t9
	.set		reorder
	subu		sp, sp, DECODE_STACK_SIZE
	.cprestore	DECODE_VAR_GP
	sw		ra, DECODE_VAR_RA(sp)
	sw		$fp, DECODE_VAR_FP(sp)
	move		$fp, sp
	sw		a0, DECODE_FDIN($fp)
	sw		a1, DECODE_FDOUT($fp)

	la		a1, DECODE_BUFFER($fp)
	li		a2, 5
	li		v0, SYS_read
	syscall
	bnez		a3, error_lectura_decode

	move		s7, v0
	bne		s7, 5, leer_finales

loop:
	# resolver (b, 4);
	la              a0, DECODE_BUFFER($fp)	
	li		a1, 4
	jal		deco_resolver	

	lb		s0, DECODE_BUFFER($fp)
	lb		s1, DECODE_BUFFER+1($fp)
	lb		s2, DECODE_BUFFER+2($fp)
	lb		s3, DECODE_BUFFER+3($fp)
	lb		s4, DECODE_BUFFER+4($fp)

	# escribir (((b[0] & 0x3f) << 2) | ((b[1] & 0x30) >> 4), salida);
	andi		t5, s0, 0x3f
	sll		t5, t5, 2
	andi		t6, s1, 0x30
	srl		t6, t6, 4
	or		t7, t5, t6
	move		a0, t7
	lw		a1, DECODE_FDOUT($fp)
	jal		deco_escribir_char

	# escribir (((b[1] & 0x0f) << 4) | ((b[2] & 0x3c) >> 2), salida);
        andi            t5, s1, 0x0f
        sll             t5, t5, 4
        andi            t6, s2, 0x3c
        srl             t6, t6, 2
        or              t7, t5, t6
        move            a0, t7
        lw              a1, DECODE_FDOUT($fp)
        jal             deco_escribir_char

	# escribir (((b[2] & 0x03) << 6) | (b[3] & 0x3f), salida);
	andi            t5, s2, 0x03
        sll             t5, t5, 6
        andi            t6, s3, 0x3f
        or              t7, t5, t6
        move            a0, t7
        lw              a1, DECODE_FDOUT($fp)
        jal             deco_escribir_char

	# b[0] = b[4];
	sw		s4, DECODE_BUFFER($fp)

	# while ((leidos = fread (b+1, 1, 4, entrada)) == 4);
	lw		a0, DECODE_FDIN($fp)
	la              a1, DECODE_BUFFER+1($fp)
	li              a2, 4
	li              v0, SYS_read
	syscall
	bnez            a3, error_lectura_decode
	move		s7, v0
	beq             s7, 4, loop

	# leidos += 1;
	addi		s7, s7, 1

leer_finales:
	beqz		s7, salir

	# si (leidos == 4) 
	bne		s7, 4, no_es_4

	# finales = b[3] == '=' ? (b[2] == '=' ? 1 : 2) : 3;

        lb              t2, DECODE_BUFFER+2($fp)
        lb              t3, DECODE_BUFFER+3($fp)
	bne		t3, '=', else_e1
	bne		t2, '=', else_i1
	li              t4, 1
	b		fin_1
else_i1:
	li              t4, 2
	b		fin_1
else_e1:
	li		t4, 3
fin_1:
	sw		t4, DECODE_FINALES($fp)
	b		finales

no_es_4:
	bne		s7, 3, no_es_3
	# Muestra error
	la		a0, msg_error_falta_1_relleno
	li		a1, STDERR
	jal		deco_escribir
	# finales = b[2] == '=' ? 1 : 2;
	lb              t2, DECODE_BUFFER+2($fp)
	bne		t2, '=', else_2
	li              t4, 1
	b fin_2
else_2:
	li              t4, 2
fin_2:
	sw              t4, DECODE_FINALES($fp)
	b		finales

no_es_3:
	bne		s7, 2, no_es_2
        # Muestra error
        la              a0, msg_error_faltan_2_relleno
        li              a1, STDERR
        jal             deco_escribir
	li              t4, 1
	sw              t4, DECODE_FINALES($fp)
	b               finales

no_es_2:
        # Muestra error
        la              a0, msg_error_faltan_2_relleno
        li              a1, STDERR
        jal             deco_escribir
        la              a0, msg_error_falta_1_info
        li              a1, STDERR
        jal             deco_escribir
	b 		salir

finales:
	la		a0, DECODE_BUFFER($fp)
	#move		a1, t4		
	lw		a1, DECODE_FINALES($fp)
	lw		a2, DECODE_FDOUT($fp)
	jal		deco_finales
	b		salir	

error_lectura_decode:
        la              a0, msg_error_lectura
        li              a1, STDERR
        jal             deco_escribir

salir:
	move		sp, $fp
	lw		gp, DECODE_VAR_GP(sp)
	lw		$fp, DECODE_VAR_FP(sp)
	lw		ra, DECODE_VAR_RA(sp)
	addu		sp, sp, DECODE_STACK_SIZE
	jr		ra
	.end		base64_decode


#define DECODE_ESCRIBIR_A1		36
#define DECODE_ESCRIBIR_A0		32
#define DECODE_ESCRIBIR_STACK_SIZE	32
#define DECODE_ESCRIBIR_RA		24
#define DECODE_ESCRIBIR_FP		20
#define DECODE_ESCRIBIR_GP		16


	.globl		deco_escribir_char
        .ent            deco_escribir_char
deco_escribir_char:
	.frame		$fp, DECODE_ESCRIBIR_STACK_SIZE, ra
	.set noreorder
	.cpload t9
	.set reorder
	subu		sp, sp, DECODE_ESCRIBIR_STACK_SIZE
	.cprestore	DECODE_ESCRIBIR_GP
	sw		$fp, DECODE_ESCRIBIR_FP(sp)
	sw		ra, DECODE_ESCRIBIR_RA(sp)
	move		$fp, sp
	sw		a0, DECODE_ESCRIBIR_A0($fp)
	sw		a1, DECODE_ESCRIBIR_A1($fp)

	move		t0, a0
	sw              t0, 0($fp)

	lw		a0, DECODE_ESCRIBIR_A1($fp)
	la		a1, 0($fp)
	li		a2, 1
	li		v0, SYS_write
	syscall
	beqz		a3, salir_deco_escribir_char
	
        la              a0, msg_error_escritura
        li              a1, STDERR
	jal		deco_escribir

	li		a0, 1
	li		v0, SYS_exit
	syscall
	
salir_deco_escribir_char:
        move            sp, $fp
        lw              gp, DECODE_ESCRIBIR_GP(sp)
        lw              $fp, DECODE_ESCRIBIR_FP(sp)
        lw              ra, DECODE_ESCRIBIR_RA(sp)
        addu            sp, sp, DECODE_ESCRIBIR_STACK_SIZE
        jr              ra
        .end            deco_escribir_char

        .globl          deco_escribir
        .ent            deco_escribir
deco_escribir:
        .frame          $fp, DECODE_ESCRIBIR_STACK_SIZE, ra
        .set noreorder
        .cpload t9
        .set reorder
        subu            sp, sp, DECODE_ESCRIBIR_STACK_SIZE
        .cprestore      DECODE_ESCRIBIR_GP
        sw              $fp, DECODE_ESCRIBIR_FP(sp)
        sw              ra, DECODE_ESCRIBIR_RA(sp)
        move            $fp, sp
        sw              a0, DECODE_ESCRIBIR_A0($fp)
        sw              a1, DECODE_ESCRIBIR_A1($fp)

	li		t0, 0
	move		t1, a0
deco_escribir_contar:
	lb		t2, 0(t1)
	beqz		t2, deco_escribir_fin_contar
	addu		t0, t0, 1
	addu		t1, t1, 1
	b		deco_escribir_contar
deco_escribir_fin_contar:

        lw              a0, DECODE_ESCRIBIR_A1($fp)
        lw              a1, DECODE_ESCRIBIR_A0($fp)
        move            a2, t0
        li              v0, SYS_write
        syscall
        beqz            a3, salir_deco_escribir

        la              a0, msg_error_escritura
        li              a1, STDERR
        jal             deco_escribir

        li              a0, 1
        li              v0, SYS_exit
        syscall

salir_deco_escribir:
        move            sp, $fp
        lw              gp, DECODE_ESCRIBIR_GP(sp)
        lw              $fp, DECODE_ESCRIBIR_FP(sp)
        lw              ra, DECODE_ESCRIBIR_RA(sp)
        addu            sp, sp, DECODE_ESCRIBIR_STACK_SIZE
        jr              ra
        .end            deco_escribir

#define DECODE_RESOLVER_A1              44
#define DECODE_RESOLVER_A0              40
#define DECODE_RESOLVER_STACK_SIZE      40
#define DECODE_RESOLVER_RA              36
#define DECODE_RESOLVER_FP              32
#define DECODE_RESOLVER_GP              28
#define DECODE_RESOLVER_I	        24
#define DECODE_RESOLVER_TABLA           20
#define DECODE_RESOLVER_C               16

	.globl		deco_resolver
        .ent            deco_resolver
deco_resolver:
        .frame          $fp, DECODE_RESOLVER_STACK_SIZE, ra
        .set noreorder
        .cpload t9
        .set reorder
        subu            sp, sp, DECODE_RESOLVER_STACK_SIZE
        .cprestore      DECODE_RESOLVER_GP
        sw              $fp, DECODE_RESOLVER_FP(sp)
        sw              ra, DECODE_RESOLVER_RA(sp)
        move            $fp, sp
        sw              a0, DECODE_RESOLVER_A0($fp)
        sw              a1, DECODE_RESOLVER_A1($fp)
	la		t0, deco_tabla
	sw		t0, DECODE_RESOLVER_TABLA($fp)

	move		t5, t0 # t5 = tabla
	li		t0, -1 # t0 = i
	move		t1, a1 # t1 = largo
	addu		t1, t1, -1 # t1 = largo - 1
	move		t2, a0 # t2 = b
	b		while_resolver

loop_resolver:
	
	addu		t0, t0, 1
sw              t0, DECODE_RESOLVER_I($fp)

	addu		t3, t2, t0 # t3 = b + i
	lb		t4, 0(t3)  # t4 = b[i]
	sb		t4, DECODE_RESOLVER_C($fp)

	addu		t6, t5, t4 # t6 = tabla + b[i]
	lb		t7, 0(t6)  # tabla[c]
	sb		t7, 0(t3)

	beq		t7, -1, error_resolver

while_resolver:
	blt		t0, t1, loop_resolver
	b		salir_deco_resolver

error_resolver:
        la              a0, msg_error_caracter_1
        li              a1, STDERR
        jal             deco_escribir

	# TODO deco_escribir_hexa
        lb              a0, DECODE_RESOLVER_C($fp)
        li              a1, STDERR
        jal             deco_escribir_char

        la              a0, msg_error_caracter_2
        li              a1, STDERR
        jal             deco_escribir
	
        li              a0, 1
        li              v0, SYS_exit
        syscall


salir_deco_resolver:

        move            sp, $fp
        lw              gp, DECODE_RESOLVER_GP(sp)
        lw              $fp, DECODE_RESOLVER_FP(sp)
        lw              ra, DECODE_RESOLVER_RA(sp)
        addu            sp, sp, DECODE_RESOLVER_STACK_SIZE
        jr              ra
        .end            deco_resolver

#define DECODE_FINALES_A2              40
#define DECODE_FINALES_A1              36
#define DECODE_FINALES_A0              32
#define DECODE_FINALES_STACK_SIZE      32
#define DECODE_FINALES_RA              24
#define DECODE_FINALES_FP              20
#define DECODE_FINALES_GP              16

	.globl		deco_finales
	.ent		deco_finales
deco_finales:
        .frame          $fp, DECODE_FINALES_STACK_SIZE, ra
        .set noreorder
        .cpload t9
        .set reorder
        subu            sp, sp, DECODE_FINALES_STACK_SIZE
        .cprestore      DECODE_FINALES_GP
        sw              $fp, DECODE_FINALES_FP(sp)
        sw              ra, DECODE_FINALES_RA(sp)
        move            $fp, sp
        sw              a0, DECODE_FINALES_A0($fp)
        sw              a1, DECODE_FINALES_A1($fp)
        sw              a2, DECODE_FINALES_A2($fp)

	bne		a1, 1, finales_no_es_1

        # resolver (b, 2);
        lw              a0, DECODE_FINALES_A0($fp)
        #la              a0, DECODE_BUFFER($fp)
        li              a1, 2
        jal             deco_resolver

        lw              t8, DECODE_FINALES_A0($fp)
        lb              t0, 0(t8)
        lb              t1, 1(t8)
        #lb              t0, DECODE_BUFFER($fp)
        #lb              t1, DECODE_BUFFER+1($fp)

        # escribir (((b[0] & 0x3f) << 2) | ((b[1] & 0x30) >> 4), salida);
        andi            t5, t0, 0x3f
        sll             t5, t5, 2
        andi            t6, t1, 0x30
        srl             t6, t6, 4
        or              t7, t5, t6
        move            a0, t7
        lw              a1, DECODE_FINALES_A2($fp)
        jal             deco_escribir_char

	b		salir_deco_finales

finales_no_es_1:
        lw              a1, DECODE_FINALES_A1($fp)
	bne		a1, 2, finales_no_es_2

        # resolver (b, 3);
        lw              a0, DECODE_FINALES_A0($fp)
        li              a1, 3
        jal             deco_resolver

        lw              t8, DECODE_FINALES_A0($fp)
        lb              t0, 0(t8)
        lb              t1, 1(t8)
        #lb              t0, DECODE_BUFFER($fp)
        #lb              t1, DECODE_BUFFER+1($fp)

        # escribir (((b[0] & 0x3f) << 2) | ((b[1] & 0x30) >> 4), salida);
        andi            t5, t0, 0x3f
        sll             t5, t5, 2
        andi            t6, t1, 0x30
        srl             t6, t6, 4
        or              t7, t5, t6
        move            a0, t7
        lw              a1, DECODE_FINALES_A2($fp)
        jal             deco_escribir_char

        lw              t8, DECODE_FINALES_A0($fp)
        lb              t1, 1(t8)
        lb              t2, 2(t8)
        #lb              t1, DECODE_BUFFER+1($fp)
        #lb              t2, DECODE_BUFFER+2($fp)

        # escribir (((b[1] & 0x0f) << 4) | ((b[2] & 0x3c) >> 2), salida);
        andi            t5, t1, 0x0f
        sll             t5, t5, 4
        andi            t6, t2, 0x3c
        srl             t6, t6, 2
        or              t7, t5, t6
        move            a0, t7
        lw              a1, DECODE_FINALES_A2($fp)
        jal             deco_escribir_char

	b		salir_deco_finales

finales_no_es_2:
        lw              a1, DECODE_FINALES_A1($fp)
	bne		a1, 3, salir_deco_finales

        # resolver (b, 4);
        lw              a0, DECODE_FINALES_A0($fp)
        li              a1, 4
        jal             deco_resolver

	lw		t8, DECODE_FINALES_A0($fp)
        lb              t0, 0(t8)
        lb              t1, 1(t8)

        # escribir (((b[0] & 0x3f) << 2) | ((b[1] & 0x30) >> 4), salida);
        andi            t5, t0, 0x3f
        sll             t5, t5, 2
        andi            t6, t1, 0x30
        srl             t6, t6, 4
        or              t7, t5, t6
        move            a0, t7
        lw              a1, DECODE_FINALES_A2($fp)
        jal             deco_escribir_char

        lw              t8, DECODE_FINALES_A0($fp)
        lb              t1, 1(t8)
        lb              t2, 2(t8)
        #lb              t1, DECODE_BUFFER+1($fp)
        #lb              t2, DECODE_BUFFER+2($fp)

        # escribir (((b[1] & 0x0f) << 4) | ((b[2] & 0x3c) >> 2), salida);
        andi            t5, t1, 0x0f
        sll             t5, t5, 4
        andi            t6, t2, 0x3c
        srl             t6, t6, 2
        or              t7, t5, t6
        move            a0, t7
        lw              a1, DECODE_FINALES_A2($fp)
        jal             deco_escribir_char

        lw              t8, DECODE_FINALES_A0($fp)
        lb              t2, 2(t8)
        lb              t3, 3(t8)
        #lb              t2, DECODE_BUFFER+2($fp)
        #lb              t3, DECODE_BUFFER+3($fp)

        # escribir (((b[2] & 0x03) << 6) | (b[3] & 0x3f), salida);
        andi            t5, t2, 0x03
        sll             t5, t5, 6
        andi            t6, t3, 0x3f
        or              t7, t5, t6
        move            a0, t7
        lw              a1, DECODE_FINALES_A2($fp)
        jal             deco_escribir_char


salir_deco_finales:
        move            sp, $fp 
        lw              gp, DECODE_FINALES_GP(sp)
        lw              $fp, DECODE_FINALES_FP(sp)
        lw              ra, DECODE_FINALES_RA(sp)
        addu            sp, sp, DECODE_FINALES_STACK_SIZE
        jr              ra
        .end            deco_finales

.rdata
.align 2
	msg_error_falta_1_relleno: .asciiz "Error: Falta 1 caracter de relleno\n"
	msg_error_faltan_2_relleno: .asciiz "Error: Faltan 2 caracteres de relleno\n"
	msg_error_falta_1_info: .asciiz "Error: Falta 1 caracter de informacion\n"
	msg_error_lectura: .asciiz "Error: Fallo SYS_read\n"
	msg_error_escritura: .asciiz "Error: Fallo SYS_write\n"
	msg_error_caracter_1: .asciiz "Error: Caracter '"
	msg_error_caracter_2: .asciiz "' ilegal en la entrada\n"
.align 2
deco_tabla:
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	62
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	63
	.byte	52
	.byte	53
	.byte	54
	.byte	55
	.byte	56
	.byte	57
	.byte	58
	.byte	59
	.byte	60
	.byte	61
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	0
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	6
	.byte	7
	.byte	8
	.byte	9
	.byte	10
	.byte	11
	.byte	12
	.byte	13
	.byte	14
	.byte	15
	.byte	16
	.byte	17
	.byte	18
	.byte	19
	.byte	20
	.byte	21
	.byte	22
	.byte	23
	.byte	24
	.byte	25
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	26
	.byte	27
	.byte	28
	.byte	29
	.byte	30
	.byte	31
	.byte	32
	.byte	33
	.byte	34
	.byte	35
	.byte	36
	.byte	37
	.byte	38
	.byte	39
	.byte	40
	.byte	41
	.byte	42
	.byte	43
	.byte	44
	.byte	45
	.byte	46
	.byte	47
	.byte	48
	.byte	49
	.byte	50
	.byte	51
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1

