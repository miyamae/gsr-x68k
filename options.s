*********************************************************
*
*
*
*
*	ＧＳＲ	コマンドライン解析
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
*	オプション設定
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

optstring:	.dc.b	'ptsc:p:f:',0		;オプションキャラクタ列
mes_usage:	.dc.b	'usage: GSR [option..]',CR,LF
		.dc.b	'options',CR,LF
		.dc.b	'        -p          セレクタを使用しない',CR,LF
		.dc.b	'        -t          セレクタ⇔パネル切り替えを速くする',CR,LF
		.dc.b	'        -s          ファイル名をソートする',CR,LF
		.dc.b	'        -c<cont>    画面の明るさ(cont:0～[20]～32)',CR,LF
		.dc.b	'        -p<path>    [RC]systemがあるパスの設定',CR,LF
		.dc.b	'        -f<speed>   フェードアウト速度(speed:0～[15]～32767)',CR,LF
		.dc.b	'        -h          ヘルプ',CR,LF
		.dc.b	CR,LF
		.dc.b	'・環境変数 GSR で、デフォルトオプションの設定ができます',CR,LF,0

	.end
