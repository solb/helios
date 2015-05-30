#ifndef BOOT_BIOS_H_
#define BOOT_BIOS_H_

/*
 * Address space
 */

#define BIOS_MBR_SEGMENT 0x7c0
#define BIOS_MBR_LENGTH 512

/*
 * Service routine IRQs
 */

#define BIOS_IRQ_SCREEN 0x10
#define BIOS_IRQ_DISK   0x13
#define BIOS_IRQ_EISA   0x15 // Extended Industry "Standard" Architecture

/*
 * Service routine signatures
 */

#define BIOS_GPR_OPERATION %ah

#define BIOS_OP_SCREEN_MODE 0x0
#define BIOS_GPR_SCREEN_MODE %al

#define BIOS_OP_SCREEN_CURSOR 0x2
#define BIOS_GPR_SCREEN_CURSOR_PAGE %bh
#define BIOS_GPR_SCREEN_CURSOR_ROW %dh
#define BIOS_GPR_SCREEN_CURSOR_COL %dl

#define BIOS_OP_SCREEN_PUTC 0xe
#define BIOS_GPR_SCREEN_PUTC_CHAR %al

#define BIOS_GPR_DISK_RESULT %ah // 0 on success

#define BIOS_OP_DISK_XREAD 0x42
#define BIOS_GPR_DISK_XREAD_DRIVE %dl
#define BIOS_GPR_DISK_XREAD_STRUCT %si // %ds ptr, word-aligned

#define BIOS_OP_EISA_A20 0x24
#define BIOS_GPR_EISA_A20_FUNC %al

/*
 * Service routine arguments
 */

#define BIOS_SCREEN_MODE_40_25_BW      $0
#define BIOS_SCREEN_MODE_40_25_COLOR   $1
#define BIOS_SCREEN_MODE_80_25_BW      $2
#define BIOS_SCREEN_MODE_80_25_COLOR   $3
#define BIOS_SCREEN_MODE_320_200_COLOR $4
#define BIOS_SCREEN_MODE_320_200_BW    $5
#define BIOS_SCREEN_MODE_640_200_BW    $6
#define BIOS_SCREEN_MODE_MONO_ONLY     $7

/* "Disk Address Packet" describing a set of 512-byte sectors to load */
#define BIOS_STRUCT_DISK_XREAD_SIZE 0x10 // 1 byte
#define BIOS_STRUCT_DISK_XREAD_RESERVED 0x0 // 1 byte
// BIOS_STRUCT_DISK_XREAD_NUMSECTORS (2 bytes)
// BIOS_STRUCT_DISK_XREAD_POINTER (2 bytes)
// BIOS_STRUCT_DISK_XREAD_SEGMENT (2 bytes)
// BIOS_STRUCT_DISK_XREAD_FIRSTSECTOR (8 bytes)

#define BIOS_EISA_A20_DISABLE 0x0
#define BIOS_EISA_A20_ENABLE  0x1

/*
 * Service macros
 */

.macro bios_screen_mode mode
	movb \mode, BIOS_GPR_SCREEN_MODE
	movb $BIOS_OP_SCREEN_MODE, BIOS_GPR_OPERATION
	int $BIOS_IRQ_SCREEN
.endm

.macro bios_screen_cursor row col
	movb \row, BIOS_GPR_SCREEN_CURSOR_ROW
	movb \col, BIOS_GPR_SCREEN_CURSOR_COL
	movb $BIOS_OP_SCREEN_CURSOR, BIOS_GPR_OPERATION
	movb $0, BIOS_GPR_SCREEN_CURSOR_PAGE
	int $BIOS_IRQ_SCREEN
.endm

.macro bios_screen_putc char
	movb \char, BIOS_GPR_SCREEN_PUTC_CHAR
	movb $BIOS_OP_SCREEN_PUTC, BIOS_GPR_OPERATION
	int $BIOS_IRQ_SCREEN
.endm

.macro bios_disk_xread disk startsector numsectors destaddr
	pushw $0x0
	pushw $0x0
	pushw $0x0
	pushw \startsector
	pushw %ds
	pushw \destaddr
	pushw \numsectors
	subw $2, %sp
	movw %sp, %bp
	movb $BIOS_STRUCT_DISK_XREAD_RESERVED, 1(%bp)
	movb $BIOS_STRUCT_DISK_XREAD_SIZE, 0(%bp)
	movb $BIOS_OP_DISK_XREAD, BIOS_GPR_OPERATION
	movb \disk, BIOS_GPR_DISK_XREAD_DRIVE
	movw %ss, %bp
	movw %bp, %ds
	movw %sp, BIOS_GPR_DISK_XREAD_STRUCT
	int $BIOS_IRQ_DISK
	movw %sp, %bp
	movw 6(%bp), %ds
	addw (%bp), %sp
.endm

.macro bios_eisa_a20 func
	movb \func, BIOS_GPR_EISA_A20_FUNC
	movb $BIOS_OP_EISA_A20, BIOS_GPR_OPERATION
	int $BIOS_IRQ_EISA
.endm

#endif
