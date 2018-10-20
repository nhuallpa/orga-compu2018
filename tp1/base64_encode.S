#include <mips/regdef.h>
#include <sys/syscall.h>


#define ENCODE_STACK_SIZE       64
#define ENCODE_VAR_RA           60
#define ENCODE_VAR_GP           56
#define ENCODE_VAR_FP           52

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




    .end          base64_encode