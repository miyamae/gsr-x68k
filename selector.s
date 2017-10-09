*********************************************************
*
*
*
*
*	ＧＳＲ	セレクタモード
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

GPIP		equ	$e88001		;GPIPレジスタ
R00		equ	$e80000		;水平トータル
R01		equ	$e80002		;水平同期終了位置
R02		equ	$e80004		;水平表示開始位置
R03		equ	$e80006		;水平表示終了位置
R04		equ	$e80008		;垂直トータル
R05		equ	$e8000a		;垂直同期終了位置
R06		equ	$e8000c		;垂直表示開始位置
R07		equ	$e8000e		;垂直表示終了位置
R20		equ	$e80028		;メモリモード／表示モード制御
R21		equ	$e8002a		;同時ｱｸｾｽ/ﾗｽﾀｺﾋﾟｰ/高速ｸﾘｱﾌﾟﾚｰﾝ選択
R22		equ	$e8002c		;ラスタコピー動作用
R23		equ	$e8002e		;テキスト画面アクセスマスクパタン
CRTC		equ	$e80480		;画像取り込み/高速ｸﾘｱ/ﾗｽﾀｺﾋﾟｰ制御
TVRAM		equ	$e00000		;T-VRAMアドレス
TPALET		equ	$e82200		;テキストパレットアドレス
PCG		equ	$eb8000		;PCG領域アドレス

*---------------------------------------*
*ラスタコピー開始
RASCST	.macro
	.local	rs_lp
	ori.w	#$0700,sr		;割り込み禁止
rs_lp:	btst.b	#7,GPIP
	beq	rs_lp
	move.w	#%1000,CRTC		;ラスタコピー開始
	.endm
*---------------------------------------*
*ラスタコピー停止
RASCEND	.macro
	.local	re_lp
re_lp:	btst.b	#7,GPIP
	beq	re_lp
	move.w	#%0000,CRTC		;ラスタコピー停止
	andi.w	#$f8ff,sr		;割り込み許可
	.endm
*---------------------------------------*

	.text
	.even

music_selector:
*	jsr	scroll_down
*********************************************************
*
*	初期設定
*
*********************************************************
	move.b	#1,kbclr_flag

*---------------------------------------*
*初めてのセレクタ起動
	tst.b	sel_fstart_flg		;初めての起動か
	beq	2f
	clr.b	sel_fstart_flg
	bsr	init_cd

	move.l	drive,d1		;
	move.w	d1,-(sp)		;
	DOS	_CHGDRV			;
	addq.l	#2,sp			;
	subq.l	#1,d0			;
	move.l	d0,drive_max		;LAST DIRVE番号を登録
*	move.l	#2,drive_max		;LAST DIRVE番号を登録
2:
*********************************************************
*
*	メインループ
*
*********************************************************
ms_loop:
	tst.b	kbclr_flag
	bne	ttl_end

	tst.b	ttl
	beq	ttl_end
	move.w	fno,d0

	bsr	set_title		;曲タイトルを読み込む
	bsr	print_title		;曲タイトルを表示
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
*キーバッファクリア
	tst.b	kbclr_flag
	beq	@@f
	IOCS	_B_KEYSNS
	tst.l	d0
	beq	@f
	IOCS	_B_KEYINP
	bra	s_break
@@:	clr.b	kbclr_flag
*---------------------------------------*
*キー入力チェック
@@:	IOCS	_B_KEYSNS
	tst.l	d0
	beq	s_break
	move.b	#1,kbclr_flag
	IOCS	_B_KEYINP
	lsr.w	#8,d0
*---------------------------------------*
@@:	cmp.b	#$01,d0			;[ESC]=終了
	bne	@f
	tst.b	mode			;パネルモードなら
	beq	1f			;
	jsr	scroll_down		;
	jmp	return_display		;
1:	jmp	quit			;セレクタモードなら

@@:	cmp.b	#$6c,d0			;[F10]=終了
	bne	@f
	tst.b	mode			;パネルモードなら
	beq	1f			;
	jsr	scroll_down		;
	jmp	return_display		;
1:	jmp	quit			;セレクタモードなら
*---------------------------------------*
@@:	cmp.b	#$10,d0			;[TAB]=演奏停止終了
	bne	@f
	tst.b	mode			;パネルモードなら
	beq	1f			;
	jsr	scroll_down		;
	jmp	return_display		;
1:	jmp	stop_and_quit		;セレクタモードなら

@@:	cmp.b	#$6b,d0			;[F9]=演奏停止終了
	bne	@f
	tst.b	mode			;パネルモードなら
	beq	1f			;
	jsr	scroll_down		;
	jmp	return_display		;
