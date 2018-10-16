	.file	1 "codec.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.rdata
	.align	2
$LC0:
	.ascii	"%s\n\000"
	.text
	.align	2
	.globl	escribir
	.ent	escribir
escribir:
	.frame	$fp,40,$31		# vars= 0, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	reorder
	subu	$sp,$sp,40
	.cprestore 16
	sw	$31,32($sp)
	sw	$fp,28($sp)
	sw	$28,24($sp)
	move	$fp,$sp
	sw	$4,40($fp)
	sw	$5,44($fp)
	lw	$4,40($fp)
	lw	$5,44($fp)
	la	$25,fputc
	jal	$31,$25
	move	$3,$2
	li	$2,-1			# 0xffffffffffffffff
	bne	$3,$2,$L17
	la	$25,__errno
	jal	$31,$25
	lw	$4,0($2)
	la	$25,strerror
	jal	$31,$25
	la	$4,__sF+176
	la	$5,$LC0
	move	$6,$2
	la	$25,fprintf
	jal	$31,$25
	li	$4,1			# 0x1
	la	$25,exit
	jal	$31,$25
$L17:
	move	$sp,$fp
	lw	$31,32($sp)
	lw	$fp,28($sp)
	addu	$sp,$sp,40
	j	$31
	.end	escribir
	.size	escribir, .-escribir
	.rdata
	.align	2
$LC2:
	.word	0
	.word	3
	.word	15
	.word	0
	.word	252
	.word	240
	.word	192
	.word	63
	.align	2
$LC3:
	.word	0
	.word	4
	.word	2
	.word	0
	.word	2
	.word	4
	.word	6
	.word	0
	.align	2
$LC4:
	.word	0
	.word	2
	.word	1
	.align	2
$LC1:
	.ascii	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123"
	.ascii	"456789+/\000"
	.text
	.align	2
	.globl	codificar
	.ent	codificar
codificar:
	.frame	$fp,152,$31		# vars= 112, regs= 4/0, args= 16, extra= 8
	.mask	0xd0010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	reorder
	subu	$sp,$sp,152
	.cprestore 16
	sw	$31,148($sp)
	sw	$fp,144($sp)
	sw	$28,140($sp)
	sw	$16,136($sp)
	move	$fp,$sp
	sw	$4,152($fp)
	sw	$5,156($fp)
	la	$2,$LC1
	sw	$2,24($fp)
	sw	$0,28($fp)
	li	$2,1			# 0x1
	sw	$2,32($fp)
	lw	$2,$LC2
	sw	$2,40($fp)
	lw	$2,$LC2+4
	sw	$2,44($fp)
	lw	$2,$LC2+8
	sw	$2,48($fp)
	lw	$2,$LC2+12
	sw	$2,52($fp)
	lw	$2,$LC2+16
	sw	$2,56($fp)
	lw	$2,$LC2+20
	sw	$2,60($fp)
	lw	$2,$LC2+24
	sw	$2,64($fp)
	lw	$2,$LC2+28
	sw	$2,68($fp)
	lw	$2,$LC3
	sw	$2,72($fp)
	lw	$2,$LC3+4
	sw	$2,76($fp)
	lw	$2,$LC3+8
	sw	$2,80($fp)
	lw	$2,$LC3+12
	sw	$2,84($fp)
	lw	$2,$LC3+16
	sw	$2,88($fp)
	lw	$2,$LC3+20
	sw	$2,92($fp)
	lw	$2,$LC3+24
	sw	$2,96($fp)
	lw	$2,$LC3+28
	sw	$2,100($fp)
	lw	$2,$LC4
	sw	$2,104($fp)
	lw	$2,$LC4+4
	sw	$2,108($fp)
	lw	$2,$LC4+8
	sw	$2,112($fp)
	sw	$0,120($fp)
	sw	$0,124($fp)
	sw	$0,128($fp)
