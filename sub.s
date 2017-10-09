*********************************************************
*
*
*
*		�ėp�T�u���[�`���W
*
*
*			Programmed by T.MIYAMAE
*
*
*
*********************************************************

	.include	iocscall.mac
	.include	doscall.mac
	.include	const.h
	.include	gsr.mac

	.xdef	bin_adec
	.xdef	bin_adec2
	.xdef	left3keta
	.xdef	left5keta
	.xdef	left6keta
	.xdef	super_mode
	.xdef	user_mode
	.xdef	text_pset
	.xdef	text_fill
	.xdef	xy_to_address
	.xdef	set_text_color
	.xdef	text_clear
	.xdef	bg_clear
	.xdef	strcmp
	.xdef	strlen
	.xdef	key_detach_wait
	.xdef	sprite_off
	.xdef	child
	.xdef	con_off
	.xdef	con_on

	.text
	.even

*********************************************************
*
*	�o�C�i�����P�O�i��������
*		����	sp	���l.l
*				������擪�A�h���X.l
*
*********************************************************
bin_adec:
	move.w	sr,-(sp)
	link	a6,#0
	movem.l	d0-d3/a0-a1,-(sp)
	move.l	10(a6),d0
	move.l	14(a6),a0
	moveq	#9,d1
	lea	exp_tbl,a1
ex_loop0:
	clr.b	d2
	move.l	(a1)+,d3
ex_loop1:
	or	d3,d3
	sub.l	d3,d0
	bcs	xbcd_str
	addq.b	#1,d2
	bra	ex_loop1
xbcd_str:
	add.l	d3,d0
	add.b	#'0',d2
	move.b	d2,(a0)+
	dbra	d1,ex_loop0
	move.l	14(a6),a0
	move	#9,d0			;1 ���ڂ� 0 �͎c��
str0_loop0:
	cmpi.b	#'0',(a0)
	bne	str0_end
	move.b	#' ',(a0)+
	subq	#1,d0
	beq	str0_end
	bra	str0_loop0
str0_end:
	movem.l	(sp)+,d0-d3/a0-a1
	unlk	a6
	rtr

exp_tbl:				*�P�O�i���e�[�u��
	.dc.l	1000000000
	.dc.l	100000000
	.dc.l	10000000
	.dc.l	1000000
	.dc.l	100000
	.dc.l	10000
	.dc.l	1000
	.dc.l	100
	.dc.l	10
	.dc.l	1

*********************************************************
*
*	�o�C�i�����P�O�i��������i�󔒂�'0'�Ŗ��߂�j
*		����	sp	���l.l
*				������擪�A�h���X.l
*
*********************************************************
bin_adec2:
	move.w	sr,-(sp)
	link	a6,#0
	movem.l	d0-d3/a0-a1,-(sp)
	move.l	10(a6),d0
	move.l	14(a6),a0
	moveq	#9,d1
	lea	exp_tbl,a1
ex_loop0_:
	clr.b	d2
	move.l	(a1)+,d3
ex_loop1_:
	or	d3,d3
	sub.l	d3,d0
	bcs	xbcd_str_
	addq.b	#1,d2
	bra	ex_loop1_
xbcd_str_:
	add.l	d3,d0
	add.b	#'0',d2
	move.b	d2,(a0)+
	dbra	d1,ex_loop0_
	move.l	14(a6),a0
	move	#9,d0			;1 ���ڂ� 0 �͎c��
str0_loop0_:
	cmpi.b	#'0',(a0)
	bne	str0_end_
	move.b	#'0',(a0)+
	subq	#1,d0
	beq	str0_end
	bra	str0_loop0_
str0_end_:
	movem.l	(sp)+,d0-d3/a0-a1
	unlk	a6
	rtr

*********************************************************
*
*	bin_adec�̏o�͂��R�����l�߂ɕϊ�
*
*		����	a6.l	������擪�A�h���X
*		���^�[��a6.l	�ϊ���̕�����擪�A�h���X
*
*********************************************************
left3keta:
*     0000000111
* (a6)^     7^
	adda.l	#7,a6			; 0000000x11
	cmp.b	#' ',(a6)		;�R���̈ʒu���󔒂Ȃ珈�����J�n
	bne	lk3brk
	adda.l	#1,a6			; 00000001x1
	cmp.b	#' ',(a6)		;�Q���̈ʒu���󔒂Ȃ�P��������
	beq	@f
	move.b	#' ',2(a6)		;�G���h�R�[�h����
	clr.b	3(a6)			;�V�G���h�R�[�h
	bra	lk3brk
@@:	adda.l	#1,a6			; 000000011x
	move.b	#' ',1(a6)		;�G���h�R�[�h����
	move.b	#' ',2(a6)
	clr.b	3(a6)			;�V�G���h�R�[�h
lk3brk:	rts

*********************************************************
*
*	bin_adec�̏o�͂��T�����l�߂ɕϊ�
*
*		����	a6.l	������擪�A�h���X
*		���^�[��a6.l	�ϊ���̕�����擪�A�h���X
*
*********************************************************
left5keta:
*     0000011111
* (a6)^   5^
	addq.l	#5,a6			; 00000x1111
	cmp.b	#' ',(a6)		;�T���̈ʒu���󔒂Ȃ珈�����J�n
	bne	lk5brk

	addq.l	#1,a6			; 000001x111
	cmp.b	#' ',(a6)		;�S���̈ʒu���󔒂Ȃ�R��������
	beq	@f
	move.b	#' ',4(a6)		;�G���h�R�[�h����
	clr.b	5(a6)			;�V�G���h�R�[�h
	bra	lk5brk
@@:
	addq.l	#1,a6			; 0000011x11
	cmp.b	#' ',(a6)		;�R���̈ʒu���󔒂Ȃ�Q��������
	beq	@f
	move.b	#' ',3(a6)		;�G���h�R�[�h����
	move.b	#' ',4(a6)
	clr.b	5(a6)			;�V�G���h�R�[�h
	bra	lk5brk
@@:
	addq.l	#1,a6			; 00000111x1
	cmp.b	#' ',(a6)		;�Q���̈ʒu���󔒂Ȃ�P��������
	beq	@f
	move.b	#' ',2(a6)		;�G���h�R�[�h����
	move.b	#' ',3(a6)
	move.b	#' ',4(a6)
	clr.b	5(a6)			;�V�G���h�R�[�h
	bra	lk5brk
@@:
	addq.l	#1,a6			; 000001111x
	move.b	#' ',1(a6)		;�G���h�R�[�h����
	move.b	#' ',2(a6)
	move.b	#' ',3(a6)
	move.b	#' ',4(a6)
	clr.b	5(a6)			;�V�G���h�R�[�h
lk5brk:	rts

*********************************************************
*
*	bin_adec�̏o�͂��U�����l�߂ɕϊ�
*
*		����	a6.l	������擪�A�h���X
*		���^�[��a6.l	�ϊ���̕�����擪�A�h���X
*
*********************************************************
left6keta:
*     0000111111
* (a6)^  4^
	addq.l	#4,a6			; 0000x11111
	cmp.b	#' ',(a6)		;�U���̈ʒu���󔒂Ȃ珈�����J�n
	bne	lk6brk

	addq.l	#1,a6			; 00001x1111
	cmp.b	#' ',(a6)		;�T���̈ʒu���󔒂Ȃ�R��������
	beq	@f
	move.b	#' ',5(a6)		;�G���h�R�[�h����
	clr.b	6(a6)			;�V�G���h�R�[�h
	bra	lk6brk
@@:
	addq.l	#1,a6			; 000011x111
	cmp.b	#' ',(a6)		;�S���̈ʒu���󔒂Ȃ�R��������
	beq	@f
	move.b	#' ',4(a6)		;�G���h�R�[�h����
	move.b	#' ',5(a6)
	clr.b	6(a6)			;�V�G���h�R�[�h
	bra	lk6brk
@@:
	addq.l	#1,a6			; 0000111x11
	cmp.b	#' ',(a6)		;�R���̈ʒu���󔒂Ȃ�Q��������
	beq	@f
	move.b	#' ',3(a6)		;�G���h�R�[�h����
	move.b	#' ',4(a6)
	move.b	#' ',5(a6)
	clr.b	6(a6)			;�V�G���h�R�[�h
	bra	lk6brk
@@:
	addq.l	#1,a6			; 00000111x1
	cmp.b	#' ',(a6)		;�Q���̈ʒu���󔒂Ȃ�P��������
	beq	@f
	move.b	#' ',2(a6)		;�G���h�R�[�h����
	move.b	#' ',3(a6)
	move.b	#' ',4(a6)
	move.b	#' ',5(a6)
	clr.b	6(a6)			;�V�G���h�R�[�h
	bra	lk6brk
@@:
	addq.l	#1,a6			; 000001111x
	move.b	#' ',1(a6)		;�G���h�R�[�h����
	move.b	#' ',2(a6)
	move.b	#' ',3(a6)
	move.b	#' ',4(a6)
	move.b	#' ',5(a6)
	clr.b	6(a6)			;�V�G���h�R�[�h
lk6brk:	rts

*********************************************************
*
*	���s���[�h�؂�ւ�
*
*********************************************************
super_mode:
	move.l	a1,-(sp)
	suba.l	a1,a1
	IOCS	_B_SUPER
	move.l	d0,sspbuf
	move.l	(sp)+,a1
	rts
*---------------------------------------*
user_mode:
	move.l	a1,-(sp)
	movea.l	sspbuf,a1
	IOCS	_B_SUPER
	move.l	(sp)+,a1
	rts
*---------------------------------------*
sspbuf:	.dc.l	0

*********************************************************
*
*	�e�L�X�g��ʏ���
*
*********************************************************
text_clear:
	movem.l	d0/a1,-(sp)

	move.l	#$e8002a,a1
	move.w	#%01_1111_0000,(a1)
	move.l	#$e00000,a1

	move.w	#1024*1024/32,d0
@@:
	clr.l	(a1)+
	dbra	d0,@b

	movem.l	(sp)+,d0/a1
	rts

*********************************************************
*
*	�a�f��ʏ���
*
*********************************************************
bg_clear:
	movem.l	d1-d2,-(sp)

	move.l	#0,d1
	move.l	#0,d2
	IOCS	_BGTEXTCL
	move.l	#1,d1
	move.l	#0,d2
	IOCS	_BGTEXTCL

	movem.l	(sp)+,d1-d2
	rts

*********************************************************
*
*	�������r
*		����	a0.l	��r������P
*			a1.l	��r������Q
*
*********************************************************
strcmp:
*	movem.l	a0-a1,-(sp)

	tst.b	(a1)			;��r������͏I��肩�H
	beq	strcmp0			;�����ł���΃��[�v�𔲂���
	cmpm.b	(a1)+,(a0)+		;1������r
	beq	strcmp			;��v���Ă���ԌJ��Ԃ�

*	movem.l	(sp)+,a0-a1
	rts				;��v���Ȃ�����

strcmp0:
	cmpm.b	(a1)+,(a0)+		;���X�g�`�����X

*	movem.l	(sp)+,a0-a1
	rts

*********************************************************
*
*	������̒����𐔂���
*		����	a0.l	������擪�A�h���X
*		���^�[��d0.l	����
*
*********************************************************
strlen:
	moveq.l	#-1,d0			;�J�E���^�̏�����
strlen0:
	addq.l	#1,d0			;�J�E���g
	tst.b	(a0,d0.l)		;�I���R�[�h���H
	bne	strlen0			;�����łȂ���ΌJ��Ԃ�

	rts


************************************************
*
*	�e�L�X�g�ɓ_�`��i�P�U�F�Ή��j
*		����	d1.w = �w���W
*			d2.w = �x���W
*			d5.w = �J���[
*
************************************************
text_pset:
	movem.l	d3/a0,-(sp)

	bsr	xy_to_address
	bsr	set_text_color
	bset	d3,(a0)

	movem.l	(sp)+,d3/a0
	rts

************************************************
*
*	�e�L�X�g��`�h��ׂ��i�P�U�F�Ή��j
*		����	d1.w = ����w���W
*			d2.w = ����x���W
*			d3.w = �w�T�C�Y
*			d4.w = �x�T�C�Y
*			d5.w = �J���[
*
************************************************
text_fill:
	movem.l	d2/d4/d7,-(sp)
	move.w	d3,d7			;d0.w=�w�T�C�Y
	move.w	d1,d6			;d6.w=���[�w���W

tfly:					;���x�T�C�Y�񃋁[�v
tflx:					;�@���w�T�C�Y�񃋁[�v
	bsr	text_pset		;�@�@�_��ł�
	addq.w	#1,d1			;�@�@�w���W�C���N�������g
	dbra	d3,tflx			;�@����

	move.w	d7,d3			;�@�w�T�C�Y���Z�b�g
	move.w	d6,d1			;�@�w���W���Z�b�g
	addq.w	#1,d2			;�@�x���W�C���N�������g
	dbra	d4,tfly			;����

	movem.l	(sp)+,d2/d4/d7
	rts

************************************************
*
*	���W����e�L�X�g�u�q�`�l�A�h���X�ƃr�b�g�ʒu���Z�o
*		����	d1.w = �w���W
*			d2.w = �x���W
*		���^�[��a0.l = �A�h���X
*			d3.w = �r�b�g�ԍ�
*
************************************************
xy_to_address:
	movem.l	d1-d2/d4,-(sp)

	movea.l	#$e00000,a0

	mulu.w	#1024/8,d2		;�x���W���Z
	adda.l	d2,a0

	andi.l	#$0000ffff,d1
	divu.w	#8,d1			;�W�Ŋ���
	adda.w	d1,a0

	moveq.l	#0,d3
	swap.w	d1			;�]������o��
	move.w	d1,d4			;�V�|�i�W�Ŋ������]��j���r�b�g�ԍ�
	move.w	#7,d3
	sub.w	d4,d3

	movem.l	(sp)+,d1-d2/d4
	rts

************************************************
*
*	�e�L�X�g�`��F��ݒ�
*		����	d5.w = �J���[�i�O�`�P�T�j
*
************************************************
set_text_color:
	movem.l	d5,-(sp)

	rol.b	#4,d5			;0000_XXXX �� XXXX_0000
	add.w	#%01_0000_0000,d5
	move.w	d5,$e8002a		;�����A�N�Z�X�ݒ�

	movem.l	(sp)+,d5
	rts

************************************************
*
*	�L�[�𗣂��܂ő҂�
*
************************************************
key_detach_wait:
	move.l	d0,-(sp)
@@:
	IOCS	_B_KEYSNS
	tst.l	d0
	bne	@b

	move.l	(sp)+,d0
	rts

************************************************
*
*	�X�v���C�g������
*
************************************************
sprite_off:
	movem.l	d1/a1,-(sp)

	lea.l	$EB0006,a1
	move.w	#128-1,d1
@@:
	andi.w	#$FFFC,(a1)
	addq.l	#8,a1
	dbra	d1,@b

	movem.l	(sp)+,d1/a1
	rts


************************************************
*
*	�q�v���Z�X�N��
*
************************************************
child:
	link	a6,#-512		;512�o�C�g�̃��[�J���G���A
	movem.l	d1-d7/a0-a6,-(sp)

	movea.l	8(a6),a1		;�^����ꂽ�������
	lea.l	-512(a6),a0		;�@���[�J���G���A��
	move.w	#255-1,d0		;�@�ő�255�o�C�g
chld0:	move.b	(a1)+,(a0)+		;�@�R�s�[���Ă���
	dbeq	d0,chld0		;��㏑������邩��
	clr.b	(a0)			;�O�̂��߂̏I�[�R�[�h

	clr.l	-(sp)			;�����̊�
	pea.l	-256(a6)		;�p�����[�^���i�[�̈�
	pea.l	-512(a6)		;�R�}���h���C����
					;�@�t���p�X���i�[�̈�
	move.w	#2,-(sp)		;PATH����
	DOS	_EXEC			;
	tst.l	d0			;d0.l�����Ȃ�
	bmi	chld1			;�@�G���[

	clr.w	(sp)			;���[�h�����s
	DOS	_EXEC			;
chld1:	lea	14(sp),sp		;�X�^�b�N�␳ 4*3+2�o�C�g

	movem.l	(sp)+,d1-d7/a0-a6
	unlk	a6
	rts


************************************************
*
*	�W���o�́^�W���G���[�o�͂����_�C���N�g
*
************************************************
con_off:
	movem.l	d0-d1,-(sp)

	move.w	#ARCHIVE,-(sp)		;�w�肳�ꂽ�t�@�C����
	pea.l	filnam			;�@�V�K�쐬����
	DOS	_CREATE			;
	addq.l	#6,sp			;
	tst.l	d0			;�G���[�H
	bpl	wopen0			;�@�G���[���Ȃ���΃I�[�v������

	move.w	#WOPEN,-(sp)		;create�ŃG���[�����������Ƃ���
	pea.l	filnam			;�@open���g����
	DOS	_OPEN			;�@������x���C�g�I�[�v�����Ă݂�
	addq.l	#6,sp			;
	tst.l	d0			;�G���[�H
	bmi	ns_end			;�@�����Ȃ獡�x�����G���[�I��

wopen0:	move.w	d0,d1			;d1.w=�o�͐�t�@�C���n���h��

	move.w	#STDOUT,-(sp)		;�I�[�v�������t�@�C���n���h����
	move.w	d1,-(sp)		;�@�W���o�͂�
	DOS	_DUP2			;�@�����R�s�[
	addq.l	#4,sp			;
	tst.l	d0			;�G���[�H
	bmi	ns_end			;�@�����Ȃ�G���[�I��

	move.w	#STDERR,-(sp)		;�I�[�v�������t�@�C���n���h����
	move.w	d1,-(sp)		;�@�W���G���[�o�͂�
	DOS	_DUP2			;�@�����R�s�[
	addq.l	#4,sp			;
	tst.l	d0			;�G���[�H
	bmi	ns_end			;�@�����Ȃ�G���[�I��

	move.w	d1,-(sp)		;���܃I�[�v�������t�@�C���n���h����
	DOS	_CLOSE			;�@��������Ȃ�����
	addq.l	#2,sp			;�@�N���[�Y���Ă��܂�
ns_end:
	movem.l	(sp)+,d0-d1
	rts

filnam:	.dc.b	'NUL',0
	.even


************************************************
*
*	�W���o�́^�W���G���[�o�͂����ɖ߂�
*
************************************************
con_on:
	move.w	#STDOUT,-(sp)		;�W���o�͂��N���[�Y
	DOS	_CLOSE			;�i���蓖�Ă�con�ɖ߂�j
	addq.l	#2,sp			;
	move.w	#STDERR,-(sp)		;�W���G���[�o�͂��N���[�Y
	DOS	_CLOSE			;�i���蓖�Ă�con�ɖ߂�j
	addq.l	#2,sp			;

	rts


	.end
