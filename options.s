*********************************************************
*
*
*
*
*	�f�r�q	�R�}���h���C�����
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

	.xdef		get_option

*---------------------------------------*

	.text
	.even

*********************************************************
*
*	�I�v�V�����ݒ�
*
*********************************************************
get_option:
	movem.l	d0/a2,-(sp)
	addq.l	#1,a2
1:
*	pea.l	optstring
*	move.l	a2,-(sp)
*	move.l	#1,-(sp)		;argc
*	jsr	_getopt
*	lea.l	12(sp),sp
*
*	cmpi.l	#-1,d0
*	bne	1b

	movem.l	(sp)+,d0/a2
	rts

*---------------------------------------*

optstring:	.dc.b	'ptsc:p:f:',0		;�I�v�V�����L�����N�^��
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

	.end
