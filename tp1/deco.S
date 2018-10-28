#include <mips/regdef.h>
#include <sys/syscall.h>

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

