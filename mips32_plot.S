#include <mips/regdef.h>
#include <sys/syscall.h>

#define ASCII_0 48

#define BUF_SZ 8192

#define STACK_SZ BUF_SZ+56

#define A0_OFFSET BUF_SZ+56
#define FP_OFFSET BUF_SZ+52
#define GP_OFFSET BUF_SZ+48
#define SEED_I_OFFSET BUF_SZ+44
#define SEED_R_OFFSET BUF_SZ+40
#define C_OFFSET BUF_SZ+36
#define Y_OFFSET BUF_SZ+32
#define X_OFFSET BUF_SZ+28
#define SI_OFFSET BUF_SZ+24
#define SR_OFFSET BUF_SZ+20
#define ZI_OFFSET BUF_SZ+16
#define ZR_OFFSET BUF_SZ+12
#define CI_OFFSET BUF_SZ+8
#define CR_OFFSET BUF_SZ+4
#define BUFF_LEN_OFFSET BUF_SZ
#define BUFF_OFFSET 0

#define PARAM_UL_RE 0
#define PARAM_UL_IM 4
#define PARAM_LR_RE 8
#define PARAM_LR_IM 12
#define PARAM_D_RE 16
#define PARAM_D_IM 20
#define PARAM_SEED_RE 24
#define PARAM_SEED_IM 28
#define PARAM_X_RES 32
#define PARAM_Y_RES 36
#define PARAM_SHADES 40
#define PARAM_FD 44

    .text
    .abicalls
    .globl mips32_plot
    .ent mips32_plot


mips32_plot:
    ###############################################################
    # Push stack frame
    subu sp, sp, STACK_SZ # push stack pointer down
    
    sw $fp, FP_OFFSET(sp) # store $fp on mem(sp + FP_OFFSET)
    sw gp, GP_OFFSET(sp)  # store gp on mem(sp + GP_OFFSET)
    
    move $fp, sp      # $fp = sp
    
    sw a0, A0_OFFSET($fp) # store params on mem($fp + A0_OFFSET) 
    
    l.s $f0, PARAM_SEED_RE(a0) 
    s.s $f0, SEED_R_OFFSET($fp)  # store cpr on mem($fp + CPR_OFFSET)
    #lw t0, PARAM_CP_RE(a0) # cpr = params->cp_re on t0
    #sw t0, CPR_OFFSET($fp) # store cpr on mem($fp + CPR_OFFSET)
    l.s $f0, PARAM_SEED_IM(a0) 
    s.s $f0, SEED_I_OFFSET($fp)  # store cpr on mem($fp + CPR_OFFSET)
    #lw t0, PARAM_CP_IM(a0) # cpi = params->cp_im on t2
    #sw t0, CPI_OFFSET($fp) # store cpi on mem($fp + CPI_OFFSET)
    li t0, 0        # t0 = 0
    sw t0, C_OFFSET($fp)  # store c = 0 on mem($fp + C_OFFSET) 
    sw t0, X_OFFSET($fp)  # store x = 0 on mem($fp + X_OFFSET)
    sw t0, Y_OFFSET($fp)  # store y = 0 on mem($fp + Y_OFFSET)
    sw t0, SI_OFFSET($fp) # store si = 0
    sw t0, SR_OFFSET($fp) # store sr = 0
    sw t0, ZI_OFFSET($fp) # store zi = 0
    sw t0, ZR_OFFSET($fp) # store zr = 0
    # This change its not really necessary, so it can be reverted
    l.s $f0, PARAM_UL_IM(a0)  # ci = parms->UL_im on t0
    #lw t0, PARAM_UL_IM(a0) # ci = parms->UL_im on t0
    s.s $f0, CI_OFFSET($fp) # store ci on mem($fp + CI_OFFSET)
    #sw t0, CI_OFFSET($fp)  # store ci on mem($fp + CI_OFFSET)
    l.s $f0, PARAM_UL_RE(a0)  # cr = parms->UL_re on t0
    #lw t0, PARAM_UL_RE(a0) # cr = parms->UL_re on t0
    s.s $f0, CR_OFFSET($fp) # store cr on mem($fp + CR_OFFSET)
    #sw t0, CR_OFFSET($fp)  # store cr on mem($fp + CR_OFFSET)
    
    li t0, 0
    sw t0, BUFF_LEN_OFFSET($fp) # store buff_len = 0

    ###############################################################
    
    ###############################################################
    # Store PGM header on buffer, this is "P2\nx_res\ny_res\nshades\n"
    
    addiu t0, $fp, BUFF_OFFSET  # buff_addr on t0
    lw t1, BUFF_LEN_OFFSET($fp)   # buff_len on t1

title:
    li t2, 0      # i = 0
title_loop:
    li t3, 3
    bge t2, t3, write_buffer # if (i >= 3) finish 
    la t3, header
    addu t3, t3, t2
    lb t3, 0(t3)    # header[i]
    addu t4, t0, t1
    sb t3, 0(t4)    # store header[i] on buff_addr[buff_len]
    addiu t1, t1, 1   # buff_len++
    addiu t2, t2, 1   # i++
    j title_loop

    sw t1,BUFF_LEN_OFFSET($fp)

    
write_buffer:  
  li v0, SYS_write
  li a0, 1
  la a1, header
  li a2, 3
  syscall
  //bltz v0, io_error     # if v0 < 0, io error
  
  j return
  sw zero, BUFF_LEN_OFFSET($fp) # reset buffer
  

io_error:
    move t0,v0
    li v0, SYS_write
    li a0, 2
    la a1, error_msg
    li a2, 11
    syscall

    move v0, t0     # return value -1
    j return

success:
    li v0, 0      # return value 0

return:
    ###############################################################
    # Pop stack frame
    move sp, $fp
    lw $fp, FP_OFFSET(sp) # loads mem(sp + FP_OFFSET) on $fp
    lw gp, GP_OFFSET(sp)  # loads mem(sp + GP_OFFSET) on gp
    addiu sp, sp, STACK_SZ  # pop stack pointer up
    ###############################################################

    jr ra
    
    .end mips32_plot

    .data
header: 
  .asciiz "P2\n"
line_break:
  .ascii "\n"
error_msg:
  .asciiz "i/o error.\n"
