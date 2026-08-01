.section .text.init
.globl _start
_start:
    # Write 1 to GPIOA output register (0x10012008)
    # This sets LED0 on
    li t0, 0x10012000
    li t1, 1
    sw t1, 8(t0)
    
    # Read mhartid and store it to GPIOA output register
    # If GPIOA[1:0] == 0, mhartid == 0
    csrr t2, mhartid
    sw t2, 8(t0)
    
    # Infinite loop
1:  j 1b
