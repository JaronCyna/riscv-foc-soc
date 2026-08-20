# crt0.s
.section .text.entry
.global _start

_start:
    # Initialize Stack Pointer to the top of your Data RAM (e.g., 8KB)
    la sp, _stack_top
    
    # Jump to your C main() function
    call main

    # Catch unintentional returns
1:  j 1b