1:	jmp	stop_and_quit		;セレクタモードなら
*---------------------------------------*
@@:	cmp.b	#$3e,d0			;[↓]=カーソル下移動
	bne	@f
	bsr	cur_down
	bra	s_break
@@:	cmp.b	#$3c,d0			;[↑]=カーソル上移動
	bne	@f
	bsr	cur_up
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$38,d0			;[ROLLUP]=１ページ進める
	bne	@f
	bsr	roll_up
	bra	s_break
@@:	cmp.b	#$39,d0			;[ROLDWN]=１ページ戻す
	bne	@f
	bsr	roll_down
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$37,d0			;[DEL]=ディレクトリ最後へ
	bne	@f
	bsr	go_end_dir
	bra	s_break
@@:	cmp.b	#$36,d0			;[HOME]=ディレクトリ先頭へ
	bne	@f
	bsr	go_top_dir
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$3f,d0			;[CLR]=一時停止／演奏開始トグル
	bne	@f
	jsr	stop_or_play
	bra	s_break
@@:	cmp.b	#$0f,d0			;[BS]=一時停止／演奏開始トグル
	bne	@f
	jsr	stop_or_play
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$40,d0			;t[/]=演奏停止
	bne	@f
	IOCS	_B_SFTSNS
	btst.l	#0,d0			;[SHIFT]+t[/]=フェードアウト
	beq	1f
	jsr	fade_out
	bra	s_break
1:	jsr	music_end
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$41,d0			;t[*]=再演奏開始
	bne	@f
	jsr	replay
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$1d,d0			;[RET]=演奏開始
	bne	@f
	IOCS	_B_SFTSNS
	bsr	exec
	btst.l	#0,d0			;[SHIFT]+[RET]=演奏開始＆パネル
	beq	@f
	jsr	scroll_down
	jmp	start_display
@@:	cmp.b	#$4e,d0			;[ENTER]=演奏開始
	bne	@f
	IOCS	_B_SFTSNS
	bsr	exec
	btst.l	#0,d0			;[SHIFT]+[ENTER]=演奏開始＆パネル
	beq	@f
	jsr	scroll_down
	jmp	start_display
*---------------------------------------*
@@:	cmp.b	#$35,d0			;[SPACE]=カーソル位置マーク反転
	bne	@f
	bsr	mark_cur
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$1e,d0			;[A]=全ファイルマーク反転
	bne	@f
	bsr	mark_all
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$3d,d0			;[→]=親ディレクトリへ移動
	bne	@f
	IOCS	_B_SFTSNS
	btst.l	#1,d0			;[CTRL]+[→]=ドライブ＋＋
	beq	1f
	bsr	drive_inc
	bra	s_break
1:	btst.l	#2,d0			;[OPT1]+[→]=ドライブ＋＋
	beq	1f
	bsr	drive_inc
	bra	s_break
1:	bsr	cd2parent
	bra	s_break
@@:	cmp.b	#$3b,d0			;[←]=親ディレクトリへ移動
	bne	@f
	IOCS	_B_SFTSNS
	btst.l	#1,d0			;[CTRL]+[←]=ドライブ－－
	beq	1f
	bsr	drive_dec
	bra	s_break
1:	btst.l	#2,d0			;[OPT1]+[←]=ドライブ－－
	beq	1f
	bsr	drive_dec
	bra	s_break
1:	bsr	cd2parent
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$0e,d0			;[\]=ルートディレクトリへ移動
	bne	@f
	bsr	cd2root
	bra	s_break
*---------------------------------------*
@@:	cmp.b	#$42,d0			;t[-]=ディスプレイモード
	bne	@f
	jsr	scroll_down
	tst.b	fstart_flag
	bne	1f
	jmp	return_display
1:	jmp	start_display
*---------------------------------------*
@@:	cmp.b	#$4f,d0			;テンキー=ドライブチェンジ
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
*	ファイル名一覧表示
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
*	ファイル名表示（d0.w=ファイル管理番号）
*
*********************************************************
print_fname:
	movem.l	d0-d2/d6-d7/a1-a2/a6,-(sp)

	cmp.w	file_c,d0		;存在しないファイル管理番号
	bge	pn_end			;

	move.w	rolpos,d1		;表示画面中に納まる項目か？
	cmp.w	d0,d1			;
	bgt	pn_end			;
	addi.w	#WIDTH,d1		;
	cmp.w	d0,d1			;
	ble	pn_end			;

	move.w	#%01_1111_0000,R21	;マークファイルか
	lea.l	fmark,a0		;
	tst.b	0(a0,d0.w)		;
	beq	@f			;
	move.w	#%01_0010_0000,R21	;
