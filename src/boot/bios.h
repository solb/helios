#ifndef BOOT_BIOS_H_
#define BOOT_BIOS_H_

/*
 * Address space
 */

#define BIOS_MBR_SEGMENT 0x7c0

/*
 * Service routine IRQs
 */

#define BIOS_IRQ_SCREEN 0x10

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

/*
 * Service macros
 */

.macro bios_screen_mode mode
	movb $BIOS_OP_SCREEN_MODE, BIOS_GPR_OPERATION
	movb \mode, BIOS_GPR_SCREEN_MODE
	int $BIOS_IRQ_SCREEN
.endm

.macro bios_screen_cursor row col
	movb $BIOS_OP_SCREEN_CURSOR, BIOS_GPR_OPERATION
	movb $0, BIOS_GPR_SCREEN_CURSOR_PAGE
	movb \row, BIOS_GPR_SCREEN_CURSOR_ROW
	movb \col, BIOS_GPR_SCREEN_CURSOR_COL
	int $BIOS_IRQ_SCREEN
.endm

.macro bios_screen_putc char
	movb $BIOS_OP_SCREEN_PUTC, BIOS_GPR_OPERATION
	movb \char, BIOS_GPR_SCREEN_PUTC_CHAR
	int $BIOS_IRQ_SCREEN
.endm

#endif
