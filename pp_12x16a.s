*
* 12x16���k�t�H���g������\���i���p����ROM�W���t�H���g�Łj
*
.include	IOCSCALL.MAC
.include	DOSCALL.MAC

CRTC_R11	equ	$E80016
CRTC_R21	equ	$E8002A
CRTC_R22	equ	$E8002C
CRTC_R23	equ	$E8002E
TXT0		equ	$E00000
TXT1		equ	$E20000
TXT2		equ	$E40000
TXT3		equ	$E60000
_FNTADR		equ	$16

.xdef	prs_print_12x16		* �P�Q�i�U�j�h�b�g���k�����\�����[�`��
.xdef	make_hankaku_12x16	* ���p���k�����̍쐬
.xdef	COLOR_12x16		* ���k�\�������̐F

.text
.even
make_hankaku_12x16:
	lea	h_prs_table,a0
	lea	hankaku6,a2
*	move.l	#$f3a800,a1

	move.w	#$8000,d1			* d1.w=S.JIS CODE
*	moveq.l	#8,d2
*	IOCS	_FNTADR
*	move.l	d0,a1				* a1.L=���p�����f�[�^�̃A�h���X

	move.w	d1,d2				* ROM font
	lsl.w	#4,d2
	lea.l	$f3a800,a1
	add.w	d2,a1

	moveq.l	#0,d1				* d1=�C���f�b�N�X���W�X�^�ɂȂ�
	move.w	#16*256-1,d0
make_hankaku2:
	move.b	(a1)+,d1
	move.b	(a0,d1),(a2)+
	dbra	d0,make_hankaku2
	rts



prs_print_12x16:			* in d7.L=�c*$80*16
					*    d6.L=��
					*    a6=������{�I�[�R�[�h(0)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	CRTC_R21,-(sp)
	lsl.l	#7,d7			* �i�x���W�Z�o by �݂�܂��j
	move.l	#TXT0,a0
	add.l	d7,a0			* �x���W���Z
	divu.w	#8,d6			* �W�̏ꍇ����
	move.w	d6,d5
	mulu.w	#6,d5			* d5=�I�t�Z�b�g
	add.l	d5,a0
	swap	d6			* d6=�ꍇ�����̂��߂̐��l
	lea	offset_tbl,a2
	moveq.l	#0,d0
	add.b	(a2,d6.w),d0
	add.l	d0,a0			* a0=�����n�߂̃A�h���X
*	move.l	a0,a3			* a3=a0�̃R�s�[
	move.b	8(a2,d6),d6		* d6=d6*4
	and.l	#$FF,d6			* ��ʃ��[�h�N���A
	move.l	#CRTC_R21,a5
*	move.w	#%1_1_0110_0000,(a5)
**	move.w	COLOR_12x16,(a5)
	bset.b	#1,(a5)			* ��̍s�̑���i���� �݂�܂��j
	move.l	#CRTC_R23,a5		* a5=�}�X�N�p�^�[���̃��W�X�^
	moveq.l	#0,d4
	moveq.l	#0,d3
	moveq.l	#0,d0
	bra	��{���[�v

go���p:	bsr	���p
	bra	��{���[�v
go�S�p:	move.b	d0,d1
	lsl.w	#8,d1
	move.b	(a6)+,d1			* d1.w=S.JIS CODE
	moveq.l	#8,d2
	IOCS	_FNTADR
	move.l	d0,a4				* �����f�[�^�̃A�h���X
	lea	prs_table,a3
	lea	zen_work,a1
	move.b	(a4)+,d3			* �S�p���������k���ă��[�N�Ɋi�[
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	move.b	(a4)+,d3
	move.b	(a3,d3.w),(a1)+
	move.b	(a4)+,d3
	move.b	(a3,d3.w),15(a1)
	lea	zen_work,a1
	bsr	�S�p
	bsr	�S�p
��{���[�v:
	move.b	(a6)+,d0		* d0=�P�o�C�g��
	beq	�I���			* �I�[�R�[�h�o��

*	cmp.b	#09,d0
*	beq	�^�u			* ���Ή�
*	cmp.b	#$0D,d0
*	beq	���s			* ���Ή�
	cmp.b	#$0d,d0
	beq	�I���
	cmp.b	#$0a,d0
	beq	�I���
	cmp.b	#$80,d0
	bcs	go���p		* Alpha or CTRL
	cmp.b	#$a0,d0
	bcs	go�S�p		* Kanji
	cmp.b	#$e0,d0
	bcs	go���p		* Kana
	bra	go�S�p

���p:	andi.l	#$FF,d0
	lsl.w	#4,d0
	lea	hankaku6,a1
	add.l	d0,a1

�S�p:	lea	z_bra_tbl,a4
	add.l	d6,a4				* ����
	move.l	(a4),a2
	jmp	(a2)

h_sp_0:	move.w	#%00000011_11111111,(a5)	* �}�X�N�p�^�[��
h_sp_0a:move.b	(a1)+,(a0)
	move.b	(a1)+,$80(a0)
	move.b	(a1)+,$80*2(a0)
	move.b	(a1)+,$80*3(a0)
	move.b	(a1)+,$80*4(a0)
	move.b	(a1)+,$80*5(a0)
	move.b	(a1)+,$80*6(a0)
	move.b	(a1)+,$80*7(a0)
	move.b	(a1)+,$80*8(a0)
	move.b	(a1)+,$80*9(a0)
	move.b	(a1)+,$80*10(a0)
	move.b	(a1)+,$80*11(a0)
	move.b	(a1)+,$80*12(a0)
	move.b	(a1)+,$80*13(a0)
	move.b	(a1)+,$80*14(a0)
	move.b	(a1)+,$80*15(a0)
	move.l	#7*4,d6				* ���̏ꍇ����
	rts
h_sp_7:	move.w	#%11111100_00001111,(a5)	* �}�X�N�p�^�[��
h_sp_7a:
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,(a0)

	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*2(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*3(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*4(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*5(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*6(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*7(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*8(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*9(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*10(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*11(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*12(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*13(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*14(a0)
	moveq.l	#0,d4
	move.b	(a1)+,d4
	lsl.w	#2,d4
	move.w	d4,$80*15(a0)

	addq.l	#1,a0
	moveq.l	#6*4,d6				* ���̏ꍇ����
	rts

h_sp_6:	move.w	#%00111111_11110000,(a5)	 �}�X�N�p�^�[��
h_sp_6a:move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,(a0)+
	move.b	d4,(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80-1(a0)
	move.b	d4,$80(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*2-1(a0)
	move.b	d4,$80*2(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*3-1(a0)
	move.b	d4,$80*3(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*4-1(a0)
	move.b	d4,$80*4(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*5-1(a0)
	move.b	d4,$80*5(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*6-1(a0)
	move.b	d4,$80*6(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*7-1(a0)
	move.b	d4,$80*7(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*8-1(a0)
	move.b	d4,$80*8(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*9-1(a0)
	move.b	d4,$80*9(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*10-1(a0)
	move.b	d4,$80*10(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*11-1(a0)
	move.b	d4,$80*11(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*12-1(a0)
	move.b	d4,$80*12(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*13-1(a0)
	move.b	d4,$80*13(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*14-1(a0)
	move.b	d4,$80*14(a0)
	move.b	(a1)+,d4
	rol.b	#4,d4
	move.b	d4,$80*15-1(a0)
	move.b	d4,$80*15(a0)
	moveq.l	#5*4,d6				* ���̏ꍇ����
	rts

h_sp_5:	move.w	#%11000000_11111111,(a5)	* �}�X�N�p�^�[��
h_sp_5a:move.b	(a1)+,d4
	ror.b	#2,d4

	move.b	d4,(a0)+
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*2-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*3-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*4-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*5-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*6-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*7-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*8-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*9-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*10-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*11-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*12-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*13-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*14-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*15-1(a0)

	moveq.l	#4*4,d6				* ���̏ꍇ����
	rts

h_sp_4:	move.w	#%11111111_00000011,(a5)	* �}�X�N�p�^�[��
h_sp_4a:move.b	(a1)+,(a0)
	move.b	(a1)+,$80(a0)
	move.b	(a1)+,$80*2(a0)
	move.b	(a1)+,$80*3(a0)
	move.b	(a1)+,$80*4(a0)
	move.b	(a1)+,$80*5(a0)
	move.b	(a1)+,$80*6(a0)
	move.b	(a1)+,$80*7(a0)
	move.b	(a1)+,$80*8(a0)
	move.b	(a1)+,$80*9(a0)
	move.b	(a1)+,$80*10(a0)
	move.b	(a1)+,$80*11(a0)
	move.b	(a1)+,$80*12(a0)
	move.b	(a1)+,$80*13(a0)
	move.b	(a1)+,$80*14(a0)
	move.b	(a1)+,$80*15(a0)
	moveq.l	#3*4,d6				* ���̏ꍇ����
	rts

h_sp_3:	move.w	#%00001111_11111100,(a5)	* �}�X�N�p�^�[��
h_sp_3a:move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,(a0)+
	move.b	d4,(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80-1(a0)
	move.b	d4,$80(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*2-1(a0)
	move.b	d4,$80*2(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*3-1(a0)
	move.b	d4,$80*3(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*4-1(a0)
	move.b	d4,$80*4(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*5-1(a0)
	move.b	d4,$80*5(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*6-1(a0)
	move.b	d4,$80*6(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*7-1(a0)
	move.b	d4,$80*7(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*8-1(a0)
	move.b	d4,$80*8(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*9-1(a0)
	move.b	d4,$80*9(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*10-1(a0)
	move.b	d4,$80*10(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*11-1(a0)
	move.b	d4,$80*11(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*12-1(a0)
	move.b	d4,$80*12(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*13-1(a0)
	move.b	d4,$80*13(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*14-1(a0)
	move.b	d4,$80*14(a0)
	move.b	(a1)+,d4
	rol.b	#2,d4
	move.b	d4,$80*15-1(a0)
	move.b	d4,$80*15(a0)
	moveq.l	#2*4,d6				* ���̏ꍇ����
	rts

h_sp_2:	move.w	#%11110000_00111111,(a5)	* �}�X�N�p�^�[��
h_sp_2a:move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*2(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*3(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*4(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*5(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*6(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*7(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*8(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*9(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*10(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*11(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*12(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*13(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*14(a0)
	move.b	(a1)+,d4
	lsl.w	#4,d4
	move.w	d4,$80*15(a0)
	addq.l	#1,a0
	moveq.l	#1*4,d6				* ���̏ꍇ����
	rts

h_sp_1:	move.w	#%11111111_11000000,(a5)		* �}�X�N�p�^�[��
h_sp_1a:move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,(a0)+

	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80-1(a0)

	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*2-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*3-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*4-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*5-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*6-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*7-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*8-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*9-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*10-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*11-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*12-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*13-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*14-1(a0)
	move.b	(a1)+,d4
	ror.b	#2,d4
	move.b	d4,$80*15-1(a0)

	moveq.l	#0*4,d6				* ���̏ꍇ����
	rts


�I���:	move.l	#CRTC_R21,a5
**	move.w	#%110011,(a5)			* �V�X�e���p��CRTC_R21�ɖ߂�
	move.w	(sp)+,CRTC_R21
	movem.l	(sp)+,d0-d7/a0-a6
	rts

.data
.even
COLOR_12x16:	.dc.w	%1_1_0010_0000			* ���k������̕\���F�iCRTC_R21�̃f�[�^�`���j

offset_tbl:					* �擪�������݃A�h���X�Z�o�p�e�[�u��
	.dc.b	0,0,1,2,3,3,4,5
	.dc.b	0,7*4,6*4,5*4,4*4,3*4,2*4,1*4

.even
z_bra_tbl:					* �W�����v�e�[�u��
	.dc.l	h_sp_0
	.dc.l	h_sp_1
	.dc.l	h_sp_2
	.dc.l	h_sp_3
	.dc.l	h_sp_4
	.dc.l	h_sp_5
	.dc.l	h_sp_6
	.dc.l	h_sp_7

prs_table:	*   ���k��       ���k�O
	.dc.b	%0_00_0_00_00 *00_00_00_00
	.dc.b	%0_00_0_01_00 *00_00_00_01
	.dc.b	%0_00_0_10_00 *00_00_00_10
	.dc.b	%0_00_0_11_00 *00_00_00_11
	.dc.b	%0_00_1_00_00 *00_00_01_00
	.dc.b	%0_00_1_01_00 *00_00_01_01
	.dc.b	%0_00_1_10_00 *00_00_01_10
	.dc.b	%0_00_1_11_00 *00_00_01_11
	.dc.b	%0_00_1_00_00 *00_00_10_00
	.dc.b	%0_00_1_01_00 *00_00_10_01
	.dc.b	%0_00_1_10_00 *00_00_10_10
	.dc.b	%0_00_1_11_00 *00_00_10_11
	.dc.b	%0_00_1_00_00 *00_00_11_00
	.dc.b	%0_00_1_01_00 *00_00_11_01
	.dc.b	%0_00_1_10_00 *00_00_11_10
	.dc.b	%0_00_1_11_00 *00_00_11_11
	.dc.b	%0_01_0_00_00 *00_01_00_00
	.dc.b	%0_01_0_01_00 *00_01_00_01
	.dc.b	%0_01_0_10_00 *00_01_00_10
	.dc.b	%0_01_0_11_00 *00_01_00_11
	.dc.b	%0_01_1_00_00 *00_01_01_00
	.dc.b	%0_01_1_01_00 *00_01_01_01
	.dc.b	%0_01_1_10_00 *00_01_01_10
	.dc.b	%0_01_1_11_00 *00_01_01_11
	.dc.b	%0_01_1_00_00 *00_01_10_00
	.dc.b	%0_01_1_01_00 *00_01_10_01
	.dc.b	%0_01_1_10_00 *00_01_10_10
	.dc.b	%0_01_1_11_00 *00_01_10_11
	.dc.b	%0_01_1_00_00 *00_01_11_00
	.dc.b	%0_01_1_01_00 *00_01_11_01
	.dc.b	%0_01_1_10_00 *00_01_11_10
	.dc.b	%0_01_1_11_00 *00_01_11_11
	.dc.b	%0_10_0_00_00 *00_10_00_00
	.dc.b	%0_10_0_01_00 *00_10_00_01
	.dc.b	%0_10_0_10_00 *00_10_00_10
	.dc.b	%0_10_0_11_00 *00_10_00_11
	.dc.b	%0_10_1_00_00 *00_10_01_00
	.dc.b	%0_10_1_01_00 *00_10_01_01
	.dc.b	%0_10_1_10_00 *00_10_01_10
	.dc.b	%0_10_1_11_00 *00_10_01_11
	.dc.b	%0_10_1_00_00 *00_10_10_00
	.dc.b	%0_10_1_01_00 *00_10_10_01
	.dc.b	%0_10_1_10_00 *00_10_10_10
	.dc.b	%0_10_1_11_00 *00_10_10_11
	.dc.b	%0_10_1_00_00 *00_10_11_00
	.dc.b	%0_10_1_01_00 *00_10_11_01
	.dc.b	%0_10_1_10_00 *00_10_11_10
	.dc.b	%0_10_1_11_00 *00_10_11_11
	.dc.b	%0_11_0_00_00 *00_11_00_00
	.dc.b	%0_11_0_01_00 *00_11_00_01
	.dc.b	%0_11_0_10_00 *00_11_00_10
	.dc.b	%0_11_0_11_00 *00_11_00_11
	.dc.b	%0_11_1_00_00 *00_11_01_00
	.dc.b	%0_11_1_01_00 *00_11_01_01
	.dc.b	%0_11_1_10_00 *00_11_01_10
	.dc.b	%0_11_1_11_00 *00_11_01_11
	.dc.b	%0_11_1_00_00 *00_11_10_00
	.dc.b	%0_11_1_01_00 *00_11_10_01
	.dc.b	%0_11_1_10_00 *00_11_10_10
	.dc.b	%0_11_1_11_00 *00_11_10_11
	.dc.b	%0_11_1_00_00 *00_11_11_00
	.dc.b	%0_11_1_01_00 *00_11_11_01
	.dc.b	%0_11_1_10_00 *00_11_11_10
	.dc.b	%0_11_1_11_00 *00_11_11_11
	.dc.b	%1_00_0_00_00 *01_00_00_00
	.dc.b	%1_00_0_01_00 *01_00_00_01
	.dc.b	%1_00_0_10_00 *01_00_00_10
	.dc.b	%1_00_0_11_00 *01_00_00_11
	.dc.b	%1_00_1_00_00 *01_00_01_00
	.dc.b	%1_00_1_01_00 *01_00_01_01
	.dc.b	%1_00_1_10_00 *01_00_01_10
	.dc.b	%1_00_1_11_00 *01_00_01_11
	.dc.b	%1_00_1_00_00 *01_00_10_00
	.dc.b	%1_00_1_01_00 *01_00_10_01
	.dc.b	%1_00_1_10_00 *01_00_10_10
	.dc.b	%1_00_1_11_00 *01_00_10_11
	.dc.b	%1_00_1_00_00 *01_00_11_00
	.dc.b	%1_00_1_01_00 *01_00_11_01
	.dc.b	%1_00_1_10_00 *01_00_11_10
	.dc.b	%1_00_1_11_00 *01_00_11_11
	.dc.b	%1_01_0_00_00 *01_01_00_00
	.dc.b	%1_01_0_01_00 *01_01_00_01
	.dc.b	%1_01_0_10_00 *01_01_00_10
	.dc.b	%1_01_0_11_00 *01_01_00_11
	.dc.b	%1_01_1_00_00 *01_01_01_00
	.dc.b	%1_01_1_01_00 *01_01_01_01
	.dc.b	%1_01_1_10_00 *01_01_01_10
	.dc.b	%1_01_1_11_00 *01_01_01_11
	.dc.b	%1_01_1_00_00 *01_01_10_00
	.dc.b	%1_01_1_01_00 *01_01_10_01
	.dc.b	%1_01_1_10_00 *01_01_10_10
	.dc.b	%1_01_1_11_00 *01_01_10_11
	.dc.b	%1_01_1_00_00 *01_01_11_00
	.dc.b	%1_01_1_01_00 *01_01_11_01
	.dc.b	%1_01_1_10_00 *01_01_11_10
	.dc.b	%1_01_1_11_00 *01_01_11_11
	.dc.b	%1_10_0_00_00 *01_10_00_00
	.dc.b	%1_10_0_01_00 *01_10_00_01
	.dc.b	%1_10_0_10_00 *01_10_00_10
	.dc.b	%1_10_0_11_00 *01_10_00_11
	.dc.b	%1_10_1_00_00 *01_10_01_00
	.dc.b	%1_10_1_01_00 *01_10_01_01
	.dc.b	%1_10_1_10_00 *01_10_01_10
	.dc.b	%1_10_1_11_00 *01_10_01_11
	.dc.b	%1_10_1_00_00 *01_10_10_00
	.dc.b	%1_10_1_01_00 *01_10_10_01
	.dc.b	%1_10_1_10_00 *01_10_10_10
	.dc.b	%1_10_1_11_00 *01_10_10_11
	.dc.b	%1_10_1_00_00 *01_10_11_00
	.dc.b	%1_10_1_01_00 *01_10_11_01
	.dc.b	%1_10_1_10_00 *01_10_11_10
	.dc.b	%1_10_1_11_00 *01_10_11_11
	.dc.b	%1_11_0_00_00 *01_11_00_00
	.dc.b	%1_11_0_01_00 *01_11_00_01
	.dc.b	%1_11_0_10_00 *01_11_00_10
	.dc.b	%1_11_0_11_00 *01_11_00_11
	.dc.b	%1_11_1_00_00 *01_11_01_00
	.dc.b	%1_11_1_01_00 *01_11_01_01
	.dc.b	%1_11_1_10_00 *01_11_01_10
	.dc.b	%1_11_1_11_00 *01_11_01_11
	.dc.b	%1_11_1_00_00 *01_11_10_00
	.dc.b	%1_11_1_01_00 *01_11_10_01
	.dc.b	%1_11_1_10_00 *01_11_10_10
	.dc.b	%1_11_1_11_00 *01_11_10_11
	.dc.b	%1_11_1_00_00 *01_11_11_00
	.dc.b	%1_11_1_01_00 *01_11_11_01
	.dc.b	%1_11_1_10_00 *01_11_11_10
	.dc.b	%1_11_1_11_00 *01_11_11_11

	.dc.b	%1_00_0_00_00 *10_00_00_00
	.dc.b	%1_00_0_01_00 *10_00_00_01
	.dc.b	%1_00_0_10_00 *10_00_00_10
	.dc.b	%1_00_0_11_00 *10_00_00_11
	.dc.b	%1_00_1_00_00 *10_00_01_00
	.dc.b	%1_00_1_01_00 *10_00_01_01
	.dc.b	%1_00_1_10_00 *10_00_01_10
	.dc.b	%1_00_1_11_00 *10_00_01_11
	.dc.b	%1_00_1_00_00 *10_00_10_00
	.dc.b	%1_00_1_01_00 *10_00_10_01
	.dc.b	%1_00_1_10_00 *10_00_10_10
	.dc.b	%1_00_1_11_00 *10_00_10_11
	.dc.b	%1_00_1_00_00 *10_00_11_00
	.dc.b	%1_00_1_01_00 *10_00_11_01
	.dc.b	%1_00_1_10_00 *10_00_11_10
	.dc.b	%1_00_1_11_00 *10_00_11_11
	.dc.b	%1_01_0_00_00 *10_01_00_00
	.dc.b	%1_01_0_01_00 *10_01_00_01
	.dc.b	%1_01_0_10_00 *10_01_00_10
	.dc.b	%1_01_0_11_00 *10_01_00_11
	.dc.b	%1_01_1_00_00 *10_01_01_00
	.dc.b	%1_01_1_01_00 *10_01_01_01
	.dc.b	%1_01_1_10_00 *10_01_01_10
	.dc.b	%1_01_1_11_00 *10_01_01_11
	.dc.b	%1_01_1_00_00 *10_01_10_00
	.dc.b	%1_01_1_01_00 *10_01_10_01
	.dc.b	%1_01_1_10_00 *10_01_10_10
	.dc.b	%1_01_1_11_00 *10_01_10_11
	.dc.b	%1_01_1_00_00 *10_01_11_00
	.dc.b	%1_01_1_01_00 *10_01_11_01
	.dc.b	%1_01_1_10_00 *10_01_11_10
	.dc.b	%1_01_1_11_00 *10_01_11_11
	.dc.b	%1_10_0_00_00 *10_10_00_00
	.dc.b	%1_10_0_01_00 *10_10_00_01
	.dc.b	%1_10_0_10_00 *10_10_00_10
	.dc.b	%1_10_0_11_00 *10_10_00_11
	.dc.b	%1_10_1_00_00 *10_10_01_00
	.dc.b	%1_10_1_01_00 *10_10_01_01
	.dc.b	%1_10_1_10_00 *10_10_01_10
	.dc.b	%1_10_1_11_00 *10_10_01_11
	.dc.b	%1_10_1_00_00 *10_10_10_00
	.dc.b	%1_10_1_01_00 *10_10_10_01
	.dc.b	%1_10_1_10_00 *10_10_10_10
	.dc.b	%1_10_1_11_00 *10_10_10_11
	.dc.b	%1_10_1_00_00 *10_10_11_00
	.dc.b	%1_10_1_01_00 *10_10_11_01
	.dc.b	%1_10_1_10_00 *10_10_11_10
	.dc.b	%1_10_1_11_00 *10_10_11_11
	.dc.b	%1_11_0_00_00 *10_11_00_00
	.dc.b	%1_11_0_01_00 *10_11_00_01
	.dc.b	%1_11_0_10_00 *10_11_00_10
	.dc.b	%1_11_0_11_00 *10_11_00_11
	.dc.b	%1_11_1_00_00 *10_11_01_00
	.dc.b	%1_11_1_01_00 *10_11_01_01
	.dc.b	%1_11_1_10_00 *10_11_01_10
	.dc.b	%1_11_1_11_00 *10_11_01_11
	.dc.b	%1_11_1_00_00 *10_11_10_00
	.dc.b	%1_11_1_01_00 *10_11_10_01
	.dc.b	%1_11_1_10_00 *10_11_10_10
	.dc.b	%1_11_1_11_00 *10_11_10_11
	.dc.b	%1_11_1_00_00 *10_11_11_00
	.dc.b	%1_11_1_01_00 *10_11_11_01
	.dc.b	%1_11_1_10_00 *10_11_11_10
	.dc.b	%1_11_1_11_00 *10_11_11_11
	.dc.b	%1_00_0_00_00 *11_00_00_00
	.dc.b	%1_00_0_01_00 *11_00_00_01
	.dc.b	%1_00_0_10_00 *11_00_00_10
	.dc.b	%1_00_0_11_00 *11_00_00_11
	.dc.b	%1_00_1_00_00 *11_00_01_00
	.dc.b	%1_00_1_01_00 *11_00_01_01
	.dc.b	%1_00_1_10_00 *11_00_01_10
	.dc.b	%1_00_1_11_00 *11_00_01_11
	.dc.b	%1_00_1_00_00 *11_00_10_00
	.dc.b	%1_00_1_01_00 *11_00_10_01
	.dc.b	%1_00_1_10_00 *11_00_10_10
	.dc.b	%1_00_1_11_00 *11_00_10_11
	.dc.b	%1_00_1_00_00 *11_00_11_00
	.dc.b	%1_00_1_01_00 *11_00_11_01
	.dc.b	%1_00_1_10_00 *11_00_11_10
	.dc.b	%1_00_1_11_00 *11_00_11_11
	.dc.b	%1_01_0_00_00 *11_01_00_00
	.dc.b	%1_01_0_01_00 *11_01_00_01
	.dc.b	%1_01_0_10_00 *11_01_00_10
	.dc.b	%1_01_0_11_00 *11_01_00_11
	.dc.b	%1_01_1_00_00 *11_01_01_00
	.dc.b	%1_01_1_01_00 *11_01_01_01
	.dc.b	%1_01_1_10_00 *11_01_01_10
	.dc.b	%1_01_1_11_00 *11_01_01_11
	.dc.b	%1_01_1_00_00 *11_01_10_00
	.dc.b	%1_01_1_01_00 *11_01_10_01
	.dc.b	%1_01_1_10_00 *11_01_10_10
	.dc.b	%1_01_1_11_00 *11_01_10_11
	.dc.b	%1_01_1_00_00 *11_01_11_00
	.dc.b	%1_01_1_01_00 *11_01_11_01
	.dc.b	%1_01_1_10_00 *11_01_11_10
	.dc.b	%1_01_1_11_00 *11_01_11_11
	.dc.b	%1_10_0_00_00 *11_10_00_00
	.dc.b	%1_10_0_01_00 *11_10_00_01
	.dc.b	%1_10_0_10_00 *11_10_00_10
	.dc.b	%1_10_0_11_00 *11_10_00_11
	.dc.b	%1_10_1_00_00 *11_10_01_00
	.dc.b	%1_10_1_01_00 *11_10_01_01
	.dc.b	%1_10_1_10_00 *11_10_01_10
	.dc.b	%1_10_1_11_00 *11_10_01_11
	.dc.b	%1_10_1_00_00 *11_10_10_00
	.dc.b	%1_10_1_01_00 *11_10_10_01
	.dc.b	%1_10_1_10_00 *11_10_10_10
	.dc.b	%1_10_1_11_00 *11_10_10_11
	.dc.b	%1_10_1_00_00 *11_10_11_00
	.dc.b	%1_10_1_01_00 *11_10_11_01
	.dc.b	%1_10_1_10_00 *11_10_11_10
	.dc.b	%1_10_1_11_00 *11_10_11_11
	.dc.b	%1_11_0_00_00 *11_11_00_00
	.dc.b	%1_11_0_01_00 *11_11_00_01
	.dc.b	%1_11_0_10_00 *11_11_00_10
	.dc.b	%1_11_0_11_00 *11_11_00_11
	.dc.b	%1_11_1_00_00 *11_11_01_00
	.dc.b	%1_11_1_01_00 *11_11_01_01
	.dc.b	%1_11_1_10_00 *11_11_01_10
	.dc.b	%1_11_1_11_00 *11_11_01_11
	.dc.b	%1_11_1_00_00 *11_11_10_00
	.dc.b	%1_11_1_01_00 *11_11_10_01
	.dc.b	%1_11_1_10_00 *11_11_10_10
	.dc.b	%1_11_1_11_00 *11_11_10_11
	.dc.b	%1_11_1_00_00 *11_11_11_00
	.dc.b	%1_11_1_01_00 *11_11_11_01
	.dc.b	%1_11_1_10_00 *11_11_11_10
	.dc.b	%1_11_1_11_00 *11_11_11_11

h_prs_table:					* ���p�����p�̈��k�e�[�u��
	.dc.b	%0_000_0_000 *00_000_00_0
	.dc.b	%0_000_0_000 *00_000_00_1
	.dc.b	%0_000_1_000 *00_000_01_0
	.dc.b	%0_000_1_000 *00_000_01_1
	.dc.b	%0_000_1_000 *00_000_10_0
	.dc.b	%0_000_1_000 *00_000_10_1
	.dc.b	%0_000_1_000 *00_000_11_0
	.dc.b	%0_000_1_000 *00_000_11_1
	.dc.b	%0_001_0_000 *00_001_00_0
	.dc.b	%0_001_0_000 *00_001_00_1
	.dc.b	%0_001_1_000 *00_001_01_0
	.dc.b	%0_001_1_000 *00_001_01_1
	.dc.b	%0_001_1_000 *00_001_10_0
	.dc.b	%0_001_1_000 *00_001_10_1
	.dc.b	%0_001_1_000 *00_001_11_0
	.dc.b	%0_001_1_000 *00_001_11_1
	.dc.b	%0_010_0_000 *00_010_00_0
	.dc.b	%0_010_0_000 *00_010_00_1
	.dc.b	%0_010_1_000 *00_010_01_0
	.dc.b	%0_010_1_000 *00_010_01_1
	.dc.b	%0_010_1_000 *00_010_10_0
	.dc.b	%0_010_1_000 *00_010_10_1
	.dc.b	%0_010_1_000 *00_010_11_0
	.dc.b	%0_010_1_000 *00_010_11_1
	.dc.b	%0_011_0_000 *00_011_00_0
	.dc.b	%0_011_0_000 *00_011_00_1
	.dc.b	%0_011_1_000 *00_011_01_0
	.dc.b	%0_011_1_000 *00_011_01_1
	.dc.b	%0_011_1_000 *00_011_10_0
	.dc.b	%0_011_1_000 *00_011_10_1
	.dc.b	%0_011_1_000 *00_011_11_0
	.dc.b	%0_011_1_000 *00_011_11_1
	.dc.b	%0_100_0_000 *00_100_00_0
	.dc.b	%0_100_0_000 *00_100_00_1
	.dc.b	%0_100_1_000 *00_100_01_0
	.dc.b	%0_100_1_000 *00_100_01_1
	.dc.b	%0_100_1_000 *00_100_10_0
	.dc.b	%0_100_1_000 *00_100_10_1
	.dc.b	%0_100_1_000 *00_100_11_0
	.dc.b	%0_100_1_000 *00_100_11_1
	.dc.b	%0_101_0_000 *00_101_00_0
	.dc.b	%0_101_0_000 *00_101_00_1
	.dc.b	%0_101_1_000 *00_101_01_0
	.dc.b	%0_101_1_000 *00_101_01_1
	.dc.b	%0_101_1_000 *00_101_10_0
	.dc.b	%0_101_1_000 *00_101_10_1
	.dc.b	%0_101_1_000 *00_101_11_0
	.dc.b	%0_101_1_000 *00_101_11_1
	.dc.b	%0_110_0_000 *00_110_00_0
	.dc.b	%0_110_0_000 *00_110_00_1
	.dc.b	%0_110_1_000 *00_110_01_0
	.dc.b	%0_110_1_000 *00_110_01_1
	.dc.b	%0_110_1_000 *00_110_10_0
	.dc.b	%0_110_1_000 *00_110_10_1
	.dc.b	%0_110_1_000 *00_110_11_0
	.dc.b	%0_110_1_000 *00_110_11_1
	.dc.b	%0_111_0_000 *00_111_00_0
	.dc.b	%0_111_0_000 *00_111_00_1
	.dc.b	%0_111_1_000 *00_111_01_0
	.dc.b	%0_111_1_000 *00_111_01_1
	.dc.b	%0_111_1_000 *00_111_10_0
	.dc.b	%0_111_1_000 *00_111_10_1
	.dc.b	%0_111_1_000 *00_111_11_0
	.dc.b	%0_111_1_000 *00_111_11_1
	.dc.b	%1_000_0_000 *01_000_00_0
	.dc.b	%1_000_0_000 *01_000_00_1
	.dc.b	%1_000_1_000 *01_000_01_0
	.dc.b	%1_000_1_000 *01_000_01_1
	.dc.b	%1_000_1_000 *01_000_10_0
	.dc.b	%1_000_1_000 *01_000_10_1
	.dc.b	%1_000_1_000 *01_000_11_0
	.dc.b	%1_000_1_000 *01_000_11_1
	.dc.b	%1_001_0_000 *01_001_00_0
	.dc.b	%1_001_0_000 *01_001_00_1
	.dc.b	%1_001_1_000 *01_001_01_0
	.dc.b	%1_001_1_000 *01_001_01_1
	.dc.b	%1_001_1_000 *01_001_10_0
	.dc.b	%1_001_1_000 *01_001_10_1
	.dc.b	%1_001_1_000 *01_001_11_0
	.dc.b	%1_001_1_000 *01_001_11_1
	.dc.b	%1_010_0_000 *01_010_00_0
	.dc.b	%1_010_0_000 *01_010_00_1
	.dc.b	%1_010_1_000 *01_010_01_0
	.dc.b	%1_010_1_000 *01_010_01_1
	.dc.b	%1_010_1_000 *01_010_10_0
	.dc.b	%1_010_1_000 *01_010_10_1
	.dc.b	%1_010_1_000 *01_010_11_0
	.dc.b	%1_010_1_000 *01_010_11_1
	.dc.b	%1_011_0_000 *01_011_00_0
	.dc.b	%1_011_0_000 *01_011_00_1
	.dc.b	%1_011_1_000 *01_011_01_0
	.dc.b	%1_011_1_000 *01_011_01_1
	.dc.b	%1_011_1_000 *01_011_10_0
	.dc.b	%1_011_1_000 *01_011_10_1
	.dc.b	%1_011_1_000 *01_011_11_0
	.dc.b	%1_011_1_000 *01_011_11_1
	.dc.b	%1_100_0_000 *01_100_00_0
	.dc.b	%1_100_0_000 *01_100_00_1
	.dc.b	%1_100_1_000 *01_100_01_0
	.dc.b	%1_100_1_000 *01_100_01_1
	.dc.b	%1_100_1_000 *01_100_10_0
	.dc.b	%1_100_1_000 *01_100_10_1
	.dc.b	%1_100_1_000 *01_100_11_0
	.dc.b	%1_100_1_000 *01_100_11_1
	.dc.b	%1_101_0_000 *01_101_00_0
	.dc.b	%1_101_0_000 *01_101_00_1
	.dc.b	%1_101_1_000 *01_101_01_0
	.dc.b	%1_101_1_000 *01_101_01_1
	.dc.b	%1_101_1_000 *01_101_10_0
	.dc.b	%1_101_1_000 *01_101_10_1
	.dc.b	%1_101_1_000 *01_101_11_0
	.dc.b	%1_101_1_000 *01_101_11_1
	.dc.b	%1_110_0_000 *01_110_00_0
	.dc.b	%1_110_0_000 *01_110_00_1
	.dc.b	%1_110_1_000 *01_110_01_0
	.dc.b	%1_110_1_000 *01_110_01_1
	.dc.b	%1_110_1_000 *01_110_10_0
	.dc.b	%1_110_1_000 *01_110_10_1
	.dc.b	%1_110_1_000 *01_110_11_0
	.dc.b	%1_110_1_000 *01_110_11_1
	.dc.b	%1_111_0_000 *01_111_00_0
	.dc.b	%1_111_0_000 *01_111_00_1
	.dc.b	%1_111_1_000 *01_111_01_0
	.dc.b	%1_111_1_000 *01_111_01_1
	.dc.b	%1_111_1_000 *01_111_10_0
	.dc.b	%1_111_1_000 *01_111_10_1
	.dc.b	%1_111_1_000 *01_111_11_0
	.dc.b	%1_111_1_000 *01_111_11_1

	.dc.b	%1_000_0_000 *10_000_00_0
	.dc.b	%1_000_0_000 *10_000_00_1
	.dc.b	%1_000_1_000 *10_000_01_0
	.dc.b	%1_000_1_000 *10_000_01_1
	.dc.b	%1_000_1_000 *10_000_10_0
	.dc.b	%1_000_1_000 *10_000_10_1
	.dc.b	%1_000_1_000 *10_000_11_0
	.dc.b	%1_000_1_000 *10_000_11_1
	.dc.b	%1_001_0_000 *10_001_00_0
	.dc.b	%1_001_0_000 *10_001_00_1
	.dc.b	%1_001_1_000 *10_001_01_0
	.dc.b	%1_001_1_000 *10_001_01_1
	.dc.b	%1_001_1_000 *10_001_10_0
	.dc.b	%1_001_1_000 *10_001_10_1
	.dc.b	%1_001_1_000 *10_001_11_0
	.dc.b	%1_001_1_000 *10_001_11_1
	.dc.b	%1_010_0_000 *10_010_00_0
	.dc.b	%1_010_0_000 *10_010_00_1
	.dc.b	%1_010_1_000 *10_010_01_0
	.dc.b	%1_010_1_000 *10_010_01_1
	.dc.b	%1_010_1_000 *10_010_10_0
	.dc.b	%1_010_1_000 *10_010_10_1
	.dc.b	%1_010_1_000 *10_010_11_0
	.dc.b	%1_010_1_000 *10_010_11_1
	.dc.b	%1_011_0_000 *10_011_00_0
	.dc.b	%1_011_0_000 *10_011_00_1
	.dc.b	%1_011_1_000 *10_011_01_0
	.dc.b	%1_011_1_000 *10_011_01_1
	.dc.b	%1_011_1_000 *10_011_10_0
	.dc.b	%1_011_1_000 *10_011_10_1
	.dc.b	%1_011_1_000 *10_011_11_0
	.dc.b	%1_011_1_000 *10_011_11_1
	.dc.b	%1_100_0_000 *10_100_00_0
	.dc.b	%1_100_0_000 *10_100_00_1
	.dc.b	%1_100_1_000 *10_100_01_0
	.dc.b	%1_100_1_000 *10_100_01_1
	.dc.b	%1_100_1_000 *10_100_10_0
	.dc.b	%1_100_1_000 *10_100_10_1
	.dc.b	%1_100_1_000 *10_100_11_0
	.dc.b	%1_100_1_000 *10_100_11_1
	.dc.b	%1_101_0_000 *10_101_00_0
	.dc.b	%1_101_0_000 *10_101_00_1
	.dc.b	%1_101_1_000 *10_101_01_0
	.dc.b	%1_101_1_000 *10_101_01_1
	.dc.b	%1_101_1_000 *10_101_10_0
	.dc.b	%1_101_1_000 *10_101_10_1
	.dc.b	%1_101_1_000 *10_101_11_0
	.dc.b	%1_101_1_000 *10_101_11_1
	.dc.b	%1_110_0_000 *10_110_00_0
	.dc.b	%1_110_0_000 *10_110_00_1
	.dc.b	%1_110_1_000 *10_110_01_0
	.dc.b	%1_110_1_000 *10_110_01_1
	.dc.b	%1_110_1_000 *10_110_10_0
	.dc.b	%1_110_1_000 *10_110_10_1
	.dc.b	%1_110_1_000 *10_110_11_0
	.dc.b	%1_110_1_000 *10_110_11_1
	.dc.b	%1_111_0_000 *10_111_00_0
	.dc.b	%1_111_0_000 *10_111_00_1
	.dc.b	%1_111_1_000 *10_111_01_0
	.dc.b	%1_111_1_000 *10_111_01_1
	.dc.b	%1_111_1_000 *10_111_10_0
	.dc.b	%1_111_1_000 *10_111_10_1
	.dc.b	%1_111_1_000 *10_111_11_0
	.dc.b	%1_111_1_000 *10_111_11_1
	.dc.b	%1_000_0_000 *11_000_00_0
	.dc.b	%1_000_0_000 *11_000_00_1
	.dc.b	%1_000_1_000 *11_000_01_0
	.dc.b	%1_000_1_000 *11_000_01_1
	.dc.b	%1_000_1_000 *11_000_10_0
	.dc.b	%1_000_1_000 *11_000_10_1
	.dc.b	%1_000_1_000 *11_000_11_0
	.dc.b	%1_000_1_000 *11_000_11_1
	.dc.b	%1_001_0_000 *11_001_00_0
	.dc.b	%1_001_0_000 *11_001_00_1
	.dc.b	%1_001_1_000 *11_001_01_0
	.dc.b	%1_001_1_000 *11_001_01_1
	.dc.b	%1_001_1_000 *11_001_10_0
	.dc.b	%1_001_1_000 *11_001_10_1
	.dc.b	%1_001_1_000 *11_001_11_0
	.dc.b	%1_001_1_000 *11_001_11_1
	.dc.b	%1_010_0_000 *11_010_00_0
	.dc.b	%1_010_0_000 *11_010_00_1
	.dc.b	%1_010_1_000 *11_010_01_0
	.dc.b	%1_010_1_000 *11_010_01_1
	.dc.b	%1_010_1_000 *11_010_10_0
	.dc.b	%1_010_1_000 *11_010_10_1
	.dc.b	%1_010_1_000 *11_010_11_0
	.dc.b	%1_010_1_000 *11_010_11_1
	.dc.b	%1_011_0_000 *11_011_00_0
	.dc.b	%1_011_0_000 *11_011_00_1
	.dc.b	%1_011_1_000 *11_011_01_0
	.dc.b	%1_011_1_000 *11_011_01_1
	.dc.b	%1_011_1_000 *11_011_10_0
	.dc.b	%1_011_1_000 *11_011_10_1
	.dc.b	%1_011_1_000 *11_011_11_0
	.dc.b	%1_011_1_000 *11_011_11_1
	.dc.b	%1_100_0_000 *11_100_00_0
	.dc.b	%1_100_0_000 *11_100_00_1
	.dc.b	%1_100_1_000 *11_100_01_0
	.dc.b	%1_100_1_000 *11_100_01_1
	.dc.b	%1_100_1_000 *11_100_10_0
	.dc.b	%1_100_1_000 *11_100_10_1
	.dc.b	%1_100_1_000 *11_100_11_0
	.dc.b	%1_100_1_000 *11_100_11_1
	.dc.b	%1_101_0_000 *11_101_00_0
	.dc.b	%1_101_0_000 *11_101_00_1
	.dc.b	%1_101_1_000 *11_101_01_0
	.dc.b	%1_101_1_000 *11_101_01_1
	.dc.b	%1_101_1_000 *11_101_10_0
	.dc.b	%1_101_1_000 *11_101_10_1
	.dc.b	%1_101_1_000 *11_101_11_0
	.dc.b	%1_101_1_000 *11_101_11_1
	.dc.b	%1_110_0_000 *11_110_00_0
	.dc.b	%1_110_0_000 *11_110_00_1
	.dc.b	%1_110_1_000 *11_110_01_0
	.dc.b	%1_110_1_000 *11_110_01_1
	.dc.b	%1_110_1_000 *11_110_10_0
	.dc.b	%1_110_1_000 *11_110_10_1
	.dc.b	%1_110_1_000 *11_110_11_0
	.dc.b	%1_110_1_000 *11_110_11_1
	.dc.b	%1_111_0_000 *11_111_00_0
	.dc.b	%1_111_0_000 *11_111_00_1
	.dc.b	%1_111_1_000 *11_111_01_0
	.dc.b	%1_111_1_000 *11_111_01_1
	.dc.b	%1_111_1_000 *11_111_10_0
	.dc.b	%1_111_1_000 *11_111_10_1
	.dc.b	%1_111_1_000 *11_111_11_0
	.dc.b	%1_111_1_000 *11_111_11_1
.bss
.even
hankaku6:	.ds.b	4096			* ���k���p�����f�[�^�̊i�[�̈�
zen_work:	.ds.b	32			* �S�p�������k���̃��[�N