@@:
	lea.l	files,a1		;ワーク位置を決定
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			:*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a1			;

	move.l	d0,d1
	pea.l	namck_buf		;ファイル名展開
	move.l	a1,-(sp)		;
	DOS	_NAMECK			;
	addq.l	#8,sp			;

	lea.l	ncbuf_name,a6		;ファイル名表示
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

	lea.l	ncbuf_ext,a6		;拡張子表示
	moveq.l	#1+13,d6		;
	jsr	prs_print_12x16		;

pn_end:
	movem.l	(sp)+,d0-d2/d6-d7/a1-a2/a6
	rts

*********************************************************
*
*	曲タイトルを得てワークに格納（d0.w=ファイル管理番号）
*
*********************************************************
set_title:
	movem.l	d0-d1/d5-d7/a0-a3/a6,-(sp)

	cmp.w	file_c,d0		;存在しないファイル管理番号
	bge	st_end			;

	lea.l	ftdone,a1		;すでに検索終了している
	tst.b	0(a1,d0.w)		;
	bne	st_end			;

	move.b	#1,0(a1,d0.w)		;タイトル検索が終了したフラグＯＮ

	lea.l	files,a1		;ワーク位置を決定
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			:*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a1			;

	lea.l	fnbuf,a2		;調べたいファイル名をセット
@@:	move.b	(a1)+,(a2)+		;
	bne	@b			;

	lea.l	titles,a3		;書き込むワーク位置を決定
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=65
	lsl.w	#6,d1			;*
	add.w	d2,d1			;*
	adda.l	d1,a3			;

	lea.l	ftype,a1		;ディレクトリか？
	move.w	d0,d1			;
	tst.b	0(a1,d1.w)		;
	beq	st_fmode		;

	lea.l	fnbuf,a0		;<..>か？
	cmpi.b	#'.',(a0)		;
	bne	st_wdir			;
	cmpi.b	#'.',1(a0)		;
	bne	st_wdir			;
	tst.b	2(a0)			;
	bne	st_wdir			;
@@:	lea.l	mes_parent,a2		;　'<parent dir>'を書き込む
@@:	move.b	(a2)+,(a3)+		;
	bne	@b			;
	bra	st_end
st_wdir:
	lea.l	mes_dir,a2		;'<dir>'を書き込む
@@:	move.b	(a2)+,(a3)+		;
	bne	@b			;
	bra	st_end

st_fmode:				;ファイルだった場合
	clr.w	-(sp)
	pea.l	fnbuf
	DOS	_OPEN
	addq.l	#6,sp
	move.l	d0,d7			;d7=ファイルハンドル
	tst.l	d7
	bge	@f
	clr.b	(a3)			;エラーが発生した場合
	bra	st_end
@@:
*---------------------------------------*
1:
	lea.l	fnbuf,a0
@@:	tst.b	(a0)+			;a0.l=ファイル名の最後
	bne	@b			;
	subq.l	#1,a0
@@:	cmp.b	#'.',-(a0)		;a0.l=ファイル名の拡張子位置
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

	tst.b	5(a6)			;モード０
	bne	1f			;
	move.b	6(a6),ttlpos		;
	move.b	7(a6),ttllen		;
	bra	@f
1:
	clr.b	ttlpos			;モード０以外
	move.b	#$ff,ttllen		;
@@:
*---------------------------------------*

	moveq.l	#0,d5
	moveq.l	#0,d6
	move.b	ttlpos,d5		;d5.b=タイトルのある位置
	move.b	ttllen,d6		;d6.b=タイトルの長さ

	clr.w	-(sp)			;タイトル位置へシーク
	move.l	d5,-(sp)		;
	move.w	d7,-(sp)		;
	DOS	_SEEK			;
	addq.l	#8,sp			:

	lea.l	buf,a2			;仮Bufに書き込む
	move.l	d6,-(sp)		;
	move.l	a2,-(sp)		;
	move.w	d7,-(sp)		;
	DOS	_READ			;
	lea.l	10(sp),sp		;
*	clr.b	64(a2)			;

	move.w	d7,-(sp)
	DOS	_CLOSE
	addq.l	#2,sp

	tst.b	5(a6)			;モード０
	bne	1f

	move.w	#64-1,d1
@@:	move.b	(a2)+,(a3)+		;　タイトルを書き込む
	dbeq	d1,@b			;
	clr.b	(a3)			;
	bra	st_end

1:					;モード１(SMF)

	clr.b	(a3)
