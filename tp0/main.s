	.file	1 "main.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.rdata
	.align	2
$LC0:
	.ascii	"encode\000"
	.data
	.align	2
	.type	ENCODE, @object
	.size	ENCODE, 4
ENCODE:
	.word	$LC0
	.rdata
	.align	2
$LC1:
	.ascii	"decode\000"
	.data
	.align	2
	.type	DECODE, @object
	.size	DECODE, 4
DECODE:
	.word	$LC1
	.rdata
	.align	2
$LC3:
	.ascii	"help\000"
	.align	2
$LC4:
	.ascii	"version\000"
	.align	2
$LC5:
	.ascii	"action\000"
	.align	2
$LC6:
	.ascii	"input\000"
	.align	2
$LC7:
	.ascii	"output\000"
	.data
	.align	2
$LC8:
	.word	$LC3
	.word	0
	.word	0
	.word	104
	.word	$LC4
	.word	0
	.word	0
	.word	86
	.word	$LC5
	.word	1
	.word	0
	.word	97
	.word	$LC6
	.word	1
	.word	0
	.word	105
	.word	$LC7
	.word	1
	.word	0
	.word	111
	.word	0
	.word	0
	.word	0
	.word	0
	.globl	memcpy
	.rdata
	.align	2
$LC2:
	.ascii	"hva:i:o:\000"
	.align	2
$LC9:
	.ascii	"\000"
	.align	2
$LC10:
	.ascii	"Usage:\n\000"
	.align	2
$LC11:
	.ascii	"\ttp0 -h\n\000"
	.align	2
$LC12:
	.ascii	"\ttp0 -V\n\000"
	.align	2
$LC13:
	.ascii	"\ttp0 [ options ]\n\000"
	.align	2
$LC14:
	.ascii	"Options:\n\000"
	.align	2
$LC15:
	.ascii	"\t-V, --version       Print version and quit.\n\000"
	.align	2
$LC16:
	.ascii	"\t-h, --help          Print this information.\n\000"
	.align	2
$LC17:
	.ascii	"\t-i, --input         Location of the input file.\n\000"
	.align	2
$LC18:
	.ascii	"\t-o, --output        Location of the output file.\n\000"
	.align	2
$LC19:
	.ascii	"\t-a, --action        Program action: encode (default) o"
	.ascii	"r decode.\n\000"
	.align	2
$LC20:
	.ascii	"Examples:\n\000"
	.align	2
$LC21:
	.ascii	"\ttp0 -a encode -i ~/input -o ~/output\n\000"
	.align	2
$LC22:
	.ascii	"\ttp0 -a encode\n\000"
	.align	2
$LC23:
	.ascii	"Tp0:Version_0.1:Grupo: B\303\241rbara Mesones Miret, Nes"
	.ascii	"tor Huallpa, Sebasti\303\241n D'Alessandro Szymanowski\n"
	.ascii	"\000"
	.text
	.align	2
	.globl	manejarArgumentosEntrada
	.ent	manejarArgumentosEntrada
manejarArgumentosEntrada:
	.frame	$fp,184,$31		# vars= 136, regs= 3/0, args= 24, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	reorder
	subu	$sp,$sp,184
	.cprestore 24
	sw	$31,176($sp)
	sw	$fp,172($sp)
	sw	$28,168($sp)
	move	$fp,$sp
	sw	$4,184($fp)
	sw	$5,188($fp)
	sw	$6,192($fp)
	la	$2,$LC2
	sw	$2,40($fp)
	addu	$2,$fp,48
	la	$3,$LC8
	move	$4,$2
	move	$5,$3
	li	$6,96			# 0x60
	la	$25,memcpy
	jal	$31,$25
	lw	$2,ENCODE
	sw	$2,144($fp)
	la	$2,$LC9
	sw	$2,148($fp)
	la	$2,$LC9
	sw	$2,152($fp)
$L18:
	addu	$3,$fp,48
	addu	$2,$fp,36
	sw	$2,16($sp)
	lw	$4,188($fp)
	lw	$5,192($fp)
	lw	$6,40($fp)
	move	$7,$3
	la	$25,getopt_long
	jal	$31,$25
	sw	$2,32($fp)
	lw	$3,32($fp)
	li	$2,-1			# 0xffffffffffffffff
	bne	$3,$2,$L21
	b	$L19
$L21:
	lw	$2,32($fp)
	addu	$2,$2,-97
	sw	$2,160($fp)
	lw	$3,160($fp)
	sltu	$2,$3,22
	beq	$2,$0,$L18
	lw	$2,160($fp)
	sll	$3,$2,2
	la	$2,$L31
	addu	$2,$3,$2
	lw	$2,0($2)
	.cpadd	$2
	j	$2
	.rdata
	.align	2
$L31:
	.gpword	$L25
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L23
	.gpword	$L27
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L29
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L18
	.gpword	$L24
	.text
