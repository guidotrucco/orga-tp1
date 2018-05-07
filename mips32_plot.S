#include <sys/syscall.h>
#include <mips/regdef.h>


.data
  .align 2
  pgm: .asciiz "P2\n"

.text
  .abicalls
  .align 2
  .globl mips32_plot
  .ent mips32_plot
mips32_plot:
  .frame $fp, 64, ra
  .set noreorder
  .cpload t9
  .set reorder
  subu sp, sp, 64
  .cprestore 48
  sw $fp, 52(sp)
  sw ra, 56(sp)
  move $fp, sp                # Fin de creacion de SF
  sw a0, 64($fp)              # Guardo la variable params en el stack                  
  lw t0, 44(a0)               # Obtengo dir de fp en t0
  lh t0, 14(t0)               # Obtengo fd
  sw t0, 16($fp)              # Salvo fd en la region de argumentos
  la a0, pgm                  # Guardo la direccion del header de pgm en a0 para llamar a strlen
  jal my_strlen
  move a2,v0                 # Cargo len(pgm) en a2
  lw a0, 16($fp)              # Cargo fd en a0
  la a1, pgm                  # Cargo pgm en a1
  
  jal my_fprintf              # Imprimo el header                                 


  .end mips32_plot

#mystrlen de ejemplo (no se si la podemos usar)
  .ent  my_strlen
my_strlen:
  .frame $fp, 8, ra
  .set noreorder
  .cpload t9
  .set reorder
  subu sp, sp, 8
  .cprestore 0
  sw $fp, 4(sp)
  move $fp, sp
  sw a0, 8($fp)               # Fin de creacion de SF
  move t0, zero               # En t0 guardo el indice (i=0)
  b loop
increment:
  addiu t0, t0, 1             # i++
loop:
  addu t1, t0, a0             # Sumo el indice al inicio de la cadena
  lb t1, 0(t1)                # Cargo el caracter actual en t1
  bnez t1, increment          # Si el caracter es distinto de '\0'(0) incremento
  move v0, t0                 # LLegue al final de la cadena
  lw $fp, 4(sp)              
  lw gp, 0(sp)
  addu sp, sp, 8
  jr ra
  .end my_strlen
  .size my_strlen, .-my_strlen
  
.ent my_fprintf
my_fprintf:
  .frame $fp, 8, ra
  .set noreorder
  .cpload t9
  .set reorder
  subu sp, sp, 8
  .cprestore 0
  sw $fp, 4(sp)
  move $fp, sp
  sw a0, 8($fp)               # Fin de creacion de SF
  li v0, SYS_write
  syscall
  lw $fp, 4(sp)              
  lw gp, 0(sp)
  addu sp, sp, 8
  jr ra
  .end my_fprintf
.size my_fprintf, .-my_fprintf