@@:	cmp.l	#buf+256,a2
	bge	st_end
	cmpi.b	#$ff,(a2)+		;　$ff03検索
	bne	@b			;
	cmpi.b	#$03,(a2)+		;
	bne	@b			;
	clr.w	d1
	move.b	(a2)+,d1
	subq.b	#1,d1
@@:	move.b	(a2)+,(a3)+		;　タイトルを書き込む
	dbeq	d1,@b			;
	clr.b	(a3)			;

st_end:
	movem.l	(sp)+,d0-d1/d5-d7/a0-a3/a6
	rts

*********************************************************
*
*	曲タイトル表示（d0.w=ファイル管理番号）
*
*********************************************************
print_title:
	movem.l	d0-d2/d6-d7/a6,-(sp)

	cmp.w	file_c,d0		;存在しないファイル管理番号
	bge	pt_end			;

	move.w	rolpos,d1		;表示画面中に納まる項目か？
	cmp.w	d0,d1			;
	bgt	pt_end			;
	addi.w	#WIDTH,d1		;
	cmp.w	d0,d1			;
	ble	pt_end			;

	lea.l	ftdone,a1		;まだ検索終了していない
	tst.b	0(a1,d0.w)		;
	bne	@f			;
	bsr	set_title		;　タイトル検索する
@@:
	move.w	#%01_1111_0000,R21	;マークファイルか
	lea.l	fmark,a0		;
	tst.b	0(a0,d0.w)		;
	beq	@f			;
	move.w	#%01_0010_0000,R21	;
@@:
	lea.l	titles,a6		;読み出すワーク位置を決定
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=65
	lsl.w	#6,d1			;*
	add.w	d2,d1			;*
	adda.l	d1,a6			;

	move.l	#20,d6			;d6=表示Ｘ座標
	moveq.l	#WINPOS-1,d7		;d7=表示Ｙ座標
	add.w	d0,d7			;
	sub.w	rolpos,d7		;
	move.w	d7,d2			;* d7*=20
	lsl.w	#4,d7			;*
	add.w	d2,d2			;*
	add.w	d2,d2			;*
	add.w	d2,d7			;*
	addi.w	#512+17,d7		;
	jsr	prs_print_12x16		;表示

pt_end:
	movem.l	(sp)+,d0-d2/d6-d7/a6
	rts

*********************************************************
*
*	曲タイトル一覧表示
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
*	カーソル表示／消去
*
*********************************************************
put_cur:
	movem.l	d0-d1/a0,-(sp)

	movea.l	#(TVRAM+128*512)+128*34,a0
	move.w	curpos,d1
	addq.w	#1,d1
	mulu.w	#128*20,d1
	adda.l	d1,a0

*	move.w	#%01_1111_0000,R21	;カーソル表示
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

	move.w	#%01_1111_0000,R21	;カーソル消去
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
*	カーソル上下移動
*
*********************************************************
cur_up:
	move.l	d0,-(sp)

	move.w	curpos,d0		;カーソル位置が０か
	add.w	rolpos,d0		;
	tst.w	d0			;
	ble	cu_end			;

	tst.w	rolpos			;スクロール位置が０か
	ble	1f			;
	cmp.w	#4,curpos		;
	bmi	2f			;
1:
	bsr	kill_cur		;カーソル移動
	subq.w	#1,curpos		;
	bsr	put_cur			;
	bra	cu_end			;
2:
	bsr	roll_1down		;ロールダウン
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

	move.w	curpos,d0		;これ以上ファイルがないか
	add.w	rolpos,d0		;
	addq.w	#1,d0			;
	move.w	file_c,d1		;
	cmp.w	d0,d1			;
	ble	cd_end			;

	move.w	rolpos,d0		;ファイル残り４つ以下か
	add.w	curpos,d0		;
	move.w	file_c,d1		;
	subq.w	#4,d1			;
	cmp.w	d0,d1			;
	ble	1f			;
	cmp.w	#WIDTH-4,curpos		;
	bge	2f			;
1:
	bsr	kill_cur		;カーソル移動
	addq.w	#1,curpos		;
	bsr	put_cur			;
	bra	cd_end			;
2:
	bsr	roll_1up		;ロールアップ
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
*	１行スクロールアップ／ダウン
*
*********************************************************
roll_1up:
	movem.l	d1-d2,-(sp)

	bsr	kill_cur		;カーソルを消す

*	bsr	wait_vdisp		;スクロール処理
	move.w	#%1111,R21		;
	move.w	#$8d_88,d1		;
	move.w	#WIDTH*5-5,d2		;