$L23:
	la	$4,$LC10
	la	$25,printf
	jal	$31,$25
	la	$4,$LC11
	la	$25,printf
	jal	$31,$25
	la	$4,$LC12
	la	$25,printf
	jal	$31,$25
	la	$4,$LC13
	la	$25,printf
	jal	$31,$25
	la	$4,$LC14
	la	$25,printf
	jal	$31,$25
	la	$4,$LC15
	la	$25,printf
	jal	$31,$25
	la	$4,$LC16
	la	$25,printf
	jal	$31,$25
	la	$4,$LC17
	la	$25,printf
	jal	$31,$25
	la	$4,$LC18
	la	$25,printf
	jal	$31,$25
	la	$4,$LC19
	la	$25,printf
	jal	$31,$25
	la	$4,$LC20
	la	$25,printf
	jal	$31,$25
	la	$4,$LC21
	la	$25,printf
	jal	$31,$25
	la	$4,$LC22
	la	$25,printf
	jal	$31,$25
	move	$4,$0
	la	$25,exit
	jal	$31,$25
$L24:
	la	$4,$LC23
	la	$25,printf
	jal	$31,$25
	move	$4,$0
	la	$25,exit
	jal	$31,$25
$L25:
	lw	$2,optarg
	beq	$2,$0,$L18
	lw	$2,optarg
	sw	$2,144($fp)
	b	$L18
$L27:
	lw	$2,optarg
	beq	$2,$0,$L18
	lw	$2,optarg
	sw	$2,148($fp)
	b	$L18
$L29:
	lw	$2,optarg
	beq	$2,$0,$L18
	lw	$2,optarg
	sw	$2,152($fp)
	b	$L18
$L19:
	lw	$2,144($fp)
	lw	$3,184($fp)
	sw	$2,0($3)
	lw	$2,148($fp)
	lw	$3,184($fp)
	sw	$2,4($3)
	lw	$2,152($fp)
	lw	$3,184($fp)
	sw	$2,8($3)
	lw	$2,184($fp)
	move	$sp,$fp
	lw	$31,176($sp)
	lw	$fp,172($sp)
	addu	$sp,$sp,184
	j	$31
	.end	manejarArgumentosEntrada
	.size	manejarArgumentosEntrada, .-manejarArgumentosEntrada
	.rdata
	.align	2
$LC24:
	.ascii	"rb\000"
	.align	2
$LC25:
	.ascii	"w\000"
	.align	2
$LC26:
	.ascii	"ERROR: SE DEBE INGRESAR UN ARGUMENTO CORRECTO PARA LA OP"
	.ascii	"CION i.\n\000"
	.text
	.align	2
	.globl	main
	.ent	main
main:
	.frame	$fp,88,$31		# vars= 48, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	reorder
	subu	$sp,$sp,88
	.cprestore 16
	sw	$31,80($sp)
	sw	$fp,76($sp)
	sw	$28,72($sp)
	move	$fp,$sp
	sw	$4,88($fp)
	sw	$5,92($fp)
	sw	$0,24($fp)
	addu	$2,$fp,32
	move	$4,$2
	lw	$5,88($fp)
	lw	$6,92($fp)
	la	$25,manejarArgumentosEntrada
	jal	$31,$25
	lw	$4,36($fp)
	la	$5,$LC9
	la	$25,strcmp
	jal	$31,$25
	sw	$2,48($fp)
	lw	$4,40($fp)
	la	$5,$LC9
	la	$25,strcmp
	jal	$31,$25
	sw	$2,52($fp)
	lw	$2,48($fp)
	beq	$2,$0,$L34
	lw	$4,36($fp)
	la	$5,$LC24
	la	$25,fopen
	jal	$31,$25
	sw	$2,64($fp)
	b	$L35
$L34:
	la	$2,__sF
	sw	$2,64($fp)
$L35:
	lw	$2,64($fp)
	sw	$2,56($fp)
	lw	$2,52($fp)
	beq	$2,$0,$L36
	lw	$4,40($fp)
	la	$5,$LC25
	la	$25,fopen
	jal	$31,$25
	sw	$2,68($fp)
	b	$L37
$L36:
	la	$2,__sF+88
	sw	$2,68($fp)
$L37:
	lw	$2,68($fp)
	sw	$2,60($fp)
	lw	$4,32($fp)
	lw	$5,ENCODE
	la	$25,strcmp
	jal	$31,$25
	bne	$2,$0,$L38
	lw	$4,56($fp)
	lw	$5,60($fp)
	la	$25,codificar
	jal	$31,$25
	b	$L39
$L38:
	lw	$4,32($fp)
	lw	$5,DECODE
	la	$25,strcmp
	jal	$31,$25
	bne	$2,$0,$L40
	lw	$4,56($fp)
	lw	$5,60($fp)
	la	$25,decodificar
	jal	$31,$25
	b	$L39
$L40:
	la	$4,__sF+176
	la	$5,$LC26
	la	$25,fprintf
	jal	$31,$25
$L39:
	lw	$2,48($fp)
	beq	$2,$0,$L42
	lw	$4,56($fp)
	la	$25,fclose
	jal	$31,$25
$L42:
	lw	$2,52($fp)
	beq	$2,$0,$L43
	lw	$4,60($fp)
	la	$25,fclose
	jal	$31,$25
$L43:
	lw	$2,24($fp)
	beq	$2,$0,$L44
	li	$4,1			# 0x1
	la	$25,exit
	jal	$31,$25
$L44:
	lw	$2,24($fp)
	move	$sp,$fp
	lw	$31,80($sp)
	lw	$fp,76($sp)
	addu	$sp,$sp,88
	j	$31
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
