
	.include	iocscall.mac
	.include	doscall.mac

TVRAM		equ	$e00000
_FNTADR		equ	$16

	.xdef	print_8x16font

	.text
	.even

*********************************************************
*
*	8x16フォント文字列高速表示ルーチン（漢字非対応）
*
*			入力	d6.w=Ｘ座標（８ドット単位）
*				d7.w=Ｙ座標（１ドット単位）
*				a6.l=表示文字列先頭
print_8x16font:
*********************************************************
	movem.l	d0-d4/d6-d7/a1-a2/a6,-(sp)

	movea.l	#TVRAM,a2		;座標決定
	lsl.l	#7,d7			;　d7=d7*(1024/8)
	adda.l	d7,a2			;　Ｙ
	adda.w	d6,a2			;　Ｘ
	moveq.l	#0,d4

	move.w	#16-1,d3		;16文字ループ
loop:
	moveq.l	#0,d1
	move.b	(a6)+,d1		;d1.l=ポインタ位置文字コード
	tst.b	d1			;終端コードか？
*	seq.b	d4
	bne	@f
	move.b	#1,d4
@@:
	tst.b	d4
	beq	@f
	move.b	#' ',d1
@@:
*	moveq.l	#8,d2			;FNTADR文字サイズ=16x16/8x16
*	IOCS	_FNTADR
*	movea.l	d0,a1			;a1.l=文字パターンアドレス

	move.w	d1,d2
	lsl.w	#4,d2
	lea.l	$f3a800,a1
	add.w	d2,a1

	move.b	15(a1),1024/8*15(a2)	;テキスト書き込み
	move.b	14(a1),1024/8*14(a2)	;	↓パターン下から上へ描いていく
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
