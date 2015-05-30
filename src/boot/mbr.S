#include "bios.h"
#include "layout.h"

// Processor starts in real mode, so generate code for the 8086
.code16

// This section contains the bootsector, which is located within the MBR and gets loaded by the BIOS
.text

//
// Code
//

/* params:
 *  %dl drive
 */
.globl _start
_start:
	// Initialize the code segment to match the code's linkage
	ljmp $BIOS_MBR_SEGMENT, $bootsector // %cs = BIOS_MBR_SEGMENT

/* params:
 *  %dl drive
 */
bootsector:
	// Initialize the data segment to match the code segment
	movw %cs, %ax
	movw %ax, %ds // %ds = %cs

	// Place the stack
	movw $LAYOUT_STACK_SEGMENT, %ax
	movw %ax, %ss // %ss = LAYOUT_STACK_SEGMENT
	movw $LAYOUT_STACK_POINTER, %sp

	// Tell the BIOS to clear the screen
	bios_screen_mode BIOS_SCREEN_MODE_80_25_BW
	movb %dl, %cl // %cl = drive
	bios_screen_cursor $0, $0

	// Oh, hi Mark!
	movw $splash, %bx
	call puts
	movw $stack_ok, %bx
	call puts

	// Load the payload from the same disk the BIOS got *us* from
	movw $edata, %ax
	subw $BIOS_MBR_LENGTH, %ax // Subtract the MBR's sector
	call bytes_to_sectors
	bios_disk_xread %cl, $1, %ax, $LAYOUT_PAYLOAD_POINTER
	movb BIOS_GPR_DISK_RESULT, %al
	movw $load_ok, %bx
	movw $err_load_failed, %si
	call report_status

	// Put the payload in charge if we were able to load it
	movb %cl, %dl // %dl = drive
	testb %al, %al
	jz payload

	// We should never get here!
	movw $err_off_mbr_end, %bx
	call puts
	jmp . // Halt

/* params:
 *  %ax number of bytes
 * clobbers:
 *  %ax, %dx, %bx
 * returns:
 *  %ax number of sectors
 */
bytes_to_sectors:
	xorw %dx, %dx
	movw $BIOS_MBR_LENGTH, %bx
	divw %bx
	testw %dx, %dx
	setnzb %dl
	xorb %dh, %dh
	addw %dx, %ax
	ret

/* params:
 *  %al decision value
 *  %bx message on zero
 *  %si message on nonzero
 * clobbers:
 *  %bx, %al
 */
report_status:
	testb %al, %al
	jz _report_status
	movw %si, %bx
_report_status:
	call puts
	ret

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
load_ok:
	.asciz "Payload loaded from disk\r\n"
err_load_failed:
	.asciz "ERROR: Failed to load payload from disk\r\n"
err_off_mbr_end:
	.asciz "FATAL: Reached end of MBR; halting."

// 2-byte bootsector signature (expected by BIOS)
.section .bootsig, "a"
	.byte 0x55
	.byte 0xaa

// This section contains the payload, which gets loaded by our bootblock using a BIOS call
.data

//
// More data (if all went well...)
//

payload_ok:
	.asciz "Payload now executing\r\n"
err_off_payload_end:
	.asciz "FATAL: Reached end of payload; halting."

//
// More code (hopefully!)
//

/* params:
 *  %dl drive
 */
payload:
	movw $payload_ok, %bx
	call puts

	// We should never get here!
	movw $err_off_payload_end, %bx
	call puts
	jmp . // Halt
