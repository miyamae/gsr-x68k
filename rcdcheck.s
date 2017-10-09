*=======================================*
* rcdcheck.s				*
*---------------------------------------*
* RCM stay check subroutine		*
*					*
*---------------------------------------*
*
*	COPYRIGHT 1990,91,92,93 HARPOON,TURBO and K.YONEZAWA , ALL RIGHTS RESERVED
*

O_title		equ	$0100
O_version	equ	$0104
O_staymark	equ	$0108

	.include	doscall.mac
	.include	IOCSCALL.MAC

	.xdef	_rcd_check
	.xdef	_rcd
	.xdef	_rcd_version

*=======================================*
* RCD stay check			*
*=======================================*
_rcd_check:
	movem.l	d0-d2/a0-a3,-(sp)

	DOS	_GETPDB
	movea.l	d0,a3
	lea.l	-$10(a3),a3

	suba.l	a1,a1
	IOCS	_B_SUPER		*into supervisor mode
	move.l	d0,-(sp)

	bra	rcd_check1

rcd_check0:
	movea.l	d0,a3
rcd_check1:
	move.l	4(a3),d0
	bne	rcd_check0

	moveq.l	#-1,d2
rcd_check2:
	cmp.b	4(a3),d2
	bne	rcd_check3

	lea.l	O_staymark+4(a3),a1
	cmpa.l	8(a3),a1
	bcc	rcd_check3

	move.l	O_title(a3),d0		*check title
	cmp.l	_rcd_title(pc),d0
	bne	rcd_check3

	cmpi.l	#$12345678,O_staymark(a3)
	beq	rcd_check50

rcd_check3:
	move.l	12(a3),d0
	beq	rcd_check90

	movea.l	d0,a3
	bra	rcd_check2

rcd_check50:
	move.l	O_version(a3),_rcd_version
	lea.l	O_title(a3),a1
	move.l	a1,_rcd

rcd_check90:
	move.l	(sp)+,d0
	bmi	rcd_check99
	movea.l	d0,a1
	IOCS	_B_SUPER		*return to user mode
rcd_check99:
	movem.l	(sp)+,d0-d2/a0-a3
	rts

*********************
	.even
_rcd:		.dc.l	0
_rcd_title:	.dc.b	"RCD "
_rcd_version:	.dc.b	0,0,0,0,0

	.even
	.end
