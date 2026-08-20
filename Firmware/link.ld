MEMORY
{
    /* Example: 8KB Instruction/Data BRAM starting at 0x00000000 */
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 8K
}

SECTIONS
{
    .text : {
        *(.text.entry)  /* Place _start first at address 0x0 */
        *(.text*)
        *(.rodata*)
    } > RAM

    .data : {
        *(.data*)
        *(.sdata*)
    } > RAM

    .bss : {
        *(.sbss*)
        *(.bss*)
    } > RAM

    /* Set stack at the very end of your RAM */
    .stack (NOLOAD) : {
        . = ALIGN(4);
        _stack_bottom = .;
        . = . + 0x800;  /* 2KB Stack space */
        _stack_top = .;
    } > RAM
}