*********************************************************
*
*
*
*
*	�f�r�q	version 1.12
*
*		RCD status display for GS
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

	.xdef		kbclr_flag
	.xdef		fstart_flag
	.xdef		quit
	.xdef		stop_and_quit
	.xdef		stop_or_play
	.xdef		replay
	.xdef		music_end
	.xdef		fade_out
	.xdef		return_display
	.xdef		start_display
	.xdef		scroll_up
	.xdef		scroll_down
	.xdef		mode
	.xdef		_main
	.xdef		sc55disp_ptn
	.xdef		sc55disp_str
	.xdef		level_meter_down
	.xdef		speana_down
	.xdef		comment
	.xdef		tbuf

*---------------------------------------*
RCD_VERSION	equ	'3.01'

TXT_X		equ	$e80014
TXT_Y		equ	$e80016
R21		equ	$e8002a
R23		equ	$e8002e
TVRAM		equ	$e00000
TPALET		equ	$e82200
PCG		equ	$eb8000

DEF_LIGHT	equ	20

*---------------------------------------*

	.text
	.even

	.dc.b	'$Id: gsr_main.s,v 1.1 1994/10/20 12:28:56 T.MIYAMAE Exp $'
_main:
*********************************************************
*
*	�����ݒ�
*
startup:
*********************************************************
	jsr	get_option		;�I�v�V�����ݒ�

*�v���O�����{�̈ȍ~�̗]���ȃ����������
	lea.l	16(a0),a0
	suba.l	a0,a1
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	DOS	_SETBLOCK
	addq.l	#8,sp
*---------------------------------------*
*�N���`�F�b�N
startup_chk:
	jsr	_rcd_check		;RCD�풓�`�F�b�N
	tst.l	_rcd
	beq	rcd_no_stay
	move.l	_rcd,a5			;a5=RCD�擪�A�h���X
	cmp.l	#RCD_VERSION,version(a5)	;RCD�o�[�W�����`�F�b�N
	bne	rcd_ver_err
*	cmp.b	#1,moduletype(a5)	;������ރ`�F�b�N
*	bne	gs_err
*	tst.l	act(a5)			;���t�����`�F�b�N
*	beq	no_playing
	tst.b	fmt(a5)			;RCP���`�F�b�N
	beq	mcp_err
