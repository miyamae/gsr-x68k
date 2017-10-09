*********************************************************
*
*
*
*		汎用サブルーチン集
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
*	バイナリ→１０進数文字列
*		入力	sp	数値.l
*				文字列先頭アドレス.l
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
	move	#9,d0			;1 ｹﾀ目の 0 は残す
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

exp_tbl:				*１０進化テーブル
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
*	バイナリ→１０進数文字列（空白は'0'で埋める）
*		入力	sp	数値.l
*				文字列先頭アドレス.l
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
	move	#9,d0			;1 ｹﾀ目の 0 は残す
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
*	bin_adecの出力を３桁左詰めに変換
*
*		入力	a6.l	文字列先頭アドレス
*		リターンa6.l	変換後の文字列先頭アドレス
*
*********************************************************
left3keta:
*     0000000111
* (a6)^     7^
	adda.l	#7,a6			; 0000000x11
	cmp.b	#' ',(a6)		;３桁の位置が空白なら処理を開始
	bne	lk3brk
	adda.l	#1,a6			; 00000001x1
	cmp.b	#' ',(a6)		;２桁の位置も空白なら１桁処理へ
	beq	@f
	move.b	#' ',2(a6)		;エンドコード解除
	clr.b	3(a6)			;新エンドコード
	bra	lk3brk
@@:	adda.l	#1,a6			; 000000011x
	move.b	#' ',1(a6)		;エンドコード解除
	move.b	#' ',2(a6)
	clr.b	3(a6)			;新エンドコード
lk3brk:	rts

*********************************************************
*
*	bin_adecの出力を５桁左詰めに変換
*
*		入力	a6.l	文字列先頭アドレス
*		リターンa6.l	変換後の文字列先頭アドレス
*
*********************************************************
left5keta:
*     0000011111
* (a6)^   5^
	addq.l	#5,a6			; 00000x1111
	cmp.b	#' ',(a6)		;５桁の位置が空白なら処理を開始
	bne	lk5brk

	addq.l	#1,a6			; 000001x111
	cmp.b	#' ',(a6)		;４桁の位置も空白なら３桁処理へ
	beq	@f
	move.b	#' ',4(a6)		;エンドコード解除
	clr.b	5(a6)			;新エンドコード
	bra	lk5brk
@@:
	addq.l	#1,a6			; 0000011x11
	cmp.b	#' ',(a6)		;３桁の位置も空白なら２桁処理へ
	beq	@f
	move.b	#' ',3(a6)		;エンドコード解除
	move.b	#' ',4(a6)
	clr.b	5(a6)			;新エンドコード
	bra	lk5brk
@@:
	addq.l	#1,a6			; 00000111x1
	cmp.b	#' ',(a6)		;２桁の位置も空白なら１桁処理へ
	beq	@f
	move.b	#' ',2(a6)		;エンドコード解除
	move.b	#' ',3(a6)
	move.b	#' ',4(a6)
	clr.b	5(a6)			;新エンドコード
	bra	lk5brk
@@:
	addq.l	#1,a6			; 000001111x
	move.b	#' ',1(a6)		;エンドコード解除
	move.b	#' ',2(a6)
	move.b	#' ',3(a6)
	move.b	#' ',4(a6)
	clr.b	5(a6)			;新エンドコード
lk5brk:	rts

*********************************************************
*
*	bin_adecの出力を６桁左詰めに変換
*
*		入力	a6.l	文字列先頭アドレス
*		リターンa6.l	変換後の文字列先頭アドレス
*
*********************************************************
left6keta:
*     0000111111
* (a6)^  4^
	addq.l	#4,a6			; 0000x11111
	cmp.b	#' ',(a6)		;６桁の位置が空白なら処理を開始
	bne	lk6brk

	addq.l	#1,a6			; 00001x1111
	cmp.b	#' ',(a6)		;５桁の位置も空白なら３桁処理へ
	beq	@f
	move.b	#' ',5(a6)		;エンドコード解除
	clr.b	6(a6)			;新エンドコード
	bra	lk6brk
@@:
	addq.l	#1,a6			; 000011x111
	cmp.b	#' ',(a6)		;４桁の位置も空白なら３桁処理へ
	beq	@f
	move.b	#' ',4(a6)		;エンドコード解除
	move.b	#' ',5(a6)
	clr.b	6(a6)			;新エンドコード
	bra	lk6brk