@@:	move.w	d1,R22			;
	RASCST				;
	addi.w	#$01_01,d1		;
	dbra	d2,@b			;
	RASCEND				;

	move.b	#WIDTH-1,d0		;最下行を消す
	move.w	#%01_1111_0000,R21	;
	bsr	kill_line		;

	bsr	put_cur			;カーソルを表示する

	movem.l	(sp)+,d1-d2
	rts

*---------------------------------------*
roll_1down:
	movem.l	d1-d2,-(sp)

	bsr	kill_cur		;カーソルを消す

*	bsr	wait_vdisp		;スクロール処理
	move.w	#%1111,R21		;
	move.w	#$f7_fc,d1		;
	move.w	#WIDTH*5-5,d2		;
@@:	move.w	d1,R22			;
	RASCST				;
	subi.w	#$01_01,d1		;
	dbra	d2,@b			;
	RASCEND				;

	clr.b	d0			;最上行を消す
	move.w	#%01_1111_0000,R21	;
	bsr	kill_line		;

	bsr	put_cur			;カーソルを表示する

	movem.l	(sp)+,d1-d2
	rts

*********************************************************
*
*	１画面ロールアップ／ダウン
*
*********************************************************
roll_up:
	bsr	kill_cur		;カーソルを消す
	move.w	#WIDTH-3-1,curpos	;最下行(+3)にカーソルセット

	move.w	file_c,d1
	subi.w	#WIDTH,d1
	bge	1f

	move.w	file_c,d1		;ファイル数が１画面に満たなければ
	subq.w	#1,d1			;　ロールアップしない
	bmi	@f			;
	move.w	d1,curpos		;
	bra	4f			;
@@:	clr.w	curpos			;
	bra	4f			;
1:
	move.w	rolpos,d2		;
	cmp.w	d2,d1			;既にスクロール位置がMAXなら
	bgt	2f			;
	move.w	#WIDTH-1,curpos		;　最下行にカーソルセット
	bra	4f			;　ロールアップしない
2:
	addi.w	#WIDTH,d2		;ロールアップするとはみ出してしまう場合
	cmp.w	d2,d1			;
	bgt	@f			;
	move.w	d1,rolpos		;　スクロール位置を最下位置に補正
	move.w	#WIDTH-1,curpos		;　カーソル位置を最下行に補正
	bra	3f			;
@@:
	addi.w	#WIDTH-3,rolpos		;スクロール位置を変える
3:
	bsr	clr_win			;ウィンドウクリア
	bsr	print_files		;ファイル名一覧表示
	bsr	print_ttls		;曲タイトル一覧表示
4:
	bsr	put_cur			;カーソルを表示

	rts

*---------------------------------------*
roll_down:
	bsr	kill_cur		;カーソルを消す

	tst.w	rolpos			;既にスクロール位置が０なら
	bgt	@f			;
	clr.w	curpos			;　最上行にカーソルセット
	bra	3f			;　ロールダウンしない
@@:
	move.w	#3,curpos		;最上行(-3)にカーソルセット

	cmpi.w	#WIDTH-3,rolpos		;ロールダウンするとはみだしてしまう場合
	bgt	1f			;
	clr.w	rolpos			;　スクロール位置を０に補正
	clr.w	curpos			;　カーソル位置を０に補正
	bra	2f			;
1:
	subi.w	#WIDTH-3,rolpos		;スクロール位置を変える
2:
	bsr	clr_win			;ウィンドウクリア
	bsr	print_files		;ファイル名一覧表示
	bsr	print_ttls		;曲タイトル一覧表示
3:
	bsr	put_cur			;カーソルを表示

	rts

*********************************************************
*
*	ディレクトリ先頭／最後移動
*
*********************************************************
go_top_dir:
	bsr	kill_cur		;カーソルを消す

	clr.w	curpos			;カーソル位置   = 0

	tst.w	rolpos			;既にスクロール位置が先頭
	bgt	1f			;
	bra	2f			;
1:
	clr.w	rolpos			;スクロール位置 = 0
	bsr	clr_win			;ウィンドウクリア
	bsr	print_files		;ファイル名一覧表示
	bsr	print_ttls		;曲タイトル一覧表示
2:
	bsr	put_cur			;カーソルを表示

	rts

*---------------------------------------*
go_end_dir:
	move.l	d1,-(sp)

	bsr	kill_cur		;カーソルを消す

	move.w	#WIDTH-1,curpos		;カーソル位置   = max
	move.w	file_c,d1
	subi.w	#WIDTH,d1
	bge	1f

	move.w	file_c,d1		;ファイル数が１画面に満たない
	subq.w	#1,d1			;
	bmi	@f			;
	move.w	d1,curpos		;
	bra	3f			;
@@:	clr.w	curpos			;
	bra	3f			;
