
	.include	iocscall.mac
	.include	doscall.mac

TVRAM		equ	$e00000
_FNTADR		equ	$16

	.xdef	print_8x16font

	.text
	.even

*********************************************************
*
*	8x16�t�H���g�����񍂑��\�����[�`���i������Ή��j
*
*			����	d6.w=�w���W�i�W�h�b�g�P�ʁj
*				d7.w=�x���W�i�P�h�b�g�P�ʁj
*				a6.l=�\��������擪
print_8x16font:
*********************************************************
	movem.l	d0-d4/d6-d7/a1-a2/a6,-(sp)

	movea.l	#TVRAM,a2		;���W����
	lsl.l	#7,d7			;�@d7=d7*(1024/8)
	adda.l	d7,a2			;�@�x
	adda.w	d6,a2			;�@�w
	moveq.l	#0,d4

	move.w	#16-1,d3		;16�������[�v
loop:
	moveq.l	#0,d1
	move.b	(a6)+,d1		;d1.l=�|�C���^�ʒu�����R�[�h
	tst.b	d1			;�I�[�R�[�h���H
*	seq.b	d4
	bne	@f
	move.b	#1,d4
@@:
	tst.b	d4
	beq	@f
	move.b	#' ',d1
@@:
*	moveq.l	#8,d2			;FNTADR�����T�C�Y=16x16/8x16
*	IOCS	_FNTADR
*	movea.l	d0,a1			;a1.l=�����p�^�[���A�h���X

	move.w	d1,d2
	lsl.w	#4,d2
	lea.l	$f3a800,a1
	add.w	d2,a1

	move.b	15(a1),1024/8*15(a2)	;�e�L�X�g��������
	move.b	14(a1),1024/8*14(a2)	;	���p�^�[���������֕`���Ă���
	move.b	13(a1),1024/8*13(a2)
	move.b	12(a1),1024/8*12(a2)
	move.b	11(a1),1024/8*11(a2)
	move.b	10(a1),1024/8*10(a2)
	move.b	09(a1),1024/8*09(a2)
	move.b	08(a1),1024/8*08(a2)
	move.b	07(a1),1024/8*07(a2)
	move.b	06(a1),1024/8*06(a2)
	move.b	05(a1),1024/8*05(a2)
	move.b	04(a1),1024/8*04(a2)
	move.b	03(a1),1024/8*03(a2)
	move.b	02(a1),1024/8*02(a2)
	move.b	01(a1),1024/8*01(a2)
	move.b	00(a1),(a2)+

	dbra	d3,loop		***

break:
	movem.l	(sp)+,d0-d4/d6-d7/a1-a2/a6
	rts


	.end
