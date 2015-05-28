#include "bios.h"
#include "layout.h"

// Processor starts in real mode, so generate code for the 8086
.code16

.text

//
// Code
//

/* params:
 *  %dl drive
 */
.globl _start
_start:
	ljmp $BIOS_MBR_SEGMENT, $bootsector // %cs = BIOS_MBR_SEGMENT

/* params:
 *  %dl drive
 */
bootsector:
	movw %cs, %ax
	movw %ax, %ds // %ds = %cs

	movw $LAYOUT_STACK_SEGMENT, %ax
	movw %ax, %ss // %ss = LAYOUT_STACK_SEGMENT
	movw $LAYOUT_STACK_POINTER, %sp

	bios_screen_mode BIOS_SCREEN_MODE_80_25_BW
	bios_screen_cursor $0, $0
	movw $splash, %bx
	call puts
	movw $stack_ok, %bx
	call puts

	movw $err_off_end, %bx
	call puts
	jmp .

/* params:
 *  %bx str
 * clobbers:
 *  %bx, %al
 */
puts:
	movb (%bx), %al
	testb %al, %al
	jz ret
	bios_screen_putc %al
	addw $1, %bx
	jmp puts

/* Helper to allow conditional returns (e.g. `jz ret') */
ret:
	ret

//
// Data
//

splash:
	.asciz "Booting HeliOS...\r\n\n"
stack_ok:
	.asciz "Stack initialized\r\n"
err_off_end:
	.asciz "ERROR: Reached end of MBR; halting."

// 2-byte bootsector signature (expected by BIOS)
.section .bootsig, "a"
	.byte 0x55
	.byte 0xaa