@@:
	addq.l	#1,a6			; 0000111x11
	cmp.b	#' ',(a6)		;３桁の位置も空白なら２桁処理へ
	beq	@f
	move.b	#' ',3(a6)		;エンドコード解除
	move.b	#' ',4(a6)
	move.b	#' ',5(a6)
	clr.b	6(a6)			;新エンドコード
	bra	lk6brk
@@:
	addq.l	#1,a6			; 00000111x1
	cmp.b	#' ',(a6)		;２桁の位置も空白なら１桁処理へ
	beq	@f
	move.b	#' ',2(a6)		;エンドコード解除
	move.b	#' ',3(a6)
	move.b	#' ',4(a6)
	move.b	#' ',5(a6)
	clr.b	6(a6)			;新エンドコード
	bra	lk6brk
@@:
	addq.l	#1,a6			; 000001111x
	move.b	#' ',1(a6)		;エンドコード解除
	move.b	#' ',2(a6)
	move.b	#' ',3(a6)
	move.b	#' ',4(a6)
	move.b	#' ',5(a6)
	clr.b	6(a6)			;新エンドコード
lk6brk:	rts

*********************************************************
*
*	走行モード切り替え
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
*	テキスト画面消去
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
*	ＢＧ画面消去
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
*	文字列比較
*		入力	a0.l	比較文字列１
*			a1.l	比較文字列２
*
*********************************************************
strcmp:
*	movem.l	a0-a1,-(sp)

	tst.b	(a1)			;比較文字列は終わりか？
	beq	strcmp0			;そうであればループを抜ける
	cmpm.b	(a1)+,(a0)+		;1文字比較
	beq	strcmp			;一致している間繰り返す

*	movem.l	(sp)+,a0-a1
	rts				;一致しなかった

strcmp0:
	cmpm.b	(a1)+,(a0)+		;ラストチャンス

*	movem.l	(sp)+,a0-a1
	rts

*********************************************************
*
*	文字列の長さを数える
*		入力	a0.l	文字列先頭アドレス
*		リターンd0.l	長さ
*
*********************************************************
strlen:
	moveq.l	#-1,d0			;カウンタの初期化
strlen0:
	addq.l	#1,d0			;カウント
	tst.b	(a0,d0.l)		;終了コードか？
	bne	strlen0			;そうでなければ繰り返す

	rts


************************************************
*
*	テキストに点描画（１６色対応）
*		入力	d1.w = Ｘ座標
*			d2.w = Ｙ座標
*			d5.w = カラー
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
*	テキスト矩形塗り潰し（１６色対応）
*		入力	d1.w = 左上Ｘ座標
*			d2.w = 左上Ｙ座標
*			d3.w = Ｘサイズ
*			d4.w = Ｙサイズ
*			d5.w = カラー
*
************************************************
text_fill:
	movem.l	d2/d4/d7,-(sp)
	move.w	d3,d7			;d0.w=Ｘサイズ
	move.w	d1,d6			;d6.w=左端Ｘ座標

tfly:					;┌Ｙサイズ回ループ
tflx:					;　┌Ｘサイズ回ループ
	bsr	text_pset		;　　点を打つ
	addq.w	#1,d1			;　　Ｘ座標インクリメント
	dbra	d3,tflx			;　└─

	move.w	d7,d3			;　Ｘサイズリセット
	move.w	d6,d1			;　Ｘ座標リセット
	addq.w	#1,d2			;　Ｙ座標インクリメント
	dbra	d4,tfly			;└─

	movem.l	(sp)+,d2/d4/d7
	rts

************************************************
*
*	座標からテキストＶＲＡＭアドレスとビット位置を算出
*		入力	d1.w = Ｘ座標
*			d2.w = Ｙ座標
*		リターンa0.l = アドレス
*			d3.w = ビット番号
*
************************************************
xy_to_address:
	movem.l	d1-d2/d4,-(sp)

	movea.l	#$e00000,a0

	mulu.w	#1024/8,d2		;Ｙ座標加算
	adda.l	d2,a0

	andi.l	#$0000ffff,d1
	divu.w	#8,d1			;８で割る
	adda.w	d1,a0

	moveq.l	#0,d3
	swap.w	d1			;余りを取り出す
	move.w	d1,d4			;７－（８で割った余り）＝ビット番号
	move.w	#7,d3
	sub.w	d4,d3

	movem.l	(sp)+,d1-d2/d4
	rts

