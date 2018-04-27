#include <sys/syscall.h>
#include <mips/regdef.h>


.data
  .align 2
  pgm: .asciiz "P\n"

.text
  .abicalls
  .align 2
  .globl mips32_plot
  .ent mips32_plot
mips32_plot:
  #creo stack frame con size 64 (por ahora)
  .frame  $fp, 64, ra       
  .set  noreorder
  .cpload t9
  .set  reorder
  subu  sp, sp, 64
  .cprestore 20
  #guardo los valores de ra y fp
  sw  ra,  52(sp)
  sw  $fp, 56(sp)
  move  $fp, sp 
  #guardo el parametro en el stack           
  sw a0, 64($fp)            
  
  #obtengo file descriptor y lo guardo en t0
  lh t0, 58(a0)
  #guardo file descriptor en el stack
  sw t0, 16($fp)
  la a0, pgm
  jal mystrlen
  move a2, v0                                   
  //lw a0, 16($fp)   #aca hay segfault                            
  //la a1, pgm                               
  //jal fprintf                                  


  .end mips32_plot

#mystrlen de ejemplo (no se si la podemos usar)
  .ent  mystrlen
mystrlen:
  .frame  $fp, 16, ra
  .set  noreorder
  .cpload t9
  .set  reorder
  subu  sp, sp, 16
  .cprestore 0
  sw  gp, 4(sp)
  sw  $fp, 8(sp)
  move  $fp, sp
  sw  a0, 16(sp)

  # Use v0 for the result.
  #
  li  v0, 0
mystrlen_loop:
  lb  t0, 0(a0)
  beqz  t0, mystrlen_return
  addiu a0, a0, 1
  addiu v0, v0, 1
  j mystrlen_loop

mystrlen_return:
  # Destruimos el frame.
  #
  lw  $fp, 8(sp)
  addu  sp, sp, 16

  # Retorno.
  #
  j ra
  .end  mystrlen