1:
	cmp.w	rolpos,d1		;既にスクロール位置が最後
	bgt	2f			;
	bra	3f			;
2:
	move.w	d1,rolpos		;スクロール位置 = max
	bsr	clr_win			;ウィンドウクリア
	bsr	print_files		;ファイル名一覧表示
	bsr	print_ttls		;曲タイトル一覧表示
3:
	bsr	put_cur			;カーソルを表示

	move.l	(sp)+,d1
	rts

*********************************************************
*
*	行を消す（d0.b=pos）
*
*********************************************************
kill_line:
	movem.l	d0-d2/a0,-(sp)

*	move.w	#%01_1111_0000,R21
	movea.l	#(TVRAM+128*512)+128*17,a0	;先頭アドレス設定
	move.l	#WINPOS-1,d1		;
	add.b	d0,d1			;
	mulu.w	#128*20,d1		;
	adda.l	d1,a0			;

	move.w	#16,d2			;０クリアする
@@:	.rept	16			;
	clr.l	(a0)+			;
	.endm				;
	adda.l	#64,a0			;
	dbra	d2,@b			;

	movem.l	(sp)+,d0-d2/a0
	rts

*********************************************************
*
*	ウィンドウ・クリア
*
*********************************************************
clr_win:
	movem.l	d0-d1,-(sp)

	move.w	#%01_1111_1111,R21
	clr.w	d0			;最上行を０クリア
	bsr	kill_line		;

	move.w	#$89_8d,d1		;クリアした行をラスタコピー
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
*	ディレクトリ中の位置を表示
*
*********************************************************
put_dirpos:
	movem.l	d0-d5/a6,-(sp)

*数値表示
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

*ポインタ表示
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
*	addi.l	#435,d2			;Ｘ座標
*
*	move.l	#16,d3			;Ｙ座標
*	move.l	#118,d1			;スプライトページ
*	bset.l	#31,d1			;垂直帰線期間検出なし
*	move.l	#$01+%0001_00_000000,d4	;パターンコード
*	moveq.l	#3,d5			;プライオリティ
*	IOCS	_SP_REGST

	movem.l	(sp)+,d0-d5/a6
	rts

*********************************************************
*
*	ファイル一覧を取る
*
*********************************************************
get_file_list:
	movem.l	d0-d2/a0-a3/a6,-(sp)

	lea.l	files,a2
	lea.l	ftype,a3

	clr.w	file_d_c
	clr.w	file_f_c
	clr.w	file_c

	tst.b	nofd_flg		;FD未挿入
	bne	flist_end

*---------------------------------------*
*ディレクトリ
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
	lea.l	fname,a0		;<.>ならスキップ
	cmpi.b	#'.',(a0)		;
	bne	@f			;
	tst.b	1(a0)			;
	beq	pd_skip			;
@@:
	move.b	#1,(a3)+		;FileType=dir

	lea.l	fname,a1
	lea.l	files,a2		;書き込むワーク位置を決定
	moveq.l	#0,d1			;
	move.w	file_c,d1		;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			:*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a2			;

@@:	move.b	(a1)+,(a2)+		;ワークに書き込む
	bne	@b			;
	add.w	#1,file_d_c
	add.w	#1,file_c
pd_skip:
	bra	s_dnext

s_file:
*---------------------------------------*
*ディレクトリソート
	moveq.l	#0,d1
	move.w	file_d_c,d1

	pea.l	_compare_str
	move.l	#24,-(sp)
	move.l	d1,-(sp)
	pea.l	files
	jsr	_qsort
	lea.l	16(sp),sp

*---------------------------------------*
*ファイル
	lea.l	ext,a6
s_fstart:
@@:	cmpi.b	#$ff,(a6)		;次の拡張子文字列位置に移動
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
	lea.l	files,a2		;書き込むワーク位置を決定
	moveq.l	#0,d1			;
	move.w	file_c,d1		;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			;*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a2			;

@@:	move.b	(a1)+,(a2)+		;ワークに書き込む
	bne	@b			;

	add.w	#1,file_f_c
	add.w	#1,file_c
	bra	s_fnext

search_end:
*---------------------------------------*
*ファイルソート
	moveq.l	#0,d1
	move.w	file_f_c,d1

	moveq.l	#0,d0
	move.w	file_d_c,d0
	lea.l	files,a1		;ファイル名位置
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
*	親dirに移動した時のカーソル位置設定
*
*********************************************************
set_curpos:
	movem.l	d0-d2/a0-a2,-(sp)

	lea.l	files,a1
	moveq.l	#0,d2

	move.w	file_c,d0		;直前のdirと同じ名前を探す
	subq.w	#1,d0			;
