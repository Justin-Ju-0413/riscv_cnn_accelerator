    .section .text.init, "ax"
    .globl _start
    .type _start, @function

_start:
    la sp, _stack_top
    call main

1:
    j 1b