$L20:
	lw	$2,32($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$16,$2,96
	lw	$4,152($fp)
	la	$25,fgetc
	jal	$31,$25
	sw	$2,0($16)
	lw	$3,0($16)
	li	$2,-1			# 0xffffffffffffffff
	bne	$3,$2,$L22
	b	$L21
$L22:
	lw	$2,28($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$4,$2,96
	lw	$2,28($fp)
	sll	$3,$2,2
	lw	$2,128($fp)
	addu	$2,$3,$2
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,16
	lw	$3,0($4)
	lw	$2,0($2)
	and	$4,$3,$2
	lw	$2,28($fp)
	sll	$3,$2,2
	lw	$2,128($fp)
	addu	$2,$3,$2
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,48
	lw	$2,0($2)
	sll	$5,$4,$2
	lw	$2,32($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$4,$2,96
	lw	$2,32($fp)
	sll	$3,$2,2
	lw	$2,128($fp)
	addu	$2,$3,$2
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,16
	lw	$3,0($4)
	lw	$2,0($2)
	and	$4,$3,$2
	lw	$2,32($fp)
	sll	$3,$2,2
	lw	$2,128($fp)
	addu	$2,$3,$2
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,48
	lw	$2,0($2)
	sra	$2,$4,$2
	or	$2,$5,$2
	sw	$2,132($fp)
	lw	$3,24($fp)
	lw	$2,132($fp)
	addu	$2,$3,$2
	lb	$2,0($2)
	move	$4,$2
	lw	$5,156($fp)
	la	$25,escribir
	jal	$31,$25
	lw	$2,128($fp)
	addu	$2,$2,1
	sw	$2,128($fp)
	lw	$3,128($fp)
	li	$2,3			# 0x3
	bne	$3,$2,$L23
	lw	$2,32($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$4,$2,96
	lw	$2,32($fp)
	sll	$3,$2,2
	lw	$2,128($fp)
	addu	$2,$3,$2
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,16
	lw	$3,0($4)
	lw	$2,0($2)
	and	$2,$3,$2
	sw	$2,132($fp)
	lw	$3,24($fp)
	lw	$2,132($fp)
	addu	$2,$3,$2
	lb	$2,0($2)
	move	$4,$2
	lw	$5,156($fp)
	la	$25,escribir
	jal	$31,$25
	sw	$0,128($fp)
$L23:
	lw	$2,28($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$4,$2,96
	lw	$2,32($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,96
	lw	$2,0($2)
	sw	$2,0($4)
	b	$L20
$L21:
	lw	$2,128($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,80
	lw	$3,0($2)
	li	$2,1			# 0x1
	bne	$3,$2,$L24
	lw	$2,28($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,96
	lw	$2,0($2)
	andi	$2,$2,0xf
	sll	$2,$2,2
	sw	$2,132($fp)
	lw	$3,24($fp)
	lw	$2,132($fp)
	addu	$2,$3,$2
	lb	$2,0($2)
	move	$4,$2
	lw	$5,156($fp)
	la	$25,escribir
	jal	$31,$25
	b	$L25
$L24:
	lw	$2,128($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,80
	lw	$3,0($2)
	li	$2,2			# 0x2
	bne	$3,$2,$L25
	lw	$2,28($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,96
	lw	$2,0($2)
	andi	$2,$2,0x3
	sll	$2,$2,4
	sw	$2,132($fp)
	lw	$3,24($fp)
	lw	$2,132($fp)
	addu	$2,$3,$2
	lb	$2,0($2)
	move	$4,$2
	lw	$5,156($fp)
	la	$25,escribir
	jal	$31,$25
$L25:
	sw	$0,132($fp)
$L27:
	lw	$2,128($fp)
	sll	$3,$2,2
	addu	$2,$fp,24
	addu	$2,$3,$2
	addu	$2,$2,80
	lw	$3,132($fp)
	lw	$2,0($2)
	slt	$2,$3,$2
	bne	$2,$0,$L30
	b	$L19
$L30:
	li	$4,61			# 0x3d
	lw	$5,156($fp)
	la	$25,escribir
	jal	$31,$25
	lw	$2,132($fp)
	addu	$2,$2,1
	sw	$2,132($fp)
	b	$L27
$L19:
	move	$sp,$fp
	lw	$31,148($sp)
	lw	$fp,144($sp)
	lw	$16,136($sp)
	addu	$sp,$sp,152
	j	$31
	.end	codificar
	.size	codificar, .-codificar
	.rdata
	.align	2
$LC5:
	.ascii	"\n\000"
	.align	2
$LC6:
	.ascii	"0x%02x, \000"
	.text
	.align	2
	.globl	crear_tabla_de_decodificacion
	.ent	crear_tabla_de_decodificacion
crear_tabla_de_decodificacion:
	.frame	$fp,72,$31		# vars= 32, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	reorder
	subu	$sp,$sp,72
	.cprestore 16
	sw	$31,64($sp)
	sw	$fp,60($sp)
	sw	$28,56($sp)
	move	$fp,$sp
	sw	$sp,44($fp)
	la	$2,$LC1
	sw	$2,24($fp)
	li	$2,256			# 0x100
	sw	$2,28($fp)
	lw	$2,28($fp)
	addu	$2,$2,7
	srl	$2,$2,3
	sll	$2,$2,3
	subu	$sp,$sp,$2
	addu	$2,$sp,16
	sw	$2,48($fp)
	sw	$0,32($fp)
$L32:
	lw	$2,32($fp)
	lw	$3,28($fp)
	slt	$2,$2,$3
	bne	$2,$0,$L35
	b	$L33
$L35:
	lw	$2,32($fp)
	lw	$4,48($fp)
	addu	$3,$4,$2
	li	$2,-1			# 0xffffffffffffffff
	sb	$2,0($3)
	lw	$2,32($fp)
	addu	$2,$2,1
	sw	$2,32($fp)
	b	$L32
$L33:
	sw	$0,32($fp)
$L36:
	lw	$3,24($fp)
	lw	$2,32($fp)
	addu	$2,$3,$2
	lbu	$2,0($2)
	sb	$2,36($fp)
	andi	$2,$2,0x00ff
	bne	$2,$0,$L38
	b	$L37
$L38:
	lbu	$2,36($fp)
	lw	$3,48($fp)
	addu	$5,$3,$2
	addu	$4,$fp,32
	lw	$2,0($4)
	move	$3,$2
	sb	$3,0($5)
	addu	$2,$2,1
	sw	$2,0($4)
	b	$L36
$L37:
	sw	$0,40($fp)
$L39:
	lw	$2,40($fp)
	lw	$3,28($fp)
	slt	$2,$2,$3
	bne	$2,$0,$L42
	b	$L40
$L42:
	lw	$2,40($fp)
	andi	$2,$2,0xf
	bne	$2,$0,$L43
	la	$4,__sF+176
	la	$5,$LC5
	la	$25,fprintf
	jal	$31,$25
$L43:
	lw	$2,40($fp)
	lw	$4,48($fp)
	addu	$2,$4,$2
	lb	$2,0($2)
	la	$4,__sF+176
	la	$5,$LC6
	move	$6,$2
	la	$25,fprintf
	jal	$31,$25
	lw	$2,40($fp)
	addu	$2,$2,1
	sw	$2,40($fp)
	b	$L39
$L40:
	la	$4,__sF+176
	la	$5,$LC5
	la	$25,fprintf
	jal	$31,$25
	lw	$sp,44($fp)
	move	$sp,$fp
	lw	$31,64($sp)
	lw	$fp,60($sp)
	addu	$sp,$sp,72
	j	$31
	.end	crear_tabla_de_decodificacion
	.size	crear_tabla_de_decodificacion, .-crear_tabla_de_decodificacion
	.rdata
	.align	2
$LC7:
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
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
	.globl	memcpy
	.align	2
$LC8:
	.ascii	"Error: Caracter '%c' ilegal en la entrada\n\000"
	.text
	.align	2
	.globl	resolver
	.ent	resolver
resolver:
	.frame	$fp,304,$31		# vars= 264, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	reorder
	subu	$sp,$sp,304
	.cprestore 16
	sw	$31,296($sp)
	sw	$fp,292($sp)
	sw	$28,288($sp)
	move	$fp,$sp
	sw	$4,304($fp)
	sw	$5,308($fp)
	addu	$2,$fp,24
	la	$3,$LC7
	move	$4,$2
	move	$5,$3
	li	$6,256			# 0x100
	la	$25,memcpy
	jal	$31,$25
	sw	$0,280($fp)
$L45:
	lw	$2,280($fp)
	lw	$3,308($fp)
	slt	$2,$2,$3
	bne	$2,$0,$L48
	b	$L44
$L48:
	lw	$3,304($fp)
	lw	$2,280($fp)
	addu	$2,$3,$2
	lbu	$2,0($2)
	sb	$2,284($fp)
	lw	$3,304($fp)
	lw	$2,280($fp)
	addu	$2,$3,$2
	lb	$3,0($2)
	li	$2,-1			# 0xffffffffffffffff
	bne	$3,$2,$L49
	lbu	$2,284($fp)
	la	$4,__sF+176
	la	$5,$LC8
	move	$6,$2
	la	$25,fprintf
	jal	$31,$25
	li	$4,1			# 0x1
	la	$25,exit
	jal	$31,$25
$L49:
	lw	$3,304($fp)
	lw	$2,280($fp)
	addu	$4,$3,$2
	lbu	$3,284($fp)
	addu	$2,$fp,24
	addu	$2,$2,$3
	lbu	$2,0($2)
	sb	$2,0($4)
	lw	$2,280($fp)
	addu	$2,$2,1
	sw	$2,280($fp)
	b	$L45
$L44:
	move	$sp,$fp
	lw	$31,296($sp)
	lw	$fp,292($sp)
	addu	$sp,$sp,304
	j	$31
	.end	resolver
	.size	resolver, .-resolver
	.align	2
	.globl	decodificar_finales
	.ent	decodificar_finales
decodificar_finales:
	.frame	$fp,40,$31		# vars= 0, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	reorder
	subu	$sp,$sp,40
	.cprestore 16
	sw	$31,32($sp)
	sw	$fp,28($sp)
	sw	$28,24($sp)
	move	$fp,$sp
	sw	$4,40($fp)
	sw	$5,44($fp)
	sw	$6,48($fp)
	lw	$3,44($fp)
	li	$2,1			# 0x1
	bne	$3,$2,$L51
	lw	$4,40($fp)
	li	$5,2			# 0x2
	la	$25,resolver
	jal	$31,$25
	lw	$2,40($fp)
	lbu	$2,0($2)
	andi	$2,$2,0x3f
	sll	$3,$2,2
	lw	$2,40($fp)
	addu	$2,$2,1
	lbu	$2,0($2)
	andi	$2,$2,0x30
	sra	$2,$2,4
	or	$2,$3,$2
	move	$4,$2
	lw	$5,48($fp)
	la	$25,escribir
	jal	$31,$25
	b	$L50
$L51:
	lw	$3,44($fp)
	li	$2,2			# 0x2
	bne	$3,$2,$L53
	lw	$4,40($fp)
	li	$5,3			# 0x3
	la	$25,resolver
	jal	$31,$25
	lw	$2,40($fp)
	lbu	$2,0($2)
	andi	$2,$2,0x3f
	sll	$3,$2,2
	lw	$2,40($fp)
	addu	$2,$2,1
	lbu	$2,0($2)
	andi	$2,$2,0x30
	sra	$2,$2,4
	or	$2,$3,$2
	move	$4,$2
	lw	$5,48($fp)
	la	$25,escribir
	jal	$31,$25
	lw	$2,40($fp)
	addu	$2,$2,1
	lbu	$2,0($2)
	andi	$2,$2,0xf
	sll	$3,$2,4
	lw	$2,40($fp)
	addu	$2,$2,2
	lbu	$2,0($2)
	andi	$2,$2,0x3c
	sra	$2,$2,2
	or	$2,$3,$2
	move	$4,$2
	lw	$5,48($fp)
	la	$25,escribir
	jal	$31,$25
	b	$L50
$L53:
	lw	$3,44($fp)
	li	$2,3			# 0x3
	bne	$3,$2,$L50
	lw	$4,40($fp)
	li	$5,4			# 0x4
	la	$25,resolver
	jal	$31,$25
	lw	$2,40($fp)
	lbu	$2,0($2)
	andi	$2,$2,0x3f
	sll	$3,$2,2
	lw	$2,40($fp)
	addu	$2,$2,1
	lbu	$2,0($2)
	andi	$2,$2,0x30
	sra	$2,$2,4
	or	$2,$3,$2
	move	$4,$2
	lw	$5,48($fp)
	la	$25,escribir
	jal	$31,$25
	lw	$2,40($fp)
	addu	$2,$2,1
	lbu	$2,0($2)
	andi	$2,$2,0xf
	sll	$3,$2,4
	lw	$2,40($fp)
	addu	$2,$2,2
	lbu	$2,0($2)
	andi	$2,$2,0x3c
	sra	$2,$2,2
	or	$2,$3,$2
	move	$4,$2
	lw	$5,48($fp)
	la	$25,escribir
	jal	$31,$25
	lw	$2,40($fp)
	addu	$2,$2,2
	lbu	$2,0($2)
	andi	$2,$2,0x3
	sll	$3,$2,6
	lw	$2,40($fp)
	addu	$2,$2,3
	lbu	$2,0($2)
	andi	$2,$2,0x3f
	or	$2,$3,$2
	move	$4,$2
	lw	$5,48($fp)
	la	$25,escribir
	jal	$31,$25
$L50:
	move	$sp,$fp
	lw	$31,32($sp)
	lw	$fp,28($sp)
	addu	$sp,$sp,40
	j	$31
	.end	decodificar_finales
	.size	decodificar_finales, .-decodificar_finales
	.rdata
	.align	2
$LC9:
	.ascii	"Error: Faltan 1 caracter de relleno\n\000"
	.align	2
$LC10:
	.ascii	"Error: Faltan 2 caracteres de relleno\n\000"
	.align	2
$LC11:
	.ascii	"Error: Faltan 1 caracter de informacion\n\000"
	.text
	.align	2
	.globl	decodificar
	.ent	decodificar
decodificar:
	.frame	$fp,64,$31		# vars= 24, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	reorder
	subu	$sp,$sp,64
	.cprestore 16
	sw	$31,56($sp)
	sw	$fp,52($sp)
	sw	$28,48($sp)
	move	$fp,$sp
	sw	$4,64($fp)
	sw	$5,68($fp)
	addu	$4,$fp,24
	li	$5,1			# 0x1
	li	$6,5			# 0x5
	lw	$7,64($fp)
	la	$25,fread
	jal	$31,$25
	sw	$2,32($fp)
	lw	$3,32($fp)
	li	$2,5			# 0x5
	bne	$3,$2,$L57
$L58:
	addu	$4,$fp,24
	li	$5,4			# 0x4
	la	$25,resolver
	jal	$31,$25
	lbu	$2,24($fp)
	andi	$2,$2,0x3f
	sll	$3,$2,2
	lbu	$2,25($fp)
	andi	$2,$2,0x30
	sra	$2,$2,4
	or	$2,$3,$2
	move	$4,$2
	lw	$5,68($fp)
	la	$25,escribir
	jal	$31,$25
	lbu	$2,25($fp)
	andi	$2,$2,0xf
	sll	$3,$2,4
	lbu	$2,26($fp)
	andi	$2,$2,0x3c
	sra	$2,$2,2
	or	$2,$3,$2
	move	$4,$2
	lw	$5,68($fp)
	la	$25,escribir
	jal	$31,$25
	lbu	$2,26($fp)
	andi	$2,$2,0x3
	sll	$3,$2,6
	lbu	$2,27($fp)
	andi	$2,$2,0x3f
	or	$2,$3,$2
	move	$4,$2
	lw	$5,68($fp)
	la	$25,escribir
	jal	$31,$25
	lbu	$2,28($fp)
	sb	$2,24($fp)
	addu	$2,$fp,25
	move	$4,$2
	li	$5,1			# 0x1
	li	$6,4			# 0x4
	lw	$7,64($fp)
	la	$25,fread
	jal	$31,$25
	sw	$2,32($fp)
	lw	$3,32($fp)
	li	$2,4			# 0x4
	beq	$3,$2,$L58
	lw	$2,32($fp)
	addu	$2,$2,1
	sw	$2,32($fp)
$L57:
	lw	$2,32($fp)
	beq	$2,$0,$L56
	lw	$3,32($fp)
	li	$2,4			# 0x4
	bne	$3,$2,$L63
	lb	$3,27($fp)
	li	$2,61			# 0x3d
	bne	$3,$2,$L64
	lb	$3,26($fp)
	li	$2,61			# 0x3d
	bne	$3,$2,$L66
	li	$2,1			# 0x1
	sw	$2,40($fp)
	b	$L65
$L66:
	li	$2,2			# 0x2
	sw	$2,40($fp)
	b	$L65
$L64:
	li	$2,3			# 0x3
	sw	$2,40($fp)
$L65:
	lw	$2,40($fp)
	sw	$2,36($fp)
	b	$L68
$L63:
	lw	$3,32($fp)
	li	$2,3			# 0x3
	bne	$3,$2,$L69
	la	$4,__sF+176
	la	$5,$LC9
	la	$25,fprintf
	jal	$31,$25
	lb	$3,26($fp)
	li	$2,61			# 0x3d
	bne	$3,$2,$L70
	li	$2,1			# 0x1
	sw	$2,44($fp)
	b	$L71
$L70:
	li	$2,2			# 0x2
	sw	$2,44($fp)
$L71:
	lw	$2,44($fp)
	sw	$2,36($fp)
	b	$L68
$L69:
	lw	$3,32($fp)
	li	$2,2			# 0x2
	bne	$3,$2,$L73
	la	$4,__sF+176
	la	$5,$LC10
	la	$25,fprintf
	jal	$31,$25
	li	$2,1			# 0x1
	sw	$2,36($fp)
	b	$L68
$L73:
	la	$4,__sF+176
	la	$5,$LC10
	la	$25,fprintf
	jal	$31,$25
	la	$4,__sF+176
	la	$5,$LC11
	la	$25,fprintf
	jal	$31,$25
	b	$L56
$L68:
	addu	$4,$fp,24
	lw	$5,36($fp)
	lw	$6,68($fp)
	la	$25,decodificar_finales
	jal	$31,$25
$L56:
	move	$sp,$fp
	lw	$31,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$31
	.end	decodificar
	.size	decodificar, .-decodificar
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