2:	lea.l	dirname,a0		;
	movea.l	a1,a2			;
	jsr	strcmp			;　比較
	beq	@f			;　　一致したら抜ける
	movea.l	a2,a1			;
	adda.l	#24,a1			;　a1.l=次のファイル名位置
	addq.w	#1,d2			;　d2.w=ファイル管理番号++
	dbra	d0,2b			;
	tst.b	d0			;　念のため最後まで見つからなければ
	ble	sc_end			;　　抜ける
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
*	ディレクトリが変わった時の処理
*
*********************************************************
init_cd:
	movem.l	d0-d3/a0-a1,-(sp)

*配列初期化
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

*変数初期化
	move.b	#1,ttl
	clr.w	fno
	clr.w	mark_c
	clr.w	curpos
	clr.w	rolpos

	bsr	get_file_list
*
	moveq.l	#0,d1			;ファイル数の表示
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

	tst.b	nofd_flg		;-FD未挿入- 表示
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
	DOS	_CURDRV			;カレントドライブを得る
	move.l	d0,drive		;
	pea	pathbuf			;カレントパスを得る
	clr.w	-(sp)			;
	DOS	_CURDIR			;
	addq.l	#6,sp			;

	lea.l	pathbuf,a1		;pathにカレントパス文字列を作る
	lea.l	path,a2			;
	lea.l	drive_data,a3		;　ドライブ名を付ける
	move.l	drive,d1		;
	move.b	0(a3,d1.l),(a2)+	;
	move.b	#':',(a2)+		;
	move.b	#PATHCHARA,(a2)+	;　ルートの / を付ける
1:	cmp.b	#'\',(a1)		;　\ を / に置き換える
	bne	@f			;
	move.b	#PATHCHARA,(a2)+	;
	addq.l	#1,a1			;
@@:	move.b	(a1)+,(a2)+		;
	bne	1b			;
2:
	SPRINT	#005,#512+019,#mes_43space
	SPRINT	#005,#512+019,#path	;パス表示

	tst.b	topar_flg		;親ディレクトリへの移動ならその処理
	beq	@f			;
	clr.b	topar_flg		;
	bsr	set_curpos		;
@@:
	bsr	clr_win

	bsr	print_files		;ファイル一覧の表示

*	move.w	rolpos,d0		:タイトル一覧の表示
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
*	ディレクトリ移動（a0.l=移動したいディレクトリ名）
*
*********************************************************
change_dir:
	movem.l	d0-d1/a0-a2,-(sp)

	lea.l	path,a1			;直前にいたディレクトリ名を記憶
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
	DOS	_CHDIR			;カレントパス移動
	addq.l	#4,sp

	cmpi.b	#'.',(a0)		;<..>か？
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
*	ロード＆演奏
*
*********************************************************
load_and_play:
	movem.l	d0-d1/a0-a2/a6,-(sp)

	lea.l	files,a1		;ワーク位置を決定
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			:*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a1			;

	lea.l	fnbuf,a2		;調べたいファイル名をセット
@@:	move.b	(a1)+,(a2)+		;
	bne	@b			;

	lea.l	fnbuf,a0
@@:	tst.b	(a0)+			;a0.l=ファイル名の最後
	bne	@b			;
	subq.l	#1,a0
@@:	cmp.b	#'.',-(a0)		;a0.l=ファイル名の拡張子位置
	bne	@b			;

*---------------------------------------*
*コマンドライン文字列を作る

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
	jsr	con_off			;コンソール出力 OFF
	pea.l	comline			;実行
	jsr	child			;
	addq.l	#4,sp			;
	jsr	con_on			;コンソール出力 ON
	SSPRINT	#024,#512+006,#mes_messpc

	movem.l	(sp)+,d0-d1/a0-a2/a6
	rts

*********************************************************
*
*	実行
*
*********************************************************
exec:
	movem.l	d0/a2,-(sp)

	tst.w	file_c			;ファイルが無いドライブ？
	beq	exec_end		;

	move.w	curpos,d0
	add.w	rolpos,d0

	lea.l	ftype,a2		;ディレクトリか
	tst.b	0(a2,d0.w)		;
	beq	@f			;

	lea.l	files,a0		;a0=ディレクトリ名
	moveq.l	#0,d1			;
	move.w	d0,d1			;
	move.w	d1,d2			;* d1*=24
	lsl.w	#3,d1			:*
	lsl.w	#4,d2			;*
	add.w	d2,d1			;*
	adda.l	d1,a0			;
	bsr	change_dir		;ディレクトリ移動
	bra	exec_end		;