*---------------------------------------*
	move.l	sp,ssp_buf
	lea.l	u_sp,sp

	jsr	super_mode		;�X�[�p�[�o�C�U���[�h
*---------------------------------------*
*�J�����g�p�X��o�^
	DOS	_CURDRV
	move.l	d0,drive
	pea	pathbuf
	clr.w	-(sp)
	DOS	_CURDIR
	addq.l	#6,sp
*---------------------------------------*
*��ʏ�����
	move.w	#-1,d1			;���݂̃��[�h��ޔ�
	IOCS	_CRTMOD
	move.l	d0,crt_mode
	move.w	#-1,-(sp)
	move.w	#14,-(sp)
	DOS	_CONCTRL
	addq.l	#2+2,sp
	move.w	d0,fn_mode

	move.w	#0,d1			;512x512 16�F���[�h
	IOCS	_CRTMOD
	move.w	#3,-(sp)		;�t�@���N�V�����L�[�s����
	move.w	#14,-(sp)
	DOS	_CONCTRL
	addq.l	#4,sp
	IOCS	_B_CUROFF

	move.b	#1,d1
	move.b	#2,d2
	IOCS	_TGUSEMD
	IOCS	_MS_CUROF		;debug
	move.l	#0,d1			;debug
	IOCS	_SKEY_MOD		;debug

	IOCS	_SP_INIT		;debug

*�e�L�X�g�p���b�g�ޔ�
	lea.l	tpalet_buf,a1
	movea.l	#TPALET,a2
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2),(a1)

*�e�L�X�g�p���b�g�ݒ�
	movea.l	#TPALET,a2
	move.w	#$0000,(a2)+		;�O����
	move.w	#$2e00,(a2)+		;�P�ԃX���C�_�[
	move.w	#$a88e,(a2)+		;�Q�΃X���C�_�[
	move.w	#$9e40,(a2)+		;�R���X���C�_�[
	move.w	#$f83e,(a2)+		;�S
	move.w	#$0001,(a2)+		;�T������
	move.w	#$f83e,(a2)+		;�U���x�����[�^�[
	move.w	#$07c0,(a2)+		;�V�ԃ��x�����[�^�[
	move.w	#$a032,(a2)+		;�W��
	move.w	#$bec0,(a2)+		;�X�Z���N�^�J�[�\��
	move.w	#$e73a,(a2)+		;�P�O���D
	move.w	#$8425,(a2)+		;�P�P�ÊD
	move.w	#$2202,(a2)+		;�P�QSC DISPLAY����
	move.w	#$ffff,(a2)+		;�P�R
	move.w	#$ffff,(a2)+		;�P�S
	move.w	#$bdee,(a2)+		;�P�T������

*	bra	skip_spdef		;debug

*�X�v���C�g�p���b�g��`
	lea.l	sprite_palett,a1
	adda.l	#16*2,a1
	move.w	#16*15-1,d1
@@:	move.w	(a1)+,(a2)+
	dbra	d1,@b
*�X�v���C�g�p�^�[����`
	lea.l	sprite_pattern,a1
	movea.l	#PCG,a2
	move.w	#16*16*128/4-1,d1
@@:	move.l	(a1)+,(a2)+
	dbra	d1,@b
skip_spdef:

*�p���b�g���邳�ݒ�
	move.b	#DEF_LIGHT,light	;�f�t�H���g�Z�b�g

	pea.l	env_value		;���ϐ������o��
	clr.l	-(sp)
	pea.l	env_str
	DOS	_GETENV
	lea.l	12(sp),sp
	tst.l	d0
	bgt	env_skip

	clr.w	d0			;�����񁨐��l�ϊ�
	clr.w	d1
	lea.l	env_value,a0
@@:	tst.b	(a0)
	beq	env_skip
	cmp.b	#' ',(a0)+
	beq	@b
	move.b	-1(a0),d0
	sub.b	#'0',d0
	tst.b	(a0)
	beq	set_env
	mulu.w	#10,d0
	move.b	(a0),d1
	sub.b	#'0',d1
	add.b	d1,d0
set_env:
	addq.b	#1,d0			;���x�l�Z�b�g
	cmp.b	#31,d0
	bhi	env_skip
	move.b	d0,light
env_skip:

	movea.l	#TPALET,a2
	lea.l	lightflg_tbl,a1

	move.b	light,d0
	move.w	#32,d1
	sub.w	d0,d1

	move.w	d1,d0			;���邳��RGB�ϊ�
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#1,d1
pl_lp:
	cmp.b	#2,(a1)			;���邳�ݒ�
	beq	pl_end
	tst.b	(a1)+
	beq	pl_skip
	cmp.w	(a2),d1
	bls	@f
	clr.w	(a2)
	bra	pl_skip
@@:
	sub.w	d1,(a2)
pl_skip:
	addq.l	#2,a2
	bra	pl_lp
pl_end:

*
	moveq.l	#0,d1			;�o�b�N�O���E���h�O
	moveq.l	#0,d2			;�e�L�X�g�y�[�W�P
	moveq.l	#1,d3			;�\���n�m
	IOCS	_BGCTRLST
	move.w	#%00__01_00_10__11_10_01_00,$e82500	;�D�揇�ʐݒ�

*---------------------------------------*
	IOCS	_SP_OFF
	jsr	bg_clear
	jsr	sprite_off
	jsr	text_clear

*---------------------------------------*
*�z�񏉊���
	lea.l	tbuf,a1
	move.w	#128/4-1,d1
@@:	clr.l	(a1)+
	dbra	d1,@b

	lea.l	tbuf2,a1
	move.w	#128/4-1,d1
@@:	clr.l	(a1)+
	dbra	d1,@b

	lea.l	level,a1
	move.w	#16/4-1,d1
@@:	clr.l	(a1)+
	dbra	d1,@b

	lea.l	speana_r,a1
	move.w	#32/4-1,d1
@@:	clr.l	(a1)+
	dbra	d1,@b

	lea.l	speana_l,a1
	move.w	#32/4-1,d1
@@:	clr.l	(a1)+
	dbra	d1,@b
*---------------------------------------*
	jsr	make_hankaku_12x12	; ���p�����쐬
	move.w	#%1_1_1111_0000,COLOR_12x12
	jsr	make_hankaku_12x16
	move.w	#%1_1_1111_0000,COLOR_12x16
*---------------------------------------*
	bsr	draw_mixer
*GSR���S
	move.l	#350,d2			;�w���W
	move.l	#516,d3			;�x���W
	move.l	#125,d1			;�X�v���C�g�y�[�W
	move.l	#$1e,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST
	move.l	#350+16,d2		;�w���W
	move.l	#516,d3			;�x���W
	move.l	#126,d1			;�X�v���C�g�y�[�W
	move.l	#$1f,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B

	IOCS	_SP_REGST
	move.l	#350,d2			;�w���W
	move.l	#512+515,d3		;�x���W
	move.l	#120,d1			;�X�v���C�g�y�[�W
	move.l	#$1e,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST
	move.l	#350+16,d2		;�w���W
	move.l	#512+515,d3		;�x���W
	move.l	#119,d1			;�X�v���C�g�y�[�W
	move.l	#$1f,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

*SELECTOR���S
	move.l	#16+008,d2		;�w���W
	move.l	#512+16+004,d3		;�x���W
	move.l	#124,d1			;�X�v���C�g�y�[�W
	move.l	#$38,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST
	move.l	#16+008+16,d2		;�w���W
	move.l	#512+16+004,d3		;�x���W
	move.l	#123,d1			;�X�v���C�g�y�[�W
	move.l	#$39,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST
	move.l	#16+008+16*2,d2		;�w���W
	move.l	#512+16+004,d3		;�x���W
	move.l	#122,d1			;�X�v���C�g�y�[�W
	move.l	#$36,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST
	move.l	#16+008+16*3,d2		;�w���W
	move.l	#512+16+004,d3		;�x���W
	move.l	#121,d1			;�X�v���C�g�y�[�W
	move.l	#$7f,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	SSPRINT	#091,#502,#mes_titlebar
	SSPRINT	#001,#389,#mes_effect
	SSPRINT	#092,#389,#mes_sc_display
	SSPRINT	#036,#389,#mes_speana
	SSPRINT	#036,#434,#mes_spe_guide
	SSPRINT	#036,#453,#mes_level
	SSPRINT	#036,#498,#mes_level_guide
	SSPRINT	#000,#069,#mes_trk_guide

	SSPRINT	#091,#512+501,#mes_titlebar
	SSPRINT	#002,#512+022,#mes_path
	SSPRINT	#121,#512+006,#mes_slash

	lea.l	mes_eff_guide,a1
	move.l	#400,d1
	move.w	#13-1,d2
@@:	SSPRINT	#1,d1,a1
	addi.l	#8,d1
	adda.l	#36,a1
	dbra	d2,@b

*---------------------------------------*
	IOCS	_SP_ON
	move.b	#1,mode			;�p�l����p���[�h

	tst.l	act(a5)			;���t�����`�F�b�N
	bne	@f
	clr.b	mode			;�Z���N�^���[�h
	bsr	scroll_up
	jmp	music_selector
@@:
start_display:
	tst.l	act(a5)			;���t�����`�F�b�N
	bne	@f
	bsr	scroll_up
	jmp	music_selector
@@:
restart:
*	IOCS	_ONTIME
*	move.l	d0,lv_ontime
*	move.l	d0,sp_ontime

	clr.b	fstart_flag
	bsr	o_clr
	bsr	memo_note
*---------------------------------------*
*���X�e�b�v���\��
	jsr	_max_step
	move.l	d0,max_step

	pea.l	tbuf
	move.l	d0,-(sp)
	jsr	bin_adec2
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#4,a6
	move.w	#%01_1111_0000,R21
	SEG7	#34+7,#32,a6

*---------------------------------------*
*�����t���ԕ\��
	SEG7	#35+2,#48,#mes_coron

	move.l	max_step,-(sp)
	jsr	_tm_caluc
	addq.l	#4,sp
	move.l	d0,max_time

	divu.w	#6000,d0
*��
	moveq.l	#0,d1
	move.w	d0,d1

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#4+4,sp
	lea.l	tbuf,a6
	addq.l	#8,a6			;�Q���̈ʒu�Ƀ|�C���^�ړ�
	clr.b	2(a6)			;�I�[�R�[�h
	cmp.b	#' ',(a6)
	bne	@f
	move.b	#'0',(a6)
@@:
	SEG7	#35,#48,a6
*�b
	moveq.l	#0,d1
	swap.w	d0
	move.w	d0,d1

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#4+4,sp
	lea.l	tbuf,a6
	addq.l	#6,a6			;�Q���̈ʒu�Ƀ|�C���^�ړ�
	clr.b	2(a6)			;�I�[�R�[�h
	cmp.b	#' ',(a6)
	bne	@f
	move.b	#'0',(a6)
@@:
	cmp.b	#' ',1(a6)
	bne	@f
	move.b	#'0',1(a6)
@@:
	SEG7	#35+3,#48,a6

*---------------------------------------*
*�g���b�N�ԍ��\��
	moveq.l	#1,d6			;���l�\���w���W
	moveq.l	#0,d5
	move.w	ps_trk,d5
	move.w	#18-1,d1
draw_trk_lp:
	move.w	ps_trk,d5
	add.w	d1,d5
	pea.l	tbuf
	move.l	d5,d2
	addq.l	#1,d2
	move.l	d2,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#8,a6			;���Q���̈ʒu�Ƀ|�C���^�����炷
	move.l	d1,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#86,d7			;�I�t�Z�b�g��������
	jsr	print_4x8font

	dbra	d1,draw_trk_lp
*--------------------------------------*
	SSPRINT	#1,#373,#mes_master

*********************************************************
*
*	�ȃf�[�^�̏��
*
data_info:
*********************************************************
	SSPRINT	#1,#38,#mes_rcp_info
	SSPRINT	#1,#54,#mes_status

*---------------------------------------*
*�t�@�C�����\��
	move.w	#%01_1111_0000,R21
	SPRINT	#5,#19,#mes_64space
	move.w	#%01_1111_0000,R21
	SSPRINT	#1,#22,#mes_rcp_files
*�q�b�o
	movea.l	a5,a1
	adda.l	#filename,a1		;a1=�t�@�C����������擪
	lea.l	tbuf,a2
	move.w	#30-1,d1
@@:
	move.b	(a1)+,(a2)+		;�o�b�t�@�ɕ�����R�s�[
	tst.b	(a1)
	beq	@f			;�󔒂Ȃ烋�[�v�𔲂���
	dbra	d1,@b
*�f�r�c
@@:
	move.b	#' ',(a2)+		;�o�b�t�@�ɕ�����R�s�[
	movea.l	a5,a1
	adda.l	#gsdname,a1
	move.w	#30-1,d1
@@:
	move.b	(a1)+,(a2)+		;�o�b�t�@�ɕ�����R�s�[
	tst.b	(a1)
	beq	@f			;�󔒂Ȃ烋�[�v�𔲂���
	dbra	d1,@b
*�b�l�U
@@:
	move.b	#' ',(a2)+		;�o�b�t�@�ɕ�����R�s�[
	movea.l	a5,a1
	adda.l	#tonename,a1
	move.w	#30-1,d1
@@:
	move.b	(a1)+,(a2)+		;�o�b�t�@�ɕ�����R�s�[
	tst.b	(a1)
	beq	@f			;�󔒂Ȃ烋�[�v�𔲂���
	dbra	d1,@b
@@:
	clr.b	(a1)			;�G���h�R�[�h��������
	lea.l	tbuf,a2
	SPRINT	#5,#19,a2

*---------------------------------------*
*�Ȗ��\��
	move.w	#%01_1111_0000,R21
	SSPRINT	#1,#6,#mes_rcp_title
	movea.l	a5,a1
	adda.l	#data_adr,a1
	movea.l	(a1),a1			;a1=RCP�f�[�^�擪
	adda.l	#rcp_name,a1		;a1=�Ȗ�������擪
	lea.l	tbuf,a2
	move.w	#64-1,d1
@@:	move.b	(a1)+,(a2)+		;�o�b�t�@�ɕ�����R�s�[
	dbra	d1,@b
	clr.b	(a1)			;�G���h�R�[�h��������
	lea.l	tbuf,a2
	SPRINT	#5,#3,a2

*---------------------------------------*
*���\��
	move.w	#%01_1111_0000,R21
	movea.l	a5,a1
	adda.l	#data_adr,a1
	movea.l	(a1),a1			;a1=RCP�f�[�^�擪
	adda.l	#rcp_key,a1		;a1=���R�[�h�i�[�A�h���X
	moveq.l	#0,d1
	move.b	(a1),d1			;d1.b=���R�[�h

	mulu.w	#4,d1
	lea.l	key,a0
	add.l	d1,a0
	SEG7	#9,#32,a0

*---------------------------------------*
*�^�C���x�[�X�\��
	movea.l	a5,a1
	adda.l	#data_adr,a1
	movea.l	(a1),a1			;a1=RCP�f�[�^�擪
	adda.l	#rcp_tmbase,a1		;a1=�^�C���x�[�X�i�[�A�h���X
	moveq.l	#0,d1
	move.b	(a1),d1			;d1.b=�^�C���x�[�X�l
	move.b	d1,timebase

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	jsr	left3keta
	SEG7	#17,#32,a6

*---------------------------------------*
*���q�\��
	moveq.l	#0,d1
	movea.l	data_adr(a5),a1		;a1=RCP�f�[�^�擪
	move.b	rcp_rhythm0(a1),d1	;d1.b=���q���q�l

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a3
	lea.l	tbuf2,a4

	addq.l	#8,a3			;�Q���̈ʒu�Ƀ|�C���^�ړ�
	cmp.b	#' ',(a3)
	beq	@f
	move.b	(a3),(a4)
	addq.l	#1,a4
@@:
	move.b	1(a3),(a4)
	move.b	#'/',1(a4)
	addq.l	#2,a4

	move.b	rcp_rhythm1(a1),d1	;d1.b=���q����l
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp

	cmp.b	#' ',(a3)
	beq	@f
	move.b	(a3),(a4)
	addq.l	#1,a4
@@:
	move.b	1(a3),(a4)
	clr.b	1(a4)

	lea.l	tbuf2,a4
	SEG7	#23,#32,a4

*---------------------------------------*
	move.w	#%01_1100_0000,R21
	movea.l	a5,a0			;-SOUND CANVAS-
	adda.l	#gs_info,a0		;a0.l=���ʌ�
	lea.l	sc_mes,a1		;a1.l=���ʐ�
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	lea.l	sc_mes,a6
	move.w	#46,d6			;d6.l=�w���W
	move.w	#401,d7			;d7.l=�x���W
	jsr	print_sc

*---------------------------------------*
*�f�[�^���W�X�^������
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
*---------------------------------------*












*		�ȏ�A�����ݒ�











*---------------------------------------*
return_display:
	IOCS	_ONTIME
	move.l	d0,start_time			;�N�����ԃZ�b�g
	move.l	d0,vel_ontime
	move.l	d0,lv_ontime
	move.l	d0,sp_ontime

	clr.b	flg_gsinst(a5)
	clr.b	flg_gspanel(a5)

	move.b	#1,kbclr_flag

*********************************************************
*
*	���C�����[�v
*
loop:
*********************************************************
	tst.l	act(a5)			;���t�����`�F�b�N
	bne	@f			;
	tst.b	mode			;�p�l����p���[�h�Ȃ�
	bne	quit			;�@GSR�I��
	bsr	scroll_up		;�Z���N�^���[�h�Ȃ�Z���N�^�N��
	jmp	music_selector		;
@@:
*---------------------------------------*
	bsr	all_step
	tst.b	d0
	bne	restart

	bsr	brunch

*---------------------------------------*
*�L�[�o�b�t�@�N���A
@@:	tst.b	kbclr_flag
	beq	@@f
	IOCS	_B_KEYSNS
	tst.l	d0
	beq	@f
	IOCS	_B_KEYINP
	bra	break
@@:	clr.b	kbclr_flag
*---------------------------------------*
*�L�[���̓`�F�b�N
@@:	IOCS	_B_KEYSNS
	tst.l	d0
	beq	break
	move.b	#1,kbclr_flag
	IOCS	_B_KEYINP
	lsr.w	#8,d0
*---------------------------------------*
@@:	cmp.b	#$01,d0			;[ESC]=�I��
	bne	@f
	tst.b	mode			;�p�l����p���[�h�Ȃ�
	bne	quit			;�@GSR�I��
	bsr	scroll_up		;�Z���N�^���[�h�Ȃ�Z���N�^�N��
	jmp	music_selector		;
@@:	cmp.b	#$6c,d0			;[F10]=�I��
	bne	@f
	tst.b	mode			;�p�l����p���[�h�Ȃ�
	bne	quit			;�@GSR�I��
	bsr	scroll_up		;�Z���N�^���[�h�Ȃ�Z���N�^�N��
	jmp	music_selector		;
*---------------------------------------*
@@:	cmp.b	#$10,d0			;[TAB]=���t��~�I��
	bne	@f
	bsr	music_end
	bra	break
@@:	cmp.b	#$37,d0			;[DEL]=���t��~�I��
	bne	@f
	bsr	music_end
	bra	break
@@:	cmp.b	#$6b,d0			;[F9]=���t��~�I��
	bne	@f
	bsr	music_end
	bra	break
@@:	cmp.b	#$40,d0			;t[/]=���t��~�I��
	bne	@f
	jsr	fade_out	**
*	IOCS	_B_SFTSNS
*	btst.l	#0,d0			;[SHIFT]+t[/]=�t�F�[�h�A�E�g
*	beq	1f
*	jsr	fade_out
*	bra	break
*1:	jsr	music_end
*	bra	break
*---------------------------------------*
@@:	cmp.b	#$3e,d0			;[��]=����
	bne	@f
	bsr	memo_memo
	bra	break
*---------------------------------------*
@@:	cmp.b	#$3c,d0			;[��]=�g���b�N����
	bne	@f
	bsr	memo_trk_memo
	bra	break
*---------------------------------------*
@@:	cmp.b	#$36,d0			;[HOME]=���[�h�g�O��
	bne	@f
	bsr	memo_togle
	bra	break
@@:	cmp.b	#$64,d0			;[F2]=���[�h�g�O��
	bne	@f
	bsr	memo_togle
	bra	break
*---------------------------------------*
@@:	cmp.b	#$54,d0			;[HELP]=�I�����C���w���v
	bne	@f
	bsr	help
	bra	break
*---------------------------------------*
@@:	cmp.b	#$3d,d0			;[��]=�I�N�^�[�u�A�b�v
	bne	@f
	cmpi.b	#48,note_shift
	beq	@f
	addi.b	#12,note_shift
	bsr	memo_note
	bra	break
@@:	cmp.b	#$6a,d0			;[F8]=�I�N�^�[�u�A�b�v
	bne	@f
	cmpi.b	#48,note_shift
	beq	@f
	addi.b	#12,note_shift
	bsr	memo_note
	bra	break
*---------------------------------------*
@@:	cmp.b	#$3b,d0			;[��]=�I�N�^�[�u�_�E��
	bne	@f
	tst.b	note_shift
	beq	@f
	subi.b	#12,note_shift
	bsr	memo_note
	bra	break
@@:	cmp.b	#$69,d0			;[F7]=�I�N�^�[�u�_�E��
	bne	@f
	tst.b	note_shift
	beq	@f
	subi.b	#12,note_shift
	bsr	memo_note
	bra	break
*---------------------------------------*
@@:	cmp.b	#$3a,d0			;[UNDO]=������^���t�J�n�g�O��
	bne	@f
	bsr	cue_or_play
	bra	break
*---------------------------------------*
@@:	cmp.b	#$3f,d0			;[CLR]=�ꎞ��~�^���t�J�n�g�O��
	bne	@f
	bsr	stop_or_play
	bra	break
*---------------------------------------*
@@:	cmp.b	#$0f,d0			;[BS]=�ꎞ��~�^���t�J�n�g�O��
	bne	@f
	bsr	stop_or_play
	bra	break
*---------------------------------------*
@@:	cmp.b	#$41,d0			;t[*]=�ĉ��t�J�n
	bne	@f
	bsr	replay
	bra	break
*---------------------------------------*
@@:	cmp.b	#$42,d0			;t[-]=�Z���N�^���[�h
	bne	@f
	bsr	scroll_up
	jmp	music_selector
@@:	cmp.b	#$1d,d0			;[RET]=�Z���N�^���[�h
	bne	@f
	bsr	scroll_up
	jmp	music_selector
@@:	cmp.b	#$4e,d0			;[ENTER]=�Z���N�^���[�h
	bne	@f
	bsr	scroll_up
	jmp	music_selector
*---------------------------------------*
@@:
break:
	bra	loop

*********************************************************
*
*	�e�������s��
*
brunch:
*********************************************************
	bsr	passed_time
	bsr	motion_pointer
	bsr	playing_mode
	bsr	playing_status
	bsr	print_tempo
	bsr	comment
	bsr	loop_count

	bsr	channel
	bsr	bar_no
	bsr	step_no
	bsr	velocity
	bsr	volume
	bsr	expression
	bsr	modulation
	bsr	panpot
	bsr	pitchbend
	bsr	reverb
	bsr	chorus
	bsr	hold
	bsr	instrument
	bsr	keyboard

	bsr	master_volume
	bsr	master_panpot

	bsr	sc55disp_ptn
	bsr	sc55disp_str
	bsr	effect

	bsr	level_meter_down
	bsr	speana_down

	rts

*********************************************************
*
*	���t�J�n����̃X�e�b�v�J�E���g
*
all_step:
*********************************************************
	movem.l	d1/a6,-(sp)

	move.l	stepcount(a5),d1
	cmp.l	o_allstp,d1
	bcs	go_restart		;�J�E���^�������Ă�����ċN��
	move.l	d1,o_allstp
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec2
	addq.l	#4*2,sp

	lea.l	tbuf,a6
	addq.l	#4,a6
	move.w	#%01_1111_0000,R21
	SEG7	#34,#32,a6
	SEG7	#34+6,#32,#mes_slash

	movem.l	(sp)+,d1/a6
	move.b	#0,d0
	rts

*go_restart:
*	movem.l	(sp)+,d1/a6
*	addq.l	#4,sp
*	move.b	#1,d0
*	bra	restart
*	rts

go_restart:
	movem.l	(sp)+,d1/a6
	move.b	#1,d0
	rts

*********************************************************
*
*	���t�o�ߎ���
*
passed_time:
*********************************************************
	movem.l	d0-d1/a6,-(sp)

	move.l	stepcount(a5),-(sp)
	jsr	_tm_caluc
	addq.l	#4,sp
	move.l	d0,run_time
	move.w	#%01_1111_0000,R21
*�R����
	move.l	d0,d1

	clr.b	tcoron_flag
	divu.w	#50*2,d1		;0.50�b���Ƃɓ_��
	swap.w	d1
	cmpi.w	#50,d1
	bcc	@f
	move.b	#1,tcoron_flag
@@:
	tst.b	tcoron_flag		;�t���O�ɉ����Ăn�m�^�n�e�e
	beq	tc_off
tc_on:
	SEG7	#29+2,#48,#mes_coron
	bra	@f
tc_off:
	SEG7	#29+2,#48,#mes_1space
@@:
	divu.w	#6000,d0
*��
	moveq.l	#0,d1
	move.w	d0,d1

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#4+4,sp
	lea.l	tbuf,a6
	addq.l	#8,a6			;�Q���̈ʒu�Ƀ|�C���^�ړ�
	clr.b	2(a6)			;�I�[�R�[�h
	cmp.b	#' ',(a6)
	bne	@f
	move.b	#'0',(a6)
@@:
	SEG7	#29,#48,a6
*�b
	moveq.l	#0,d1
	swap.w	d0
	move.w	d0,d1

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#4+4,sp
	lea.l	tbuf,a6
	addq.l	#6,a6			;�Q���̈ʒu�Ƀ|�C���^�ړ�
	clr.b	2(a6)			;�I�[�R�[�h
	cmp.b	#' ',(a6)
	bne	@f
	move.b	#'0',(a6)
@@:
	cmp.b	#' ',1(a6)
	bne	@f
	move.b	#'0',1(a6)
@@:
	SEG7	#29+3,#48,a6
	SEG7	#29+5,#48,#mes_slash

	movem.l	(sp)+,d0-d1/a6
	rts

*********************************************************
*
*	�e���|
*
print_tempo:
*********************************************************
	movem.l	d1/a0-a1/a5,-(sp)

	move.l	panel_tempo(a5),d1

	cmp.l	o_tempo,d1		;�p�����[�^���ς���Ă邩�H
	beq	tmp_skip		;�ς���ĂȂ���΃X�L�b�v
	move.l	d1,o_tempo

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#4+4,sp

	lea.l	tbuf,a6
	jsr	left3keta
	move.w	#%01_1111_0000,R21
	SEG7	#3,#32,a6

*---------------------------------------*
tmp_skip:
	movem.l	(sp)+,d1/a0-a1/a5
	rts

*********************************************************
*
*	�R�����g
*
comment:
*********************************************************
	movem.l	d1/a1-a2,-(sp)
	tst.b	flg_song(a5)
	beq	cm_bk
	clr.b	flg_song(a5)
*---------------------------------------*
	movea.l	a5,a1
	adda.l	#song,a1
	lea.l	tbuf,a2
	move.l	4*0(a1),4*0(a2)		;�R�����g��������o�b�t�@��
	move.l	4*1(a1),4*1(a2)
	move.l	4*2(a1),4*2(a2)
	move.l	4*3(a1),4*3(a2)
	move.l	4*4(a1),4*4(a2)
	move.l	4*5(a1),4*5(a2)
	clr.b	20(a2)			;�G���h�R�[�h��������
	SPRINT	#65,#35,a2
	clr.l	4*0(a2)			;�o�b�t�@������
	clr.l	4*1(a2)
	clr.l	4*2(a2)
	clr.l	4*3(a2)
	clr.l	4*4(a2)
	clr.l	4*5(a2)
	SPRINT	#65,#35,a2
*---------------------------------------*
cm_bk:
	movem.l	(sp)+,d1/a1-a2
	rts

*********************************************************
*
*	���[�v�J�E���^
*
loop_count:
*********************************************************
	movem.l	d1/a5-a6,-(sp)

	moveq.l	#0,d1
	move.w	loopcount(a5),d1
	cmp.w	o_loopcount,d1		;�p�����[�^���ς���Ă邩�H
	beq	lc_bk			;�ς���ĂȂ���΃X�L�b�v
	move.w	d1,o_loopcount

	addq.l	#1,d1			;0�` -> 1�`
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	addq.l	#8,a6			;�Q���̈ʒu�Ƀ|�C���^�ړ�
	clr.b	2(a6)			;�I�[�R�[�h
	cmp.b	#' ',(a6)
	bne	@f
	move.b	#'0',(a6)
@@:
	move.w	#%01_1111_0000,R21
	SEG7	#23,#48,a6
lc_bk:
	movem.l	(sp)+,d1/a5-a6
	rts

*********************************************************
*
*	�`�����l��
*
channel:
*********************************************************
	movem.l	d2-d7/a1/a6,-(sp)

	move.w	ps_trk,d4
	moveq.l	#18-1,d2
ch_trk_loop:
	move.w	d4,d5
	add.w	d2,d5

	move.b	#-1,d3
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	(a1,d5.w)
	beq	@f

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#midich,a1		;a1.l=�`�����l���f�[�^�擪
	move.b	(a1,d5.w),d3		;d3.b=�`�����l���ԍ�
@@:
	lea.l	o_cha,a1
	adda.w	d5,a1
	cmp.b	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	ch_skip			;�ς���ĂȂ���΃X�L�b�v
	move.b	d3,(a1)
*---------------------------------------*
*�`�����l���\��
	cmp.b	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	clr.b	d3			;�@���ۂ̒l���O�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
	bra	@@f
@@:
	pea.l	tbuf
	addq.b	#1,d3
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#8,a6			;���Q���̈ʒu�Ƀ|�C���^�����炷
@@:
	move.l	#4,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#86,d7			;�I�t�Z�b�g��������
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	jsr	print_4x8font

*---------------------------------------*
ch_skip:
	dbra	d2,ch_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d2-d7/a1/a6
	rts

*********************************************************
*
*	���t���
*
playing_status:
*********************************************************
	movem.l	d1-d3/a1,-(sp)

	moveq.l	#0,d2
	move.b	timebase,d2		;d2.b=�^�C���x�[�X�l
	move.w	d2,d3
	mulu.w	#2,d3

	move.l	stepcount(a5),d1

	clr.b	brink_flag
	divu.w	d3,d1			;�^�C���x�[�X�N���b�N���Ƃɓ_��
	swap.w	d1
	cmp.w	d2,d1
	bcc	@f
	move.b	#1,brink_flag
@@:
	move.w	#%01_1111_0000,R21
	tst.b	brink_flag		;�t���O�ɉ����Ăn�m�^�n�e�e
	beq	sts_off
sts_on:
	lea.l	mes_sts,a1
	move.l	sts(a5),d2
	move.w	d2,d1			;d2=d2*5
	add.w	d2,d2
	add.w	d2,d2
	add.w	d1,d2
	adda.w	d2,a1
	SEG7	#14,#48,a1
	bra	psbk
sts_off:
	cmp.l	#1,sts(a5)
	beq	psbk
	SEG7	#14,#48,#mes_6space
psbk:
	movem.l	(sp)+,d1-d3/a1
	rts

*********************************************************
*
*	���t���[�h
*
playing_mode:
*********************************************************
	movem.l	d1-d2/a1,-(sp)

	move.l	play_mode(a5),d1
	lea.l	mes_play_mode,a1

	move.w	d1,d2			;d1=d1*7
	lsl.w	#3,d1
	sub.w	d2,d1

	adda.w	d1,a1
	move.w	#%01_1111_0000,R21
	SEG7	#3,#48,a1

	movem.l	(sp)+,d1-d2/a1
	rts

*********************************************************
*
*	���ߔԍ�
*
bar_no:
*********************************************************
	movem.l	d1-d7/a1/a6,-(sp)

	move.w	ps_trk,d4
	moveq.l	#18-1,d2
bar_trk_loop:
	move.w	d4,d5
	add.w	d2,d5

	moveq.l	#-1,d3			;������
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	(a1,d5.w)		;d3.b=�g���b�N�L���t���O
	beq	@f

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#bar,a1			;a1.l=���ߔԍ��f�[�^�擪
	move.w	d5,d1
	add.w	d1,d1			;d1=d1*4
	add.w	d1,d1			;
	adda.l	d1,a1
	move.l	(a1),d3			;d3.l=���ߔԍ�
@@:
	lea.l	o_bar,a1
	move.w	d5,d1
	add.w	d1,d1			;d1=d1*4
	add.w	d1,d1			;
	adda.l	d1,a1
	cmp.l	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	bar_skip		;�ς���ĂȂ���΃X�L�b�v
	move.l	d3,(a1)
*---------------------------------------*
*���ߔԍ��\��
	cmp.l	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	clr.l	d3			;�@���ۂ̒l���O�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
	bra	@@f
@@:
	pea.l	tbuf
	addq.l	#1,d3
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	add.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷
@@:
	move.l	#7,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#86,d7			;�I�t�Z�b�g��������
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	jsr	print_4x8font
*---------------------------------------*
bar_skip:
	dbra	d2,bar_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d1-d7/a1/a6
	rts

*********************************************************
*
*	�X�e�b�v�ԍ�
*
step_no:
*********************************************************
	movem.l	d1-d7/a1/a6,-(sp)

	move.w	ps_trk,d4
	moveq.l	#18-1,d2
step_trk_loop:
	move.w	d4,d5
	add.w	d2,d5

	moveq.l	#-1,d3			;������
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	(a1,d5.w)
	beq	@f

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#step,a1		;a1.l=�X�e�b�v�ԍ��f�[�^�擪
	move.w	d5,d1
	add.w	d1,d1			;d1=d1*4
	add.w	d1,d1			;
	adda.l	d1,a1
	move.l	(a1),d3			;d3.l=���ߔԍ�
@@:
	lea.l	o_stp,a1
	move.w	d5,d1
	add.w	d1,d1			;d1=d1*4
	add.w	d1,d1			;
	adda.l	d1,a1
	cmp.l	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	step_skip		;�ς���ĂȂ���΃X�L�b�v
	move.l	d3,(a1)
*---------------------------------------*
*�X�e�b�v�ԍ��\��
	cmp.l	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	clr.l	d3			;�@���ۂ̒l���O�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷
@@:
	move.l	#11,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#86,d7			;�I�t�Z�b�g��������
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	jsr	print_4x8font
*---------------------------------------*
step_skip:
	dbra	d2,step_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d1-d7/a1/a6
	rts

*********************************************************
*
*	�x���V�e�B
*
velocity:
*********************************************************
	movem.l	d0-d7/a1-a3/a6,-(sp)

	move.b	#-1,vel_flag
	IOCS	_ONTIME
	move.l	d0,d1
	sub.l	vel_ontime,d1
	subq.l	#4,d1
	bcs	@f
	clr.b	vel_flag
	move.l	d0,vel_ontime
	sub.l	d1,vel_ontime
@@:
*---------------------------------------*
	moveq.l	#18-1,d2
vel_trk_loop:
*	add.l	ps_trk,d2

	moveq.l	#0,d3
	move.b	#-1,d3
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	0(a1,d2.l)
	bne	@f
	bsr	vel_no			;�g���b�N�����Ȃ琔�l����
@@:
	lea.l	m_vel,a3
	adda.l	d2,a3			;(a3)=���[�^�[�l

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#flg_off,a1
	tst.b	0(a1,d2.l)		;�n�e�e�t���O�����Ă邩�H
	beq	@f
				*note off
	clr.b	0(a1,d2.l)		;�n�e�e�t���O����
	lea.l	vel_speed,a2
	move.b	#2,0(a2,d2.l)		;���[�^�[�������x
@@:
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#flg_vel,a1
	tst.b	0(a1,d2.l)		;�n�m�t���O�����Ă邩�H
	beq	vel_meter
				*note on
	clr.b	0(a1,d2.l)		;�n�m�t���O����
	lea.l	vel_speed,a2
	move.b	#4,0(a2,d2.l)		;���[�^�[�������x
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#vel,a1			;a1.l=�x���V�e�B�f�[�^�擪
	move.b	0(a1,d2.l),d3		;d3.b=�x���V�e�B�l
	move.b	d3,(a3)			;�u�x���V�e�B�����[�^�l�v�ɐݒ�
	bsr	vel_no
	bsr	level_meter		;16ch���x�����[�^���[�`�� d2.b=trk d3.b=vel
*---------------------------------------*
*���[�^�[
vel_meter:
	tst.b	vel_flag
	bne	vel_skip

	move.b	(a3),d1
	lea.l	vel_speed,a2
	move.b	0(a2,d2.l),d0		;d0.b=���[�^�[�������x
	tst.b	d1
	beq	@@f
	lsr.w	d0,d1
	tst.b	d1
	bne	@f
	move.b	#1,d1
@@:
	sub.b	d1,(a3)			;���[�^�[�𓮂���
@@:
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	(a3),d2
	divu.w	#10,d2			;�P�O�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	move.l	#TVRAM,a1
	adda.l	#7,a1			;�w���W�^�W
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;�x�I�t�Z�b�g��������
	add.l	d5,a1

	lea.l	vel_tbl,a2
	moveq.l	#0,d4
	move.l	d2,d4
	add.w	d4,d4			;d4=d4*4
	add.w	d4,d4			;
	adda.l	d4,a2

	move.w	#%01_0110_0000,R21	;�����A�N�Z�X
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.w	#%01_0111_0000,R21	;�����A�N�Z�X
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	move.l	d7,d2			;d2���A
	bra	vel_skip
*---------------------------------------*
vel_skip:
*	sub.l	ps_trk,d2
	dbra	d2,vel_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1-a3/a6
	rts

*---------------------------------------*
*���l
vel_no:
	lea.l	o_vel,a1
	cmp.b	0(a1,d2.l),d3		;�l���ς���ĂȂ���΋A��
	bne	@f
	rts
@@:
	move.b	d3,0(a1,d2.l)
	cmp.b	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	clr.b	d3			;�@���ۂ̒l���O�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷
@@:
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#18,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

	rts

*********************************************************
*
*	�{�����[��
*
volume:
*********************************************************
	movem.l	d0-d7/a1-a2,-(sp)

	moveq.l	#18-1,d2
vol_trk_loop:
*	add.l	ps_trk,d2

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#midich,a1		;a1.l=�`�����l���f�[�^�擪
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=�`�����l���ԍ�

	move.b	#-1,d3			;d3.b=�{�����[���l���n�e�e
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_vol,a1		;a1.l=�{�����[���f�[�^�擪
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=�{�����[���l
@@:
	lea.l	o_vol,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	vol_skip		;�ς���ĂȂ���΃X�L�b�v
	move.b	d3,(a1)

*---------------------------------------*
*���l
	cmp.b	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	clr.b	d3			;�@���ۂ̒l���O�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷
*	jsr	left3keta
@@:
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#25,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#6,d2			;�U�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	move.l	#TVRAM,a1
	adda.l	#11,a1			;�w���W�^�W
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;�x�I�t�Z�b�g��������
	add.l	d5,a1

	lea.l	vol_slide_tbl,a2
	move.l	d2,d4
	add.w	d4,d4			;d4=d4*4
	add.w	d4,d4			;
	adda.l	d4,a2

	move.w	#%01_0001_0000,R21	;�����A�N�Z�X
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)

*---------------------------------------*
*�X���C�_�[�܂�
	addi.l	#104,d2			;�w���W�i�w�I�t�Z�b�g�{�l�j
	move.l	d7,d3			;�x���W
	lsl.w	#4,d3			;�@�g���b�N�ԍ����P�U�{
	addi.l	#16*6-3,d3		;�@�x�I�t�Z�b�g��������
	move.l	d7,d1			;�X�v���C�g�y�[�W�i�g���b�N�ԍ��j
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$01,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	move.l	d7,d2			;d2���A
*---------------------------------------*
vol_skip:
*	sub.l	ps_trk,d2
	dbra	d2,vol_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1-a2
	rts

*********************************************************
*
*	�G�N�X�v���b�V����
*
expression:
*********************************************************
	movem.l	d0-d7/a1-a2,-(sp)

	moveq.l	#18-1,d2
exp_trk_loop:
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#midich,a1		;a1.l=�`�����l���f�[�^�擪
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=�`�����l���ԍ�

	move.b	#-1,d3			;d3.b=�G�N�X�v���b�V�����l���n�e�e
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_expr,a1		;a1.l=�G�N�X�v���b�V�����f�[�^�擪
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=�G�N�X�v���b�V�����l
@@:
	lea.l	o_exp,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	exp_skip		;�ς���ĂȂ���΃X�L�b�v
	move.b	d3,(a1)

*---------------------------------------*
*���l
	cmp.b	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	clr.b	d3			;�@���ۂ̒l���O�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷
*	jsr	left3keta
@@:
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#32,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#6,d2			;�U�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	move.l	#TVRAM,a1
	adda.l	#14,a1			;�w���W�^�W
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;�x�I�t�Z�b�g��������
	add.l	d5,a1

	lea.l	exp_slide_tbl,a2
	move.l	d2,d4
	add.w	d4,d4			;d4=d4*4
	add.w	d4,d4			;
	adda.l	d4,a2

	move.w	#%01_0001_0000,R21	;�����A�N�Z�X
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)

*---------------------------------------*
*�X���C�_�[�܂�
	addi.l	#132,d2			;�w���W�i�w�I�t�Z�b�g�{�l�j
	move.l	d7,d3			;�x���W
	lsl.w	#4,d3			;�@�g���b�N�ԍ����P�U�{
	addi.l	#16*6-3,d3		;�@�x�I�t�Z�b�g��������
	move.w	d7,d1
	addi.w	#18,d1			;�X�v���C�g�y�[�W�i�g���b�N�ԍ��{�P�W�j
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$01,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	move.l	d7,d2			;d2���A
*---------------------------------------*
exp_skip:
	dbra	d2,exp_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1-a2
	rts

*********************************************************
*
*	���W�����[�V����
*
modulation:
*********************************************************
	movem.l	d0-d7/a1/a2/a6,-(sp)

	moveq.l	#18-1,d2
mod_trk_loop:
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#midich,a1		;a1.l=�`�����l���f�[�^�擪
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=�`�����l���ԍ�

	move.b	#-1,d3			;d3.b=���W�����[�V�����l���n�e�e
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_modu,a1		;a1.l=�p���|�b�g�f�[�^�擪
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=�p���|�b�g�l
@@:
	lea.l	o_mod,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	mod_skip		;�ς���ĂȂ���΃X�L�b�v
	move.b	d3,(a1)

*---------------------------------------*
*���l
	cmp.b	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	clr.b	d3			;�@���ۂ̒l���O�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷
*	jsr	left3keta
@@:
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#37,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#9,d2			;�X�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	move.l	#TVRAM,a1
	adda.l	#18,a1			;�w���W�^�W
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;�x�I�t�Z�b�g��������
	add.l	d5,a1

	lea.l	mod_slide_tbl,a2
	move.l	d2,d4
	add.w	d4,d4			;d4=d4*2
	adda.l	d4,a2

	move.w	#%01_0010_0000,R21	;�����A�N�Z�X
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)

*---------------------------------------*
*�X���C�_�[�܂�
	addi.l	#160,d2			;�w���W�i�w�I�t�Z�b�g�{�l�j
	move.l	d7,d3			;�x���W
	lsl.w	#4,d3			;�@�g���b�N�ԍ����P�U�{
	addi.l	#16*6-3,d3		;�@�x�I�t�Z�b�g��������
	move.w	d7,d1
	addi.w	#18*2,d1		;�X�v���C�g�y�[�W�i�g���b�N�ԍ��{�P�W���Q�j
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$01,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	move.l	d7,d2			;d2���A
*---------------------------------------*
mod_skip:
	dbra	d2,mod_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1/a2/a6
	rts

*********************************************************
*
*	�p���|�b�g
*
panpot:
*********************************************************
	movem.l	d0-d7/a1-a2/a5-a6,-(sp)

	moveq.l	#18-1,d2
pan_trk_loop:
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#midich,a1		;a1.l=�`�����l���f�[�^�擪
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=�`�����l���ԍ�

	move.b	#-1,d3			;d3.b=�p���|�b�g�l���n�e�e
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_panpot,a1		;a1.l=�p���|�b�g�f�[�^�擪
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=�p���|�b�g�l
@@:
	lea.l	o_pan,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	pan_skip		;�ς���ĂȂ���΃X�L�b�v
	move.b	d3,(a1)

*---------------------------------------*
*���l
	cmp.b	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	move.b	#64,d3			;�@���ۂ̒l���U�S�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷
*	jsr	left3keta
@@:
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#44,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini
*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#6,d2			;�U�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	addi.l	#160+21,d2		;�w���W�i�w�I�t�Z�b�g�{�l�j
	move.l	d7,d3			;�x���W
	lsl.w	#4,d3			;�@�g���b�N�ԍ����P�U�{
	addi.l	#16*6-3,d3		;�@�x�I�t�Z�b�g��������
	move.w	d7,d1
	addi.w	#18*5,d1		;�X�v���C�g�y�[�W�i�g���b�N�ԍ��{�P�W���T�j
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$37,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	move.l	d7,d2			;d2���A
*---------------------------------------*
pan_skip:
	dbra	d2,pan_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1-a2/a5-a6
	rts

*********************************************************
*
*	�s�b�`�x���h
*
pitchbend:
*********************************************************
	movem.l	d0-d7/a1-a2/a5-a6,-(sp)

	moveq.l	#18-1,d2
bnd_trk_loop:
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#midich,a1		;a1.l=�`�����l���f�[�^�擪
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=�`�����l���ԍ�

	move.l	#$ffff_ffff,d3		;d3.l=�s�b�`�x���h���n�e�e
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	0(a1,d2.l)
	beq	@f

	lsl.l	#2,d7
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_pbend,a1		;a1.l=�s�b�`�x���h�f�[�^�擪
	move.l	0(a1,d7.w),d3		;d3.l=�s�b�`�x���h�l
@@:
	lea.l	o_bnd,a1
	move.l	d2,d4
	lsl.l	#2,d4
	adda.l	d4,a1
	cmp.l	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	bnd_skip		;�ς���ĂȂ���΃X�L�b�v
	move.l	d3,(a1)

*---------------------------------------*
*���l
	cmp.l	#$ffff_ffff,d3		;�l���n�e�e�Ȃ�
	bne	@f
	move.l	#8192,d3		;�@���ۂ̒l���O�ɂ���
	lea.l	mes_6space,a6		;�@�󔒕\��
	bra	bpm
@@:
	clr.b	d5			;d5.b=�}�C�i�X�t���O
	pea.l	tbuf
	move.l	d3,d4
	subi.l	#8192,d4		;d4.l= 0�`16384 �� -8192�`8192
	bcc	@f
	neg.l	d4
	move.b	#-1,d5
@@:
	move.l	d4,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#5,a6
*	jsr	left5keta
	tst.b	d5			;�}�C�i�X��������'-'��t��
	beq	bpm
	cmp.b	#' ',1(a6)
	beq	@f
	move.b	#'-',(a6)
	bra	bpm
@@:	cmp.b	#' ',2(a6)
	beq	@f
	move.b	#'-',1(a6)
	bra	bpm
@@:	cmp.b	#' ',3(a6)
	beq	@f
	move.b	#'-',2(a6)
	bra	bpm
@@:	cmp.b	#' ',4(a6)
	beq	@f
	move.b	#'-',3(a6)
	bra	bpm
@@:	move.b	#'-',4(a6)
bpm:
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#49,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	move.l	d3,d2
	divu.w	#128*5,d2		;�P�Q�W�Ŋ��違�T�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	move.l	#TVRAM,a1
	adda.l	#24,a1			;�w���W�^�W
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-14),d5	;�x�I�t�Z�b�g��������
	adda.l	d5,a1

	lea.l	bnd_slide_tbl1,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.w	d4,a2

	move.w	#%01_1010_0000,R21	;�����A�N�Z�X

	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)
	move.b	(a2),1024/8*3(a1)
	move.b	(a2),1024/8*4(a1)
	move.b	(a2)+,1024/8*5(a1)
	addq.l	#1,a1
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)
	move.b	(a2),1024/8*3(a1)
	move.b	(a2),1024/8*4(a1)
	move.b	(a2)+,1024/8*5(a1)
	addq.l	#1,a1
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)
	move.b	(a2),1024/8*3(a1)
	move.b	(a2),1024/8*4(a1)
	move.b	(a2),1024/8*5(a1)

	subq.l	#2,a1
	lea.l	bnd_slide_tbl2,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.w	d4,a2

	move.w	#%01_0001_0000,R21	;�����A�N�Z�X

	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)
	move.b	(a2),1024/8*3(a1)
	move.b	(a2),1024/8*4(a1)
	move.b	(a2)+,1024/8*5(a1)
	addq.l	#1,a1
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)
	move.b	(a2),1024/8*3(a1)
	move.b	(a2),1024/8*4(a1)
	move.b	(a2)+,1024/8*5(a1)
	addq.l	#1,a1
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)
	move.b	(a2),1024/8*3(a1)
	move.b	(a2),1024/8*4(a1)
	move.b	(a2),1024/8*5(a1)

	move.l	d7,d2			;d2���A
*---------------------------------------*
bnd_skip:
	dbra	d2,bnd_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1-a2/a5-a6
	rts

*********************************************************
*
*	���o�[�u
*
reverb:
*********************************************************
	movem.l	d0-d7/a1/a2/a6,-(sp)

	moveq.l	#18-1,d2
rvb_trk_loop:
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#midich,a1		;a1.l=�`�����l���f�[�^�擪
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=�`�����l���ԍ�

	move.b	#-1,d3			;d3.b=���o�[�u�l���n�e�e
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_gsrev,a1		;a1.l=���o�[�u�f�[�^�擪
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=���o�[�u�l
@@:
	lea.l	o_rvb,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	rvb_skip		;�ς���ĂȂ���΃X�L�b�v
	move.b	d3,(a1)

*---------------------------------------*
*���l
	cmp.b	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	clr.b	d3			;�@���ۂ̒l���O�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷
*	jsr	left3keta

	cmp.b	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	clr.b	d3			;�@���ۂ̒l���O�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
@@:
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#57,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#7,d2			;�V�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	move.l	#TVRAM,a1
	adda.l	#27,a1			;�w���W�^�W
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;�x�I�t�Z�b�g��������
	add.l	d5,a1

	lea.l	rvb_slide_tbl,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.l	d4,a2

	move.w	#%01_0011_0000,R21	;�����A�N�Z�X
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)

*---------------------------------------*
*�X���C�_�[�܂�
	addi.l	#236,d2			;�w���W�i�w�I�t�Z�b�g�{�l�j
	move.l	d7,d3			;�x���W
	lsl.w	#4,d3			;�@�g���b�N�ԍ����P�U�{
	addi.l	#16*6-3,d3		;�@�x�I�t�Z�b�g��������
	move.w	d7,d1
	addi.w	#18*3,d1		;�X�v���C�g�y�[�W�i�g���b�N�ԍ��{�P�W���R�j
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$01,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	move.l	d7,d2			;d2���A
*---------------------------------------*
rvb_skip:
	dbra	d2,rvb_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1/a2/a6
	rts

*********************************************************
*
*	�R�[���X
*
chorus:
*********************************************************
	movem.l	d0-d7/a1/a2/a6,-(sp)

	moveq.l	#18-1,d2
cho_trk_loop:
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#midich,a1		;a1.l=�`�����l���f�[�^�擪
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=�`�����l���ԍ�

	move.b	#-1,d3			;d3.b=�R�[���X�l���n�e�e
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_gscho,a1		;a1.l=�R�[���X�f�[�^�擪
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=�R�[���X�l
@@:
	lea.l	o_cho,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	cho_skip		;�ς���ĂȂ���΃X�L�b�v
	move.b	d3,(a1)

*---------------------------------------*
*���l
	cmp.b	#-1,d3			;�l���n�e�e�Ȃ�
	bne	@f
	clr.b	d3			;�@���ۂ̒l���O�ɂ���
	lea.l	mes_3space,a6		;�@�󔒕\��
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷
*	jsr	left3keta
@@:
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#63,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#7,d2			;�V�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	move.l	#TVRAM,a1
	adda.l	#30,a1			;�w���W�^�W
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;�x�I�t�Z�b�g��������
	add.l	d5,a1

	lea.l	cho_slide_tbl,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.l	d4,a2

	move.w	#%01_0011_0000,R21	;�����A�N�Z�X
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)

*---------------------------------------*
*�X���C�_�[�܂�
	addi.l	#260,d2			;�w���W�i�w�I�t�Z�b�g�{�l�j
	move.l	d7,d3			;�x���W
	lsl.w	#4,d3			;�@�g���b�N�ԍ����P�U�{
	addi.l	#16*6-3,d3		;�@�x�I�t�Z�b�g��������
	move.w	d7,d1
	addi.w	#18*4,d1		;�X�v���C�g�y�[�W�i�g���b�N�ԍ��{�P�W���S�j
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$01,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	move.l	d7,d2			;d2���A
*---------------------------------------*
cho_skip:
	dbra	d2,cho_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1/a2/a6
	rts

*********************************************************
*
*	�_���p�[�y�_��
*
hold:
*********************************************************
	movem.l	d0-d7/a0-a6,-(sp)

	moveq.l	#18-1,d2
hold_trk_loop:
	moveq.l	#0,d7
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#midich,a1		;a1.l=�`�����l���f�[�^�擪
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=�`�����l���ԍ�

	clr.b	d3			;d3.b=�z�[���h�l���O
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#active,a1		;a1.l=�g���b�N�L���t���O�擪
	tst.b	0(a1,d2.l)
	beq	@f			;�g���b�N�������Ȃ�X�L�b�v

	moveq.l	#0,d3
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_hold1,a1		;a1.l=�z�[���h�f�[�^�擪
	move.b	0(a1,d7.w),d3		;d3.b=�z�[���h�l
@@:
	lea.l	o_hld,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	hold_skip		;�ς���Ă��Ȃ���΃X�L�b�v
	move.b	d3,(a1)

	cmp.b	#64,d3			;64�ȏ�Ȃ�HOLD ON
	bge	@f
	lea.l	mes_1space,a6
	bra	@@f
@@:
	lea.l	mes_ten,a6
@@:
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#15,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

*---------------------------------------*
hold_skip:
	dbra	d2,hold_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a0-a6
	rts

*********************************************************
*
*	���F��
*
instrument:
*********************************************************
	movem.l	d1-d7/a1-a2/a6,-(sp)
	cmpi.b	#1,memo_mode
	beq	inst_end
*---------------------------------------*
	moveq.l	#18-1,d2
inst_trk_loop:
	moveq.l	#0,d7
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#midich,a1		;a1.l=�`�����l���f�[�^�擪
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=�`�����l���ԍ�

	move.b	#-1,d4			;d4.b=�o���N�ԍ����n�e�e
	move.b	#-1,d3			;d3.b=���F�ԍ����n�e�e

	movea.l	a5,a2			;a1.l=RCD���[�N�擪
	adda.l	#active,a2		;a1.l=�g���b�N�L���t���O�擪
	tst.b	0(a2,d2.l)
	beq	@f			;�g���b�N�������Ȃ�X�L�b�v

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_bank,a1		;a1.l=�o���N�ԍ��f�[�^�擪
	move.b	0(a1,d7.w),d4		;d4.b=�o���N�ԍ�
@@:
	lea.l	o_bnk,a1
	adda.l	d2,a1
	cmp.b	(a1),d4			;�p�����[�^���ς���Ă邩�H
	beq	@f			;�ς���ĂȂ���Ύ���
	move.b	#1,d1			;�ς���Ă���΃t���O�𗧂ĂĂ���(d1)
	move.b	d4,(a1)
@@:
	tst.b	0(a2,d2.l)
	beq	@f			;�g���b�N�������Ȃ�X�L�b�v

	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_prg,a1		;a1.l=�v���O�����ԍ��f�[�^�擪
	move.b	0(a1,d7.w),d3		;d3.b=�v���O�����ԍ�
	cmp.b	#1,d1			;d1�t���O�������Ă��邩�H
	beq	inst_main		;�����Ă���Ώ����J�n
@@:
	lea.l	o_prg,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;�p�����[�^���ς���Ă邩�H
	beq	inst_skip		;�ς���Ă��Ȃ���΃X�L�b�v
	move.b	d3,(a1)
inst_main:
*---------------------------------------*
*�O�̕\��������
	move.l	d2,d5			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d5			;�g���b�N�ԍ����P�U
	addi.l	#83,d5			;�I�t�Z�b�g��������
	lsl.l	#7,d5			;Y=Y*128
	addi.l	#34,d5			;�w���W
	movea.l	#TVRAM,a1
	adda.l	d5,a1
	move.w	#%01_1111_0000,R21

	clr.b	-1(a1)
	clr.b	128-1(a1)
	clr.b	128*2-1(a1)
	clr.b	128*3-1(a1)
	clr.b	128*4-1(a1)
	clr.b	128*5-1(a1)
	clr.b	128*6-1(a1)
	clr.b	128*7-1(a1)
	clr.b	128*8-1(a1)
	clr.b	128*9-1(a1)
	clr.b	128*10-1(a1)
	clr.b	128*11-1(a1)
	clr.l	(a1)
	clr.l	128(a1)
	clr.l	128*2(a1)
	clr.l	128*3(a1)
	clr.l	128*4(a1)
	clr.l	128*5(a1)
	clr.l	128*6(a1)
	clr.l	128*7(a1)
	clr.l	128*8(a1)
	clr.l	128*9(a1)
	clr.l	128*10(a1)
	clr.l	128*11(a1)
	clr.l	4(a1)
	clr.l	128+4(a1)
	clr.l	128*2+4(a1)
	clr.l	128*3+4(a1)
	clr.l	128*4+4(a1)
	clr.l	128*5+4(a1)
	clr.l	128*6+4(a1)
	clr.l	128*7+4(a1)
	clr.l	128*8+4(a1)
	clr.l	128*9+4(a1)
	clr.l	128*10+4(a1)
	clr.l	128*11+4(a1)

	cmp.b	#-1,d3			;�v���O�����ԍ����n�e�e�Ȃ�
	beq	inst_skip
*---------------------------------------*
*���F�ԍ��\��
	move.l	d7,-(sp)		;! d7�ۑ�
*bank
	move.w	#%01_1111_0000,R21
	pea.l	tbuf
	move.l	d4,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷

	move.l	#67,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	addi.l	#83,d7			;�I�t�Z�b�g��������
	jsr	print_mini
*program
	pea.l	tbuf
	move.l	d3,d5
	addq.l	#1,d5
	move.l	d5,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷

	addq.l	#6,d7			;�x�I�t�Z�b�g��������
	jsr	print_mini
	move.l	(sp)+,d7		;! d7���A
*---------------------------------------*
*���F���\��
inst_name:
*���Y���p�[�g
@@:	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#ch_part,a1		;a1.l=������ރf�[�^�擪
	cmp.b	#2,0(a1,d7.w)		;���Y���p�[�g�H
	bne	@f
	lea.l	inst_drums,a6
	move.w	#%01_0011_0000,R21
	bra	inst_break
*�o���N����
@@:	move.w	#%01_1111_0000,R21
	cmp.b	#0,d4
	bne	@f
	lea.l	inst_capital,a6
	bra	inst_break
@@:	move.w	#%01_0010_0000,R21
	cmp.b	#1,d4
	bne	@f
	lea.l	inst_var1,a6
	bra	inst_break
@@:	cmp.b	#2,d4
	bne	@f
	lea.l	inst_var2,a6
	bra	inst_break
@@:	cmp.b	#3,d4
	bne	@f
	lea.l	inst_var3,a6
	bra	inst_break
@@:	cmp.b	#4,d4
	bne	@f
	lea.l	inst_var4,a6
	bra	inst_break
@@:	cmp.b	#5,d4
	bne	@f
	lea.l	inst_var5,a6
	bra	inst_break
@@:	cmp.b	#6,d4
	bne	@f
	lea.l	inst_var6,a6
	bra	inst_break
@@:	cmp.b	#7,d4
	bne	@f
	lea.l	inst_var7,a6
	bra	inst_break
@@:	cmp.b	#8,d4
	bne	@f
	lea.l	inst_var8,a6
	bra	inst_break
@@:	cmp.b	#9,d4
	bne	@f
	lea.l	inst_var9,a6
	bra	inst_break
@@:	cmp.b	#10,d4
	bne	@f
	lea.l	inst_var10,a6
	bra	inst_break
@@:	cmp.b	#11,d4
	bne	@f
	lea.l	inst_var11,a6
	bra	inst_break
@@:	cmp.b	#16,d4
	bne	@f
	lea.l	inst_var16,a6
	bra	inst_break
@@:	cmp.b	#17,d4
	bne	@f
	lea.l	inst_var17,a6
	bra	inst_break
@@:	cmp.b	#18,d4
	bne	@f
	lea.l	inst_var18,a6
	bra	inst_break
@@:	cmp.b	#19,d4
	bne	@f
	lea.l	inst_var19,a6
	bra	inst_break
@@:	cmp.b	#24,d4
	bne	@f
	lea.l	inst_var24,a6
	bra	inst_break
@@:	cmp.b	#25,d4
	bne	@f
	lea.l	inst_var25,a6
	bra	inst_break
@@:	cmp.b	#26,d4
	bne	@f
	lea.l	inst_var26,a6
	bra	inst_break
@@:	cmp.b	#32,d4
	bne	@f
	lea.l	inst_var32,a6
	bra	inst_break
@@:	cmp.b	#33,d4
	bne	@f
	lea.l	inst_var33,a6
	bra	inst_break
@@:	cmp.b	#40,d4
	bne	@f
	lea.l	inst_var40,a6
	bra	inst_break
@@:	cmp.b	#126,d4
	bne	@f
	lea.l	inst_CM32P,a6
	bra	inst_break
@@:	cmp.b	#127,d4
	bne	@f
	lea.l	inst_CM32L,a6
	move.w	#%01_1000_0000,R21
	bra	inst_break
@@:
*���[�U�[�C���X�g�D�������g
	cmp.b	#64,d4
	bne	@f
	lea.l	inst_user,a6
	bra	inst_break_2
@@:	cmp.b	#65,d4
	bne	@f
	lea.l	inst_user,a6
	bra	inst_break_2
@@:
*������ɂ����Ă͂܂炸
	lea.l	capital_out,a6
	bra	inst_break_2
inst_break:
	cmp.b	#119,d3			;���ʉ�
	bls	@f
	move.w	#%01_0001_0000,R21
@@:
	move.l	d3,d5			;���F��������̃A�h���X������
	mulu.w	#13,d5
	adda.l	d5,a6
inst_break_2:
	move.l	#71,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#86,d7			;�I�t�Z�b�g��������
	jsr	print_4x8font

*---------------------------------------*
inst_skip:
	dbra	d2,inst_trk_loop
*---------------------------------------*
inst_end:
	movem.l	(sp)+,d1-d7/a1-a2/a6
	rts

*********************************************************
*
*	�}�X�^�[�{�����[��
*
master_volume:
*********************************************************
	movem.l	d0-d7/a1-a2,-(sp)

	moveq.l	#18,d2

	moveq.l	#0,d3
	move.b	GS_VOL(a5),d3		;d3.b=�{�����[���l
	cmp.b	o_mvol,d3		;�p�����[�^���ς���Ă邩�H
	beq	mvol_skip		;�ς���ĂȂ���΃X�L�b�v
	move.b	d3,o_mvol

*---------------------------------------*
*���l
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷

	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#25,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#6,d2			;�U�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	move.l	#TVRAM,a1
	adda.l	#11,a1			;�w���W�^�W
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;�x�I�t�Z�b�g��������
	add.l	d5,a1

	lea.l	vol_slide_tbl,a2
	move.l	d2,d4
	add.w	d4,d4			;d4=d4*4
	add.w	d4,d4			;
	adda.l	d4,a2

	move.w	#%01_0001_0000,R21	;�����A�N�Z�X
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)

*---------------------------------------*
*�X���C�_�[�܂�
	addi.l	#104,d2			;�w���W�i�w�I�t�Z�b�g�{�l�j
	move.l	d7,d3			;�x���W
	lsl.w	#4,d3			;�@�g���b�N�ԍ����P�U�{
	addi.l	#16*6-3,d3		;�@�x�I�t�Z�b�g��������
	move.l	#108,d1			;�X�v���C�g�y�[�W
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$01,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	move.l	d7,d2			;d2���A
*---------------------------------------*
mvol_skip:
	movem.l	(sp)+,d0-d7/a1-a2
	rts

*********************************************************
*
*	�}�X�^�[�p���|�b�g
*
master_panpot:
*********************************************************
	movem.l	d0-d7/a1-a2/a5-a6,-(sp)

	moveq.l	#18,d2

	moveq.l	#0,d3
	move.b	GS_PAN(a5),d3		;d3.b=�p���|�b�g�l
	cmp.b	o_mpan,d3		;�p�����[�^���ς���Ă邩�H
	beq	mpan_skip		;�ς���ĂȂ���΃X�L�b�v
	move.b	d3,o_mpan

*---------------------------------------*
*���l
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str�ϊ�
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;���R���̈ʒu�Ƀ|�C���^�����炷

	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#44,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini
*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#6,d2			;�U�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	addi.l	#160+21,d2		;�w���W�i�w�I�t�Z�b�g�{�l�j
	move.l	d7,d3			;�x���W
	lsl.w	#4,d3			;�@�g���b�N�ԍ����P�U�{
	addi.l	#16*6-3,d3		;�@�x�I�t�Z�b�g��������
	move.l	#111,d1			;�X�v���C�g�y�[�W
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$37,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	move.l	d7,d2			;d2���A
*---------------------------------------*
mpan_skip:
	movem.l	(sp)+,d0-d7/a1-a2/a5-a6
	rts

*********************************************************
*
*	�}�X�^�[���o�[�u
*
master_reverb:
*********************************************************
	movem.l	d0-d7/a1/a2/a6,-(sp)

	moveq.l	#18,d2
	move.l	d1,d3
*---------------------------------------*
*���l
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#57,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#7,d2			;�V�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	move.l	#TVRAM,a1
	adda.l	#27,a1			;�w���W�^�W
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;�x�I�t�Z�b�g��������
	add.l	d5,a1

	lea.l	rvb_slide_tbl,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.l	d4,a2

	move.w	#%01_0011_0000,R21	;�����A�N�Z�X
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X

*---------------------------------------*
*�X���C�_�[�܂�
	addi.l	#236,d2			;�w���W�i�w�I�t�Z�b�g�{�l�j
	move.l	d7,d3			;�x���W
	lsl.w	#4,d3			;�@�g���b�N�ԍ����P�U�{
	addi.l	#16*6-3,d3		;�@�x�I�t�Z�b�g��������
	move.l	#109,d1			;�X�v���C�g�y�[�W
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$01,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	move.l	d7,d2			;d2���A
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1/a2/a6
	rts

*********************************************************
*
*	�}�X�^�[�R�[���X
*
master_chorus:
*********************************************************
	movem.l	d0-d7/a1/a2/a6,-(sp)

	moveq.l	#18,d2
	move.l	d1,d3

*---------------------------------------*
*���l
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X�ݒ�
	move.l	#63,d6			;�w���W
	move.l	d2,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#89,d7			;�I�t�Z�b�g��������
	jsr	print_mini

*---------------------------------------*
*�X���C�_�[
	move.l	d2,d7			;d2�ޔ�

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#7,d2			;�V�Ŋ���
	andi.l	#$0000_ffff,d2		;���ʃ��[�h����

	move.l	#TVRAM,a1
	adda.l	#30,a1			;�w���W�^�W
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;�x�I�t�Z�b�g��������
	add.l	d5,a1

	lea.l	cho_slide_tbl,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.l	d4,a2

	move.w	#%01_0011_0000,R21	;�����A�N�Z�X
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X

*---------------------------------------*
*�X���C�_�[�܂�
	addi.l	#260,d2			;�w���W�i�w�I�t�Z�b�g�{�l�j
	move.l	d7,d3			;�x���W
	lsl.w	#4,d3			;�@�g���b�N�ԍ����P�U�{
	addi.l	#16*6-3,d3		;�@�x�I�t�Z�b�g��������
	move.l	#110,d1			;�X�v���C�g�y�[�W
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$01,d4			;�p�^�[���R�[�h
	add.l	#%0001_00_000000,d4	;�p���b�g�R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	move.l	d7,d2			;d2���A
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1/a2/a6
	rts

*********************************************************
*
*	����
*
keyboard:
*********************************************************
	movem.l	d1-d7/a1-a6,-(sp)
*---------------------------------------*
*���Y���p�[�g���ԊǗ�
	lea.l	rhy_flags,a4
rht_lp:
	cmpa.l	rhy_pointer,a4
	bcc	get_note		;���[�v�I��

	tst.b	1(a4)			;���[�N���󂢂Ă���X�L�b�v
	bne	@f
	addq.l	#6,a4
	bra	rht_lp
@@:
	IOCS	_ONTIME
	sub.l	2(a4),d0		;d0.l=ɰĵ݂��猻�݂܂ł̎��ԍ�
	cmpi.l	#10,d0
	bcc	@f
	addq.l	#6,a4			;���Ԃ����ĂȂ���΃X�L�b�v
	bra	rht_lp
@@:
	moveq.l	#0,d2			;���Ԃ�������m�[�g�I�t����
	moveq.l	#0,d1
	move.b	(a4),d2		*trk
	move.b	1(a4),d1	*note
	moveq.l	#0,d4		*vel
	bsr	key_main
	clr.b	1(a4)
	addq.l	#6,a4
	bra	rht_lp
*---------------------------------------*
get_note:
	move.l	cnoteptr,d7
kb_loop:
	movea.l	note_adr(a5),a1
	movea.l	noteptr(a5),a2
	cmp.l	d7,a2
	beq	kb_break

	moveq.l	#0,d2
	moveq.l	#0,d1
	move.b	0(a1,d7.l),d2		;d2.b=track
	move.b	1(a1,d7.l),d1		;d1.b=note
*	move.b	2(a1,d7.l),d3		;d3.b=gate�i���g�p�j
	move.b	3(a1,d7.l),d4		;d4.b=velo

	tst.b	d4			;vel=0�H
	beq	@f
	bsr	speana
@@:
	moveq.l	#0,d6
	movea.l	a5,a3			;a3.l=RCD���[�N�擪
	adda.l	#midich,a3		;a3.l=�`�����l���f�[�^�擪
	move.b	(a3,d2.l),d6		;d6.b=�`�����l���ԍ�
	movea.l	a5,a3			;a3.l=RCD���[�N�擪
	adda.l	#ch_part,a3		;a3.l=������ރf�[�^�擪
	cmp.b	#2,(a3,d6.l)		;���Y���p�[�g�H
	bne	bsr_key_main
	tst.b	d4			;vel=0�H
	beq	key_break

	lea.l	rhy_flags,a4
@@:
	tst.b	1(a4)			;���[�N�󂢂Ă邩�H
	beq	@f
	addq.l	#6,a4			;�󂢂Ă��Ȃ���΃|�C���^��i�߂ă��[�v
	bra	@b
@@:
	move.b	d2,(a4)			;trk
	move.b	d1,1(a4)		;note
	movem.l	d0-d1,-(sp)
	IOCS	_ONTIME
	move.l	d0,2(a4)		;note-on time
	movem.l	(sp)+,d0-d1
	cmpa.l	rhy_pointer,a4
	bls	@f
	move.l	a4,rhy_pointer		;rhy_pointer=���[�N�l�`�w
@@:
bsr_key_main:
	bsr	key_main
key_break:
	addq.l	#4,d7
	andi.l	#$3ff,d7
	move.l	d7,cnoteptr
	bra	kb_loop

*---------------------------------------*
kb_break:
	movem.l	(sp)+,d1-d7/a1-a6
	rts

*---------------------------------------*
*���Օ\�����C�����[�`��
key_main:
	movem.l	d0-d7/a1-a2/a5,-(sp)

	cmp.b	#18,d2			;�g���b�N19�ȏ�Ȃ�\���͈͊O�����甲����
	bcc	km_ret

	move.b	d1,d7			;d7.b=�m�[�g�ԍ�
	move.l	d2,d6			;d6.b=�g���b�N�ԍ�
	moveq.l	#0,d5

	sub.b	note_shift,d1		;0=c1�ɃZ�b�g

	divu.w	#12,d1
	move.w	d1,d5			;d5.w=�I�N�^�[�u
	swap.w	d1			;d1.w=����
	lsl.w	#4,d2			;�x���g���b�N�ԍ����P�U

*---------------------------------------*
	lea.l	note_jmp_tbl,a1		;���Ոʒu����(table jump)
	move.w	d1,d3
	add.w	d3,d3
	add.w	d3,d3
	adda.w	d3,a1
	movea.l	(a1),a1
	jsr	(a1)
*---------------------------------------*
put_key:
	add.w	#334,d1			;�w�I�t�Z�b�g��������
	mulu.w	#4*7,d5
	add.w	d5,d1			;�I�N�^�[�u��������
	add.w	#84+6,d2		;�x�I�t�Z�b�g��������

	andi.b	#$ff,d7
	cmpi.b	#$ff,d7
	bne	@f
	bsr	key_clr
	bra	km_ret
@@:
	cmpi.b	#$fd,d7
	bne	@f
	bra	km_ret
@@:
	tst.b	memo_mode		;�������[�h�Ȃ�`���Ȃ�
	bne	km_ret
	tst.b	d4
	bne	@f
	bsr	key_clr
	bra	km_ret
@@:
	bsr	key_pset
*---------------------------------------*
km_ret:
	movem.l	(sp)+,d0-d7/a1-a2/a5
	rts

*---------------------------------------*
*���Ոʒu����
note_jmp_tbl:
	.dc.l	note0
	.dc.l	note1
	.dc.l	note2
	.dc.l	note3
	.dc.l	note4
	.dc.l	note5
	.dc.l	note6
	.dc.l	note7
	.dc.l	note8
	.dc.l	note9
	.dc.l	note10
	.dc.l	note11
note0:					;C
	rts
note1:					;C+
	addq.w	#1,d1
	subq.w	#6,d2
	rts
note2:					;D
	addq.w	#2,d1
	rts
note3:					;D+
	addq.w	#2+1,d1
	subq.w	#6,d2
	rts
note4:					;E
	addq.w	#2*2,d1
	rts
note5:					;F
	addq.w	#2*3+1,d1
	rts
note6:					;F+
	addq.w	#2*3+2,d1
	subq.w	#6,d2
	rts
note7:					;G
	addi.w	#2*4+1,d1
	rts
note8:					;G+
	addi.w	#2*4+2,d1
	subq.w	#6,d2
	rts
note9:					;A
	addi.w	#2*5+1,d1
	rts
note10:					;A+
	addi.w	#2*5+2,d1
	subq.w	#6,d2
	rts
note11:					;B
	add.w	#2*6+1,d1
	rts

*********************************************************
*
*	���Փ_��������
*		����	d1.w = �w���W
*			d2.w = �x���W
*
*********************************************************
*�_��
key_pset:
	movem.l	d1-d4/a0,-(sp)
	move.w	R21,d4
	move.w	#%01_0111_0000,R21

	addq.w	#1,d1
	jsr	xy_to_address
	bset	d3,(a0)
	addq.w	#1,d1

	addq.w	#1,d2
	jsr	xy_to_address
	bset	d3,(a0)
	subq.w	#1,d1
	jsr	xy_to_address
	bset	d3,(a0)
	subq.w	#1,d1
	jsr	xy_to_address
	bset	d3,(a0)

	addq.w	#1,d2
	jsr	xy_to_address
	bset	d3,(a0)
	addq.w	#1,d1
	jsr	xy_to_address
	bset	d3,(a0)
	addq.w	#1,d1
	jsr	xy_to_address
	bset	d3,(a0)

	addq.w	#1,d2
	jsr	xy_to_address
	bset	d3,(a0)
	subq.w	#1,d1
	jsr	xy_to_address
	bset	d3,(a0)
	subq.w	#1,d1
	jsr	xy_to_address
	bset	d3,(a0)

	addq.w	#1,d2
	addq.w	#1,d1
	jsr	xy_to_address
	bset	d3,(a0)

	move.w	d4,R21
	movem.l	(sp)+,d1-d4/a0
	rts

*---------------------------------------*
*����
key_clr:
	movem.l	d1-d4/a0,-(sp)
	move.w	R21,d4
	move.w	#%01_0111_0000,R21

	addq.w	#1,d1
	jsr	xy_to_address
	bclr	d3,(a0)
	addq.w	#1,d1

	addq.w	#1,d2
	jsr	xy_to_address
	bclr	d3,(a0)
	subq.w	#1,d1
	jsr	xy_to_address
	bclr	d3,(a0)
	subq.w	#1,d1
	jsr	xy_to_address
	bclr	d3,(a0)

	addq.w	#1,d2
	jsr	xy_to_address
	bclr	d3,(a0)
	addq.w	#1,d1
	jsr	xy_to_address
	bclr	d3,(a0)
	addq.w	#1,d1
	jsr	xy_to_address
	bclr	d3,(a0)

	addq.w	#1,d2
	jsr	xy_to_address
	bclr	d3,(a0)
	subq.w	#1,d1
	jsr	xy_to_address
	bclr	d3,(a0)
	subq.w	#1,d1
	jsr	xy_to_address
	bclr	d3,(a0)

	addq.w	#1,d2
	addq.w	#1,d1
	jsr	xy_to_address
	bclr	d3,(a0)

	move.w	d4,R21
	movem.l	(sp)+,d1-d4/a0
	rts

*********************************************************
*
*	�G�t�F�N�^�[
*
effect:
*********************************************************
	movem.l	d1-d2/a1-a6,-(sp)
	move.w	#%01_1111_0000,R21	;�����A�N�Z�X
*---------------------------------------*
*���o�[�u
@@:
*MACRO(str)
	moveq.l	#0,d1
	move.b	GS_RVB_Macro(a5),d1
	cmp.b	o_rvb_mac,d1
	beq	@f
	move.b	d1,o_rvb_mac
	move.b	d1,d2			; d1.b *= 7
	lsl.b	#3,d1			;
	sub.b	d2,d1			;
	lea.l	effect_reverb,a6
	adda.l	d1,a6
	SSPRINT	#2,#400+8*1,a6
*MACRO
	move.b	GS_RVB_Macro(a5),d1
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#5,#400+8*2,a6
@@:
*CHARACTER
	move.b	GS_RVB_Char(a5),d1
	cmp.b	o_rvb_cha,d1
	beq	@f
	move.b	d1,o_rvb_cha
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#5,#400+8*3,a6
@@:
*PRE-LPF
	move.b	GS_RVB_Prelpf(a5),d1
	cmp.b	o_rvb_pre,d1
	beq	@f
	move.b	d1,o_rvb_pre
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#5,#400+8*4,a6
@@:
*LEVEL
	move.b	GS_RVB_Level(a5),d1
	cmp.b	o_rvb_lvl,d1
	beq	@f
	move.b	d1,o_rvb_lvl
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#5,#400+8*5,a6
	jsr	master_reverb
@@:
*TIME
	move.b	GS_RVB_Time(a5),d1
	cmp.b	o_rvb_tme,d1
	beq	@f
	move.b	d1,o_rvb_tme
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#5,#400+8*6,a6
@@:
*DELAY FEEDBACK
	move.b	GS_RVB_Delay(a5),d1
	cmp.b	o_rvb_dly,d1
	beq	@f
	move.b	d1,o_rvb_dly
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#5,#400+8*7,a6
@@:
*SEND LEVEL TO CHORUS
	move.b	GS_RVB_Send(a5),d1
	cmp.b	o_rvb_snd,d1
	beq	@f
	move.b	d1,o_rvb_snd
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#5,#400+8*8,a6
@@:
*PREDELAY TIME
	move.b	GS_RVB_PreDelay(a5),d1
	cmp.b	o_rvb_pdly,d1
	beq	@f
	move.b	d1,o_rvb_pdly
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#5,#400+8*9,a6
*---------------------------------------*
*�R�[���X
@@:
*MACRO(str)
	moveq.l	#0,d1
	move.b	GS_CHO_Macro(a5),d1
	cmp.b	o_cho_mac,d1
	beq	@f
	move.b	d1,o_cho_mac
	move.b	d1,d2			; d1.b *= 7
	lsl.b	#3,d1			;
	sub.b	d2,d1			;
	lea.l	effect_chorus,a6
	adda.l	d1,a6
	SSPRINT	#11,#400+8*1,a6
*MACRO
	move.b	GS_CHO_Macro(a5),d1
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#14,#400+8*2,a6
@@:
*PRE-LPF
	move.b	GS_CHO_Prelpf(a5),d1
	cmp.b	o_cho_pre,d1
	beq	@f
	move.b	d1,o_cho_pre
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#14,#400+8*3,a6
@@:
*LEVEL
	move.b	GS_CHO_Level(a5),d1
	cmp.b	o_cho_lvl,d1
	beq	@f
	move.b	d1,o_cho_lvl
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#14,#400+8*4,a6
	jsr	master_chorus
@@:
*FEEDBACK
	move.b	GS_CHO_Feed(a5),d1
	cmp.b	o_cho_fed,d1
	beq	@f
	move.b	d1,o_cho_fed
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#14,#400+8*5,a6
@@:
*DELAY
	move.b	GS_CHO_Delay(a5),d1
	cmp.b	o_cho_dly,d1
	beq	@f
	move.b	d1,o_cho_dly
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#14,#400+8*6,a6
@@:
*RATE
	move.b	GS_CHO_Rate(a5),d1
	cmp.b	o_cho_rte,d1
	beq	@f
	move.b	d1,o_cho_rte
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#14,#400+8*7,a6
@@:
*DEPTH
	move.b	GS_CHO_Depth(a5),d1
	cmp.b	o_cho_dph,d1
	beq	@f
	move.b	d1,o_cho_dph
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#14,#400+8*8,a6
@@:
*SEND LEVEL TO REVERB
	move.b	GS_CHO_Send(a5),d1
	cmp.b	o_cho_snd,d1
	beq	@f
	move.b	d1,o_cho_snd
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#14,#400+8*9,a6
@@:
*SEND LEVEL TO DELAY
	move.b	GS_CHO_Send_Dly(a5),d1
	cmp.b	o_cho_snd_dly,d1
	beq	@f
	move.b	d1,o_cho_snd_dly
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#14,#400+8*10,a6
*---------------------------------------*
*�f�B���C
@@:
*MACRO(str)
	moveq.l	#0,d1
	move.b	GS_DLY_Macro(a5),d1
	cmp.b	o_dly_mac,d1
	beq	@f
	move.b	d1,o_dly_mac
	move.b	d1,d2			; d1.b *= 7
	lsl.b	#3,d1			;
	sub.b	d2,d1			;
	lea.l	effect_delay,a6
	adda.l	d1,a6
	SSPRINT	#20,#400+8*1,a6
*MACRO
	move.b	GS_DLY_Macro(a5),d1
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*2,a6
@@:
*PRE-LPF
	move.b	GS_DLY_Prelpf(a5),d1
	cmp.b	o_dly_pre,d1
	beq	@f
	move.b	d1,o_dly_pre
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*3,a6
@@:
*TIME CENETER
	move.b	GS_DLY_Time_C(a5),d1
	cmp.b	o_dly_tme_c,d1
	beq	@f
	move.b	d1,o_dly_tme_c
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*4,a6
@@:
*TIME LEFT
	move.b	GS_DLY_Time_L(a5),d1
	cmp.b	o_dly_tme_l,d1
	beq	@f
	move.b	d1,o_dly_tme_l
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*5,a6
@@:
*TIME RIGHT
	move.b	GS_DLY_Time_R(a5),d1
	cmp.b	o_dly_tme_r,d1
	beq	@f
	move.b	d1,o_dly_tme_r
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*6,a6
@@:
*LEVEL CENETER
	move.b	GS_DLY_Lev_C(a5),d1
	cmp.b	o_dly_lvl_c,d1
	beq	@f
	move.b	d1,o_dly_lvl_c
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*7,a6
@@:
*LEVEL LEFT
	move.b	GS_DLY_Lev_L(a5),d1
	cmp.b	o_dly_lvl_l,d1
	beq	@f
	move.b	d1,o_dly_lvl_l
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*8,a6
@@:
*LEVEL RIGHT
	move.b	GS_DLY_Lev_R(a5),d1
	cmp.b	o_dly_lvl_r,d1
	beq	@f
	move.b	d1,o_dly_lvl_r
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*9,a6
@@:
*LEVEL
	move.b	GS_DLY_Level(a5),d1
	cmp.b	o_dly_lvl,d1
	beq	@f
	move.b	d1,o_dly_lvl
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*10,a6
@@:
*FEEDBACK
	move.b	GS_DLY_Feed(a5),d1
	cmp.b	o_dly_fed,d1
	beq	@f
	move.b	d1,o_dly_fed
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*11,a6
@@:
*SEND LEVEL TO REVERB
	move.b	GS_DLY_Send_Rev(a5),d1
	cmp.b	o_dly_snd,d1
	beq	@f
	move.b	d1,o_dly_snd
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#23,#400+8*12,a6
*---------------------------------------*
*�d�p
@@:
*LOW FREQ
	move.b	GS_EQ_Low_Freq(a5),d1
	cmp.b	o_eq_lf,d1
	beq	@f
	move.b	d1,o_eq_lf
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#32,#400+8*2,a6
@@:
*LOW GAIN
	move.b	GS_EQ_Low_Gain(a5),d1
	cmp.b	o_eq_lg,d1
	beq	@f
	move.b	d1,o_eq_lg
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#32,#400+8*3,a6
@@:
*HIGH FREQ
	move.b	GS_EQ_High_Freq(a5),d1
	cmp.b	o_eq_hf,d1
	beq	@f
	move.b	d1,o_eq_hf
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#32,#400+8*4,a6
@@:
*HIGH GAIN
	move.b	GS_EQ_High_Gain(a5),d1
	cmp.b	o_eq_hg,d1
	beq	@f
	move.b	d1,o_eq_hg
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	adda.l	#7,a6
	SSPRINT	#32,#400+8*5,a6
*---------------------------------------*
@@:
	movem.l	(sp)+,d1-d2/a1-a6
	rts

*********************************************************
*
*	�T�T�n�t���f�B�X�v���C�i�O���t�b�N�p�^�[���j
*
sc55disp_ptn:
*********************************************************
	movem.l	d0-d6/a3-a5,-(sp)

	tst.b	sc_ptn_flag		;�\��������Ȃ���Ύ��ԃ`�F�b�N�̓X�L�b�v
	beq	scdsp_main

	IOCS	_ONTIME
	sub.l	sc_ptn_time,d0		;d0.l=���ԍ�
	cmpi.l	#300,d0
	bls	scdsp_main

	clr.b	sc_ptn_flag

clr_sc55ptn:
	move.w	#%01_0101_0000,R21
	move.l	#TVRAM+46+417*128,a1	;�O�̕\��������
	move.w	#64-1,d2
@@:	clr.l	(a1)
	clr.l	4(a1)
	clr.l	8(a1)
	clr.l	12(a1)
	add.l	#128,a1
	dbra	d2,@b

scdsp_main:
	move.w	#%01_0101_0000,R21
	tst.b	flg_gspanel(a5)
	beq	scpt_break
	clr.b	flg_gspanel(a5)

*---------------------------------------*
*�\���J�n
	IOCS	_ONTIME
	move.l	d0,sc_ptn_time		;�\���X�^�[�g���ԃZ�b�g
	move.b	#1,sc_ptn_flag

	movea.l	a5,a3
	adda.l	#gs_panel,a3		;a3.l=�p�^�[���f�[�^�擪
	move.l	#46,d1			;d1.l=�w���W
	move.l	#26,d0			;d0.l=�x���W

*---------------------------------------*
scdsp2:
	move.l	#TVRAM,a4
	moveq.l	#11,d2
	asl.l	d2,d0
	add.l	d1,d0
	add.l	d0,a4

	moveq.l	#16-1,d3		;�x���[�v
scdsp3:
	move.b	(a3),d0
	asl.w	#5,d0
	or.b	16(a3),d0
	asl.w	#5,d0
	or.b	32(a3),d0
	asl.l	#5,d0
	or.b	48(a3),d0
	asr.l	#4,d0
	addq.l	#1,a3

	moveq.l	#16-1,d4		;�w���[�v
scdsp4:
	add.w	d0,d0
	bcc	@f

	move.b	#%11111110,128(a4)	;�h�b�g�_��
	move.b	#%11111110,128*2(a4)
	move.b	#%11111110,128*3(a4)

	addq.l	#1,a4
	dbra	d4,scdsp4

	adda.l	#128*4-16,a4
	dbra	d3,scdsp3

	bra	@@f
@@:
	move.b	#%00000000,128(a4)	;�h�b�g����
	move.b	#%00000000,128*2(a4)
	move.b	#%00000000,128*3(a4)

	addq.l	#1,a4
	dbra	d4,scdsp4

	adda.l	#128*4-16,a4
	dbra	d3,scdsp3

*---------------------------------------*
scpt_break:
@@:
	movem.l	(sp)+,d0-d6/a3-a5
	rts

*********************************************************
*
*	�T�T�n�t���f�B�X�v���C�i������j
*
sc55disp_str:
*********************************************************
	movem.l	d0-d2/d6-d7/a0-a1/a3/a6,-(sp)

*---------------------------------------*
	tst.b	sc_str_flag		;�\��������Ȃ���Ύ��ԃ`�F�b�N�̓X�L�b�v
	beq	scstr_rol

*16�����ȉ����[�h���̎��ԃ`�F�b�N
	IOCS	_ONTIME
	sub.l	sc_str_time,d0		;d0.l=���ԍ�
	cmpi.l	#300,d0
	bls	scstr_main

	clr.b	sc_str_flag

*16�����ȉ����b�Z�[�W�\���I���
clr_sc55mes:
	move.w	#%01_1100_0000,R21
	movea.l	a5,a0			;-SOUND CANVAS-
	adda.l	#gs_info,a0		;a0.l=���ʌ�
	lea.l	sc_mes,a1		;a1.l=���ʐ�
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	lea.l	sc_mes,a6
	move.w	#46,d6			;d6.l=�w���W
	move.w	#401,d7			;d7.l=�x���W
	jsr	print_sc
	bra	scstr_main

*---------------------------------------*
scstr_rol:
	tst.b	sc_rol_count		;�X�N���[�����ĂȂ��H
	beq	scstr_main

	IOCS	_ONTIME
	move.l	d0,d1
	sub.l	sc_rol_time,d1		;d0.l=���ԍ�
	subi.l	#31,d1
	bls	scstr_main
	sub.l	d1,d0
	move.l	d0,sc_rol_time		;���ԃZ�b�g

*16�����ȏ�̃X�N���[������
	subq.b	#1,sc_rol_count
	addq.l	#1,sc_rol_pointer
	move.w	#%01_1100_0000,R21
	lea.l	sc_mes,a6
	add.l	sc_rol_pointer,a6
	move.w	#46,d6			;d6.l=�w���W
	move.w	#401,d7			;d7.l=�x���W
	jsr	print_sc

*---------------------------------------*
scstr_main:
	move.w	#%01_0101_0000,R21
	tst.b	flg_gsinst(a5)		;���b�Z�[�W�ς���Ă�H
	beq	chk_scinfo
	clr.b	flg_gsinst(a5)

	clr.b	sc_rol_count
	clr.l	sc_rol_pointer
	movea.l	a5,a0
	adda.l	#gs_inst,a0		;a0.l=������f�[�^�擪

	jsr	strlen
	move.w	d0,gsinst_ren
	cmp.w	#16,d0
	bhi	str_hi16
	bra	str_lw16
chk_scinfo:
	tst.b	sc_rol_count		;�X�N���[�����Ȃ�X�L�b�v
	bne	@f
	tst.b	flg_gsinfo(a5)
	beq	scst_break
	clr.b	flg_gsinfo(a5)
	move.w	#%01_1100_0000,R21
	movea.l	a5,a6			;-SOUND CANVAS-
	adda.l	#gs_info,a6
	move.w	#46,d6			;d6.l=�w���W
	move.w	#401,d7			;d7.l=�x���W
	jsr	print_sc
	bra	scst_break
@@:
	bsr	rewright_strbuf
	bra	scst_break

*---------------------------------------*
*�P�U�����ȉ��̏ꍇ�̏���
str_lw16:
	move.l	d0,-(sp)
	IOCS	_ONTIME
	move.l	d0,sc_str_time		;�\���X�^�[�g���ԃZ�b�g
	move.b	#1,sc_str_flag
	move.l	(sp)+,d0

	lea.l	sc_mes,a6
	move.l	#'    ',(a6)
	move.l	#'    ',4(a6)
	move.l	d0,d2
	divu.w	#2,d0			;�Z���^�����O����
	moveq.l	#16/2,d1
	sub.w	d0,d1
	move.b	(a0),(a6,d1.w)
	move.b	1(a0),1(a6,d1.w)
	move.b	2(a0),2(a6,d1.w)
	move.b	3(a0),3(a6,d1.w)
	move.b	4(a0),4(a6,d1.w)
	move.b	5(a0),5(a6,d1.w)
	move.b	6(a0),6(a6,d1.w)
	move.b	7(a0),7(a6,d1.w)
	move.b	8(a0),8(a6,d1.w)
	move.b	9(a0),9(a6,d1.w)
	move.b	10(a0),10(a6,d1.w)
	move.b	11(a0),11(a6,d1.w)
	move.b	12(a0),12(a6,d1.w)
	move.b	13(a0),13(a6,d1.w)
	move.b	14(a0),14(a6,d1.w)
	move.b	15(a0),15(a6,d1.w)
*	clr.b	16(a6,d1.w)
*	add.w	d2,d1

	move.w	#%01_1100_0000,R21
*	movea.l	a0,a6
	move.w	#46,d6			;d6.l=�w���W
	move.w	#401,d7			;d7.l=�x���W
	jsr	print_sc
	bra	scst_break

*---------------------------------------*
*�P�U�������傫���ꍇ�̏���
str_hi16:
	move.b	d0,sc_rol_count
	addi.b	#18,sc_rol_count

*	move.l	d0,-(sp)
	IOCS	_ONTIME
	move.l	d0,sc_rol_time		;�\���X�^�[�g���ԃZ�b�g
*	move.l	(sp)+,d0

*	bsr	rewright_strbuf		;�X�N���[��������Z�b�g

*---------------------------------------*
scst_break:
	movem.l	(sp)+,d0-d2/d6-d7/a0-a1/a3/a6
	rts

*---------------------------------------*
rewright_strbuf:
*�o�b�t�@�ɕ����񕡎�
	lea.l	sc_mes,a1
*-SOUND CANVAS-
	movea.l	a5,a0
	adda.l	#gs_info,a0
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+

	move.b	#'<',(a1)+
*���b�Z�[�W
	movea.l	a5,a0
	adda.l	#gs_inst,a0
	move.w	gsinst_ren,d1
	subq.w	#1,d1
@@:	move.b	(a0)+,(a1)+
	dbra	d1,@b
	move.b	#'<',(a1)+
*-SOUND CANVAS-
	movea.l	a5,a0
	adda.l	#gs_info,a0
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+

	rts

*********************************************************
*
*	���[�V�����|�C���^
*
motion_pointer:
*********************************************************
	movem.l	d0-d5,-(sp)

	move.l	run_time,d2
	move.l	max_time,d1
	cmp.l	d2,d1
	bhi	@f

	move.l	d1,d2			;256���[�v�ɓ������ꍇ

*	divu.w	d1,d2			;256���[�v�ɓ������ꍇ
*	clr.w	d2
*	swap.w	d2
@@:
	lsl.l	#4,d2
	lsl.l	#4,d1
	divu.w	#171,d1
	divu.w	d1,d2
	andi.l	#$0000ffff,d2
	addi.l	#351,d2			;�w���W

	move.l	#64,d3			;�x���W
	move.l	#127,d1			;�X�v���C�g�y�[�W
	bset.l	#31,d1			;�����A�����Ԍ��o�Ȃ�
	move.l	#$10+%0001_00_000000,d4	;�p�^�[���R�[�h
	moveq.l	#3,d5			;�v���C�I���e�B
	IOCS	_SP_REGST

	movem.l	(sp)+,d0-d5
	rts

*********************************************************
*
*	�����\�����[�h�g�O���؂�ւ�
*
memo_togle:
*********************************************************
	tst.b	memo_mode		;�O�Ȃ�
	bne	@f
	bsr	memo_trk_memo
	rts
@@:
	cmpi.b	#1,memo_mode		;�P�Ȃ�
	bne	@f
	bsr	memo_memo
	rts
@@:
	cmpi.b	#2,memo_mode		;�Q�Ȃ�
	bne	@f
	bsr	memo_note
@@:
	rts

*********************************************************
*
*	memo_mode=0 ���Ճ��[�h
*
memo_note:
*********************************************************
	movem.l	d1/a1,-(sp)

	bsr	init_instrument
	cmpi.b	#1,memo_mode		;���O��TRACK MEMO���[�h�Ȃ�INST�ĕ\��
	bne	@f
	bsr	init_instrument
	jsr	clear_trk_memo
@@:
	jsr	clear_note_area
	clr.b	memo_mode		;���[�h�ԍ��Z�b�g
*---------------------------------------*
	SSPRINT	#000,#069,#mes_trk_guide
	move.l	noteptr(a5),cnoteptr
*---------------------------------------*
	jsr	draw_mixer
	move.w	#%01_1111_0000,R21
	lea.l	mes_note_guide,a1
	moveq.l	#0,d1
	move.b	note_shift,d1
	divu.w	#12,d1
	mulu.w	#7,d1
	adda.l	d1,a1
	SSPRINT	#84,#69,a1
*---------------------------------------*
mn_bk:
	movem.l	(sp)+,d1/a1
	rts

*********************************************************
*
*	memo_mode=1 �g���b�N�������[�h
*
memo_trk_memo:
*********************************************************
	movem.l	d1-d2/d7/a6,-(sp)

	cmpi.b	#1,memo_mode		;�������[�h�Ȃ�m�[�g�\��
	bne	@f
	jsr	memo_note
	bra	mt_bk
@@:
	jsr	clear_trk_memo
	move.b	#1,memo_mode		;���[�h�ԍ��Z�b�g
*---------------------------------------*
	jsr	draw_trk_memo_mode
	move.w	#%01_1111_0000,R21
	SSPRINT	#67,#69,#mes_trk_memo
*---------------------------------------*

	moveq.l	#45,d6			;�\���w���W
	move.w	#18-1,d1
@@:
	move.w	d1,d2			;�f�[�^���o��
	lsl.w	#2,d2
	movea.l	a5,a6
	adda.l	#top,a6
	adda.w	d2,a6
	movea.l	(a6),a6
	adda.l	#track_comment,a6

	move.l	d1,d7			;�x���W���g���b�N�ԍ�
	lsl.l	#4,d7			;�g���b�N�ԍ����P�U
	add.l	#83,d7			;�I�t�Z�b�g��������

	lea.l	tbuf,a2
	move.l	(a6),(a2)		;��������o�b�t�@��
	move.l	4(a6),4(a2)
	move.l	4*2(a6),4*2(a2)
	move.l	4*3(a6),4*3(a2)
	move.l	4*4(a6),4*4(a2)
	move.l	4*5(a6),4*5(a2)
	move.l	4*6(a6),4*6(a2)
	move.l	4*7(a6),4*7(a2)
	move.l	4*8(a6),4*8(a2)
	move.l	4*9(a6),4*9(a2)
	clr.b	36(a2)			;�G���h�R�[�h��������
	lea.l	tbuf,a6
	jsr	prs_print_12x12
	clr.l	(a2)			;�o�b�t�@������
	clr.l	4(a2)
	clr.l	4*2(a2)
	clr.l	4*3(a2)
	clr.l	4*4(a2)
	clr.l	4*5(a2)
	clr.l	4*6(a2)
	clr.l	4*7(a2)
	clr.l	4*8(a2)
	clr.l	4*9(a2)

	dbra	d1,@b

*---------------------------------------*
mt_bk:
	movem.l	(sp)+,d1-d2/d7/a6
	rts

*********************************************************
*
*	memo_mode=2 �������[�h
*
memo_memo:
*********************************************************
	movem.l	d1-d2/d7/a5-a6,-(sp)

	bsr	init_instrument
	cmpi.b	#2,memo_mode		;�������[�h�Ȃ�m�[�g�\��
	bne	@f
	jsr	memo_note
	bra	mm_bk
@@:
	cmpi.b	#1,memo_mode		;���O��TRACK MEMO���[�h�Ȃ�INST�ĕ\��
	bne	@f
	bsr	init_instrument
	jsr	clear_trk_memo
@@:
	jsr	clear_note_area
	move.b	#2,memo_mode		;���[�h�ԍ��Z�b�g
*---------------------------------------*
	jsr	draw_memo_mode
	move.w	#%01_1111_0000,R21
	SSPRINT	#84,#69,#mes_memo
*---------------------------------------*

	moveq.l	#57,d6			;�\���w���W
	move.l	#16*8-8,d7		;�x�I�t�Z�b�g

	movea.l	data_adr(a5),a5
	adda.l	#rcp_memo,a5

	move.w	#12-1,d1
@@:
	lea.l	tbuf,a2
	move.l	(a5),(a2)		;��������o�b�t�@��
	move.l	4(a5),4(a2)
	move.l	4*2(a5),4*2(a2)
	move.l	4*3(a5),4*3(a2)
	move.l	4*4(a5),4*4(a2)
	move.l	4*5(a5),4*5(a2)
	move.l	4*6(a5),4*6(a2)
	move.l	4*7(a5),4*7(a2)
	clr.b	28(a2)			;�G���h�R�[�h��������
	lea.l	tbuf,a6
	jsr	prs_print_12x16
	clr.l	(a2)			;�o�b�t�@������
	clr.l	4(a2)
	clr.l	4*2(a2)
	clr.l	4*3(a2)
	clr.l	4*4(a2)
	clr.l	4*5(a2)
	clr.l	4*6(a2)
	clr.l	4*7(a2)
	adda.l	#4*7,a5
	addi.l	#16,d7			;�x���W�{�P�U

	dbra	d1,@b
*---------------------------------------*
mm_bk:
	movem.l	(sp)+,d1-d2/d7/a5-a6
	rts

*********************************************************
*
*	memo_mode=3 �I�����C���w���v
*
help:
*********************************************************
	movem.l	d1-d2/d7/a5-a6,-(sp)

	bsr	init_instrument
	cmpi.b	#3,memo_mode		;�������[�h�Ȃ�m�[�g�\��
	bne	@f
	jsr	memo_note
	bra	hlp_bk
@@:
	cmpi.b	#1,memo_mode		;���O��TRACK MEMO���[�h�Ȃ�INST�ĕ\��
	bne	@f
	bsr	init_instrument
	jsr	clear_trk_memo
@@:
	jsr	clear_note_area
	move.b	#3,memo_mode		;���[�h�ԍ��Z�b�g
*---------------------------------------*
	jsr	draw_memo_mode
	move.w	#%01_1111_0000,R21
	SSPRINT	#84,#69,#mes_help_b
*---------------------------------------*

	moveq.l	#56,d6			;�\���w���W
	move.l	#16*5,d7		;�x�I�t�Z�b�g

	move.w	#18-1,d1
	lea.l	mes_help,a6
@@:
	jsr	prs_print_12x16
	addi.l	#16,d7			;�x���W�{�P�U
	adda.l	#31,a6			;������A�h���X�{�R�P

	dbra	d1,@b

*---------------------------------------*
hlp_bk:
	movem.l	(sp)+,d1-d2/d7/a5-a6
	rts

*********************************************************
*
*	�����\�������e�L�X�g����
*
clear_note_area:
*********************************************************
	movem.l	d1/a1,-(sp)

	move.w	#%01_1111_0000,R21
	move.l	#TVRAM+(1024*16*5/8+41),a1	;�����n�߃A�h���X

	move.w	#(16*19)-1,d1
@@:
**	andi.b	#%11110000,(a1)
	bclr.b	#0,(a1)
	bclr.b	#1,(a1)
*	bclr.b	#2,(a1)
*	bclr.b	#3,(a1)
	clr.l	1(a1)
	clr.l	1+4(a1)
	clr.l	1+4*2(a1)
	clr.l	1+4*3(a1)
	clr.l	1+4*4(a1)
	clr.l	1+4*5(a1)
	clr.l	1+4*6(a1)

	adda.l	#1024/8,a1
	dbra	d1,@b

	movem.l	(sp)+,d1/a1
	rts

*********************************************************
*
*	�g���b�N�����\�������e�L�X�g����
*
clear_trk_memo:
*********************************************************
	movem.l	d0-d1/a1,-(sp)

	move.w	#%01_1111_0000,R21
	move.l	#TVRAM+(1024*16*5/8+34),a1	;�����n�߃A�h���X

	move.w	#(16*19)-1,d1
@@:
	move.w	#4-1,d0
	clr.b	-1(a1)
	clr.l	(a1)
	clr.l	4(a1)
	clr.l	4*2(a1)
	clr.l	4*3(a1)
	clr.l	4*4(a1)
	clr.l	4*5(a1)
	clr.l	4*6(a1)
	clr.l	4*7(a1)

	adda.l	#1024/8,a1
	dbra	d1,@b

*---------------------------------------*
	movem.l	(sp)+,d0-d1/a1
	rts

*********************************************************
*
*	INSTRUMENT�p�����[�^������
*
init_instrument:
*********************************************************
	movem.l	d2/a1,-(sp)

	moveq.l	#18-1,d2
@@:
	lea.l	o_bnk,a1
	move.b	#-2,0(a1,d2.l)
	lea.l	o_prg,a1
	move.b	#-2,0(a1,d2.l)

	dbra	d2,@b

	movem.l	(sp)+,d2/a1
	rts

*********************************************************
*
*	�~�L�T�[��`��
*
draw_mixer:
*********************************************************
	movem.l	d0-d4/a0,-(sp)

	moveq.l	#0,d1			;�e�L�X�g�y�[�W
	moveq.l	#0,d2			;�w���W�����[
	moveq.l	#0,d3			;�x���W����
	lea.l	mixer_map,a0		;a0.l=�}�b�v�f�[�^�擪
@@:
	move.l	#%0001_00_000000,d4	;�p���b�g�R�[�h�P
	cmp.b	#$6f,(a0)
	bcs	@f
	move.l	#%0010_00_000000,d4	;�p���b�g�R�[�h�Q
@@:
	add.b	(a0)+,d4		;�p�^�[���[���R�[�h

	IOCS	_BGTEXTST		;�v�b�g
	addq.l	#1,d2			;�w���W�{�{
	cmpi.l	#32,d2			;�E�[�܂ł��ĂȂ���΃��[�v
	bne	@@b

	moveq.l	#0,d2			;�w���W�����[
	addq.l	#1,d3			;�x���W�{�{
	cmpi.l	#64,d3			;���܂ł��ĂȂ���΃��[�v
	bne	@@b

	movem.l	(sp)+,d0-d4/a0
	rts

*********************************************************
*
*	�X�N���[���A�b�v�i�Z���N�^���[�h�j
*
scroll_up:
*********************************************************
	movem.l	d0-d4/a1,-(sp)

;	bra	hs_rup		**

*---------------------------------------*
lw_rup:
	moveq.l	#0,d1			;�e�L�X�g�y�[�W
	moveq.l	#0,d2			;�w���W�����[
	moveq.l	#0,d3			;�x���W����
@@:
	addi.l	#32,d3			;�x���W�{�{
	IOCS	_BGSCRLST		;BG�X�N���[��
	move.w	d3,TXT_Y		;�e�L�X�g�X�N���[��

	lea.l	$eb0002,a1		;�X�v���C�g�X�N���[��
	move.w	#128-1,d4		;
@@:	subi.w	#32,(a1)		;
	addq.l	#8,a1			;
	dbra	d4,@b			;

	cmpi.l	#512,d3			;���܂ł��ĂȂ���΃��[�v
	bne	@@b

	bra	9f

*---------------------------------------*
hs_rup:
	moveq.l	#0,d1			;�e�L�X�g�y�[�W
	moveq.l	#0,d2			;�w���W�����[
	move.l	#512,d3			;�w���W����

	IOCS	_BGSCRLST		;BG�X�N���[��
	move.w	d3,TXT_Y		;�e�L�X�g�X�N���[��
	lea.l	$eb0002,a1		;�X�v���C�g�X�N���[��
	move.w	#128-1,d4		;
@@:	subi.w	#512,(a1)		;
	addq.l	#8,a1			;
	dbra	d4,@b			;
*---------------------------------------*
9:
	movem.l	(sp)+,d0-d4/a1
	rts

*********************************************************
*
*	�X�N���[���_�E���i�f�B�X�v���C���[�h�j
*
scroll_down:
*********************************************************
	movem.l	d0-d4/a1,-(sp)

	tst.b	memo_mode		;���Ճ��[�h�Ȃ献�Օ�����TEXT����
	bne	@f
	bsr	clear_note_area
	bsr	init_instrument
@@:
;	bra	hs_rwn		**

*---------------------------------------*
lw_rwn:
	moveq.l	#0,d1			;�e�L�X�g�y�[�W
	moveq.l	#0,d2			;�w���W�����[
	move.l	#512,d3			;�x���W����
@@:
	subi.l	#32,d3			;�x���W�|�|
	IOCS	_BGSCRLST		;BG�X�N���[��
	move.w	d3,TXT_Y		;�e�L�X�g�X�N���[��

	lea.l	$eb0002,a1		;�X�v���C�g�X�N���[��
	move.w	#128-1,d4		;
@@:	addi.w	#32,(a1)		;
	addq.l	#8,a1			;
	dbra	d4,@b			;

	cmpi.l	#0,d3			;��܂ł��ĂȂ���΃��[�v
	bne	@@b

	bra	9f

*---------------------------------------*
hs_rwn:
	moveq.l	#0,d1			;�e�L�X�g�y�[�W
	moveq.l	#0,d2			;�w���W�����[
	moveq.l	#0,d3			;�w���W����

	IOCS	_BGSCRLST		;BG�X�N���[��
	move.w	d3,TXT_Y		;�e�L�X�g�X�N���[��
	lea.l	$eb0002,a1		;�X�v���C�g�X�N���[��
	move.w	#128-1,d4		;
@@:	addi.w	#512,(a1)		;
	addq.l	#8,a1			;
	dbra	d4,@b			;

*---------------------------------------*
9:
	movem.l	(sp)+,d0-d4/a1
	rts

*********************************************************
*
*	�����̔w�i��`��
*
draw_memo_mode:
*********************************************************
	movem.l	d1-d4,-(sp)

	moveq.l	#0,d1			;�e�L�X�g�y�[�W
	move.l	#20,d2			;�w���W
	moveq.l	#6,d3			;�x���W
@@:
	move.l	#$20+%0001_00_000000,d4	;�p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
	addq.l	#1,d2			;�w���W�{�{
	cmpi.l	#20+11,d2		;�E�[�܂ł��ĂȂ���΃��[�v
	bne	@b
	move.l	#$48+%0001_00_000000,d4	;�E�p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g

	move.l	#20,d2			;�w���W���Z�b�g
	move.l	#$64+%0001_00_000000,d4	;���p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
	addq.l	#1,d3			;�x���W�{�{
	cmpi.l	#6+17,d3		;���܂ł��ĂȂ���΃��[�v
	bne	@b
*---------------------------------------*
	move.l	#20,d2			;�w���W
	moveq.l	#5,d3			;�x���W
	move.l	#$65+%0001_00_000000,d4	;����p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
	addq.l	#1,d2			;�w���W�{�{
@@:
	move.l	#$21+%0001_00_000000,d4	;��p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
	addq.l	#1,d2			;�w���W�{�{
	cmpi.l	#20+11,d2		;�E�[�܂ł��ĂȂ���΃��[�v
	bne	@b
	move.l	#$26+%0001_00_000000,d4	;�E��p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
*---------------------------------------*
	move.l	#20,d2			;�w���W
	moveq.l	#23,d3			;�x���W
	move.l	#$49+%0001_00_000000,d4	;�����p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
	addq.l	#1,d2			;�w���W�{�{
@@:
	move.l	#$2e+%0001_00_000000,d4	;���p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
	addq.l	#1,d2			;�w���W�{�{
	cmpi.l	#20+11,d2		;�E�[�܂ł��ĂȂ���΃��[�v
	bne	@b
	move.l	#$06+%0001_00_000000,d4	;�E���p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
*---------------------------------------*
	move.l	#20,d2			;�w���W
	moveq.l	#4,d3			;�x���W
@@:
	move.l	#$0c+%0001_00_000000,d4
	IOCS	_BGTEXTST
	SSPRINT	#000,#069,#mes_trk_guide
*---------------------------------------*
memo_ret:
	movem.l	(sp)+,d1-d4
	rts

*********************************************************
*
*	�g���b�N�����̔w�i��`��
*
draw_trk_memo_mode:
*********************************************************
	movem.l	d1-d4,-(sp)

	moveq.l	#0,d1			;�e�L�X�g�y�[�W
	move.l	#19,d2			;�w���W
	moveq.l	#5,d3			;�x���W
@@:
	move.l	#$03+%0001_00_000000,d4	;�p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
	addq.l	#1,d2			;�w���W�{�{
	cmpi.l	#20+11,d2		;�E�[�܂ł��ĂȂ���΃��[�v
	bne	@b
	move.l	#$0a+%0001_00_000000,d4	;�E�p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g

	move.l	#19,d2			;�w���W���Z�b�g

	addq.l	#1,d3			;�x���W�{�{
	cmpi.l	#5+18,d3		;���܂ł��ĂȂ���΃��[�v
	bne	@b
*---------------------------------------*
	move.l	#19,d2			;�w���W
	moveq.l	#23,d3			;�x���W
@@:
	move.l	#$03+%0001_00_000000,d4	;���p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
	addq.l	#1,d2			;�w���W�{�{
	cmpi.l	#20+11,d2		;�E�[�܂ł��ĂȂ���΃��[�v
	bne	@b
	move.l	#$0a+%0001_00_000000,d4	;�E���p�^�[���R�[�h
	IOCS	_BGTEXTST		;�v�b�g
*---------------------------------------*
	move.l	#20,d2			;�w���W
	moveq.l	#4,d3			;�x���W
@@:
	move.l	#$2e+%0001_00_000000,d4
	IOCS	_BGTEXTST
*---------------------------------------*
tmemo_ret:
	movem.l	(sp)+,d1-d4
	rts

*********************************************************
*
*	�P�U�������x�����[�^�[
*
level_meter:
*********************************************************
	movem.l	d1/d3/a1,-(sp)

	moveq.l	#0,d1
	move.b	d3,d1			;�x���V�e�B�l
	moveq.l	#0,d3

	moveq.l	#0,d7
	movea.l	a5,a1
	adda.l	#midich,a1
	move.b	(a1,d2.w),d7		;d7.b=�`�����l���ԍ�

	movea.l	a5,a1
	adda.l	#ch_vol,a1
	move.b	(a1,d7.w),d3		;�{�����[���l��Z
	mulu.w	d3,d1
	lsr.w	#7,d1			;�|�����̂����� /128

	movea.l	a5,a1
	adda.l	#ch_expr,a1
	move.b	(a1,d7.w),d3		;�G�N�X�v���b�V�����l��Z
	mulu.w	d3,d1
	lsr.w	#7,d1			;�|�����̂����� /128

	move.b	GS_VOL(a5),d3		;�}�X�^�[�{�����[���l��Z
	mulu.w	d3,d1
	lsr.w	#7,d1			;�|�����̂����� /128

	lea.l	level,a1
	move.b	d1,(a1,d7.w)		;���[�N�ɏ�������

	movem.l	(sp)+,d1/d3/a1
	rts

*********************************************************
*
*	�P�U�������x�����[�^�[����
*
level_meter_down:
*********************************************************
	movem.l	d0-d5/a1-a2,-(sp)

	move.b	#-1,lv_flag
	IOCS	_ONTIME
	move.l	d0,d1
	sub.l	lv_ontime,d1
	subi.l	#8,d1
	bcs	@f
	clr.b	lv_flag
	move.l	d0,lv_ontime
	sub.l	d1,lv_ontime
@@:
*---------------------------------------*
	tst.b	lv_flag
	bne	lm_end

	move.w	#%01_0110_0000,R21	;�����A�N�Z�X
	lea.l	level,a1
	move.w	#16-1,d2
lm_ch_lp:
	move.b	(a1,d2.w),d1
	lsr.b	#3,d1
	sub.b	d1,(a1,d2.w)		;�l������
	tst.b	(a1,d2.w)		;���[�^�[�������؂�����X�L�b�v
	bge	@f
	clr.b	(a1,d2.w)
	bra	lm_ch_brk
@@:
	moveq.l	#0,d3
	move.b	(a1,d2.w),d3		;�l��ǂݍ���
	lsr.w	#3,d3			;�W�Ŋ���
	lea.l	TVRAM,a2		;�������W�ݒ�
	adda.l	#493*128,a2		;y
	adda.l	#18,a2			;x
	adda.l	d2,a2

	move.w	#16-1,d4
	sub.w	d3,d4
lm1_lp:
	subq.w	#1,d3
	bls	lm2_lp
	move.b	#%01111100,(a2)
	suba.l	#128*2,a2
	bra	lm1_lp
lm2_lp:
	move.b	#%00000000,(a2)
	suba.l	#128*2,a2
	dbra	d4,lm2_lp
lm_ch_brk:
	dbra	d2,lm_ch_lp
lm_end:
	movem.l	(sp)+,d0-d5/a1-a2
	rts

*********************************************************
*
*	�X�y�N�g�����A�i���C�U�[
*
speana:
*********************************************************
	movem.l	d0-d7/a1-a3,-(sp)

	moveq.l	#0,d4
	movea.l	a5,a1			;a1.l=RCD���[�N�擪
	adda.l	#vel,a1			;a1.l=�x���V�e�B�f�[�^�擪
	move.b	(a1,d2.w),d4		;d4.b=�x���V�e�B�l
	moveq.l	#0,d3

	moveq.l	#0,d7
	movea.l	a5,a1
	adda.l	#midich,a1
	move.b	(a1,d2.w),d7		;d7.b=�`�����l���ԍ�

	movea.l	a5,a1
	adda.l	#ch_vol,a1
	move.b	(a1,d7.w),d3		;�{�����[���l��Z
	mulu.w	d3,d4
	lsr.w	#7,d4			;�|�����̂����� /128

	movea.l	a5,a1
	adda.l	#ch_expr,a1
	move.b	(a1,d7.w),d3		;�G�N�X�v���b�V�����l��Z
	mulu.w	d3,d4
	lsr.w	#7,d4			;�|�����̂����� /128

	move.b	GS_VOL(a5),d3		;�}�X�^�[�{�����[���l��Z
	mulu.w	d3,d4
	lsr.w	#7,d4			;�|�����̂����� /128

	add.b	#16,d4			;�������l�����Z
	cmpi.b	#128,d4
	bls	@f
	move.b	#127,d4
@@:
	RANDOM	#9*3,d0			;�������Z
	sub.b	d0,d4

	tst.b	d4			;�v�Z���ʂ��͈͂��z���Ă�����J�b�g
	bge	@f
	clr.b	d4
@@:
	divu.w	#9,d1
	subq.w	#1,d1
	lea.l	speana_r,a1
	lea.l	speana_l,a2
	adda.w	d1,a1
	adda.w	d1,a2
	swap.w	d1
	move.w	d1,d3
	add.w	d3,d1
	add.w	d3,d1
	add.w	d3,d1
*---------------------------------------*
*�E
sp_right_set:
	move.l	d4,-(sp)

	movea.l	a5,a3			;a1.l=RCD���[�N�擪
	adda.l	#ch_panpot,a3		;a1.l=�p���|�b�g�f�[�^�擪
	moveq.l	#0,d3
	move.b	(a3,d7.w),d3		;d3.b=�p���|�b�g�l
	move.l	d3,-(sp)
	cmpi.b	#64,d3
	bcc	@f
	add.w	d3,d3
	mulu.w	d3,d4
	lsr.w	#7,d4			;�|�����̂�����
@@:
*---------------------------------------*
*�E�Ζ�
sprsr:
	move.b	d4,d5
	subi.b	#36/2,d5
	add.b	d1,d5
	ble	sprsl
	cmp.b	1(a1),d5
	ble	@f
	move.b	d5,1(a1)
@@:
	subi.b	#36,d5
	ble	sprsl
	cmp.b	2(a1),d5
	ble	@f
	move.b	d5,2(a1)
@@:
	subi.b	#36,d5
	ble	sprsl
	cmp.b	3(a1),d5
	ble	@f
	move.b	d5,3(a1)
@@:
	subi.b	#36,d5
	ble	sprsl
	cmp.b	4(a1),d5
	ble	@f
	move.b	d5,4(a1)
@@:
	subi.b	#36,d5
	ble	sprsl
	cmp.b	5(a1),d5
	ble	@f
	move.b	d5,5(a1)
@@:
*���Ζ�
sprsl:
	move.b	d4,d5
	subi.b	#36/2,d5
	sub.b	d1,d5
	ble	sp_left_set
	cmp.b	(a1),d5
	ble	@f
	move.b	d5,(a1)
@@:
	subi.b	#36,d5
	ble	sp_left_set
	cmp.b	-1(a1),d5
	ble	@f
	move.b	d5,-1(a1)
@@:
	subi.b	#36,d5
	ble	sp_left_set
	cmp.b	-2(a1),d5
	ble	@f
	move.b	d5,-2(a1)
@@:
	subi.b	#36,d5
	ble	sp_left_set
	cmp.b	-3(a1),d5
	ble	@f
	move.b	d5,-3(a1)
@@:
	subi.b	#36,d5
	ble	sp_left_set
	cmp.b	-4(a1),d5
	ble	@f
	move.b	d5,-4(a1)
@@:
*---------------------------------------*
*��
sp_left_set:
	move.l	(sp)+,d3
	move.l	(sp)+,d4

	subi.b	#64,d3
	bls	@f
	move.b	#64,d5
	sub.b	d3,d5
	add.w	d5,d5
	mulu.w	d5,d4
	lsr.w	#7,d4			;�|�����̂�����
@@:
*---------------------------------------*
*�E�Ζ�
splsr:
	move.b	d4,d5
	subi.b	#36/2,d5
	add.b	d1,d5
	ble	splsl
	cmp.b	1(a2),d5
	ble	@f
	move.b	d5,1(a2)
@@:
	subi.b	#36,d5
	ble	splsl
	cmp.b	2(a2),d5
	ble	@f
	move.b	d5,2(a2)
@@:
	subi.b	#36,d5
	ble	splsl
	cmp.b	3(a2),d5
	ble	@f
	move.b	d5,3(a2)
@@:
	subi.b	#36,d5
	ble	splsl
	cmp.b	4(a2),d5
	ble	@f
	move.b	d5,4(a2)
@@:
	subi.b	#36,d5
	ble	splsl
	cmp.b	5(a2),d5
	ble	@f
	move.b	d5,5(a2)
@@:
*���Ζ�
splsl:
	move.b	d4,d5
	subi.b	#36/2,d5
	sub.b	d1,d5
	ble	ama_brk
	cmp.b	(a2),d5
	ble	@f
	move.b	d5,(a2)
@@:
	subi.b	#36,d5
	ble	ama_brk
	cmp.b	-1(a2),d5
	ble	@f
	move.b	d5,-1(a2)
@@:
	subi.b	#36,d5
	ble	ama_brk
	cmp.b	-2(a2),d5
	ble	@f
	move.b	d5,-2(a2)
@@:
	subi.b	#36,d5
	ble	ama_brk
	cmp.b	-3(a2),d5
	ble	@f
	move.b	d5,-3(a2)
@@:
	subi.b	#36,d5
	ble	ama_brk
	cmp.b	-4(a2),d5
	ble	@f
	move.b	d5,-4(a2)
@@:
ama_brk:
	movem.l	(sp)+,d0-d7/a1-a3
	rts

*********************************************************
*
*	�X�y�N�g�����A�i���C�U�[����
*
speana_down:
*********************************************************
	movem.l	d0-d5/a1-a2,-(sp)

	move.b	#-1,sp_flag
	IOCS	_ONTIME
	move.l	d0,d1
	sub.l	sp_ontime,d1
	subi.l	#5,d1
	bcs	@f
	clr.b	sp_flag
	move.l	d0,sp_ontime
	sub.l	d1,sp_ontime
@@:
*---------------------------------------*
	tst.b	sp_flag
	bne	sp_end

	move.w	#%01_0110_0000,R21	;�����A�N�Z�X
	lea.l	speana_r,a1
	move.w	#13-1,d2
spr_hz_lp:
	move.b	(a1,d2.w),d1
	lsr.b	#3,d1
	sub.b	d1,(a1,d2.w)		;�l������
	tst.b	(a1,d2.w)		;���[�^�[�������؂�����X�L�b�v
	bge	@f
	clr.b	(a1,d2.w)
	bra	spr_hz_brk
@@:
	moveq.l	#0,d3
	move.b	(a1,d2.w),d3		;�l��ǂݍ���
	lsr.w	#3,d3			;�W�Ŋ���
	lea.l	TVRAM,a2		;�������W�ݒ�
	adda.l	#429*128,a2		;y
	adda.l	#32,a2			;x
	adda.l	d2,a2

	move.w	#16-1,d4
	sub.w	d3,d4
spr1_lp:
	subq.b	#1,d3
	bls	spr2_lp
	move.b	#%01111100,(a2)
	suba.l	#128*2,a2
	bra	spr1_lp
spr2_lp:
	move.b	#%00000000,(a2)
	suba.l	#128*2,a2
	dbra	d4,spr2_lp
spr_hz_brk:
	dbra	d2,spr_hz_lp
spr_end:
*	movem.l	(sp)+,d0-d5/a1-a2
*	rts
*---------------------------------------*
	lea.l	speana_l,a1
	move.w	#13-1,d2
spl_hz_lp:
	move.b	(a1,d2.w),d1
	lsr.w	#3,d1
	sub.b	d1,(a1,d2.w)		;�l������
	tst.b	(a1,d2.w)		;���[�^�[�������؂�����X�L�b�v
	bge	@f
	clr.b	(a1,d2.w)
	bra	spl_hz_brk
@@:
	moveq.l	#0,d3
	move.b	(a1,d2.w),d3		;�l��ǂݍ���
	lsr.w	#3,d3			;�W�Ŋ���
	lea.l	TVRAM,a2		;�������W�ݒ�
	adda.l	#429*128,a2		;y
	adda.l	#18,a2			;x
	adda.l	d2,a2

	move.w	#16-1,d4
	sub.w	d3,d4
spl1_lp:
	subq.b	#1,d3
	bls	spl2_lp
	move.b	#%01111100,(a2)
	suba.l	#128*2,a2
	bra	spl1_lp
spl2_lp:
	move.b	#%00000000,(a2)
	suba.l	#128*2,a2
	dbra	d4,spl2_lp
spl_hz_brk:
	dbra	d2,spl_hz_lp
spl_end:
sp_end:
	movem.l	(sp)+,d0-d5/a1-a2
	rts

*********************************************************
*
*	�e��p�����[�^��������
*
o_clr:
*********************************************************
	movem.l	d0-d1/a1,-(sp)

	move.l	#0,cnoteptr
	move.l	#0,start_time
	move.l	#0,vel_ontime
	move.l	#0,lv_ontime
	move.l	#0,sp_ontime
	move.l	#0,sc_ptn_time
	move.l	#0,sc_str_time
	move.l	#0,sc_rol_time
	move.l	#0,sc_rol_pointer
	move.l	#0,loop_time
	move.l	#0,run_time
	move.l	#rhy_flags,rhy_pointer
	move.l	#0,max_step
	move.b	#24,note_shift
	move.b	#0,brink_flag
	move.b	#0,tcoron_flag
	move.b	#0,vel_flag
	move.b	#0,lv_flag
	move.b	#0,sp_flag
	move.b	#-1,memo_mode
	move.b	#0,kbclr_flag
	move.b	#0,pause_flag
	move.b	#0,sc_ptn_flag
	move.b	#0,sc_str_flag
	move.b	#0,sc_rol_count
	move.b	#0,timebase
*	move.b	#0,ps_trk
	move.b	#0,light

	move.l	#0,o_allstp
	move.l	#-2,o_tempo
	move.l	#-2,o_pmode
	move.w	#-2,o_loopcount
	move.b	#-2,o_rvb_mac
	move.b	#-2,o_rvb_cha
	move.b	#-2,o_rvb_pre
	move.b	#-2,o_rvb_lvl
	move.b	#-2,o_rvb_tme
	move.b	#-2,o_rvb_dly
	move.b	#-2,o_rvb_snd
	move.b	#-2,o_rvb_pdly
	move.b	#-2,o_cho_mac
	move.b	#-2,o_cho_pre
	move.b	#-2,o_cho_lvl
	move.b	#-2,o_cho_fed
	move.b	#-2,o_cho_dly
	move.b	#-2,o_cho_rte
	move.b	#-2,o_cho_dph
	move.b	#-2,o_cho_snd
	move.b	#-2,o_cho_snd_dly
	move.b	#-2,o_dly_mac
	move.b	#-2,o_dly_pre
	move.b	#-2,o_dly_tme_c
	move.b	#-2,o_dly_tme_r
	move.b	#-2,o_dly_tme_l
	move.b	#-2,o_dly_lvl_c
	move.b	#-2,o_dly_lvl_r
	move.b	#-2,o_dly_lvl_l
	move.b	#-2,o_dly_lvl
	move.b	#-2,o_dly_fed
	move.b	#-2,o_dly_snd
	move.b	#-2,o_eq_lf
	move.b	#-2,o_eq_lg
	move.b	#-2,o_eq_hf
	move.b	#-2,o_eq_hg
	move.b	#-2,o_mvol
	move.b	#-2,o_mpan

	moveq.l	#TRK_NUM-1,d2
@@:
	move.l	d2,d1
	mulu.w	#4,d1
	lea.l	o_bnd,a1
	move.l	#-2,0(a1,d1.w)
	lea.l	o_bar,a1
	move.l	#-2,0(a1,d1.w)
	lea.l	o_stp,a1
	move.l	#-2,0(a1,d1.w)
	lea.l	o_bnk,a1
	move.b	#-2,0(a1,d2.w)
	lea.l	o_prg,a1
	move.b	#-2,0(a1,d2.w)
	lea.l	o_cha,a1
	move.b	#-2,0(a1,d2.w)
	lea.l	o_vol,a1
	move.b	#-2,0(a1,d2.w)
	lea.l	m_vel,a1
	move.b	#0,0(a1,d2.w)
	lea.l	o_vel,a1
	move.b	#-2,0(a1,d2.w)
	lea.l	o_exp,a1
	move.b	#-2,0(a1,d2.w)
	lea.l	o_mod,a1
	move.b	#-2,0(a1,d2.w)
	lea.l	o_pan,a1
	move.b	#-2,0(a1,d2.w)
	lea.l	o_rvb,a1
	move.b	#-2,0(a1,d2.w)
	lea.l	o_cho,a1
	move.b	#-2,0(a1,d2.w)
	lea.l	o_hld,a1
	move.b	#-2,0(a1,d2.w)

	dbra	d2,@b
*�z��
	lea.l	rhy_flags,a1
	move.w	#64*6/4-1,d1
@@:	clr.l	(a1)+
	dbra	d1,@b
*---------------------------------------*
*�~�L�T�[��ʏ�������

	move.w	#%01_1111_0000,R21
	move.l	#TVRAM+(1024*16*5/8+7),a1	;�����n�߃A�h���X

	move.w	#(16*18)-1,d1
rd2:
	move.w	#26-1,d0
rd1:
	move.b	#$00,(a1)+
	dbra	d0,rd1

	adda.l	#1024/8-26,a1
	dbra	d1,rd2

	movem.l	(sp)+,d0-d1/a1
	rts

*********************************************************
*
*	�ĉ��t�J�n
*
replay:
*********************************************************
	movea.l	init(a5),a1
	jsr	(a1)
	movea.l	setup(a5),a1
	jsr	(a1)
	movea.l	begin(a5),a1
	jsr	(a1)
	rts

*********************************************************
*
*	���t�J�n
*
play:
*********************************************************
	clr.l	sts(a5)
	rts

*********************************************************
*
*	���t�I��
*
music_end:
*********************************************************
	movea.l	end(a5),a1
	jsr	(a1)
	rts

*********************************************************
*
*	�ꎞ��~
*
stop:
*********************************************************
	move.l	#1,sts(a5)
	rts

*********************************************************
*
*	�ꎞ��~�^���t�J�n�g�O��
*
stop_or_play:
*********************************************************
	cmp.l	#1,sts(a5)
	bne	@f
	clr.l	sts(a5)
	rts
@@:
	move.w	#%01_1111_0000,R21
	lea.l	mes_stop,a1
	SEG7	#14,#48,a1
	move.l	#1,sts(a5)
	rts

*********************************************************
*
*	������
*
cue:
*********************************************************
	move.l	#3,sts(a5)
	rts

*********************************************************
*
*	������^���t�J�n�g�O��
*
cue_or_play:
*********************************************************
	cmp.l	#3,sts(a5)
	bne	@f
	clr.l	sts(a5)
	rts
@@:
	move.l	#3,sts(a5)
	rts

*********************************************************
*
*	�o�b�t�@���t
*
buffer_play:
*********************************************************
	movem.l	a1,-(sp)

	movea.l	end(a5),a1
	jsr	(a1)
	movea.l	begin(a5),a1
	jsr	(a1)

	movem.l	(sp)+,a1
	rts

*********************************************************
*
*	�t�F�[�h�A�E�g
*
fade_out:
*********************************************************
	move.w	#15,fade_time(a5)
	move.b	#128,fade_count(a5)

	rts

*********************************************************
*
*	�q�b�c�o�[�W�����G���[�I��
*
rcd_ver_err:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_ver_err
	move.w	#1,(sp)
	DOS	_EXIT2

*********************************************************
*
*	�q�b�c���풓���Ă��Ȃ��G���[�I��
*
rcd_no_stay:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_no_rcd
	move.w	#1,-(sp)
	DOS	_EXIT2

*********************************************************
*
*	���t���Ă��Ȃ��G���[�I��
*
no_playing:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_no_playing
	move.w	#1,-(sp)
	DOS	_EXIT2

*********************************************************
*
*	MCP���Ή��G���[�I��
*
mcp_err:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_mcp_err
	move.w	#1,-(sp)
	DOS	_EXIT2

*********************************************************
*
*	������ރG���[�I��
*
gs_err:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_gs_err
	move.w	#1,-(sp)
	DOS	_EXIT2

*********************************************************
*
*	�g�p�@�\���I��
*
usage:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_usage
	move.w	#2,-(sp)
	DOS	_EXIT2

*********************************************************
*
*	���t��~�I��
*
stop_and_quit:
*********************************************************
	bsr	music_end
	bra	quit

*********************************************************
*
*	�풓�I��
*
quit:
*********************************************************
	move.l	ssp_buf,sp

	lea.l	tpalet_buf,a1		;�e�L�X�g�p���b�g���A
	movea.l	#TPALET,a2
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1),(a2)

	jsr	text_clear
	jsr	bg_clear

	move.l	crt_mode,d1		;��ʃ��[�h���A
	IOCS	_CRTMOD

	move.w	fn_mode,-(sp)		;�t�@���N�V�����\�����A
	move.w	#14,-(sp)
	DOS	_CONCTRL
	addq.l	#2+2,sp

	IOCS	_B_CURON
	move.l	#-1,d1
	IOCS	_SKEY_MOD

	move.b	#1,d1
	move.b	#1,d2
	IOCS	_TGUSEMD

*	jsr	user_mode
	PRINT	#mes_title
	DOS	_EXIT

*********************************************************
*
*	�f�[�^�̈�
*
data_section:
*********************************************************
	.data
		.even
		.include	mixser.s
*---------------------------------------*
*�X���C�_�[�e�[�u��
vel_tbl:
		.dc.b	%00000000,%00000000,%00000000,%00000000
		.dc.b	%00000100,%00000000,%00000000,%00000000
		.dc.b	%00000101,%00000000,%00000000,%00000000
		.dc.b	%00000101,%01000000,%00000000,%00000000
		.dc.b	%00000101,%01010000,%00000000,%00000000
		.dc.b	%00000101,%01010100,%00000000,%00000000
		.dc.b	%00000101,%01010101,%00000000,%00000000
		.dc.b	%00000101,%01010101,%01000000,%00000000
		.dc.b	%00000101,%01010101,%01010000,%00000000
		.dc.b	%00000101,%01010101,%01010100,%00000000
		.dc.b	%00000101,%01010101,%01010101,%00000000
		.dc.b	%00000101,%01010101,%01010101,%01000000
		.dc.b	%00000101,%01010101,%01010101,%01000000
vol_slide_tbl:
		.dc.b	%00000000,%00000000,%00000000,%00000000
		.dc.b	%00000000,%00000000,%00000000,%00000000
		.dc.b	%00000000,%00000000,%00000000,%00000000
		.dc.b	%00100000,%00000000,%00000000,%00000000
		.dc.b	%00110000,%00000000,%00000000,%00000000
		.dc.b	%00111000,%00000000,%00000000,%00000000
		.dc.b	%00111100,%00000000,%00000000,%00000000
		.dc.b	%00111110,%00000000,%00000000,%00000000
		.dc.b	%00111111,%00000000,%00000000,%00000000
		.dc.b	%00111111,%10000000,%00000000,%00000000
		.dc.b	%00111111,%11000000,%00000000,%00000000
		.dc.b	%00111111,%11100000,%00000000,%00000000
		.dc.b	%00111111,%11110000,%00000000,%00000000
		.dc.b	%00111111,%11111000,%00000000,%00000000
		.dc.b	%00111111,%11111100,%00000000,%00000000
		.dc.b	%00111111,%11111110,%00000000,%00000000
		.dc.b	%00111111,%11111111,%00000000,%00000000
		.dc.b	%00111111,%11111111,%10000000,%00000000
		.dc.b	%00111111,%11111111,%11000000,%00000000
		.dc.b	%00111111,%11111111,%11100000,%00000000
		.dc.b	%00111111,%11111111,%11110000,%00000000
		.dc.b	%00111111,%11111111,%11111000,%00000000
		.dc.b	%00111111,%11111111,%11111100,%00000000
		.dc.b	%00111111,%11111111,%11111110,%00000000
		.dc.b	%00111111,%11111111,%11111111,%00000000
		.dc.b	%00111111,%11111111,%11111111,%10000000
		.dc.b	%00111111,%11111111,%11111111,%11000000
exp_slide_tbl:
		.dc.b	%00000000,%00000000,%00000000,%00000000
		.dc.b	%00000000,%00000000,%00000000,%00000000
		.dc.b	%00000000,%00000000,%00000000,%00000000
		.dc.b	%00000010,%00000000,%00000000,%00000000
		.dc.b	%00000011,%00000000,%00000000,%00000000
		.dc.b	%00000011,%10000000,%00000000,%00000000
		.dc.b	%00000011,%11000000,%00000000,%00000000
		.dc.b	%00000011,%11100000,%00000000,%00000000
		.dc.b	%00000011,%11110000,%00000000,%00000000
		.dc.b	%00000011,%11111000,%00000000,%00000000
		.dc.b	%00000011,%11111100,%00000000,%00000000
		.dc.b	%00000011,%11111110,%00000000,%00000000
		.dc.b	%00000011,%11111111,%00000000,%00000000
		.dc.b	%00000011,%11111111,%10000000,%00000000
		.dc.b	%00000011,%11111111,%11000000,%00000000
		.dc.b	%00000011,%11111111,%11100000,%00000000
		.dc.b	%00000011,%11111111,%11110000,%00000000
		.dc.b	%00000011,%11111111,%11111000,%00000000
		.dc.b	%00000011,%11111111,%11111100,%00000000
		.dc.b	%00000011,%11111111,%11111110,%00000000
		.dc.b	%00000011,%11111111,%11111111,%00000000
		.dc.b	%00000011,%11111111,%11111111,%10000000
		.dc.b	%00000011,%11111111,%11111111,%11000000
		.dc.b	%00000011,%11111111,%11111111,%11100000
		.dc.b	%00000011,%11111111,%11111111,%11110000
		.dc.b	%00000011,%11111111,%11111111,%11111000
		.dc.b	%00000011,%11111111,%11111111,%11111100
mod_slide_tbl:
		.dc.b	%00000000,%00000000
		.dc.b	%00000000,%00000000
		.dc.b	%01000000,%00000000
		.dc.b	%01100000,%00000000
		.dc.b	%01110000,%00000000
		.dc.b	%01111000,%00000000
		.dc.b	%01111100,%00000000
		.dc.b	%01111110,%00000000
		.dc.b	%01111111,%00000000
		.dc.b	%01111111,%10000000
		.dc.b	%01111111,%11000000
		.dc.b	%01111111,%11100000
		.dc.b	%01111111,%11110000
		.dc.b	%01111111,%11111000
		.dc.b	%01111111,%11111100
		.dc.b	%01111111,%11111110
rvb_slide_tbl:
		.dc.b	%00000000,%00000000,%00000000
		.dc.b	%00000000,%00000000,%00000000
		.dc.b	%00000100,%00000000,%00000000
		.dc.b	%00000110,%00000000,%00000000
		.dc.b	%00000111,%00000000,%00000000
		.dc.b	%00000111,%10000000,%00000000
		.dc.b	%00000111,%11000000,%00000000
		.dc.b	%00000111,%11100000,%00000000
		.dc.b	%00000111,%11110000,%00000000
		.dc.b	%00000111,%11111000,%00000000
		.dc.b	%00000111,%11111100,%00000000
		.dc.b	%00000111,%11111110,%00000000
		.dc.b	%00000111,%11111111,%00000000
		.dc.b	%00000111,%11111111,%10000000
		.dc.b	%00000111,%11111111,%11000000
		.dc.b	%00000111,%11111111,%11100000
		.dc.b	%00000111,%11111111,%11110000
		.dc.b	%00000111,%11111111,%11111000
		.dc.b	%00000111,%11111111,%11111100
cho_slide_tbl:
		.dc.b	%00000000,%00000000,%00000000
		.dc.b	%00000000,%00000000,%00000000
		.dc.b	%00000000,%00000000,%00000000
		.dc.b	%00000010,%00000000,%00000000
		.dc.b	%00000011,%00000000,%00000000
		.dc.b	%00000011,%10000000,%00000000
		.dc.b	%00000011,%11000000,%00000000
		.dc.b	%00000011,%11100000,%00000000
		.dc.b	%00000011,%11110000,%00000000
		.dc.b	%00000011,%11111000,%00000000
		.dc.b	%00000011,%11111100,%00000000
		.dc.b	%00000011,%11111110,%00000000
		.dc.b	%00000011,%11111111,%00000000
		.dc.b	%00000011,%11111111,%10000000
		.dc.b	%00000011,%11111111,%11000000
		.dc.b	%00000011,%11111111,%11100000
		.dc.b	%00000011,%11111111,%11110000
		.dc.b	%00000011,%11111111,%11111000
		.dc.b	%00000011,%11111111,%11111100
bnd_slide_tbl1:
		.dc.b	%11000000,%00000000,%00000000
		.dc.b	%01100000,%00000000,%00000000
		.dc.b	%00110000,%00000000,%00000000
		.dc.b	%00011000,%00000000,%00000000
		.dc.b	%00001100,%00000000,%00000000
		.dc.b	%00000110,%00000000,%00000000
		.dc.b	%00000011,%00000000,%00000000
		.dc.b	%00000001,%10000000,%00000000
		.dc.b	%00000001,%10000000,%00000000
		.dc.b	%00000000,%11000000,%00000000
		.dc.b	%00000000,%01100000,%00000000
		.dc.b	%00000000,%00110000,%00000000
		.dc.b	%00000000,%00011000,%00000000
		.dc.b	%00000000,%00001100,%00000000
		.dc.b	%00000000,%00000110,%00000000
		.dc.b	%00000000,%00000011,%00000000
		.dc.b	%00000000,%00000001,%10000000
		.dc.b	%00000000,%00000001,%10000000
		.dc.b	%00000000,%00000000,%11000000
		.dc.b	%00000000,%00000000,%01100000
		.dc.b	%00000000,%00000000,%00110000
		.dc.b	%00000000,%00000000,%00011000
		.dc.b	%00000000,%00000000,%00001100
		.dc.b	%00000000,%00000000,%00000110
		.dc.b	%00000000,%00000000,%00000011
		.dc.b	%00000000,%00000000,%00000011
bnd_slide_tbl2:
		.dc.b	%01000000,%00000000,%00000000
		.dc.b	%00100000,%00000000,%00000000
		.dc.b	%00010000,%00000000,%00000000
		.dc.b	%00001000,%00000000,%00000000
		.dc.b	%00000100,%00000000,%00000000
		.dc.b	%00000010,%00000000,%00000000
		.dc.b	%00000001,%00000000,%00000000
		.dc.b	%00000000,%10000000,%00000000
		.dc.b	%00000000,%10000000,%00000000
		.dc.b	%00000000,%01000000,%00000000
		.dc.b	%00000000,%00100000,%00000000
		.dc.b	%00000000,%00010000,%00000000
		.dc.b	%00000000,%00001000,%00000000
		.dc.b	%00000000,%00000100,%00000000
		.dc.b	%00000000,%00000010,%00000000
		.dc.b	%00000000,%00000001,%00000000
		.dc.b	%00000000,%00000000,%10000000
		.dc.b	%00000000,%00000000,%10000000
		.dc.b	%00000000,%00000000,%01000000
		.dc.b	%00000000,%00000000,%00100000
		.dc.b	%00000000,%00000000,%00010000
		.dc.b	%00000000,%00000000,%00001000
		.dc.b	%00000000,%00000000,%00000100
		.dc.b	%00000000,%00000000,%00000010
		.dc.b	%00000000,%00000000,%00000001
		.dc.b	%00000000,%00000000,%00000001
*---------------------------------------*
*���邳�ςȃp���b�g�w��
lightflg_tbl:
		.dc.b	0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		.dc.b	0,1,1,1,1,0,0,0,0,0,0,0,0,1,1,0
		.dc.b	0,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,2
*---------------------------------------*
*��������
key:		.dc.b	'c* ',0,'g* ',0,'d* ',0,'a* ',0,'e* ',0
		.dc.b	'b* ',0,'f#*',0,'c#*',0,'c* ',0,'f* ',0
		.dc.b	'b$*',0,'e$*',0,'a$*',0,'d$*',0,'g$*',0
		.dc.b	'c$*',0,'am ',0,'em ',0,'bm ',0,'f#m',0
		.dc.b	'c#m',0,'g#m',0,'d#m',0,'a#m',0,'am ',0
		.dc.b	'dm ',0,'gm ',0,'cm ',0,'fm ',0,'b$m',0
		.dc.b	'e$m',0,'abm',0
*---------------------------------------*
*������f�[�^
mes_rcp_title:	.dc.b	'TITLE^',0
mes_rcp_files:	.dc.b	'FILES^',0
mes_path:	.dc.b	'PATH^',0
mes_rcp_info:	.dc.b	'TEMP^        KEY^       TIMEBASE^       BEAT^           STEP-COUNT^',0
mes_status:	.dc.b	'MODE^               STATUS^             LOOP^       TIME^',0
mes_master:	.dc.b	'MASTER',0
mes_slash:	.dc.b	'/',0
mes_coron:	.dc.b	':',0
mes_ten:	.dc.b	'.',0
mes_1space:	.dc.b	' ',0
mes_3space:	.dc.b	'   ',0
mes_6space:	.dc.b	'      ',0
mes_64space:	.dc.b	'                                                               ',0
mes_trk_guide:	.dc.b	' TR CH BAR STP VELOCI VOLUME EXPRES MODU PANPOT P.BEND REVRB CHORS    INSTRUMENT  ',0
mes_note_guide:	.dc.b	'-1     0      1      2      3      4      5      6      7      8      9',0
mes_trk_memo:	.dc.b	'                         TRACK MEMO                         ',0
mes_memo:	.dc.b	'                    MEMO                    ',0
mes_help_b:	.dc.b	'                  this is..                 ',0
*mes_help_b:	.dc.b	'                    HELP                    ',0
capital_out:	.dc.b	'            ',0
mes_effect:	.dc.b	'EFFECTER',0
mes_eff_guide:	.dc.b	'REVERB^  CHORUS^  DELAY^   EQ^     ',0
		.dc.b	'>        >        >                ',0
		.dc.b	'Mac:     Mac:     Mac:     LwF:    ',0
		.dc.b	'Chr:     LPF:     LPF:     LwG:    ',0
		.dc.b	'LPF:     Lvl:     TmC:     HiF:    ',0
		.dc.b	'Lvl:     Feb:     TmL:     HiG:    ',0
		.dc.b	'Tme:     Dly:     TmR:             ',0
		.dc.b	'DFb:     Rte:     LvC:             ',0
		.dc.b	'SCh:     Dpt:     LvL:             ',0
		.dc.b	'PDy:     SRv:     LvR:             ',0
		.dc.b	'         SDy:     Lvl:             ',0
		.dc.b	'                  Feb:             ',0
		.dc.b	'                  SRv:             ',0
mes_level:	.dc.b	'16ch LEVEL METER',0
mes_level_guide	.dc.b	'01020304050607080910111213141516',0
mes_speana:	.dc.b	'SPECTRUM ANALYZER       L    R',0
mes_spe_guide:	.dc.b	'60 ---- 1k ---- 6k --- 15k  60 ---- 1k ---- 6k --- 15k',0
mes_sc_display:	.dc.b	'-SOUND Canvas- DISPLAY',0
mes_sts:	.dc.b	'PLAY',0,'STOP',0,'SRCH',0,'FF  ',0
mes_stop:	.dc.b	'STOP',0
mes_play_mode:	.dc.b	'NORMAL',0,'SLOW  ',0,'FAST  ',0,'V.SLOW',0,'V.FAST',0
*---------------------------------------*
*���b�Z�[�W
mes_titlebar:	.dc.b	'ver.1.12 Copyright 1993,94 T-miyamae',0
mes_title:	.dc.b	'X68k GSR:  RC Selector & Display for GS v1.12 (C)1993,94 by T-miyamae',CR,LF,0
mes_usage:	.dc.b	'usage: GSR [option..]',CR,LF
		.dc.b	'options',CR,LF
		.dc.b	'        -p          �Z���N�^���g�p���Ȃ�',CR,LF
		.dc.b	'        -t          �Z���N�^�̃p�l���؂�ւ��𑬂�����',CR,LF
		.dc.b	'        -s          �t�@�C�������\�[�g����',CR,LF
		.dc.b	'        -c<cont>    ��ʂ̖��邳(cont:0�`[20]�`32)',CR,LF
		.dc.b	'        -p<path>    [RC]system������p�X�̐ݒ�',CR,LF
		.dc.b	'        -f<speed>   �t�F�[�h�A�E�g���x(speed:0�`[15]�`32767)',CR,LF
		.dc.b	'        -h          �w���v',CR,LF
		.dc.b	CR,LF
		.dc.b	'�E���ϐ� GSR �ŁA�f�t�H���g�I�v�V�����̐ݒ肪�ł��܂�',CR,LF,0
mes_no_rcd:	.dc.b	'RCD ���풓���Ă��܂���B',CR,LF,0
mes_no_playing:	.dc.b	'���t���Ă��܂���B',CR,LF,0
mes_ver_err:	.dc.b	'RCD �̃o�[�W�������Ⴂ�܂��B',CR,LF,0
mes_mcp_err:	.dc.b	'�\���󂠂�܂��� MCP�t�@�C���ɂ͑Ή����Ă���܂���B',CR,LF,0
mes_gs_err:	.dc.b	'Module Type��SC-55�ɐݒ�(RCC -TS)����Ă��܂���B',CR,LF,0
		.even
*---------------------------------------*
*�w���v
mes_help:
	.dc.b	'                              ',0
	.dc.b	'     �f�r�q version 1.12      ',0
	.dc.b	'                              ',0
	.dc.b	' ����ȘA����                 ',0
	.dc.b	'                              ',0
	.dc.b	'    MEET-NET    : MEET0001    ',0
	.dc.b	'    NIFTY-Serve : KHB15202    ',0
	.dc.b	'    KHB15202@niftyserve.or.jp ',0
	.dc.b	'                              ',0
	.dc.b	' ���T�|�[�g�a�a�r             ',0
	.dc.b	'                              ',0
	.dc.b	'    MEET-NET                  ',0
	.dc.b	'       (03)5384-1962 (24h)    ',0
	.dc.b	'       300�`14400bps          ',0
	.dc.b	'                              ',0
	.dc.b	'                              ',0
	.dc.b	'   (C) by �݂�܂� Sep.1994   ',0
	.dc.b	'                              ',0
		.even
*---------------------------------------*
env_str:	.dc.b	'GSR',0
env_value:	.ds.b	256
tbuf:		.ds.b	128		;������p�e���|����
tbuf2:		.ds.b	128		;������p�e���|����
		.even
*---------------------------------------*
*�e��ϐ�
fstart_flag:	.dc.b	1
		.bss
		.even
crt_mode:	.ds.l	1		;�N�����̉�ʃ��[�h
cnoteptr:	.ds.l	1		;�m�[�g�����j���O�|�C���^�Q
start_time:	.ds.l	1		;�f�r�q�N������ONTIME�l
vel_ontime	.ds.l	1		;�x���V�e�B���[�^�[�pONTIME�l
lv_ontime:	.ds.l	1		;���x�����[�^�[�pONTIME�l
sp_ontime:	.ds.l	1		;�X�y�A�i�pONTIME�l
sc_ptn_time:	.ds.l	1		;�t���f�B�X�v���C�p�^�[���̎��ԊǗ�
sc_str_time:	.ds.l	1		;�t���f�B�X�v���C������̎��ԊǗ�
sc_rol_time:	.ds.l	1		;�t���f�B�X�v���C������X�N���[���̎��ԊǗ�
sc_rol_pointer:	.ds.l	1		;�t���f�B�X�v���C�X�N���[�������|�C���^
loop_time:	.ds.l	1		;�P���[�v�ɔ�₵������
run_time:	.ds.l	1		;���t����
rhy_pointer:	.ds.l	1		;���Y���p�[�g�m�[�g�\���Ǘ��p�|�C���^
fn_mode:	.ds.l	1		;�N�����̃t�@���N�V�����\�����[�h
max_step:	.ds.l	1		;�ő呍�X�e�b�v
max_time:	.ds.l	1		;�����t����
ssp_buf:	.ds.l	1		;�V�X�e���X�^�b�N�|�C���^�o�b�t�@
ps_trk:		.ds.w	1		;�\���g���b�N
gsinst_ren	.ds.w	1		;�t���f�B�X�v���C������̒���
light:		.ds.b	1		;�p�l���̖��邳
note_shift:	.ds.b	1		;�\���I�N�^�[�u�V�t�g�l
brink_flag:	.ds.b	1		;"PLAY"�_�Ńt���O
tcoron_flag:	.ds.b	1		;�o�ߎ���':'�_�Ńt���O
vel_flag:	.ds.b	1		;�x���V�e�B�[���[�^�[�������t���O
lv_flag:	.ds.b	1		;���x�����[�^�[�������t���O
sp_flag:	.ds.b	1		;�X�y�A�i�������t���O
memo_mode:	.ds.b	1		;0=note 1=track-memo 2=memo 3=help
kbclr_flag:	.ds.b	1		;�L�[�{�[�h�o�b�t�@�N���A�v���t���O
pause_flag	.ds.b	1		;�ꎞ��~�t���O
sc_ptn_flag:	.ds.b	1		;�t���f�B�X�v���C�p�^�[���\�����t���O
sc_str_flag:	.ds.b	1		;�t���f�B�X�v���C������\�����t���O
sc_rol_count:	.ds.b	1		;�t���f�B�X�v���C������X�N���[���J�E���g
timebase:	.ds.b	1		;�^�C���x�[�X�l
opt_n:		.ds.b	1		;-n�I�v�V�����t���O
mode:		.ds.b	1		;0=�Z���N�^���[�h 1=�p�l�����[�h
vel_speed:	.ds.b	TRK_NUM		;�x���V�e�B�[�������x
		.even
*---------------------------------------*
*�p�����[�^
o_allstp:	.ds.l	1
o_tempo:	.ds.l	1
o_pmode:	.ds.l	1
o_loopcount:	.ds.w	1
o_bar:		.ds.l	TRK_NUM
o_stp:		.ds.l	TRK_NUM
o_bnd:		.ds.l	TRK_NUM
o_bnk:		.ds.b	TRK_NUM
o_prg:		.ds.b	TRK_NUM
o_cha:		.ds.b	TRK_NUM
m_vel:		.ds.b	TRK_NUM
o_vel:		.ds.b	TRK_NUM
o_vol:		.ds.b	TRK_NUM
o_exp:		.ds.b	TRK_NUM
o_mod:		.ds.b	TRK_NUM
o_pan:		.ds.b	TRK_NUM
o_rvb:		.ds.b	TRK_NUM
o_cho:		.ds.b	TRK_NUM
o_hld:		.ds.b	TRK_NUM
o_mvol:		.ds.b	1
o_mpan:		.ds.b	1
o_rvb_mac:	.ds.b	1
o_rvb_cha:	.ds.b	1
o_rvb_pre:	.ds.b	1
o_rvb_lvl:	.ds.b	1
o_rvb_tme:	.ds.b	1
o_rvb_dly:	.ds.b	1
o_rvb_snd:	.ds.b	1
o_rvb_pdly:	.ds.b	1
o_cho_mac:	.ds.b	1
o_cho_pre:	.ds.b	1
o_cho_lvl:	.ds.b	1
o_cho_fed:	.ds.b	1
o_cho_dly:	.ds.b	1
o_cho_rte:	.ds.b	1
o_cho_dph:	.ds.b	1
o_cho_snd:	.ds.b	1
o_cho_snd_dly:	.ds.b	1
o_dly_mac:	.ds.b	1
o_dly_pre:	.ds.b	1
o_dly_tme_c:	.ds.b	1
o_dly_tme_r:	.ds.b	1
o_dly_tme_l:	.ds.b	1
o_dly_lvl_c:	.ds.b	1
o_dly_lvl_r:	.ds.b	1
o_dly_lvl_l:	.ds.b	1
o_dly_lvl:	.ds.b	1
o_dly_fed:	.ds.b	1
o_dly_snd:	.ds.b	1
o_eq_lf:	.ds.b	1
o_eq_lg:	.ds.b	1
o_eq_hf:	.ds.b	1
o_eq_hg:	.ds.b	1
		.even
*---------------------------------------*
*�o�b�t�@
tpalet_buf:	.ds.w	16		;�e�L�X�g�p���b�g�ޔ�̈�
rhy_flags:	.ds.b	(1+1+4)*64
sc_mes:		.ds.b	128		;55�t���f�B�X�v���C������o�b�t�@
level:		.ds.b	16		;16ch���x�����[�^�[�l
		.ds.b	10		;dummy
speana_r:	.ds.b	13		;�X�y�N�g�����A�i���C�U�[(right)�l
		.ds.b	19		;dummy
speana_l:	.ds.b	13		;�X�y�N�g�����A�i���C�U�[(left)�l
		.ds.b	19		;dummy
*---------------------------------------*
	.stack
	.even
		.ds.b	8*1024
u_sp:


	.end
