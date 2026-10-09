/* netsurf.ld — links NetSurf at the browser slot (slot 14, 0x10000000,
 * 80 MB — see kernel/proc.c slot tables). Same layout contract as the
 * other user/ linker scripts. */
OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)
SECTIONS
{
    . = 0x10000000;
    .text : { *(.text*) }
    .rodata : { *(.rodata*) }
    .data : { *(.data*) }
    /* constructors: libnsfb surface registration runs via crt0_ns */
    .init_array : {
        __init_array_start = .;
        KEEP(*(.init_array*))
        __init_array_end = .;
    }
    .bss : { *(.bss*) *(COMMON) }
    /DISCARD/ : { *(.eh_frame .comment .note*) }
}