@@:
	bsr	load_and_play		;ロード＆演奏
	bsr	cur_down		;カーソルをひとつ進める
exec_end:
	movem.l	(sp)+,d0/a2
	rts

*********************************************************
*
*	マーク数表示
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
*	マーク反転処理（d0.w=ファイル管理番号）
*
*********************************************************
file_mark:
	movem.l	d0/a0,-(sp)

	lea.l	ftype,a0		;ディレクトリならマークしない
	tst.b	0(a0,d0.w)		;
	bne	2f			;

	lea.l	fmark,a0
	tst.b	0(a0,d0.w)
	bne	1f
	move.b	#1,0(a0,d0.w)		;マークをセット
	addq.w	#1,mark_c		;
	bra	2f
1:
	clr.b	0(a0,d0.w)		;マークを消す
	subq.w	#1,mark_c		;
2:
	movem.l	(sp)+,d0/a0
	rts

*********************************************************
*
*	カーソル位置マーク反転
*
*********************************************************
mark_cur:
	movem.l	d0-d1/a0/a6,-(sp)

	tst.w	file_c			;ファイルが１つもなければスキップ
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
*	全ファイルマーク反転
*
*********************************************************
mark_all:
	move.l	d0,-(sp)

	move.w	file_c,d0
	tst.w	d0			;ファイルが１つもなければスキップ
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
*	ルートディレクトリへ移動
*
*********************************************************
cd2root:
	move.l	a0,-(sp)

	tst.w	file_c			;ファイルが１つもなければスキップ
	beq	9f			;
	lea.l	path,a0			;カレントがルートならスキップ
	tst.b	3(a0)			;
	beq	9f			;

	lea.l	str_root_dir,a0
	bsr	change_dir
9:
	move.l	(sp)+,a0
	rts

*********************************************************
*
*	親ディレクトリへ移動
*
*********************************************************
cd2parent:
	move.l	a0,-(sp)

	tst.w	file_c			;ファイルが１つもなければスキップ
	beq	9f			;
	lea.l	path,a0			;カレントがルートならスキップ
	tst.b	3(a0)			;
	beq	9f			;

	lea.l	str_parent_dir,a0
	bsr	change_dir
9:
	move.l	(sp)+,a0
	rts

*********************************************************
*
*	ドライブ移動（d1.l=移動したいドライブ）
*
*********************************************************
change_drive:
	movem.l	d0-d2,-(sp)

	clr.b	nofd_flg

	move.l	d1,d2
	addi.l	#$00_01,d2
	move.w	d2,-(sp)		;FD未挿入？
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
*	ドライブインクリメント／デクリメント
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
*	データ領域
*
*********************************************************
	.data
	.even
i:		.dc.l	0
curpos:		.dc.w	0		;カーソル位置
rolpos:		.dc.w	0		;スクロール位置
file_c:		.dc.w	0		;ファイルの数
file_d_c:	.dc.w	0
file_f_c:	.dc.w	0
mark_c:		.dc.w	0		;マークファイルの数
fno:		.dc.w	0		;曲名検索処理中のファイルの管理番号
ttl:		.dc.b	0
sel_fstart_flg:	.dc.b	1
topar_flg:	.dc.b	0
cdf:		.dc.b	1		;カレントディレクトリチェンジフラグ
nofd_flg:	.dc.b	0		;カレントドライブにＦＤ未挿入フラグ
crlf:		.dc.b	CR,LF,0
chr_slash:	.dc.b	'/',0
*---------------------------------------*
*ファイル情報バッファ
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
*対応データ
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
drive:		.ds.l	1		;現在のドライブ番号
drive_max:	.ds.l	1		;最終ドライブ番号
path:		.ds.b	256		;現在のパス名
fnbuf:		.ds.b	256
buf:		.ds.b	256
dirname:	.ds.b	22		;直前にいたディレクトリ名
ttlpos:		.ds.b	1
ttllen:		.ds.b	1
com:		.ds.b	256
extbuf:		.ds.b	4
pathbuf:	.ds.b	65
comline:	.ds.b	256		;演奏コマンドのコマンドライン文字列
*---------------------------------------*
	.even
titles:		.ds.b	65*FILE_MAX	;タイトルバッファ
	.even
files:		.ds.b	24*FILE_MAX	;ファイル名バッファ
ftype:		.ds.b	FILE_MAX	;0=file 1=dir
ftdone:		.ds.b	FILE_MAX	;タイトル検索終了フラグ
fmark:		.ds.b	FILE_MAX	;ファイルマークフラグ
sortbuf:	.ds.b	FILE_MAX*4	;ファイル名ソートバッファ
sortbuf_end:
*---------------------------------------*


	.end
