.code16
.text
.globl _start
_start:
	jmp .

// 2-byte bootsector signature (expected by BIOS)
.section .bootsig, "a"
	.byte 0x55
	.byte 0xaa
