OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    ITCM (rx)  : ORIGIN = 0x80000000, LENGTH = 64K
    DTCM (rwx) : ORIGIN = 0x90000000, LENGTH = 64K
}

SECTIONS
{
    .text : ALIGN(4)
    {
        KEEP(*(.text.init))
        *(.text .text.*)
        *(.rodata .rodata.*)
    } > ITCM

    .data : ALIGN(4)
    {
        *(.sdata .sdata.*)
        *(.data .data.*)
    } > DTCM AT > ITCM

    .bss (NOLOAD) : ALIGN(4)
    {
        *(.sbss .sbss.*)
        *(.bss .bss.*)
        *(COMMON)
    } > DTCM

    .stack (NOLOAD) : ALIGN(16)
    {
        . = ORIGIN(DTCM) + LENGTH(DTCM);
        _stack_top = .;
    } > DTCM

    /DISCARD/ :
    {
        *(.note .note.*)
        *(.comment)
        *(.riscv.attributes)
    }
}
