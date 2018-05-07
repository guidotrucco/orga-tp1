#include <sys/syscall.h>
#include <mips/regdef.h>


.data
  .align 2
  p2: .asciiz "P2\n"
  buffer: .space 32

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
  la a0, p2                  # Guardo la direccion del header de pgm en a0 para llamar a strlen
  jal my_strlen
  move a2,v0                 # Cargo len(pgm) en a2
  lw a0, 16($fp)              # Cargo fd en a0
  la a1, p2                  # Cargo pgm en a1
  
  jal my_fprintf              # Imprimo el header 
  lw t0, 64($fp)
  lw a0, 32(t0)                                 # Cargo x_res
  jal itoa                                # x_res -> str
  la a0,buffer
  jal my_strlen
  move a2, v0                                   # Cargo len(number)
  lw a0, 16($fp)                                # Cargo fd
  la a1, buffer                                 # Cargo number
  jal my_fprintf # Imprimo "x_res"

  .end mips32_plot

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
  b loop_strlen
increment:
  addiu t0, t0, 1             # i++
loop_strlen:
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

.ent itoa
itoa:
  .frame $fp, 8, ra
  .set noreorder
  .cpload t9
  .set reorder
  subu sp, sp, 8
  .cprestore 0
  sw $fp, 4(sp)
  move $fp, sp
  sw a0, 8($fp)
  la   t0, buffer    # load buf
  add  t0, t0, 30   # seek the end
  sb   $0, 1(t0)     # null-terminated str
  li   t1, '0'  
  sb   t1, (t0)     # init. with ascii 0
  slt  t2, a0, 0   # keep the sign
  li   t3, 10        # preload 10
  beq  a0, 0, iend  # end if 0
  neg  a0, a0
loop_itoa:
  div  a0, t3       # a /= 10
  mflo a0
  mfhi t4            # get remainder
  add  t4, t4, t1  # convert to ASCII digit
  sb   t4, (t0)     # store it
  sub  t0, t0, 1    # dec. buf ptr
  bne  a0, 0, loop_itoa  # if not zero, loop
  addi t0, t0, 1    # adjust buf ptr
iend:
  beq  t2, 0, nolz  # was < 0?
  addi t0, t0, -1
  li   t1, '-'
  sb  t1, (t0)
nolz:
  lw $fp, 4(sp)              
  lw gp, 0(sp)
  addu sp, sp, 8
  move v0, t0      # return the addr.
  jr   ra           # of the string
  .end itoa
.size itoa, .-itoa


