*********************************************************
*
*
*
*
*	�f�r�q	�Z���N�^���[�h
*
*
*			Programmed by T-miyamae 1993,94
*
*
*
*
*********************************************************

	.include	iocscall.mac
	.include	doscall.mac
	.include	const.h
	.include	rcddef301.mac
	.include	gsr.mac

	.xdef		music_selector
	.xdef		pathbuf
	.xdef		drive

*---------------------------------------*

FILE_MAX	equ	1024
WINPOS		equ	2
WIDTH		equ	23
PATHCHARA	equ	'/'

GPIP		equ	$e88001		;GPIP���W�X�^
R00		equ	$e80000		;�����g�[�^��
R01		equ	$e80002		;���������I���ʒu
R02		equ	$e80004		;�����\���J�n�ʒu
R03		equ	$e80006		;�����\���I���ʒu
R04		equ	$e80008		;�����g�[�^��
R05		equ	$e8000a		;���������I���ʒu
R06		equ	$e8000c		;�����\���J�n�ʒu
R07		equ	$e8000e		;�����\���I���ʒu
R20		equ	$e80028		;���������[�h�^�\�����[�h����
R21		equ	$e8002a		;��������/׽���߰/�����ر��ڰݑI��
R22		equ	$e8002c		;���X�^�R�s�[����p
R23		equ	$e8002e		;�e�L�X�g��ʃA�N�Z�X�}�X�N�p�^��
CRTC		equ	$e80480		;�摜��荞��/�����ر/׽���߰����
TVRAM		equ	$e00000		;T-VRAM�A�h���X
TPALET		equ	$e82200		;�e�L�X�g�p���b�g�A�h���X
PCG		equ	$eb8000		;PCG�̈�A�h���X

*---------------------------------------*
*���X�^�R�s�[�J�n
RASCST	.macro
	.local	rs_lp
	ori.w	#$0700,sr		;���荞�݋֎~
rs_lp:	btst.b	#7,GPIP
	beq	rs_lp
	move.w	#%1000,CRTC		;���X�^�R�s�[�J�n
	.endm
*---------------------------------------*
*���X�^�R�s�[��~
RASCEND	.macro
	.local	re_lp
re_lp:	btst.b	#7,GPIP
	beq	re_lp
	move.w	#%0000,CRTC		;���X�^�R�s�[��~
	andi.w	#$f8ff,sr		;���荞�݋���
	.endm
*---------------------------------------*

	.text
	.even

music_selector:
*	jsr	scroll_down
*********************************************************
*
*	�����ݒ�
*
*********************************************************
	move.b	#1,kbclr_flag

*---------------------------------------*
*���߂ẴZ���N�^�N��
	tst.b	sel_fstart_flg		;���߂Ă̋N����
	beq	2f
	clr.b	sel_fstart_flg
	bsr	init_cd

	move.l	drive,d1		;
	move.w	d1,-(sp)		;
	DOS	_CHGDRV			;
	addq.l	#2,sp			;
	subq.l	#1,d0			;
	move.l	d0,drive_max		;LAST DIRVE�ԍ���o�^
*	move.l	#2,drive_max		;LAST DIRVE�ԍ���o�^
2:
*********************************************************
*
*	���C�����[�v
*
*********************************************************
ms_loop:
	tst.b	kbclr_flag
	bne	ttl_end

	tst.b	ttl
	beq	ttl_end
	move.w	fno,d0

	bsr	set_title		;�ȃ^�C�g����ǂݍ���
	bsr	print_title		;�ȃ^�C�g����\��
@@:
	addq.w	#1,fno

	move.w	file_c,d0
	cmp.w	fno,d0
	bgt	@f
	clr.b	ttl
@@:
ttl_end:

	jsr	sc55disp_ptn
	jsr	sc55disp_str
	jsr	comment
	jsr	level_meter_down
	jsr	speana_down

*---------------------------------------*
*�L�[�o�b�t�@�N���A
	tst.b	kbclr_flag
	beq	@@f
	IOCS	_B_KEYSNS
	tst.l	d0
	beq	@f
	IOCS	_B_KEYINP
	bra	s_break
@@:	clr.b	kbclr_flag
*---------------------------------------*
*�L�[���̓`�F�b�N
@@:	IOCS	_B_KEYSNS
	tst.l	d0
	beq	s_break
	move.b	#1,kbclr_flag
	IOCS	_B_KEYINP
	lsr.w	#8,d0
*---------------------------------------*
@@:	cmp.b	#$01,d0			;[ESC]=�I��
	bne	@f
	tst.b	mode			;�p�l�����[�h�Ȃ�
	beq	1f			;
	jsr	scroll_down		;
	jmp	return_display		;
1:	jmp	quit			;�Z���N�^���[�h�Ȃ�

@@:	cmp.b	#$6c,d0			;[F10]=�I��
	bne	@f
	tst.b	mode			;�p�l�����[�h�Ȃ�
	beq	1f			;
	jsr	scroll_down		;
	jmp	return_display		;
1:	jmp	quit			;�Z���N�^���[�h�Ȃ�
*---------------------------------------*
@@:	cmp.b	#$10,d0			;[TAB]=���t��~�I��
	bne	@f
	tst.b	mode			;�p�l�����[�h�Ȃ�
	beq	1f			;
	jsr	scroll_down		;
	jmp	return_display		;
1:	jmp	stop_and_quit		;�Z���N�^���[�h�Ȃ�

@@:	cmp.b	#$6b,d0			;[F9]=���t��~�I��
	bne	@f
	tst.b	mode			;�p�l�����[�h�Ȃ�
	beq	1f			;
	jsr	scroll_down		;
	jmp	return_display		;
1:	jmp	stop_and_quit		;�Z���N�^���[�h�Ȃ�
*---------------------------------------*
@@:	cmp.b	#$3e,d0			;[��]=�J�[�\�����ړ�
	bne	@f
	bsr	cur_down
	bra	s_break
@@:	cmp.b	#$3c,d0			;[��]=�J�[�\����ړ�
	bne	@f
	bsr	cur_up
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$38,d0			;[ROLLUP]=�P�y�[�W�i�߂�
	bne	@f
	bsr	roll_up
	bra	s_break
@@:	cmp.b	#$39,d0			;[ROLDWN]=�P�y�[�W�߂�
	bne	@f
	bsr	roll_down
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$37,d0			;[DEL]=�f�B���N�g���Ō��
	bne	@f
	bsr	go_end_dir
	bra	s_break
@@:	cmp.b	#$36,d0			;[HOME]=�f�B���N�g���擪��
	bne	@f
	bsr	go_top_dir
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$3f,d0			;[CLR]=�ꎞ��~�^���t�J�n�g�O��
	bne	@f
	jsr	stop_or_play
	bra	s_break
@@:	cmp.b	#$0f,d0			;[BS]=�ꎞ��~�^���t�J�n�g�O��
	bne	@f
	jsr	stop_or_play
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$40,d0			;t[/]=���t��~
	bne	@f
	IOCS	_B_SFTSNS
	btst.l	#0,d0			;[SHIFT]+t[/]=�t�F�[�h�A�E�g
	beq	1f
	jsr	fade_out
	bra	s_break
1:	jsr	music_end
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$41,d0			;t[*]=�ĉ��t�J�n
	bne	@f
	jsr	replay
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$1d,d0			;[RET]=���t�J�n
	bne	@f
	IOCS	_B_SFTSNS
	bsr	exec
	btst.l	#0,d0			;[SHIFT]+[RET]=���t�J�n���p�l��
	beq	@f
	jsr	scroll_down
	jmp	start_display
@@:	cmp.b	#$4e,d0			;[ENTER]=���t�J�n
	bne	@f
	IOCS	_B_SFTSNS
	bsr	exec
	btst.l	#0,d0			;[SHIFT]+[ENTER]=���t�J�n���p�l��
	beq	@f
	jsr	scroll_down
	jmp	start_display
*---------------------------------------*
@@:	cmp.b	#$35,d0			;[SPACE]=�J�[�\���ʒu�}�[�N���]
	bne	@f
	bsr	mark_cur
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$1e,d0			;[A]=�S�t�@�C���}�[�N���]
	bne	@f
	bsr	mark_all
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$3d,d0			;[��]=�e�f�B���N�g���ֈړ�
	bne	@f
	IOCS	_B_SFTSNS
	btst.l	#1,d0			;[CTRL]+[��]=�h���C�u�{�{
	beq	1f
	bsr	drive_inc
	bra	s_break
1:	btst.l	#2,d0			;[OPT1]+[��]=�h���C�u�{�{
	beq	1f
	bsr	drive_inc
	bra	s_break
1:	bsr	cd2parent
	bra	s_break
@@:	cmp.b	#$3b,d0			;[��]=�e�f�B���N�g���ֈړ�
	bne	@f
	IOCS	_B_SFTSNS
	btst.l	#1,d0			;[CTRL]+[��]=�h���C�u�|�|
	beq	1f
	bsr	drive_dec
	bra	s_break
1:	btst.l	#2,d0			;[OPT1]+[��]=�h���C�u�|�|
	beq	1f
	bsr	drive_dec
	bra	s_break
1:	bsr	cd2parent
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$0e,d0			;[\]=���[�g�f�B���N�g���ֈړ�
	bne	@f
	bsr	cd2root
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$42,d0			;t[-]=�f�B�X�v���C���[�h
	bne	@f
	jsr	scroll_down
	tst.b	fstart_flag
	bne	1f
	jmp	return_display
1:	jmp	start_display
*---------------------------------------*
@@:	cmp.b	#$4f,d0			;�e���L�[=�h���C�u�`�F���W
	bne	@f
	moveq.l	#0,d1
	bra	1f
@@:	cmp.b	#$4b,d0
	bne	@f
	moveq.l	#1,d1
	bra	1f
@@:	cmp.b	#$4c,d0
	bne	@f
	moveq.l	#2,d1
	bra	1f
@@:	cmp.b	#$4d,d0
	bne	@f
	moveq.l	#3,d1
	bra	1f
@@:	cmp.b	#$47,d0
	bne	@f
	moveq.l	#4,d1
	bra	1f
@@:	cmp.b	#$48,d0
	bne	@f
	moveq.l	#5,d1
	bra	1f
@@:	cmp.b	#$49,d0
	bne	@f
	moveq.l	#6,d1
	bra	1f
@@:	cmp.b	#$43,d0
	bne	@f
	moveq.l	#7,d1
	bra	1f
@@:	cmp.b	#$44,d0
	bne	@f
	moveq.l	#8,d1
	bra	1f
@@:	cmp.b	#$45,d0
	bne	@f
	move.l	#9,d1
	bra	1f
1:	bsr	change_drive
	bra	s_break
*---------------------------------------*
@@:
s_break:
	bra	ms_loop

*********************************************************
*
*	�t�@�C�����ꗗ�\��
*
*********************************************************
print_files:
	movem.l	d0-d1,-(sp)

	move.w	rolpos,d0

	move.w	#WIDTH-1,d2
@@:	bsr	print_fname
	addq.w	#1,d0
	dbra	d2,@b

	movem.l	(sp)+,d0-d1
	rts

*********************************************************
*
*	�t�@�C�����\���id0.w=�t�@�C���Ǘ��ԍ��j
*
*********************************************************
print_fname:
	movem.l	d0-d2/d6-d7/a1-a2/a6,-(sp)

	cmp.w	file_c,d0		;���݂��Ȃ��t�@�C���Ǘ��ԍ�
	bge	pn_end			;

	move.w	rolpos,d1		;�\����ʒ��ɔ[�܂鍀�ڂ��H
	cmp.w	d0,d1			;
	bgt	pn_end			;
	addi.w	#WIDTH,d1		;
	cmp.w	d0,d1			;
	ble	pn_end			;

	move.w	#%01_1111_0000,R21	;�}�[�N�t�@�C����
	lea.l	fmark,a0		;
	tst.b	0(a0,d0.w)		;
	beq	@f			;
	move.w	#%01_0010_0000,R21	;
@@:
	lea.l	files,a1		;���[�N�ʒu������
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			:*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a1			;

	move.l	d0,d1
	pea.l	namck_buf		;�t�@�C�����W�J
	move.l	a1,-(sp)		;
	DOS	_NAMECK			;
	addq.l	#8,sp			;

	lea.l	ncbuf_name,a6		;�t�@�C�����\��
	moveq.l	#1,d6			;
	moveq.l	#WINPOS-1,d7		;
	add.w	d1,d7			;
	sub.w	rolpos,d7		;
	move.w	d7,d2			;* d7*=20
	lsl.w	#4,d7			;*
	add.w	d2,d2			;*
	add.w	d2,d2			;*
	add.w	d2,d7			;*
	addi.w	#512+17,d7		;
	jsr	prs_print_12x16		;

	lea.l	ncbuf_ext,a6		;�g���q�\��
	moveq.l	#1+13,d6		;
	jsr	prs_print_12x16		;

pn_end:
	movem.l	(sp)+,d0-d2/d6-d7/a1-a2/a6
	rts

*********************************************************
*
*	�ȃ^�C�g���𓾂ă��[�N�Ɋi�[�id0.w=�t�@�C���Ǘ��ԍ��j
*
*********************************************************
set_title:
	movem.l	d0-d1/d5-d7/a0-a3/a6,-(sp)

	cmp.w	file_c,d0		;���݂��Ȃ��t�@�C���Ǘ��ԍ�
	bge	st_end			;

	lea.l	ftdone,a1		;���łɌ����I�����Ă���
	tst.b	0(a1,d0.w)		;
	bne	st_end			;

	move.b	#1,0(a1,d0.w)		;�^�C�g���������I�������t���O�n�m

	lea.l	files,a1		;���[�N�ʒu������
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			:*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a1			;

	lea.l	fnbuf,a2		;���ׂ����t�@�C�������Z�b�g
@@:	move.b	(a1)+,(a2)+		;
	bne	@b			;

	lea.l	titles,a3		;�������ރ��[�N�ʒu������
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=65
	lsl.w	#6,d1			;*
	add.w	d2,d1			;*
	adda.l	d1,a3			;

	lea.l	ftype,a1		;�f�B���N�g�����H
	move.w	d0,d1			;
	tst.b	0(a1,d1.w)		;
	beq	st_fmode		;

	lea.l	fnbuf,a0		;<..>���H
	cmpi.b	#'.',(a0)		;
	bne	st_wdir			;
	cmpi.b	#'.',1(a0)		;
	bne	st_wdir			;
	tst.b	2(a0)			;
	bne	st_wdir			;
@@:	lea.l	mes_parent,a2		;�@'<parent dir>'����������
@@:	move.b	(a2)+,(a3)+		;
	bne	@b			;
	bra	st_end
st_wdir:
	lea.l	mes_dir,a2		;'<dir>'����������
@@:	move.b	(a2)+,(a3)+		;
	bne	@b			;
	bra	st_end

st_fmode:				;�t�@�C���������ꍇ
	clr.w	-(sp)
	pea.l	fnbuf
	DOS	_OPEN
	addq.l	#6,sp
	move.l	d0,d7			;d7=�t�@�C���n���h��
	tst.l	d7
	bge	@f
	clr.b	(a3)			;�G���[�����������ꍇ
	bra	st_end
@@:
*---------------------------------------*
1:
	lea.l	fnbuf,a0
@@:	tst.b	(a0)+			;a0.l=�t�@�C�����̍Ō�
	bne	@b			;
	subq.l	#1,a0
@@:	cmp.b	#'.',-(a0)		;a0.l=�t�@�C�����̊g���q�ʒu
	bne	@b			;

	lea.l	ext,a6
2:
	cmpi.b	#$ff,(a6)
	beq	st_end
	cmpi.b	#'*',(a6)+
	bne	2b
	cmpi.b	#'.',(a6)
	bne	2b
	move.b	1(a0),d1
	UPPER	d1
	cmp.b	1(a6),d1
	bne	2b
	move.b	2(a0),d1
	UPPER	d1
	cmp.b	2(a6),d1
	bne	2b
	move.b	3(a0),d1
	UPPER	d1
	cmp.b	3(a6),d1
	bne	2b

	tst.b	5(a6)			;���[�h�O
	bne	1f			;
	move.b	6(a6),ttlpos		;
	move.b	7(a6),ttllen		;
	bra	@f
1:
	clr.b	ttlpos			;���[�h�O�ȊO
	move.b	#$ff,ttllen		;
@@:
*---------------------------------------*

	moveq.l	#0,d5
	moveq.l	#0,d6
	move.b	ttlpos,d5		;d5.b=�^�C�g���̂���ʒu
	move.b	ttllen,d6		;d6.b=�^�C�g���̒���

	clr.w	-(sp)			;�^�C�g���ʒu�փV�[�N
	move.l	d5,-(sp)		;
	move.w	d7,-(sp)		;
	DOS	_SEEK			;
	addq.l	#8,sp			:

	lea.l	buf,a2			;��Buf�ɏ�������
	move.l	d6,-(sp)		;
	move.l	a2,-(sp)		;
	move.w	d7,-(sp)		;
	DOS	_READ			;
	lea.l	10(sp),sp		;
*	clr.b	64(a2)			;

	move.w	d7,-(sp)
	DOS	_CLOSE
	addq.l	#2,sp

	tst.b	5(a6)			;���[�h�O
	bne	1f

	move.w	#64-1,d1
@@:	move.b	(a2)+,(a3)+		;�@�^�C�g������������
	dbeq	d1,@b			;
	clr.b	(a3)			;
	bra	st_end

1:					;���[�h�P(SMF)

	clr.b	(a3)
@@:	cmp.l	#buf+256,a2
	bge	st_end
	cmpi.b	#$ff,(a2)+		;�@$ff03����
	bne	@b			;
	cmpi.b	#$03,(a2)+		;
	bne	@b			;
	clr.w	d1
	move.b	(a2)+,d1
	subq.b	#1,d1
@@:	move.b	(a2)+,(a3)+		;�@�^�C�g������������
	dbeq	d1,@b			;
	clr.b	(a3)			;

st_end:
	movem.l	(sp)+,d0-d1/d5-d7/a0-a3/a6
	rts

*********************************************************
*
*	�ȃ^�C�g���\���id0.w=�t�@�C���Ǘ��ԍ��j
*
*********************************************************
print_title:
	movem.l	d0-d2/d6-d7/a6,-(sp)

	cmp.w	file_c,d0		;���݂��Ȃ��t�@�C���Ǘ��ԍ�
	bge	pt_end			;

	move.w	rolpos,d1		;�\����ʒ��ɔ[�܂鍀�ڂ��H
	cmp.w	d0,d1			;
	bgt	pt_end			;
	addi.w	#WIDTH,d1		;
	cmp.w	d0,d1			;
	ble	pt_end			;

	lea.l	ftdone,a1		;�܂������I�����Ă��Ȃ�
	tst.b	0(a1,d0.w)		;
	bne	@f			;
	bsr	set_title		;�@�^�C�g����������
@@:
	move.w	#%01_1111_0000,R21	;�}�[�N�t�@�C����
	lea.l	fmark,a0		;
	tst.b	0(a0,d0.w)		;
	beq	@f			;
	move.w	#%01_0010_0000,R21	;
@@:
	lea.l	titles,a6		;�ǂݏo�����[�N�ʒu������
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=65
	lsl.w	#6,d1			;*
	add.w	d2,d1			;*
	adda.l	d1,a6			;

	move.l	#20,d6			;d6=�\���w���W
	moveq.l	#WINPOS-1,d7		;d7=�\���x���W
	add.w	d0,d7			;
	sub.w	rolpos,d7		;
	move.w	d7,d2			;* d7*=20
	lsl.w	#4,d7			;*
	add.w	d2,d2			;*
	add.w	d2,d2			;*
	add.w	d2,d7			;*
	addi.w	#512+17,d7		;
	jsr	prs_print_12x16		;�\��

pt_end:
	movem.l	(sp)+,d0-d2/d6-d7/a6
	rts

*********************************************************
*
*	�ȃ^�C�g���ꗗ�\��
*
*********************************************************
print_ttls:
	movem.l	d0-d1,-(sp)

	move.w	rolpos,d0

	move.w	#WIDTH-1,d2
@@:	bsr	print_title
	addq.w	#1,d0
	dbra	d2,@b

	movem.l	(sp)+,d0-d1
	rts

*********************************************************
*
*	�J�[�\���\���^����
*
*********************************************************
put_cur:
	movem.l	d0-d1/a0,-(sp)

	movea.l	#(TVRAM+128*512)+128*34,a0
	move.w	curpos,d1
	addq.w	#1,d1
	mulu.w	#128*20,d1
	adda.l	d1,a0

*	move.w	#%01_1111_0000,R21	;�J�[�\���\��
	move.w	#%01_1001_0000,R21
	move.l	#%01111111_11111111_11111111_11111111,(a0)+
	.rept	14			;
	move.l	#$FFFFFFFF,(a0)+	;
	.endm				;
	move.l	#%11111111_11111111_11111111_11111110,(a0)+

**	move.w	curpos,d0
**	move.w	#%01_0001_0000,R21
**	bsr	kill_line

	bsr	put_dirpos

	movem.l	(sp)+,d0-d1/a0
	rts

*---------------------------------------*
kill_cur:
	movem.l	d0-d1/a0,-(sp)

	movea.l	#(TVRAM+128*512)+128*34,a0
	move.w	curpos,d1
	addq.w	#WINPOS-1,d1
	mulu.w	#128*20,d1
	adda.l	d1,a0

	move.w	#%01_1111_0000,R21	;�J�[�\������
	.rept	16			;
	clr.l	(a0)+			;
	.endm				;

**	move.w	curpos,d0
**	add.w	rolpos,d0
**	move.w	#%01_1111_0000,R21
**	bsr	print_fname
**	bsr	print_title

	movem.l	(sp)+,d0-d1/a0
	rts

*********************************************************
*
*	�J�[�\���㉺�ړ�
*
*********************************************************
cur_up:
	move.l	d0,-(sp)

	move.w	curpos,d0		;�J�[�\���ʒu���O��
	add.w	rolpos,d0		;
	tst.w	d0			;
	ble	cu_end			;

	tst.w	rolpos			;�X�N���[���ʒu���O��
	ble	1f			;
	cmp.w	#4,curpos		;
	bmi	2f			;
1:
	bsr	kill_cur		;�J�[�\���ړ�
	subq.w	#1,curpos		;
	bsr	put_cur			;
	bra	cu_end			;
2:
	bsr	roll_1down		;���[���_�E��
	subq.w	#1,rolpos		;
	move.w	rolpos,d0		;
	bsr	print_fname		;
	bsr	print_title		;
cu_end:
	move.l	(sp)+,d0
	rts

*---------------------------------------*
cur_down:
	movem.l	d0-d1,-(sp)

	move.w	curpos,d0		;����ȏ�t�@�C�����Ȃ���
	add.w	rolpos,d0		;
	addq.w	#1,d0			;
	move.w	file_c,d1		;
	cmp.w	d0,d1			;
	ble	cd_end			;

	move.w	rolpos,d0		;�t�@�C���c��S�ȉ���
	add.w	curpos,d0		;
	move.w	file_c,d1		;
	subq.w	#4,d1			;
	cmp.w	d0,d1			;
	ble	1f			;
	cmp.w	#WIDTH-4,curpos		;
	bge	2f			;
1:
	bsr	kill_cur		;�J�[�\���ړ�
	addq.w	#1,curpos		;
	bsr	put_cur			;
	bra	cd_end			;
2:
	bsr	roll_1up		;���[���A�b�v
	addq.w	#1,rolpos		;
	move.w	rolpos,d0		;
	addi.w	#WIDTH-1,d0		;
	bsr	print_fname		;
	bsr	print_title		;
cd_end:
	movem.l	(sp)+,d0-d1
	rts

*********************************************************
*
*	�P�s�X�N���[���A�b�v�^�_�E��
*
*********************************************************
roll_1up:
	movem.l	d1-d2,-(sp)

	bsr	kill_cur		;�J�[�\��������

*	bsr	wait_vdisp		;�X�N���[������
	move.w	#%1111,R21		;
	move.w	#$8d_88,d1		;
	move.w	#WIDTH*5-5,d2		;
@@:	move.w	d1,R22			;
	RASCST				;
	addi.w	#$01_01,d1		;
	dbra	d2,@b			;
	RASCEND				;

	move.b	#WIDTH-1,d0		;�ŉ��s������
	move.w	#%01_1111_0000,R21	;
	bsr	kill_line		;

	bsr	put_cur			;�J�[�\����\������

	movem.l	(sp)+,d1-d2
	rts

*---------------------------------------*
roll_1down:
	movem.l	d1-d2,-(sp)

	bsr	kill_cur		;�J�[�\��������

*	bsr	wait_vdisp		;�X�N���[������
	move.w	#%1111,R21		;
	move.w	#$f7_fc,d1		;
	move.w	#WIDTH*5-5,d2		;
@@:	move.w	d1,R22			;
	RASCST				;
	subi.w	#$01_01,d1		;
	dbra	d2,@b			;
	RASCEND				;

	clr.b	d0			;�ŏ�s������
	move.w	#%01_1111_0000,R21	;
	bsr	kill_line		;

	bsr	put_cur			;�J�[�\����\������

	movem.l	(sp)+,d1-d2
	rts

*********************************************************
*
*	�P��ʃ��[���A�b�v�^�_�E��
*
*********************************************************
roll_up:
	bsr	kill_cur		;�J�[�\��������
	move.w	#WIDTH-3-1,curpos	;�ŉ��s(+3)�ɃJ�[�\���Z�b�g

	move.w	file_c,d1
	subi.w	#WIDTH,d1
	bge	1f

	move.w	file_c,d1		;�t�@�C�������P��ʂɖ����Ȃ����
	subq.w	#1,d1			;�@���[���A�b�v���Ȃ�
	bmi	@f			;
	move.w	d1,curpos		;
	bra	4f			;
@@:	clr.w	curpos			;
	bra	4f			;
1:
	move.w	rolpos,d2		;
	cmp.w	d2,d1			;���ɃX�N���[���ʒu��MAX�Ȃ�
	bgt	2f			;
	move.w	#WIDTH-1,curpos		;�@�ŉ��s�ɃJ�[�\���Z�b�g
	bra	4f			;�@���[���A�b�v���Ȃ�
2:
	addi.w	#WIDTH,d2		;���[���A�b�v����Ƃ͂ݏo���Ă��܂��ꍇ
	cmp.w	d2,d1			;
	bgt	@f			;
	move.w	d1,rolpos		;�@�X�N���[���ʒu���ŉ��ʒu�ɕ␳
	move.w	#WIDTH-1,curpos		;�@�J�[�\���ʒu���ŉ��s�ɕ␳
	bra	3f			;
@@:
	addi.w	#WIDTH-3,rolpos		;�X�N���[���ʒu��ς���
3:
	bsr	clr_win			;�E�B���h�E�N���A
	bsr	print_files		;�t�@�C�����ꗗ�\��
	bsr	print_ttls		;�ȃ^�C�g���ꗗ�\��
4:
	bsr	put_cur			;�J�[�\����\��

	rts

*---------------------------------------*
roll_down:
	bsr	kill_cur		;�J�[�\��������

	tst.w	rolpos			;���ɃX�N���[���ʒu���O�Ȃ�
	bgt	@f			;
	clr.w	curpos			;�@�ŏ�s�ɃJ�[�\���Z�b�g
	bra	3f			;�@���[���_�E�����Ȃ�
@@:
	move.w	#3,curpos		;�ŏ�s(-3)�ɃJ�[�\���Z�b�g

	cmpi.w	#WIDTH-3,rolpos		;���[���_�E������Ƃ݂͂����Ă��܂��ꍇ
	bgt	1f			;
	clr.w	rolpos			;�@�X�N���[���ʒu���O�ɕ␳
	clr.w	curpos			;�@�J�[�\���ʒu���O�ɕ␳
	bra	2f			;
1:
	subi.w	#WIDTH-3,rolpos		;�X�N���[���ʒu��ς���
2:
	bsr	clr_win			;�E�B���h�E�N���A
	bsr	print_files		;�t�@�C�����ꗗ�\��
	bsr	print_ttls		;�ȃ^�C�g���ꗗ�\��
3:
	bsr	put_cur			;�J�[�\����\��

	rts

*********************************************************
*
*	�f�B���N�g���擪�^�Ō�ړ�
*
*********************************************************
go_top_dir:
	bsr	kill_cur		;�J�[�\��������

	clr.w	curpos			;�J�[�\���ʒu   = 0

	tst.w	rolpos			;���ɃX�N���[���ʒu���擪
	bgt	1f			;
	bra	2f			;
1:
	clr.w	rolpos			;�X�N���[���ʒu = 0
	bsr	clr_win			;�E�B���h�E�N���A
	bsr	print_files		;�t�@�C�����ꗗ�\��
	bsr	print_ttls		;�ȃ^�C�g���ꗗ�\��
2:
	bsr	put_cur			;�J�[�\����\��

	rts

*---------------------------------------*
go_end_dir:
	move.l	d1,-(sp)

	bsr	kill_cur		;�J�[�\��������

	move.w	#WIDTH-1,curpos		;�J�[�\���ʒu   = max
	move.w	file_c,d1
	subi.w	#WIDTH,d1
	bge	1f

	move.w	file_c,d1		;�t�@�C�������P��ʂɖ����Ȃ�
	subq.w	#1,d1			;
	bmi	@f			;
	move.w	d1,curpos		;
	bra	3f			;
@@:	clr.w	curpos			;
	bra	3f			;
1:
	cmp.w	rolpos,d1		;���ɃX�N���[���ʒu���Ō�
	bgt	2f			;
	bra	3f			;
2:
	move.w	d1,rolpos		;�X�N���[���ʒu = max
	bsr	clr_win			;�E�B���h�E�N���A
	bsr	print_files		;�t�@�C�����ꗗ�\��
	bsr	print_ttls		;�ȃ^�C�g���ꗗ�\��
3:
	bsr	put_cur			;�J�[�\����\��

	move.l	(sp)+,d1
	rts

*********************************************************
*
*	�s�������id0.b=pos�j
*
*********************************************************
kill_line:
	movem.l	d0-d2/a0,-(sp)

*	move.w	#%01_1111_0000,R21
	movea.l	#(TVRAM+128*512)+128*17,a0	;�擪�A�h���X�ݒ�
	move.l	#WINPOS-1,d1		;
	add.b	d0,d1			;
	mulu.w	#128*20,d1		;
	adda.l	d1,a0			;

	move.w	#16,d2			;�O�N���A����
@@:	.rept	16			;
	clr.l	(a0)+			;
	.endm				;
	adda.l	#64,a0			;
	dbra	d2,@b			;

	movem.l	(sp)+,d0-d2/a0
	rts

*********************************************************
*
*	�E�B���h�E�E�N���A
*
*********************************************************
clr_win:
	movem.l	d0-d1,-(sp)

	move.w	#%01_1111_1111,R21
	clr.w	d0			;�ŏ�s���O�N���A
	bsr	kill_line		;

	move.w	#$89_8d,d1		;�N���A�����s�����X�^�R�s�[
	move.w	#WIDTH*5-4,d2		;
@@:	move.w	d1,R22			;
	RASCST				;
	addq.w	#$00_01,d1		;
	dbra	d2,@b			;
	RASCEND				;

	movem.l	(sp)+,d0-d1
	rts

*********************************************************
*
*	�f�B���N�g�����̈ʒu��\��
*
*********************************************************
put_dirpos:
	movem.l	d0-d5/a6,-(sp)

*���l�\��
	moveq.l	#0,d2
	move.w	curpos,d2
	add.w	rolpos,d2
	addq.w	#1,d2
	pea.l	buf
	move.l	d2,-(sp)
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	buf,a6
	adda.l	#6,a6
	clr.b	4(a6)
	move.w	#%01_1111_0000,R21
	SSPRINT	#117,#512+006,a6

*�|�C���^�\��
*	subq.w	#1,d2
*	moveq.l	#0,d1
*	move.w	file_c,d1
*
*	move.l	#16,d0
*	lsl.l	d0,d1
*	lsl.l	d0,d2
*	divu.w	#77,d1
*	divu.w	d1,d2
*	andi.l	#$0000ffff,d2
*	addi.l	#435,d2			;�w���W
*
*	move.l	#16,d3			;�x���W
*	move.l	#118,d1			;�X�v���C�g�y�[�W
*	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
*	move.l	#$01+%0001_00_000000,d4	;�p�^�[���R�[�h
*	moveq.l	#3,d5			;�v���C�I���e�B
*	IOCS	_SP_REGST

	movem.l	(sp)+,d0-d5/a6
	rts

*********************************************************
*
*	�t�@�C���ꗗ�����
*
*********************************************************
get_file_list:
	movem.l	d0-d2/a0-a3/a6,-(sp)

	lea.l	files,a2
	lea.l	ftype,a3

	clr.w	file_d_c
	clr.w	file_f_c
	clr.w	file_c

	tst.b	nofd_flg		;FD���}��
	bne	flist_end

*---------------------------------------*
*�f�B���N�g��
s_dstart:
	move.w	#SUBDIR,-(sp)
	pea.l	nameptr
	pea.l	filebuf
	DOS	_FILES
	lea.l	10(sp),sp
	tst.l	d0
	bge	put_dname
	bra	s_file
s_dnext:
	pea.l	filebuf
	DOS	_NFILES
	addq.l	#4,sp
	tst.l	d0
	bge	put_dname
	bra	s_file

put_dname:
	lea.l	fname,a0		;<.>�Ȃ�X�L�b�v
	cmpi.b	#'.',(a0)		;
	bne	@f			;
	tst.b	1(a0)			;
	beq	pd_skip			;
@@:
	move.b	#1,(a3)+		;FileType=dir

	lea.l	fname,a1
	lea.l	files,a2		;�������ރ��[�N�ʒu������
	moveq.l	#0,d1			;
	move.w	file_c,d1		;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			:*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a2			;

@@:	move.b	(a1)+,(a2)+		;���[�N�ɏ�������
	bne	@b			;
	add.w	#1,file_d_c
	add.w	#1,file_c
pd_skip:
	bra	s_dnext

s_file:
*---------------------------------------*
*�f�B���N�g���\�[�g
	moveq.l	#0,d1
	move.w	file_d_c,d1

	pea.l	_compare_str
	move.l	#24,-(sp)
	move.l	d1,-(sp)
	pea.l	files
	jsr	_qsort
	lea.l	16(sp),sp

*---------------------------------------*
*�t�@�C��
	lea.l	ext,a6
s_fstart:
@@:	cmpi.b	#$ff,(a6)		;���̊g���q������ʒu�Ɉړ�
	beq	search_end		;
	cmpi.b	#'*',(a6)+		;
	bne	@b			;
	cmpi.b	#'.',(a6)		;
	bne	@b			;

	move.w	#ARCHIVE,-(sp)
	subq.l	#1,a6
	move.l	a6,-(sp)
	addq.l	#1,a6
	pea.l	filebuf
	DOS	_FILES
	lea.l	10(sp),sp

	tst.l	d0
	bge	put_fname
	bra	s_fstart

s_fnext:
	pea.l	filebuf
	DOS	_NFILES
	addq.l	#4,sp
	tst.l	d0
	bge	put_fname
	bra	s_fstart

put_fname:
	clr.b	(a3)+			;FileType=file

	lea.l	fname,a1
	lea.l	files,a2		;�������ރ��[�N�ʒu������
	moveq.l	#0,d1			;
	move.w	file_c,d1		;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			;*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a2			;

@@:	move.b	(a1)+,(a2)+		;���[�N�ɏ�������
	bne	@b			;

	add.w	#1,file_f_c
	add.w	#1,file_c
	bra	s_fnext

search_end:
*---------------------------------------*
*�t�@�C���\�[�g
	moveq.l	#0,d1
	move.w	file_f_c,d1

	moveq.l	#0,d0
	move.w	file_d_c,d0
	lea.l	files,a1		;�t�@�C�����ʒu
	move.w	d0,d2			;* d0*=24
	lsl.w	#3,d0			:*
	lsl.w	#4,d2			;*
	add.w	d2,d0			;*
	adda.l	d0,a1			;

	pea.l	_compare_str
	move.l	#24,-(sp)
	move.l	d1,-(sp)
	move.l	a1,-(sp)
	jsr	_qsort
	lea.l	16(sp),sp
flist_end:
	movem.l	(sp)+,d0-d2/a0-a3/a6
	rts

*********************************************************
*
*	�edir�Ɉړ��������̃J�[�\���ʒu�ݒ�
*
*********************************************************
set_curpos:
	movem.l	d0-d2/a0-a2,-(sp)

	lea.l	files,a1
	moveq.l	#0,d2

	move.w	file_c,d0		;���O��dir�Ɠ������O��T��
	subq.w	#1,d0			;
2:	lea.l	dirname,a0		;
	movea.l	a1,a2			;
	jsr	strcmp			;�@��r
	beq	@f			;�@�@��v�����甲����
	movea.l	a2,a1			;
	adda.l	#24,a1			;�@a1.l=���̃t�@�C�����ʒu
	addq.w	#1,d2			;�@d2.w=�t�@�C���Ǘ��ԍ�++
	dbra	d0,2b			;
	tst.b	d0			;�@�O�̂��ߍŌ�܂Ō�����Ȃ����
	ble	sc_end			;�@�@������
@@:
*---------------------------------------*
	cmpi.w	#WIDTH,file_c
	ble	2f

	cmpi.w	#WIDTH/2,d2
	ble	2f

	move.w	file_c,d0
	subi.w	#WIDTH/2,d0
	cmp.w	d0,d2
	bge	3f
1:
	subi.w	#WIDTH/2,d2
	move.w	d2,rolpos
	move.w	#WIDTH/2,curpos
	bra	sc_end
2:
	clr.w	rolpos
	move.w	d2,curpos
	bra	sc_end
3:
	move.w	file_c,d0
	subi.w	#WIDTH,d0
	move.w	d0,rolpos
	move.w	file_c,d0
	sub.w	d2,d0
	move.w	#WIDTH/2,d1
	sub.w	d0,d1
	addi.w	#WIDTH/2+1,d1
	move.w	d1,curpos

sc_end:
	movem.l	(sp)+,d0-d2/a0-a2
	rts

*********************************************************
*
*	�f�B���N�g�����ς�������̏���
*
*********************************************************
init_cd:
	movem.l	d0-d3/a0-a1,-(sp)

*�z�񏉊���
	lea.l	ftdone,a1
	move.w	#FILE_MAX-1,d1
@@:	clr.b	(a1)+
	dbra	d1,@b

	lea.l	ftype,a1
	move.w	#FILE_MAX-1,d1
@@:	clr.b	(a1)+
	dbra	d1,@b

	lea.l	fmark,a1
	move.w	#FILE_MAX-1,d1
@@:	clr.b	(a1)+
	dbra	d1,@b

*�ϐ�������
	move.b	#1,ttl
	clr.w	fno
	clr.w	mark_c
	clr.w	curpos
	clr.w	rolpos

	bsr	get_file_list
*
	moveq.l	#0,d1			;�t�@�C�����̕\��
	move.w	file_c,d1		;
	pea.l	buf			;
	move.l	d1,-(sp)		;
	jsr	bin_adec		;
	addq.l	#8,sp			;
					;
	lea.l	buf,a6			;
	adda.l	#6,a6			;
	clr.b	4(a6)			;
	move.w	#%01_1111_0000,R21	;
	SSPRINT	#122,#512+006,a6	;

	tst.b	nofd_flg		;-FD���}��- �\��
	beq	1f			;
	lea.l	path,a2			;
	lea.l	drive_data,a3		;
	move.l	drive,d1		;
	move.b	0(a3,d1.l),(a2)+	;
	lea.l	mes_nofd,a1		;
@@:	move.b	(a1)+,(a2)+		;
	bne	@b			;
	bra	2f			;
1:
	DOS	_CURDRV			;�J�����g�h���C�u�𓾂�
	move.l	d0,drive		;
	pea	pathbuf			;�J�����g�p�X�𓾂�
	clr.w	-(sp)			;
	DOS	_CURDIR			;
	addq.l	#6,sp			;

	lea.l	pathbuf,a1		;path�ɃJ�����g�p�X����������
	lea.l	path,a2			;
	lea.l	drive_data,a3		;�@�h���C�u����t����
	move.l	drive,d1		;
	move.b	0(a3,d1.l),(a2)+	;
	move.b	#':',(a2)+		;
	move.b	#PATHCHARA,(a2)+	;�@���[�g�� / ��t����
1:	cmp.b	#'\',(a1)		;�@\ �� / �ɒu��������
	bne	@f			;
	move.b	#PATHCHARA,(a2)+	;
	addq.l	#1,a1			;
@@:	move.b	(a1)+,(a2)+		;
	bne	1b			;
2:
	SPRINT	#005,#512+019,#mes_43space
	SPRINT	#005,#512+019,#path	;�p�X�\��

	tst.b	topar_flg		;�e�f�B���N�g���ւ̈ړ��Ȃ炻�̏���
	beq	@f			;
	clr.b	topar_flg		;
	bsr	set_curpos		;
@@:
	bsr	clr_win

	bsr	print_files		;�t�@�C���ꗗ�̕\��

*	move.w	rolpos,d0		:�^�C�g���ꗗ�̕\��
*	move.w	#WIDTH,d1		;
*@@:	bsr	print_title		;
*	addq.w	#1,d0			;
*	dbra	d1,@b			;

	moveq.l	#0,d0
	move.l	curpos,d0
	add.l	rolpos,d0
	bsr	set_title
	bsr	put_cur

	movem.l	(sp)+,d0-d3/a0-a1
	rts

*********************************************************
*
*	�f�B���N�g���ړ��ia0.l=�ړ��������f�B���N�g�����j
*
*********************************************************
change_dir:
	movem.l	d0-d1/a0-a2,-(sp)

	lea.l	path,a1			;���O�ɂ����f�B���N�g�������L��
@@:	tst.b	(a1)+			;
	bne	@b			;
@@:	cmpi.b	#PATHCHARA,-(a1)	;
	bne	@b			;
	addq.l	#1,a1			;
	lea.l	dirname,a2		;
@@:	move.b	(a1)+,(a2)+		;
	bne	@b			;

	bsr	kill_cur

	move.l	a0,-(sp)
	DOS	_CHDIR			;�J�����g�p�X�ړ�
	addq.l	#4,sp

	cmpi.b	#'.',(a0)		;<..>���H
	bne	1f			;
	cmpi.b	#'.',1(a0)		;
	bne	1f			;
	clr.b	topar_flg		;
	tst.b	2(a0)			;
	bne	1f			;
	move.b	#1,topar_flg		;
1:
	bsr	init_cd

	movem.l	(sp)+,d0-d1/a0-a2
	rts

*********************************************************
*
*	���[�h�����t
*
*********************************************************
load_and_play:
	movem.l	d0-d1/a0-a2/a6,-(sp)

	lea.l	files,a1		;���[�N�ʒu������
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			:*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a1			;

	lea.l	fnbuf,a2		;���ׂ����t�@�C�������Z�b�g
@@:	move.b	(a1)+,(a2)+		;
	bne	@b			;

	lea.l	fnbuf,a0
@@:	tst.b	(a0)+			;a0.l=�t�@�C�����̍Ō�
	bne	@b			;
	subq.l	#1,a0
@@:	cmp.b	#'.',-(a0)		;a0.l=�t�@�C�����̊g���q�ʒu
	bne	@b			;

*---------------------------------------*
*�R�}���h���C������������

	lea.l	ext,a6
2:
	cmpi.b	#$ff,(a6)
	beq	st_end
	cmpi.b	#'*',(a6)+
	bne	2b
	cmpi.b	#'.',(a6)
	bne	2b
	move.b	1(a0),d1
	UPPER	d1
	cmp.b	1(a6),d1
	bne	2b
	move.b	2(a0),d1
	UPPER	d1
	cmp.b	2(a6),d1
	bne	2b
	move.b	3(a0),d1
	UPPER	d1
	cmp.b	3(a6),d1
	bne	2b

	addq.l	#8,a6

	lea.l	comline,a2

@@:	move.b	(a6)+,(a2)+
	bne	@b
	subq.l	#1,a2
	move.b	#' ',(a2)+
	lea.l	fnbuf,a6
@@:	move.b	(a6)+,(a2)+
	bne	@b

	move.w	#%01_0010_0000,R21
	SSPRINT	#024,#512+006,#mes_messpc
	SSPRINT	#024,#512+006,#mes_loading
	jsr	con_off			;�R���\�[���o�� OFF
	pea.l	comline			;���s
	jsr	child			;
	addq.l	#4,sp			;
	jsr	con_on			;�R���\�[���o�� ON
	SSPRINT	#024,#512+006,#mes_messpc

	movem.l	(sp)+,d0-d1/a0-a2/a6
	rts

*********************************************************
*
*	���s
*
*********************************************************
exec:
	movem.l	d0/a2,-(sp)

	tst.w	file_c			;�t�@�C���������h���C�u�H
	beq	exec_end		;

	move.w	curpos,d0
	add.w	rolpos,d0

	lea.l	ftype,a2		;�f�B���N�g����
	tst.b	0(a2,d0.w)		;
	beq	@f			;

	lea.l	files,a0		;a0=�f�B���N�g����
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			:*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a0			;
	bsr	change_dir		;�f�B���N�g���ړ�
	bra	exec_end		;
@@:
	bsr	load_and_play		;���[�h�����t
	bsr	cur_down		;�J�[�\�����ЂƂi�߂�
exec_end:
	movem.l	(sp)+,d0/a2
	rts

*********************************************************
*
*	�}�[�N���\��
*
*********************************************************
print_mark_count:
	movem.l	d1/a6,-(sp)

	move.w	#%01_1111_0000,R21
	moveq.l	#0,d1
	move.w	mark_c,d1
	tst.b	d1
	bgt	1f
	SSPRINT	#099,#512+006,#mes_17spc
	bra	9f
1:	pea.l	buf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	buf,a6
	adda.l	#6,a6
	clr.b	4(a6)
	move.w	#%01_1111_0000,R21
	SSPRINT	#099,#512+006,a6
	SSPRINT	#104,#512+006,#mes_mark
9:
	movem.l	(sp)+,d1/a6
	rts

*********************************************************
*
*	�}�[�N���]�����id0.w=�t�@�C���Ǘ��ԍ��j
*
*********************************************************
file_mark:
	movem.l	d0/a0,-(sp)

	lea.l	ftype,a0		;�f�B���N�g���Ȃ�}�[�N���Ȃ�
	tst.b	0(a0,d0.w)		;
	bne	2f			;

	lea.l	fmark,a0
	tst.b	0(a0,d0.w)
	bne	1f
	move.b	#1,0(a0,d0.w)		;�}�[�N���Z�b�g
	addq.w	#1,mark_c		;
	bra	2f
1:
	clr.b	0(a0,d0.w)		;�}�[�N������
	subq.w	#1,mark_c		;
2:
	movem.l	(sp)+,d0/a0
	rts

*********************************************************
*
*	�J�[�\���ʒu�}�[�N���]
*
*********************************************************
mark_cur:
	movem.l	d0-d1/a0/a6,-(sp)

	tst.w	file_c			;�t�@�C�����P���Ȃ���΃X�L�b�v
	beq	9f			;

	move.w	curpos,d0
	move.w	#%01_1111_0000,R21
	bsr	kill_line
	add.w	rolpos,d0
	bsr	file_mark
	bsr	print_mark_count
	bsr	print_fname
	bsr	print_title
	bsr	cur_down
9:
	movem.l	(sp)+,d0-d1/a0/a6
	rts

*********************************************************
*
*	�S�t�@�C���}�[�N���]
*
*********************************************************
mark_all:
	move.l	d0,-(sp)

	move.w	file_c,d0
	tst.w	d0			;�t�@�C�����P���Ȃ���΃X�L�b�v
	beq	9f			;
	subq.w	#1,d0
@@:	bsr	file_mark
	dbra	d0,@b

	bsr	print_mark_count
	bsr	clr_win
	bsr	print_files
	bsr	print_ttls
	bsr	put_cur
9:
	move.l	(sp)+,d0
	rts

*********************************************************
*
*	���[�g�f�B���N�g���ֈړ�
*
*********************************************************
cd2root:
	move.l	a0,-(sp)

	tst.w	file_c			;�t�@�C�����P���Ȃ���΃X�L�b�v
	beq	9f			;
	lea.l	path,a0			;�J�����g�����[�g�Ȃ�X�L�b�v
	tst.b	3(a0)			;
	beq	9f			;

	lea.l	str_root_dir,a0
	bsr	change_dir
9:
	move.l	(sp)+,a0
	rts

*********************************************************
*
*	�e�f�B���N�g���ֈړ�
*
*********************************************************
cd2parent:
	move.l	a0,-(sp)

	tst.w	file_c			;�t�@�C�����P���Ȃ���΃X�L�b�v
	beq	9f			;
	lea.l	path,a0			;�J�����g�����[�g�Ȃ�X�L�b�v
	tst.b	3(a0)			;
	beq	9f			;

	lea.l	str_parent_dir,a0
	bsr	change_dir
9:
	move.l	(sp)+,a0
	rts

*********************************************************
*
*	�h���C�u�ړ��id1.l=�ړ��������h���C�u�j
*
*********************************************************
change_drive:
	movem.l	d0-d2,-(sp)

	clr.b	nofd_flg

	move.l	d1,d2
	addi.l	#$00_01,d2
	move.w	d2,-(sp)		;FD���}���H
	DOS	_DRVCTRL
	addq.l	#2,sp
	btst.l	#1,d0
	bne	@f
	move.b	#1,nofd_flg
	bra	8f
@@:
	move.w	d1,-(sp)
	DOS	_CHGDRV
	addq.l	#2,sp
8:
	move.l	d1,drive
	bsr	init_cd

	movem.l	(sp)+,d0-d2
	rts

*********************************************************
*
*	�h���C�u�C���N�������g�^�f�N�������g
*
*********************************************************
drive_inc:
	movem.l	d0-d1,-(sp)

	move.l	drive,d1
	move.l	drive_max,d0

	cmp.l	d0,d1
	blt	@f
	moveq.l	#0,d1
	bra	1f
@@:
	addq.l	#1,d1
1:	move.l	d1,drive

	bsr	change_drive

	movem.l	(sp)+,d0-d1
	rts

*---------------------------------------*
drive_dec:
	movem.l	d0-d1,-(sp)

	move.l	drive,d1
	move.l	drive_max,d0

	tst.l	d1
	bgt	@f
	move.l	d0,d1
	bra	1f
@@:
	subq.l	#1,d1
1:	move.l	d1,drive

	bsr	change_drive

	movem.l	(sp)+,d0-d1
	rts

*********************************************************
*
*	�f�[�^�̈�
*
*********************************************************
	.data
	.even
i:		.dc.l	0
curpos:		.dc.w	0		;�J�[�\���ʒu
rolpos:		.dc.w	0		;�X�N���[���ʒu
file_c:		.dc.w	0		;�t�@�C���̐�
file_d_c:	.dc.w	0
file_f_c:	.dc.w	0
mark_c:		.dc.w	0		;�}�[�N�t�@�C���̐�
fno:		.dc.w	0		;�Ȗ������������̃t�@�C���̊Ǘ��ԍ�
ttl:		.dc.b	0
sel_fstart_flg:	.dc.b	1
topar_flg:	.dc.b	0
cdf:		.dc.b	1		;�J�����g�f�B���N�g���`�F���W�t���O
nofd_flg:	.dc.b	0		;�J�����g�h���C�u�ɂe�c���}���t���O
crlf:		.dc.b	CR,LF,0
chr_slash:	.dc.b	'/',0
*---------------------------------------*
*�t�@�C�����o�b�t�@
	.even
nameptr:	.dc.b	'*.*',0
filebuf:	.ds.b	30
fname:		.ds.b	23
namck_buf:
namck_drv:	.ds.b	2
namck_path:	.ds.b	65
ncbuf_name:	.ds.b	19
ncbuf_ext:	.ds.b	5
*---------------------------------------*
*�Ή��f�[�^
	.even
ext:		.dc.b	'*.MCP',0, 0,$20,$40, 'RCC',0
		.dc.b	'*.MTD',0, 0,$20,$40, 'RCC',0
		.dc.b	'*.RCP',0, 0,$20,$40, 'RCC',0
		.dc.b	'*.R36',0, 0,$20,$40, 'RCC',0
		.dc.b	'*.MDF',0, 0,$06,$40, 'LZM -b',0
		.dc.b	'*.SNG',0, 0,$19,$40, 'StoR -b',0
*		.dc.b	'*.SNG',0, 0,$00,$40, 'UtoR -b',0
		.dc.b	'*.MDI',0, 0,$00,$40, 'DtoR -b',0
		.dc.b	'*.SEQ',0, 0,$00,$40, 'QtoR -b',0
		.dc.b	'*.MMC',0, 0,$17,$40, 'CtoR -b',0
		.dc.b	'*.MM2',0, 0,$17,$40, 'CtoR -b',0
		.dc.b	'*.MID',0, 1,  0,  0, 'ItoR -b',0
		.dc.b	'*.STD',0, 1,  0,  0, 'ItoR -b',0
		.dc.b	'*.MFF',0, 1   0,  0, 'ItoR -b',0
		.dc.b	$ff
*---------------------------------------*
	.even
mes_43space:	.dcb.b	43,' '
		.dc.b	0
mes_test:	.dc.b	'This is test.',0
mes_nofd:	.dc.b	': - Not Ready -',0
mes_parent:	.dc.b	'- Parent Directory -',0
mes_dir:	.dc.b	'<dir>',0
mes_path:	.dc.b	'PATH^',0
mes_fopen_err:	.dc.b	'File Open Error !',0
mes_exec_err:	.dc.b	'Load Error !',0
mes_loading:	.dc.b	'Loading..',0
mes_mark:	.dc.b	'Files Marked',0
mes_17spc:	.dc.b	'                 ',0
mes_messpc:	.dc.b	'                          ',0
drive_data:	.dc.b	'ABCDEFGHIJKLMNOPQRSTUVWXYZ',0
str_root_dir:	.dc.b	'\',0
str_parent_dir:	.dc.b	'..',0
*---------------------------------------*
	.bss
	.even
drive:		.ds.l	1		;���݂̃h���C�u�ԍ�
drive_max:	.ds.l	1		;�ŏI�h���C�u�ԍ�
path:		.ds.b	256		;���݂̃p�X��
fnbuf:		.ds.b	256
buf:		.ds.b	256
dirname:	.ds.b	22		;���O�ɂ����f�B���N�g����
ttlpos:		.ds.b	1
ttllen:		.ds.b	1
com:		.ds.b	256
extbuf:		.ds.b	4
pathbuf:	.ds.b	65
comline:	.ds.b	256		;���t�R�}���h�̃R�}���h���C��������
*---------------------------------------*
	.even
titles:		.ds.b	65*FILE_MAX	;�^�C�g���o�b�t�@
	.even
files:		.ds.b	24*FILE_MAX	;�t�@�C�����o�b�t�@
ftype:		.ds.b	FILE_MAX	;0=file 1=dir
ftdone:		.ds.b	FILE_MAX	;�^�C�g�������I���t���O
fmark:		.ds.b	FILE_MAX	;�t�@�C���}�[�N�t���O
sortbuf:	.ds.b	FILE_MAX*4	;�t�@�C�����\�[�g�o�b�t�@
sortbuf_end:
*---------------------------------------*


	.end