************************************************
*
*	テキスト描画色を設定
*		入力	d5.w = カラー（０～１５）
*
************************************************
set_text_color:
	movem.l	d5,-(sp)

	rol.b	#4,d5			;0000_XXXX → XXXX_0000
	add.w	#%01_0000_0000,d5
	move.w	d5,$e8002a		;同時アクセス設定

	movem.l	(sp)+,d5
	rts

************************************************
*
*	キーを離すまで待つ
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
*	スプライトを消す
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
*	子プロセス起動
*
************************************************
child:
	link	a6,#-512		;512バイトのローカルエリア
	movem.l	d1-d7/a0-a6,-(sp)

	movea.l	8(a6),a1		;与えられた文字列を
	lea.l	-512(a6),a0		;　ローカルエリアに
	move.w	#255-1,d0		;　最大255バイト
chld0:	move.b	(a1)+,(a0)+		;　コピーしておく
	dbeq	d0,chld0		;∵上書きされるから
	clr.b	(a0)			;念のための終端コード

	clr.l	-(sp)			;自分の環境
	pea.l	-256(a6)		;パラメータ部格納領域
	pea.l	-512(a6)		;コマンドライン兼
					;　フルパス名格納領域
	move.w	#2,-(sp)		;PATH検索
	DOS	_EXEC			;
	tst.l	d0			;d0.lが負なら
	bmi	chld1			;　エラー

	clr.w	(sp)			;ロード＆実行
	DOS	_EXEC			;
chld1:	lea	14(sp),sp		;スタック補正 4*3+2バイト

	movem.l	(sp)+,d1-d7/a0-a6
	unlk	a6
	rts


************************************************
*
*	標準出力／標準エラー出力をリダイレクト
*
************************************************
con_off:
	movem.l	d0-d1,-(sp)

	move.w	#ARCHIVE,-(sp)		;指定されたファイルを
	pea.l	filnam			;　新規作成する
	DOS	_CREATE			;
	addq.l	#6,sp			;
	tst.l	d0			;エラー？
	bpl	wopen0			;　エラーがなければオープン完了

	move.w	#WOPEN,-(sp)		;createでエラーが発生したときは
	pea.l	filnam			;　openを使って
	DOS	_OPEN			;　もう一度ライトオープンしてみる
	addq.l	#6,sp			;
	tst.l	d0			;エラー？
	bmi	ns_end			;　そうなら今度こそエラー終了

wopen0:	move.w	d0,d1			;d1.w=出力先ファイルハンドル

	move.w	#STDOUT,-(sp)		;オープンしたファイルハンドルを
	move.w	d1,-(sp)		;　標準出力に
	DOS	_DUP2			;　強制コピー
	addq.l	#4,sp			;
	tst.l	d0			;エラー？
	bmi	ns_end			;　そうならエラー終了

	move.w	#STDERR,-(sp)		;オープンしたファイルハンドルを
	move.w	d1,-(sp)		;　標準エラー出力に
	DOS	_DUP2			;　強制コピー
	addq.l	#4,sp			;
	tst.l	d0			;エラー？
	bmi	ns_end			;　そうならエラー終了

	move.w	d1,-(sp)		;いまオープンしたファイルハンドルは
	DOS	_CLOSE			;　もういらないから
	addq.l	#2,sp			;　クローズしてしまう
ns_end:
	movem.l	(sp)+,d0-d1
	rts

filnam:	.dc.b	'NUL',0
	.even


************************************************
*
*	標準出力／標準エラー出力を元に戻す
*
************************************************
con_on:
	move.w	#STDOUT,-(sp)		;標準出力をクローズ
	DOS	_CLOSE			;（割り当てはconに戻る）
	addq.l	#2,sp			;
	move.w	#STDERR,-(sp)		;標準エラー出力をクローズ
	DOS	_CLOSE			;（割り当てはconに戻る）
	addq.l	#2,sp			;

	rts


	.end
