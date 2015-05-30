#include "bios.h"
#include "controller.h"
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

	// Try up to two methods of enabling the A20 gate to access all of memory
	call enable_a20

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

/* clobbers:
 *  %ax, %bx, bootsig
 */
enable_a20:
	call test_a20
	jnz _enable_a20
	movw $a20_trying, %bx
	call puts
	bios_eisa_a20 $BIOS_EISA_A20_ENABLE
	call test_a20
	jnz _enable_a20
	movw $a20_syscontroller, %bx
	call puts
	movb $CONTROLLER_SYSTEM_PORT_A_A20_ENABLE, %ah
	call manage_a20_syscontroller
	call test_a20
_enable_a20:
	movb %al, %ch
	movw $a20_status, %bx
	call puts
	movw $a20_dis, %bx
	movw $a20_en, %si
	movb %ch, %al
	call report_status
	movw $a20_abled, %bx
	call puts
	ret

/* clobbers:
 *  %ax, %bx, bootsig
 * returns:
 *  %al whether A20 line is enabled
 *  ZF  logical inverse of %al
 */
test_a20:
	movw $0, %ax
	movw %ax, %es
	movw $0xffff, %ax
	movw %ax, %fs
	movw %ds, %bx
	shlw $4, %bx
	addw $bootsig, %bx
	movw %es:(%bx), %ax
	cmpw %fs:0x10(%bx), %ax
	setneb %al
	jne ret
	addw $0x101, %ax
	movw %ax, %es:(%bx)
	wbinvd
	cmpw %fs:0x10(%bx), %ax
	setneb %al
	ret

/* params:
 *  %ah desired A20 gate state
 * clobbers:
 *  %ax
 */
manage_a20_syscontroller:
	inb $CONTROLLER_SYSTEM_PORT_A, %al
	andb $0x1, %ah
	shlb $CONTROLLER_SYSTEM_PORT_A_A20_BIT, %ah
	orb %ah, %al
	outb %al, $CONTROLLER_SYSTEM_PORT_A
	ret

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
	.ascii "Booting HeliOS...\r\n\n"
stack_ok:
	.asciz "Stack initialized\r\n"
a20_trying:
	.ascii "Enabling A20..."
a20_bios:
	.asciz "trying BIOS..."
a20_syscontroller:
	.asciz "trying system controller..."
a20_status:
	.asciz "A20 is "
a20_dis:
	.asciz "dis"
a20_en:
	.asciz "en"
a20_abled:
	.asciz "abled\r\n"
load_ok:
	.asciz "Payload loaded from disk\r\n"
err_load_failed:
	.asciz "ERROR: Failed to load from disk\r\n"
err_off_mbr_end:
	.asciz "FATAL: Reached end of MBR; halting."

// 2-byte bootsector signature (expected by BIOS)
.section .bootsig, "a"
bootsig:
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
