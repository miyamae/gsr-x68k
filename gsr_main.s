*********************************************************
*
*
*
*
*	ＧＳＲ	version 1.12
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
*	初期設定
*
startup:
*********************************************************
	jsr	get_option		;オプション設定

*プログラム本体以降の余分なメモリを解放
	lea.l	16(a0),a0
	suba.l	a0,a1
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	DOS	_SETBLOCK
	addq.l	#8,sp
*---------------------------------------*
*起動チェック
startup_chk:
	jsr	_rcd_check		;RCD常駐チェック
	tst.l	_rcd
	beq	rcd_no_stay
	move.l	_rcd,a5			;a5=RCD先頭アドレス
	cmp.l	#RCD_VERSION,version(a5)	;RCDバージョンチェック
	bne	rcd_ver_err
*	cmp.b	#1,moduletype(a5)	;音源種類チェック
*	bne	gs_err
*	tst.l	act(a5)			;演奏中かチェック
*	beq	no_playing
	tst.b	fmt(a5)			;RCPかチェック
	beq	mcp_err
*---------------------------------------*
	move.l	sp,ssp_buf
	lea.l	u_sp,sp

	jsr	super_mode		;スーパーバイザモード
*---------------------------------------*
*カレントパスを登録
	DOS	_CURDRV
	move.l	d0,drive
	pea	pathbuf
	clr.w	-(sp)
	DOS	_CURDIR
	addq.l	#6,sp
*---------------------------------------*
*画面初期化
	move.w	#-1,d1			;現在のモードを退避
	IOCS	_CRTMOD
	move.l	d0,crt_mode
	move.w	#-1,-(sp)
	move.w	#14,-(sp)
	DOS	_CONCTRL
	addq.l	#2+2,sp
	move.w	d0,fn_mode

	move.w	#0,d1			;512x512 16色モード
	IOCS	_CRTMOD
	move.w	#3,-(sp)		;ファンクションキー行無視
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

*テキストパレット退避
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

*テキストパレット設定
	movea.l	#TPALET,a2
	move.w	#$0000,(a2)+		;０透明
	move.w	#$2e00,(a2)+		;１赤スライダー
	move.w	#$a88e,(a2)+		;２緑スライダー
	move.w	#$9e40,(a2)+		;３黄スライダー
	move.w	#$f83e,(a2)+		;４
	move.w	#$0001,(a2)+		;５黒文字
	move.w	#$f83e,(a2)+		;６青レベルメーター
	move.w	#$07c0,(a2)+		;７赤レベルメーター
	move.w	#$a032,(a2)+		;８水
	move.w	#$bec0,(a2)+		;９セレクタカーソル
	move.w	#$e73a,(a2)+		;１０明灰
	move.w	#$8425,(a2)+		;１１暗灰
	move.w	#$2202,(a2)+		;１２SC DISPLAY文字
	move.w	#$ffff,(a2)+		;１３
	move.w	#$ffff,(a2)+		;１４
	move.w	#$bdee,(a2)+		;１５白文字

*	bra	skip_spdef		;debug

*スプライトパレット定義
	lea.l	sprite_palett,a1
	adda.l	#16*2,a1
	move.w	#16*15-1,d1
@@:	move.w	(a1)+,(a2)+
	dbra	d1,@b
*スプライトパターン定義
	lea.l	sprite_pattern,a1
	movea.l	#PCG,a2
	move.w	#16*16*128/4-1,d1
@@:	move.l	(a1)+,(a2)+
	dbra	d1,@b
skip_spdef:

*パレット明るさ設定
	move.b	#DEF_LIGHT,light	;デフォルトセット

	pea.l	env_value		;環境変数を取り出す
	clr.l	-(sp)
	pea.l	env_str
	DOS	_GETENV
	lea.l	12(sp),sp
	tst.l	d0
	bgt	env_skip

	clr.w	d0			;文字列→数値変換
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
	addq.b	#1,d0			;明度値セット
	cmp.b	#31,d0
	bhi	env_skip
	move.b	d0,light
env_skip:

	movea.l	#TPALET,a2
	lea.l	lightflg_tbl,a1

	move.b	light,d0
	move.w	#32,d1
	sub.w	d0,d1

	move.w	d1,d0			;明るさをRGB変換
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#5,d1
	add.w	d0,d1
	lsl.w	#1,d1
pl_lp:
	cmp.b	#2,(a1)			;明るさ設定
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
	moveq.l	#0,d1			;バックグラウンド０
	moveq.l	#0,d2			;テキストページ１
	moveq.l	#1,d3			;表示ＯＮ
	IOCS	_BGCTRLST
	move.w	#%00__01_00_10__11_10_01_00,$e82500	;優先順位設定

*---------------------------------------*
	IOCS	_SP_OFF
	jsr	bg_clear
	jsr	sprite_off
	jsr	text_clear

*---------------------------------------*
*配列初期化
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
	jsr	make_hankaku_12x12	; 半角文字作成
	move.w	#%1_1_1111_0000,COLOR_12x12
	jsr	make_hankaku_12x16
	move.w	#%1_1_1111_0000,COLOR_12x16
*---------------------------------------*
	bsr	draw_mixer
*GSRロゴ
	move.l	#350,d2			;Ｘ座標
	move.l	#516,d3			;Ｙ座標
	move.l	#125,d1			;スプライトページ
	move.l	#$1e,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST
	move.l	#350+16,d2		;Ｘ座標
	move.l	#516,d3			;Ｙ座標
	move.l	#126,d1			;スプライトページ
	move.l	#$1f,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ

	IOCS	_SP_REGST
	move.l	#350,d2			;Ｘ座標
	move.l	#512+515,d3		;Ｙ座標
	move.l	#120,d1			;スプライトページ
	move.l	#$1e,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST
	move.l	#350+16,d2		;Ｘ座標
	move.l	#512+515,d3		;Ｙ座標
	move.l	#119,d1			;スプライトページ
	move.l	#$1f,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

*SELECTORロゴ
	move.l	#16+008,d2		;Ｘ座標
	move.l	#512+16+004,d3		;Ｙ座標
	move.l	#124,d1			;スプライトページ
	move.l	#$38,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST
	move.l	#16+008+16,d2		;Ｘ座標
	move.l	#512+16+004,d3		;Ｙ座標
	move.l	#123,d1			;スプライトページ
	move.l	#$39,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST
	move.l	#16+008+16*2,d2		;Ｘ座標
	move.l	#512+16+004,d3		;Ｙ座標
	move.l	#122,d1			;スプライトページ
	move.l	#$36,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST
	move.l	#16+008+16*3,d2		;Ｘ座標
	move.l	#512+16+004,d3		;Ｙ座標
	move.l	#121,d1			;スプライトページ
	move.l	#$7f,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
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
	move.b	#1,mode			;パネル専用モード

	tst.l	act(a5)			;演奏中かチェック
	bne	@f
	clr.b	mode			;セレクタモード
	bsr	scroll_up
	jmp	music_selector
@@:
start_display:
	tst.l	act(a5)			;演奏中かチェック
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
*総ステップ数表示
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
*総演奏時間表示
	SEG7	#35+2,#48,#mes_coron

	move.l	max_step,-(sp)
	jsr	_tm_caluc
	addq.l	#4,sp
	move.l	d0,max_time

	divu.w	#6000,d0
*分
	moveq.l	#0,d1
	move.w	d0,d1

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#4+4,sp
	lea.l	tbuf,a6
	addq.l	#8,a6			;２桁の位置にポインタ移動
	clr.b	2(a6)			;終端コード
	cmp.b	#' ',(a6)
	bne	@f
	move.b	#'0',(a6)
@@:
	SEG7	#35,#48,a6
*秒
	moveq.l	#0,d1
	swap.w	d0
	move.w	d0,d1

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#4+4,sp
	lea.l	tbuf,a6
	addq.l	#6,a6			;２桁の位置にポインタ移動
	clr.b	2(a6)			;終端コード
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
*トラック番号表示
	moveq.l	#1,d6			;数値表示Ｘ座標
	moveq.l	#0,d5
	move.w	ps_trk,d5
	move.w	#18-1,d1
draw_trk_lp:
	move.w	ps_trk,d5
	add.w	d1,d5
	pea.l	tbuf
	move.l	d5,d2
	addq.l	#1,d2
	move.l	d2,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#8,a6			;下２桁の位置にポインタをずらす
	move.l	d1,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#86,d7			;オフセットを加える
	jsr	print_4x8font

	dbra	d1,draw_trk_lp
*--------------------------------------*
	SSPRINT	#1,#373,#mes_master

*********************************************************
*
*	曲データの情報
*
data_info:
*********************************************************
	SSPRINT	#1,#38,#mes_rcp_info
	SSPRINT	#1,#54,#mes_status

*---------------------------------------*
*ファイル名表示
	move.w	#%01_1111_0000,R21
	SPRINT	#5,#19,#mes_64space
	move.w	#%01_1111_0000,R21
	SSPRINT	#1,#22,#mes_rcp_files
*ＲＣＰ
	movea.l	a5,a1
	adda.l	#filename,a1		;a1=ファイル名文字列先頭
	lea.l	tbuf,a2
	move.w	#30-1,d1
@@:
	move.b	(a1)+,(a2)+		;バッファに文字列コピー
	tst.b	(a1)
	beq	@f			;空白ならループを抜ける
	dbra	d1,@b
*ＧＳＤ
@@:
	move.b	#' ',(a2)+		;バッファに文字列コピー
	movea.l	a5,a1
	adda.l	#gsdname,a1
	move.w	#30-1,d1
@@:
	move.b	(a1)+,(a2)+		;バッファに文字列コピー
	tst.b	(a1)
	beq	@f			;空白ならループを抜ける
	dbra	d1,@b
*ＣＭ６
@@:
	move.b	#' ',(a2)+		;バッファに文字列コピー
	movea.l	a5,a1
	adda.l	#tonename,a1
	move.w	#30-1,d1
@@:
	move.b	(a1)+,(a2)+		;バッファに文字列コピー
	tst.b	(a1)
	beq	@f			;空白ならループを抜ける
	dbra	d1,@b
@@:
	clr.b	(a1)			;エンドコード書き込み
	lea.l	tbuf,a2
	SPRINT	#5,#19,a2

*---------------------------------------*
*曲名表示
	move.w	#%01_1111_0000,R21
	SSPRINT	#1,#6,#mes_rcp_title
	movea.l	a5,a1
	adda.l	#data_adr,a1
	movea.l	(a1),a1			;a1=RCPデータ先頭
	adda.l	#rcp_name,a1		;a1=曲名文字列先頭
	lea.l	tbuf,a2
	move.w	#64-1,d1
@@:	move.b	(a1)+,(a2)+		;バッファに文字列コピー
	dbra	d1,@b
	clr.b	(a1)			;エンドコード書き込み
	lea.l	tbuf,a2
	SPRINT	#5,#3,a2

*---------------------------------------*
*調表示
	move.w	#%01_1111_0000,R21
	movea.l	a5,a1
	adda.l	#data_adr,a1
	movea.l	(a1),a1			;a1=RCPデータ先頭
	adda.l	#rcp_key,a1		;a1=調コード格納アドレス
	moveq.l	#0,d1
	move.b	(a1),d1			;d1.b=調コード

	mulu.w	#4,d1
	lea.l	key,a0
	add.l	d1,a0
	SEG7	#9,#32,a0

*---------------------------------------*
*タイムベース表示
	movea.l	a5,a1
	adda.l	#data_adr,a1
	movea.l	(a1),a1			;a1=RCPデータ先頭
	adda.l	#rcp_tmbase,a1		;a1=タイムベース格納アドレス
	moveq.l	#0,d1
	move.b	(a1),d1			;d1.b=タイムベース値
	move.b	d1,timebase

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	jsr	left3keta
	SEG7	#17,#32,a6

*---------------------------------------*
*拍子表示
	moveq.l	#0,d1
	movea.l	data_adr(a5),a1		;a1=RCPデータ先頭
	move.b	rcp_rhythm0(a1),d1	;d1.b=拍子分子値

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a3
	lea.l	tbuf2,a4

	addq.l	#8,a3			;２桁の位置にポインタ移動
	cmp.b	#' ',(a3)
	beq	@f
	move.b	(a3),(a4)
	addq.l	#1,a4
@@:
	move.b	1(a3),(a4)
	move.b	#'/',1(a4)
	addq.l	#2,a4

	move.b	rcp_rhythm1(a1),d1	;d1.b=拍子分母値
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
	adda.l	#gs_info,a0		;a0.l=複写元
	lea.l	sc_mes,a1		;a1.l=複写先
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	lea.l	sc_mes,a6
	move.w	#46,d6			;d6.l=Ｘ座標
	move.w	#401,d7			;d7.l=Ｙ座標
	jsr	print_sc

*---------------------------------------*
*データレジスタ初期化
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
*---------------------------------------*












*		以上、初期設定











*---------------------------------------*
return_display:
	IOCS	_ONTIME
	move.l	d0,start_time			;起動時間セット
	move.l	d0,vel_ontime
	move.l	d0,lv_ontime
	move.l	d0,sp_ontime

	clr.b	flg_gsinst(a5)
	clr.b	flg_gspanel(a5)

	move.b	#1,kbclr_flag

*********************************************************
*
*	メインループ
*
loop:
*********************************************************
	tst.l	act(a5)			;演奏中かチェック
	bne	@f			;
	tst.b	mode			;パネル専用モードなら
	bne	quit			;　GSR終了
	bsr	scroll_up		;セレクタモードならセレクタ起動
	jmp	music_selector		;
@@:
*---------------------------------------*
	bsr	all_step
	tst.b	d0
	bne	restart

	bsr	brunch

*---------------------------------------*
*キーバッファクリア
@@:	tst.b	kbclr_flag
	beq	@@f
	IOCS	_B_KEYSNS
	tst.l	d0
	beq	@f
	IOCS	_B_KEYINP
	bra	break
@@:	clr.b	kbclr_flag
*---------------------------------------*
*キー入力チェック
@@:	IOCS	_B_KEYSNS
	tst.l	d0
	beq	break
	move.b	#1,kbclr_flag
	IOCS	_B_KEYINP
	lsr.w	#8,d0
*---------------------------------------*
@@:	cmp.b	#$01,d0			;[ESC]=終了
	bne	@f
	tst.b	mode			;パネル専用モードなら
	bne	quit			;　GSR終了
	bsr	scroll_up		;セレクタモードならセレクタ起動
	jmp	music_selector		;
@@:	cmp.b	#$6c,d0			;[F10]=終了
	bne	@f
	tst.b	mode			;パネル専用モードなら
	bne	quit			;　GSR終了
	bsr	scroll_up		;セレクタモードならセレクタ起動
	jmp	music_selector		;
*---------------------------------------*
@@:	cmp.b	#$10,d0			;[TAB]=演奏停止終了
	bne	@f
	bsr	music_end
	bra	break
@@:	cmp.b	#$37,d0			;[DEL]=演奏停止終了
	bne	@f
	bsr	music_end
	bra	break
@@:	cmp.b	#$6b,d0			;[F9]=演奏停止終了
	bne	@f
	bsr	music_end
	bra	break
@@:	cmp.b	#$40,d0			;t[/]=演奏停止終了
	bne	@f
	jsr	fade_out	**
*	IOCS	_B_SFTSNS
*	btst.l	#0,d0			;[SHIFT]+t[/]=フェードアウト
*	beq	1f
*	jsr	fade_out
*	bra	break
*1:	jsr	music_end
*	bra	break
*---------------------------------------*
@@:	cmp.b	#$3e,d0			;[↓]=メモ
	bne	@f
	bsr	memo_memo
	bra	break
*---------------------------------------*
@@:	cmp.b	#$3c,d0			;[↑]=トラックメモ
	bne	@f
	bsr	memo_trk_memo
	bra	break
*---------------------------------------*
@@:	cmp.b	#$36,d0			;[HOME]=モードトグル
	bne	@f
	bsr	memo_togle
	bra	break
@@:	cmp.b	#$64,d0			;[F2]=モードトグル
	bne	@f
	bsr	memo_togle
	bra	break
*---------------------------------------*
@@:	cmp.b	#$54,d0			;[HELP]=オンラインヘルプ
	bne	@f
	bsr	help
	bra	break
*---------------------------------------*
@@:	cmp.b	#$3d,d0			;[→]=オクターブアップ
	bne	@f
	cmpi.b	#48,note_shift
	beq	@f
	addi.b	#12,note_shift
	bsr	memo_note
	bra	break
@@:	cmp.b	#$6a,d0			;[F8]=オクターブアップ
	bne	@f
	cmpi.b	#48,note_shift
	beq	@f
	addi.b	#12,note_shift
	bsr	memo_note
	bra	break
*---------------------------------------*
@@:	cmp.b	#$3b,d0			;[←]=オクターブダウン
	bne	@f
	tst.b	note_shift
	beq	@f
	subi.b	#12,note_shift
	bsr	memo_note
	bra	break
@@:	cmp.b	#$69,d0			;[F7]=オクターブダウン
	bne	@f
	tst.b	note_shift
	beq	@f
	subi.b	#12,note_shift
	bsr	memo_note
	bra	break
*---------------------------------------*
@@:	cmp.b	#$3a,d0			;[UNDO]=早送り／演奏開始トグル
	bne	@f
	bsr	cue_or_play
	bra	break
*---------------------------------------*
@@:	cmp.b	#$3f,d0			;[CLR]=一時停止／演奏開始トグル
	bne	@f
	bsr	stop_or_play
	bra	break
*---------------------------------------*
@@:	cmp.b	#$0f,d0			;[BS]=一時停止／演奏開始トグル
	bne	@f
	bsr	stop_or_play
	bra	break
*---------------------------------------*
@@:	cmp.b	#$41,d0			;t[*]=再演奏開始
	bne	@f
	bsr	replay
	bra	break
*---------------------------------------*
@@:	cmp.b	#$42,d0			;t[-]=セレクタモード
	bne	@f
	bsr	scroll_up
	jmp	music_selector
@@:	cmp.b	#$1d,d0			;[RET]=セレクタモード
	bne	@f
	bsr	scroll_up
	jmp	music_selector
@@:	cmp.b	#$4e,d0			;[ENTER]=セレクタモード
	bne	@f
	bsr	scroll_up
	jmp	music_selector
*---------------------------------------*
@@:
break:
	bra	loop

*********************************************************
*
*	各処理を行う
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
*	演奏開始からのステップカウント
*
all_step:
*********************************************************
	movem.l	d1/a6,-(sp)

	move.l	stepcount(a5),d1
	cmp.l	o_allstp,d1
	bcs	go_restart		;カウンタが減っていたら再起動
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
*	演奏経過時間
*
passed_time:
*********************************************************
	movem.l	d0-d1/a6,-(sp)

	move.l	stepcount(a5),-(sp)
	jsr	_tm_caluc
	addq.l	#4,sp
	move.l	d0,run_time
	move.w	#%01_1111_0000,R21
*コロン
	move.l	d0,d1

	clr.b	tcoron_flag
	divu.w	#50*2,d1		;0.50秒ごとに点滅
	swap.w	d1
	cmpi.w	#50,d1
	bcc	@f
	move.b	#1,tcoron_flag
@@:
	tst.b	tcoron_flag		;フラグに応じてＯＮ／ＯＦＦ
	beq	tc_off
tc_on:
	SEG7	#29+2,#48,#mes_coron
	bra	@f
tc_off:
	SEG7	#29+2,#48,#mes_1space
@@:
	divu.w	#6000,d0
*分
	moveq.l	#0,d1
	move.w	d0,d1

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#4+4,sp
	lea.l	tbuf,a6
	addq.l	#8,a6			;２桁の位置にポインタ移動
	clr.b	2(a6)			;終端コード
	cmp.b	#' ',(a6)
	bne	@f
	move.b	#'0',(a6)
@@:
	SEG7	#29,#48,a6
*秒
	moveq.l	#0,d1
	swap.w	d0
	move.w	d0,d1

	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#4+4,sp
	lea.l	tbuf,a6
	addq.l	#6,a6			;２桁の位置にポインタ移動
	clr.b	2(a6)			;終端コード
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
*	テンポ
*
print_tempo:
*********************************************************
	movem.l	d1/a0-a1/a5,-(sp)

	move.l	panel_tempo(a5),d1

	cmp.l	o_tempo,d1		;パラメータが変わってるか？
	beq	tmp_skip		;変わってなければスキップ
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
*	コメント
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
	move.l	4*0(a1),4*0(a2)		;コメント文字列をバッファへ
	move.l	4*1(a1),4*1(a2)
	move.l	4*2(a1),4*2(a2)
	move.l	4*3(a1),4*3(a2)
	move.l	4*4(a1),4*4(a2)
	move.l	4*5(a1),4*5(a2)
	clr.b	20(a2)			;エンドコード書き込み
	SPRINT	#65,#35,a2
	clr.l	4*0(a2)			;バッファ初期化
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
*	ループカウンタ
*
loop_count:
*********************************************************
	movem.l	d1/a5-a6,-(sp)

	moveq.l	#0,d1
	move.w	loopcount(a5),d1
	cmp.w	o_loopcount,d1		;パラメータが変わってるか？
	beq	lc_bk			;変わってなければスキップ
	move.w	d1,o_loopcount

	addq.l	#1,d1			;0～ -> 1～
	pea.l	tbuf
	move.l	d1,-(sp)
	jsr	bin_adec
	addq.l	#8,sp
	lea.l	tbuf,a6
	addq.l	#8,a6			;２桁の位置にポインタ移動
	clr.b	2(a6)			;終端コード
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
*	チャンネル
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
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	(a1,d5.w)
	beq	@f

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#midich,a1		;a1.l=チャンネルデータ先頭
	move.b	(a1,d5.w),d3		;d3.b=チャンネル番号
@@:
	lea.l	o_cha,a1
	adda.w	d5,a1
	cmp.b	(a1),d3			;パラメータが変わってるか？
	beq	ch_skip			;変わってなければスキップ
	move.b	d3,(a1)
*---------------------------------------*
*チャンネル表示
	cmp.b	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	clr.b	d3			;　実際の値を０にして
	lea.l	mes_3space,a6		;　空白表示
	bra	@@f
@@:
	pea.l	tbuf
	addq.b	#1,d3
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#8,a6			;下２桁の位置にポインタをずらす
@@:
	move.l	#4,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#86,d7			;オフセットを加える
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	jsr	print_4x8font

*---------------------------------------*
ch_skip:
	dbra	d2,ch_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d2-d7/a1/a6
	rts

*********************************************************
*
*	演奏状態
*
playing_status:
*********************************************************
	movem.l	d1-d3/a1,-(sp)

	moveq.l	#0,d2
	move.b	timebase,d2		;d2.b=タイムベース値
	move.w	d2,d3
	mulu.w	#2,d3

	move.l	stepcount(a5),d1

	clr.b	brink_flag
	divu.w	d3,d1			;タイムベースクロックごとに点滅
	swap.w	d1
	cmp.w	d2,d1
	bcc	@f
	move.b	#1,brink_flag
@@:
	move.w	#%01_1111_0000,R21
	tst.b	brink_flag		;フラグに応じてＯＮ／ＯＦＦ
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
*	演奏モード
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
*	小節番号
*
bar_no:
*********************************************************
	movem.l	d1-d7/a1/a6,-(sp)

	move.w	ps_trk,d4
	moveq.l	#18-1,d2
bar_trk_loop:
	move.w	d4,d5
	add.w	d2,d5

	moveq.l	#-1,d3			;初期化
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	(a1,d5.w)		;d3.b=トラック有効フラグ
	beq	@f

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#bar,a1			;a1.l=小節番号データ先頭
	move.w	d5,d1
	add.w	d1,d1			;d1=d1*4
	add.w	d1,d1			;
	adda.l	d1,a1
	move.l	(a1),d3			;d3.l=小節番号
@@:
	lea.l	o_bar,a1
	move.w	d5,d1
	add.w	d1,d1			;d1=d1*4
	add.w	d1,d1			;
	adda.l	d1,a1
	cmp.l	(a1),d3			;パラメータが変わってるか？
	beq	bar_skip		;変わってなければスキップ
	move.l	d3,(a1)
*---------------------------------------*
*小節番号表示
	cmp.l	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	clr.l	d3			;　実際の値を０にして
	lea.l	mes_3space,a6		;　空白表示
	bra	@@f
@@:
	pea.l	tbuf
	addq.l	#1,d3
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	add.l	#7,a6			;下３桁の位置にポインタをずらす
@@:
	move.l	#7,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#86,d7			;オフセットを加える
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	jsr	print_4x8font
*---------------------------------------*
bar_skip:
	dbra	d2,bar_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d1-d7/a1/a6
	rts

*********************************************************
*
*	ステップ番号
*
step_no:
*********************************************************
	movem.l	d1-d7/a1/a6,-(sp)

	move.w	ps_trk,d4
	moveq.l	#18-1,d2
step_trk_loop:
	move.w	d4,d5
	add.w	d2,d5

	moveq.l	#-1,d3			;初期化
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	(a1,d5.w)
	beq	@f

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#step,a1		;a1.l=ステップ番号データ先頭
	move.w	d5,d1
	add.w	d1,d1			;d1=d1*4
	add.w	d1,d1			;
	adda.l	d1,a1
	move.l	(a1),d3			;d3.l=小節番号
@@:
	lea.l	o_stp,a1
	move.w	d5,d1
	add.w	d1,d1			;d1=d1*4
	add.w	d1,d1			;
	adda.l	d1,a1
	cmp.l	(a1),d3			;パラメータが変わってるか？
	beq	step_skip		;変わってなければスキップ
	move.l	d3,(a1)
*---------------------------------------*
*ステップ番号表示
	cmp.l	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	clr.l	d3			;　実際の値を０にして
	lea.l	mes_3space,a6		;　空白表示
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす
@@:
	move.l	#11,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#86,d7			;オフセットを加える
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	jsr	print_4x8font
*---------------------------------------*
step_skip:
	dbra	d2,step_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d1-d7/a1/a6
	rts

*********************************************************
*
*	ベロシティ
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
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	0(a1,d2.l)
	bne	@f
	bsr	vel_no			;トラック無効なら数値消去
@@:
	lea.l	m_vel,a3
	adda.l	d2,a3			;(a3)=メーター値

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#flg_off,a1
	tst.b	0(a1,d2.l)		;ＯＦＦフラグ立ってるか？
	beq	@f
				*note off
	clr.b	0(a1,d2.l)		;ＯＦＦフラグ解除
	lea.l	vel_speed,a2
	move.b	#2,0(a2,d2.l)		;メーター落下速度
@@:
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#flg_vel,a1
	tst.b	0(a1,d2.l)		;ＯＮフラグ立ってるか？
	beq	vel_meter
				*note on
	clr.b	0(a1,d2.l)		;ＯＮフラグ解除
	lea.l	vel_speed,a2
	move.b	#4,0(a2,d2.l)		;メーター落下速度
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#vel,a1			;a1.l=ベロシティデータ先頭
	move.b	0(a1,d2.l),d3		;d3.b=ベロシティ値
	move.b	d3,(a3)			;「ベロシティ＝メータ値」に設定
	bsr	vel_no
	bsr	level_meter		;16chレベルメータルーチン d2.b=trk d3.b=vel
*---------------------------------------*
*メーター
vel_meter:
	tst.b	vel_flag
	bne	vel_skip

	move.b	(a3),d1
	lea.l	vel_speed,a2
	move.b	0(a2,d2.l),d0		;d0.b=メーター落下速度
	tst.b	d1
	beq	@@f
	lsr.w	d0,d1
	tst.b	d1
	bne	@f
	move.b	#1,d1
@@:
	sub.b	d1,(a3)			;メーターを動かす
@@:
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	(a3),d2
	divu.w	#10,d2			;１０で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	move.l	#TVRAM,a1
	adda.l	#7,a1			;Ｘ座標／８
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;Ｙオフセットを加える
	add.l	d5,a1

	lea.l	vel_tbl,a2
	moveq.l	#0,d4
	move.l	d2,d4
	add.w	d4,d4			;d4=d4*4
	add.w	d4,d4			;
	adda.l	d4,a2

	move.w	#%01_0110_0000,R21	;同時アクセス
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.w	#%01_0111_0000,R21	;同時アクセス
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	move.l	d7,d2			;d2復帰
	bra	vel_skip
*---------------------------------------*
vel_skip:
*	sub.l	ps_trk,d2
	dbra	d2,vel_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1-a3/a6
	rts

*---------------------------------------*
*数値
vel_no:
	lea.l	o_vel,a1
	cmp.b	0(a1,d2.l),d3		;値が変わってなければ帰る
	bne	@f
	rts
@@:
	move.b	d3,0(a1,d2.l)
	cmp.b	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	clr.b	d3			;　実際の値を０にして
	lea.l	mes_3space,a6		;　空白表示
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす
@@:
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#18,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

	rts

*********************************************************
*
*	ボリューム
*
volume:
*********************************************************
	movem.l	d0-d7/a1-a2,-(sp)

	moveq.l	#18-1,d2
vol_trk_loop:
*	add.l	ps_trk,d2

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#midich,a1		;a1.l=チャンネルデータ先頭
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=チャンネル番号

	move.b	#-1,d3			;d3.b=ボリューム値＝ＯＦＦ
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_vol,a1		;a1.l=ボリュームデータ先頭
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=ボリューム値
@@:
	lea.l	o_vol,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;パラメータが変わってるか？
	beq	vol_skip		;変わってなければスキップ
	move.b	d3,(a1)

*---------------------------------------*
*数値
	cmp.b	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	clr.b	d3			;　実際の値を０にして
	lea.l	mes_3space,a6		;　空白表示
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす
*	jsr	left3keta
@@:
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#25,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#6,d2			;６で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	move.l	#TVRAM,a1
	adda.l	#11,a1			;Ｘ座標／８
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;Ｙオフセットを加える
	add.l	d5,a1

	lea.l	vol_slide_tbl,a2
	move.l	d2,d4
	add.w	d4,d4			;d4=d4*4
	add.w	d4,d4			;
	adda.l	d4,a2

	move.w	#%01_0001_0000,R21	;同時アクセス
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
*スライダーつまみ
	addi.l	#104,d2			;Ｘ座標（Ｘオフセット＋値）
	move.l	d7,d3			;Ｙ座標
	lsl.w	#4,d3			;　トラック番号を１６倍
	addi.l	#16*6-3,d3		;　Ｙオフセットを加える
	move.l	d7,d1			;スプライトページ（トラック番号）
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$01,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	move.l	d7,d2			;d2復帰
*---------------------------------------*
vol_skip:
*	sub.l	ps_trk,d2
	dbra	d2,vol_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1-a2
	rts

*********************************************************
*
*	エクスプレッション
*
expression:
*********************************************************
	movem.l	d0-d7/a1-a2,-(sp)

	moveq.l	#18-1,d2
exp_trk_loop:
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#midich,a1		;a1.l=チャンネルデータ先頭
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=チャンネル番号

	move.b	#-1,d3			;d3.b=エクスプレッション値＝ＯＦＦ
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_expr,a1		;a1.l=エクスプレッションデータ先頭
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=エクスプレッション値
@@:
	lea.l	o_exp,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;パラメータが変わってるか？
	beq	exp_skip		;変わってなければスキップ
	move.b	d3,(a1)

*---------------------------------------*
*数値
	cmp.b	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	clr.b	d3			;　実際の値を０にして
	lea.l	mes_3space,a6		;　空白表示
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす
*	jsr	left3keta
@@:
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#32,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#6,d2			;６で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	move.l	#TVRAM,a1
	adda.l	#14,a1			;Ｘ座標／８
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;Ｙオフセットを加える
	add.l	d5,a1

	lea.l	exp_slide_tbl,a2
	move.l	d2,d4
	add.w	d4,d4			;d4=d4*4
	add.w	d4,d4			;
	adda.l	d4,a2

	move.w	#%01_0001_0000,R21	;同時アクセス
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
*スライダーつまみ
	addi.l	#132,d2			;Ｘ座標（Ｘオフセット＋値）
	move.l	d7,d3			;Ｙ座標
	lsl.w	#4,d3			;　トラック番号を１６倍
	addi.l	#16*6-3,d3		;　Ｙオフセットを加える
	move.w	d7,d1
	addi.w	#18,d1			;スプライトページ（トラック番号＋１８）
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$01,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	move.l	d7,d2			;d2復帰
*---------------------------------------*
exp_skip:
	dbra	d2,exp_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1-a2
	rts

*********************************************************
*
*	モジュレーション
*
modulation:
*********************************************************
	movem.l	d0-d7/a1/a2/a6,-(sp)

	moveq.l	#18-1,d2
mod_trk_loop:
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#midich,a1		;a1.l=チャンネルデータ先頭
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=チャンネル番号

	move.b	#-1,d3			;d3.b=モジュレーション値＝ＯＦＦ
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_modu,a1		;a1.l=パンポットデータ先頭
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=パンポット値
@@:
	lea.l	o_mod,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;パラメータが変わってるか？
	beq	mod_skip		;変わってなければスキップ
	move.b	d3,(a1)

*---------------------------------------*
*数値
	cmp.b	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	clr.b	d3			;　実際の値を０にして
	lea.l	mes_3space,a6		;　空白表示
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす
*	jsr	left3keta
@@:
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#37,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#9,d2			;９で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	move.l	#TVRAM,a1
	adda.l	#18,a1			;Ｘ座標／８
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;Ｙオフセットを加える
	add.l	d5,a1

	lea.l	mod_slide_tbl,a2
	move.l	d2,d4
	add.w	d4,d4			;d4=d4*2
	adda.l	d4,a2

	move.w	#%01_0010_0000,R21	;同時アクセス
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2)+,1024/8*2(a1)
	addq.l	#1,a1
	move.b	(a2),(a1)
	move.b	(a2),1024/8(a1)
	move.b	(a2),1024/8*2(a1)

*---------------------------------------*
*スライダーつまみ
	addi.l	#160,d2			;Ｘ座標（Ｘオフセット＋値）
	move.l	d7,d3			;Ｙ座標
	lsl.w	#4,d3			;　トラック番号を１６倍
	addi.l	#16*6-3,d3		;　Ｙオフセットを加える
	move.w	d7,d1
	addi.w	#18*2,d1		;スプライトページ（トラック番号＋１８＊２）
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$01,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	move.l	d7,d2			;d2復帰
*---------------------------------------*
mod_skip:
	dbra	d2,mod_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1/a2/a6
	rts

*********************************************************
*
*	パンポット
*
panpot:
*********************************************************
	movem.l	d0-d7/a1-a2/a5-a6,-(sp)

	moveq.l	#18-1,d2
pan_trk_loop:
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#midich,a1		;a1.l=チャンネルデータ先頭
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=チャンネル番号

	move.b	#-1,d3			;d3.b=パンポット値＝ＯＦＦ
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_panpot,a1		;a1.l=パンポットデータ先頭
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=パンポット値
@@:
	lea.l	o_pan,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;パラメータが変わってるか？
	beq	pan_skip		;変わってなければスキップ
	move.b	d3,(a1)

*---------------------------------------*
*数値
	cmp.b	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	move.b	#64,d3			;　実際の値を６４にして
	lea.l	mes_3space,a6		;　空白表示
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす
*	jsr	left3keta
@@:
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#44,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini
*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#6,d2			;６で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	addi.l	#160+21,d2		;Ｘ座標（Ｘオフセット＋値）
	move.l	d7,d3			;Ｙ座標
	lsl.w	#4,d3			;　トラック番号を１６倍
	addi.l	#16*6-3,d3		;　Ｙオフセットを加える
	move.w	d7,d1
	addi.w	#18*5,d1		;スプライトページ（トラック番号＋１８＊５）
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$37,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	move.l	d7,d2			;d2復帰
*---------------------------------------*
pan_skip:
	dbra	d2,pan_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1-a2/a5-a6
	rts

*********************************************************
*
*	ピッチベンド
*
pitchbend:
*********************************************************
	movem.l	d0-d7/a1-a2/a5-a6,-(sp)

	moveq.l	#18-1,d2
bnd_trk_loop:
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#midich,a1		;a1.l=チャンネルデータ先頭
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=チャンネル番号

	move.l	#$ffff_ffff,d3		;d3.l=ピッチベンド＝ＯＦＦ
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	0(a1,d2.l)
	beq	@f

	lsl.l	#2,d7
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_pbend,a1		;a1.l=ピッチベンドデータ先頭
	move.l	0(a1,d7.w),d3		;d3.l=ピッチベンド値
@@:
	lea.l	o_bnd,a1
	move.l	d2,d4
	lsl.l	#2,d4
	adda.l	d4,a1
	cmp.l	(a1),d3			;パラメータが変わってるか？
	beq	bnd_skip		;変わってなければスキップ
	move.l	d3,(a1)

*---------------------------------------*
*数値
	cmp.l	#$ffff_ffff,d3		;値＝ＯＦＦなら
	bne	@f
	move.l	#8192,d3		;　実際の値を０にして
	lea.l	mes_6space,a6		;　空白表示
	bra	bpm
@@:
	clr.b	d5			;d5.b=マイナスフラグ
	pea.l	tbuf
	move.l	d3,d4
	subi.l	#8192,d4		;d4.l= 0～16384 → -8192～8192
	bcc	@f
	neg.l	d4
	move.b	#-1,d5
@@:
	move.l	d4,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#5,a6
*	jsr	left5keta
	tst.b	d5			;マイナスだったら'-'を付加
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
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#49,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	move.l	d3,d2
	divu.w	#128*5,d2		;１２８で割る＆５で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	move.l	#TVRAM,a1
	adda.l	#24,a1			;Ｘ座標／８
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-14),d5	;Ｙオフセットを加える
	adda.l	d5,a1

	lea.l	bnd_slide_tbl1,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.w	d4,a2

	move.w	#%01_1010_0000,R21	;同時アクセス

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

	move.w	#%01_0001_0000,R21	;同時アクセス

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

	move.l	d7,d2			;d2復帰
*---------------------------------------*
bnd_skip:
	dbra	d2,bnd_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1-a2/a5-a6
	rts

*********************************************************
*
*	リバーブ
*
reverb:
*********************************************************
	movem.l	d0-d7/a1/a2/a6,-(sp)

	moveq.l	#18-1,d2
rvb_trk_loop:
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#midich,a1		;a1.l=チャンネルデータ先頭
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=チャンネル番号

	move.b	#-1,d3			;d3.b=リバーブ値＝ＯＦＦ
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_gsrev,a1		;a1.l=リバーブデータ先頭
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=リバーブ値
@@:
	lea.l	o_rvb,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;パラメータが変わってるか？
	beq	rvb_skip		;変わってなければスキップ
	move.b	d3,(a1)

*---------------------------------------*
*数値
	cmp.b	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	clr.b	d3			;　実際の値を０にして
	lea.l	mes_3space,a6		;　空白表示
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす
*	jsr	left3keta

	cmp.b	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	clr.b	d3			;　実際の値を０にして
	lea.l	mes_3space,a6		;　空白表示
@@:
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#57,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#7,d2			;７で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	move.l	#TVRAM,a1
	adda.l	#27,a1			;Ｘ座標／８
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;Ｙオフセットを加える
	add.l	d5,a1

	lea.l	rvb_slide_tbl,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.l	d4,a2

	move.w	#%01_0011_0000,R21	;同時アクセス
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
*スライダーつまみ
	addi.l	#236,d2			;Ｘ座標（Ｘオフセット＋値）
	move.l	d7,d3			;Ｙ座標
	lsl.w	#4,d3			;　トラック番号を１６倍
	addi.l	#16*6-3,d3		;　Ｙオフセットを加える
	move.w	d7,d1
	addi.w	#18*3,d1		;スプライトページ（トラック番号＋１８＊３）
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$01,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	move.l	d7,d2			;d2復帰
*---------------------------------------*
rvb_skip:
	dbra	d2,rvb_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1/a2/a6
	rts

*********************************************************
*
*	コーラス
*
chorus:
*********************************************************
	movem.l	d0-d7/a1/a2/a6,-(sp)

	moveq.l	#18-1,d2
cho_trk_loop:
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#midich,a1		;a1.l=チャンネルデータ先頭
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=チャンネル番号

	move.b	#-1,d3			;d3.b=コーラス値＝ＯＦＦ
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	0(a1,d2.l)
	beq	@f

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_gscho,a1		;a1.l=コーラスデータ先頭
	moveq.l	#0,d3
	move.b	0(a1,d7.w),d3		;d3.b=コーラス値
@@:
	lea.l	o_cho,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;パラメータが変わってるか？
	beq	cho_skip		;変わってなければスキップ
	move.b	d3,(a1)

*---------------------------------------*
*数値
	cmp.b	#-1,d3			;値＝ＯＦＦなら
	bne	@f
	clr.b	d3			;　実際の値を０にして
	lea.l	mes_3space,a6		;　空白表示
	bra	@@f
@@:
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす
*	jsr	left3keta
@@:
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#63,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#7,d2			;７で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	move.l	#TVRAM,a1
	adda.l	#30,a1			;Ｘ座標／８
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;Ｙオフセットを加える
	add.l	d5,a1

	lea.l	cho_slide_tbl,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.l	d4,a2

	move.w	#%01_0011_0000,R21	;同時アクセス
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
*スライダーつまみ
	addi.l	#260,d2			;Ｘ座標（Ｘオフセット＋値）
	move.l	d7,d3			;Ｙ座標
	lsl.w	#4,d3			;　トラック番号を１６倍
	addi.l	#16*6-3,d3		;　Ｙオフセットを加える
	move.w	d7,d1
	addi.w	#18*4,d1		;スプライトページ（トラック番号＋１８＊４）
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$01,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	move.l	d7,d2			;d2復帰
*---------------------------------------*
cho_skip:
	dbra	d2,cho_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1/a2/a6
	rts

*********************************************************
*
*	ダンパーペダル
*
hold:
*********************************************************
	movem.l	d0-d7/a0-a6,-(sp)

	moveq.l	#18-1,d2
hold_trk_loop:
	moveq.l	#0,d7
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#midich,a1		;a1.l=チャンネルデータ先頭
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=チャンネル番号

	clr.b	d3			;d3.b=ホールド値＝０
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#active,a1		;a1.l=トラック有効フラグ先頭
	tst.b	0(a1,d2.l)
	beq	@f			;トラックが無効ならスキップ

	moveq.l	#0,d3
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_hold1,a1		;a1.l=ホールドデータ先頭
	move.b	0(a1,d7.w),d3		;d3.b=ホールド値
@@:
	lea.l	o_hld,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;パラメータが変わってるか？
	beq	hold_skip		;変わっていなければスキップ
	move.b	d3,(a1)

	cmp.b	#64,d3			;64以上ならHOLD ON
	bge	@f
	lea.l	mes_1space,a6
	bra	@@f
@@:
	lea.l	mes_ten,a6
@@:
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#15,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

*---------------------------------------*
hold_skip:
	dbra	d2,hold_trk_loop
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a0-a6
	rts

*********************************************************
*
*	音色名
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
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#midich,a1		;a1.l=チャンネルデータ先頭
	moveq.l	#0,d7
	move.b	0(a1,d2.l),d7		;d7.b=チャンネル番号

	move.b	#-1,d4			;d4.b=バンク番号＝ＯＦＦ
	move.b	#-1,d3			;d3.b=音色番号＝ＯＦＦ

	movea.l	a5,a2			;a1.l=RCDワーク先頭
	adda.l	#active,a2		;a1.l=トラック有効フラグ先頭
	tst.b	0(a2,d2.l)
	beq	@f			;トラックが無効ならスキップ

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_bank,a1		;a1.l=バンク番号データ先頭
	move.b	0(a1,d7.w),d4		;d4.b=バンク番号
@@:
	lea.l	o_bnk,a1
	adda.l	d2,a1
	cmp.b	(a1),d4			;パラメータが変わってるか？
	beq	@f			;変わってなければ次へ
	move.b	#1,d1			;変わっていればフラグを立てておく(d1)
	move.b	d4,(a1)
@@:
	tst.b	0(a2,d2.l)
	beq	@f			;トラックが無効ならスキップ

	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_prg,a1		;a1.l=プログラム番号データ先頭
	move.b	0(a1,d7.w),d3		;d3.b=プログラム番号
	cmp.b	#1,d1			;d1フラグが立っているか？
	beq	inst_main		;立っていれば処理開始
@@:
	lea.l	o_prg,a1
	adda.l	d2,a1
	cmp.b	(a1),d3			;パラメータが変わってるか？
	beq	inst_skip		;変わっていなければスキップ
	move.b	d3,(a1)
inst_main:
*---------------------------------------*
*前の表示を消去
	move.l	d2,d5			;Ｙ座標＝トラック番号
	lsl.l	#4,d5			;トラック番号＊１６
	addi.l	#83,d5			;オフセットを加える
	lsl.l	#7,d5			;Y=Y*128
	addi.l	#34,d5			;Ｘ座標
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

	cmp.b	#-1,d3			;プログラム番号がＯＦＦなら
	beq	inst_skip
*---------------------------------------*
*音色番号表示
	move.l	d7,-(sp)		;! d7保存
*bank
	move.w	#%01_1111_0000,R21
	pea.l	tbuf
	move.l	d4,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす

	move.l	#67,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	addi.l	#83,d7			;オフセットを加える
	jsr	print_mini
*program
	pea.l	tbuf
	move.l	d3,d5
	addq.l	#1,d5
	move.l	d5,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす

	addq.l	#6,d7			;Ｙオフセットを加える
	jsr	print_mini
	move.l	(sp)+,d7		;! d7復帰
*---------------------------------------*
*音色名表示
inst_name:
*リズムパート
@@:	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#ch_part,a1		;a1.l=音源種類データ先頭
	cmp.b	#2,0(a1,d7.w)		;リズムパート？
	bne	@f
	lea.l	inst_drums,a6
	move.w	#%01_0011_0000,R21
	bra	inst_break
*バンク決定
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
*ユーザーインストゥルメント
	cmp.b	#64,d4
	bne	@f
	lea.l	inst_user,a6
	bra	inst_break_2
@@:	cmp.b	#65,d4
	bne	@f
	lea.l	inst_user,a6
	bra	inst_break_2
@@:
*いずれにも当てはまらず
	lea.l	capital_out,a6
	bra	inst_break_2
inst_break:
	cmp.b	#119,d3			;効果音
	bls	@f
	move.w	#%01_0001_0000,R21
@@:
	move.l	d3,d5			;音色名文字列のアドレスを決定
	mulu.w	#13,d5
	adda.l	d5,a6
inst_break_2:
	move.l	#71,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#86,d7			;オフセットを加える
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
*	マスターボリューム
*
master_volume:
*********************************************************
	movem.l	d0-d7/a1-a2,-(sp)

	moveq.l	#18,d2

	moveq.l	#0,d3
	move.b	GS_VOL(a5),d3		;d3.b=ボリューム値
	cmp.b	o_mvol,d3		;パラメータが変わってるか？
	beq	mvol_skip		;変わってなければスキップ
	move.b	d3,o_mvol

*---------------------------------------*
*数値
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす

	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#25,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#6,d2			;６で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	move.l	#TVRAM,a1
	adda.l	#11,a1			;Ｘ座標／８
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;Ｙオフセットを加える
	add.l	d5,a1

	lea.l	vol_slide_tbl,a2
	move.l	d2,d4
	add.w	d4,d4			;d4=d4*4
	add.w	d4,d4			;
	adda.l	d4,a2

	move.w	#%01_0001_0000,R21	;同時アクセス
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
*スライダーつまみ
	addi.l	#104,d2			;Ｘ座標（Ｘオフセット＋値）
	move.l	d7,d3			;Ｙ座標
	lsl.w	#4,d3			;　トラック番号を１６倍
	addi.l	#16*6-3,d3		;　Ｙオフセットを加える
	move.l	#108,d1			;スプライトページ
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$01,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	move.l	d7,d2			;d2復帰
*---------------------------------------*
mvol_skip:
	movem.l	(sp)+,d0-d7/a1-a2
	rts

*********************************************************
*
*	マスターパンポット
*
master_panpot:
*********************************************************
	movem.l	d0-d7/a1-a2/a5-a6,-(sp)

	moveq.l	#18,d2

	moveq.l	#0,d3
	move.b	GS_PAN(a5),d3		;d3.b=パンポット値
	cmp.b	o_mpan,d3		;パラメータが変わってるか？
	beq	mpan_skip		;変わってなければスキップ
	move.b	d3,o_mpan

*---------------------------------------*
*数値
	pea.l	tbuf
	move.l	d3,-(sp)		;bin-str変換
	jsr	bin_adec
	addq.l	#8,sp

	lea.l	tbuf,a6
	addq.l	#7,a6			;下３桁の位置にポインタをずらす

	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#44,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini
*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#6,d2			;６で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	addi.l	#160+21,d2		;Ｘ座標（Ｘオフセット＋値）
	move.l	d7,d3			;Ｙ座標
	lsl.w	#4,d3			;　トラック番号を１６倍
	addi.l	#16*6-3,d3		;　Ｙオフセットを加える
	move.l	#111,d1			;スプライトページ
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$37,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	move.l	d7,d2			;d2復帰
*---------------------------------------*
mpan_skip:
	movem.l	(sp)+,d0-d7/a1-a2/a5-a6
	rts

*********************************************************
*
*	マスターリバーブ
*
master_reverb:
*********************************************************
	movem.l	d0-d7/a1/a2/a6,-(sp)

	moveq.l	#18,d2
	move.l	d1,d3
*---------------------------------------*
*数値
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#57,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#7,d2			;７で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	move.l	#TVRAM,a1
	adda.l	#27,a1			;Ｘ座標／８
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;Ｙオフセットを加える
	add.l	d5,a1

	lea.l	rvb_slide_tbl,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.l	d4,a2

	move.w	#%01_0011_0000,R21	;同時アクセス
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
	move.w	#%01_1111_0000,R21	;同時アクセス

*---------------------------------------*
*スライダーつまみ
	addi.l	#236,d2			;Ｘ座標（Ｘオフセット＋値）
	move.l	d7,d3			;Ｙ座標
	lsl.w	#4,d3			;　トラック番号を１６倍
	addi.l	#16*6-3,d3		;　Ｙオフセットを加える
	move.l	#109,d1			;スプライトページ
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$01,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	move.l	d7,d2			;d2復帰
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1/a2/a6
	rts

*********************************************************
*
*	マスターコーラス
*
master_chorus:
*********************************************************
	movem.l	d0-d7/a1/a2/a6,-(sp)

	moveq.l	#18,d2
	move.l	d1,d3

*---------------------------------------*
*数値
	move.w	#%01_1111_0000,R21	;同時アクセス設定
	move.l	#63,d6			;Ｘ座標
	move.l	d2,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#89,d7			;オフセットを加える
	jsr	print_mini

*---------------------------------------*
*スライダー
	move.l	d2,d7			;d2退避

	moveq.l	#0,d2
	move.b	d3,d2
	divu.w	#7,d2			;７で割る
	andi.l	#$0000_ffff,d2		;下位ワード消去

	move.l	#TVRAM,a1
	adda.l	#30,a1			;Ｘ座標／８
	move.l	#(1024/8)*16,d5
	mulu.w	d7,d5
	addi.l	#(1024/8)*(16*6-12),d5	;Ｙオフセットを加える
	add.l	d5,a1

	lea.l	cho_slide_tbl,a2
	move.l	d2,d4
	move.w	d4,d1			;d4=d4*3
	add.w	d4,d4			;
	add.w	d1,d4			;
	adda.l	d4,a2

	move.w	#%01_0011_0000,R21	;同時アクセス
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
	move.w	#%01_1111_0000,R21	;同時アクセス

*---------------------------------------*
*スライダーつまみ
	addi.l	#260,d2			;Ｘ座標（Ｘオフセット＋値）
	move.l	d7,d3			;Ｙ座標
	lsl.w	#4,d3			;　トラック番号を１６倍
	addi.l	#16*6-3,d3		;　Ｙオフセットを加える
	move.l	#110,d1			;スプライトページ
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$01,d4			;パターンコード
	add.l	#%0001_00_000000,d4	;パレットコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	move.l	d7,d2			;d2復帰
*---------------------------------------*
	movem.l	(sp)+,d0-d7/a1/a2/a6
	rts

*********************************************************
*
*	鍵盤
*
keyboard:
*********************************************************
	movem.l	d1-d7/a1-a6,-(sp)
*---------------------------------------*
*リズムパート時間管理
	lea.l	rhy_flags,a4
rht_lp:
	cmpa.l	rhy_pointer,a4
	bcc	get_note		;ループ終了

	tst.b	1(a4)			;ワークが空いてたらスキップ
	bne	@f
	addq.l	#6,a4
	bra	rht_lp
@@:
	IOCS	_ONTIME
	sub.l	2(a4),d0		;d0.l=ﾉｰﾄｵﾝから現在までの時間差
	cmpi.l	#10,d0
	bcc	@f
	addq.l	#6,a4			;時間が来てなければスキップ
	bra	rht_lp
@@:
	moveq.l	#0,d2			;時間が来たらノートオフ処理
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
*	move.b	2(a1,d7.l),d3		;d3.b=gate（未使用）
	move.b	3(a1,d7.l),d4		;d4.b=velo

	tst.b	d4			;vel=0？
	beq	@f
	bsr	speana
@@:
	moveq.l	#0,d6
	movea.l	a5,a3			;a3.l=RCDワーク先頭
	adda.l	#midich,a3		;a3.l=チャンネルデータ先頭
	move.b	(a3,d2.l),d6		;d6.b=チャンネル番号
	movea.l	a5,a3			;a3.l=RCDワーク先頭
	adda.l	#ch_part,a3		;a3.l=音源種類データ先頭
	cmp.b	#2,(a3,d6.l)		;リズムパート？
	bne	bsr_key_main
	tst.b	d4			;vel=0？
	beq	key_break

	lea.l	rhy_flags,a4
@@:
	tst.b	1(a4)			;ワーク空いてるか？
	beq	@f
	addq.l	#6,a4			;空いていなければポインタを進めてループ
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
	move.l	a4,rhy_pointer		;rhy_pointer=ワークＭＡＸ
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
*鍵盤表示メインルーチン
key_main:
	movem.l	d0-d7/a1-a2/a5,-(sp)

	cmp.b	#18,d2			;トラック19以上なら表示範囲外だから抜ける
	bcc	km_ret

	move.b	d1,d7			;d7.b=ノート番号
	move.l	d2,d6			;d6.b=トラック番号
	moveq.l	#0,d5

	sub.b	note_shift,d1		;0=c1にセット

	divu.w	#12,d1
	move.w	d1,d5			;d5.w=オクターブ
	swap.w	d1			;d1.w=音程
	lsl.w	#4,d2			;Ｙ＝トラック番号＊１６

*---------------------------------------*
	lea.l	note_jmp_tbl,a1		;鍵盤位置決定(table jump)
	move.w	d1,d3
	add.w	d3,d3
	add.w	d3,d3
	adda.w	d3,a1
	movea.l	(a1),a1
	jsr	(a1)
*---------------------------------------*
put_key:
	add.w	#334,d1			;Ｘオフセットを加える
	mulu.w	#4*7,d5
	add.w	d5,d1			;オクターブ分加える
	add.w	#84+6,d2		;Ｙオフセットを加える

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
	tst.b	memo_mode		;メモモードなら描かない
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
*鍵盤位置決定
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
*	鍵盤点灯＆消灯
*		入力	d1.w = Ｘ座標
*			d2.w = Ｙ座標
*
*********************************************************
*点灯
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
*消灯
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
*	エフェクター
*
effect:
*********************************************************
	movem.l	d1-d2/a1-a6,-(sp)
	move.w	#%01_1111_0000,R21	;同時アクセス
*---------------------------------------*
*リバーブ
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
*コーラス
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
*ディレイ
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
*ＥＱ
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
*	５５系液晶ディスプレイ（グラフックパターン）
*
sc55disp_ptn:
*********************************************************
	movem.l	d0-d6/a3-a5,-(sp)

	tst.b	sc_ptn_flag		;表示中じゃなければ時間チェックはスキップ
	beq	scdsp_main

	IOCS	_ONTIME
	sub.l	sc_ptn_time,d0		;d0.l=時間差
	cmpi.l	#300,d0
	bls	scdsp_main

	clr.b	sc_ptn_flag

clr_sc55ptn:
	move.w	#%01_0101_0000,R21
	move.l	#TVRAM+46+417*128,a1	;前の表示を消去
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
*表示開始
	IOCS	_ONTIME
	move.l	d0,sc_ptn_time		;表示スタート時間セット
	move.b	#1,sc_ptn_flag

	movea.l	a5,a3
	adda.l	#gs_panel,a3		;a3.l=パターンデータ先頭
	move.l	#46,d1			;d1.l=Ｘ座標
	move.l	#26,d0			;d0.l=Ｙ座標

*---------------------------------------*
scdsp2:
	move.l	#TVRAM,a4
	moveq.l	#11,d2
	asl.l	d2,d0
	add.l	d1,d0
	add.l	d0,a4

	moveq.l	#16-1,d3		;Ｙループ
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

	moveq.l	#16-1,d4		;Ｘループ
scdsp4:
	add.w	d0,d0
	bcc	@f

	move.b	#%11111110,128(a4)	;ドット点灯
	move.b	#%11111110,128*2(a4)
	move.b	#%11111110,128*3(a4)

	addq.l	#1,a4
	dbra	d4,scdsp4

	adda.l	#128*4-16,a4
	dbra	d3,scdsp3

	bra	@@f
@@:
	move.b	#%00000000,128(a4)	;ドット消灯
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
*	５５系液晶ディスプレイ（文字列）
*
sc55disp_str:
*********************************************************
	movem.l	d0-d2/d6-d7/a0-a1/a3/a6,-(sp)

*---------------------------------------*
	tst.b	sc_str_flag		;表示中じゃなければ時間チェックはスキップ
	beq	scstr_rol

*16文字以下モード時の時間チェック
	IOCS	_ONTIME
	sub.l	sc_str_time,d0		;d0.l=時間差
	cmpi.l	#300,d0
	bls	scstr_main

	clr.b	sc_str_flag

*16文字以下メッセージ表示終わり
clr_sc55mes:
	move.w	#%01_1100_0000,R21
	movea.l	a5,a0			;-SOUND CANVAS-
	adda.l	#gs_info,a0		;a0.l=複写元
	lea.l	sc_mes,a1		;a1.l=複写先
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	lea.l	sc_mes,a6
	move.w	#46,d6			;d6.l=Ｘ座標
	move.w	#401,d7			;d7.l=Ｙ座標
	jsr	print_sc
	bra	scstr_main

*---------------------------------------*
scstr_rol:
	tst.b	sc_rol_count		;スクロールしてない？
	beq	scstr_main

	IOCS	_ONTIME
	move.l	d0,d1
	sub.l	sc_rol_time,d1		;d0.l=時間差
	subi.l	#31,d1
	bls	scstr_main
	sub.l	d1,d0
	move.l	d0,sc_rol_time		;時間セット

*16文字以上のスクロール処理
	subq.b	#1,sc_rol_count
	addq.l	#1,sc_rol_pointer
	move.w	#%01_1100_0000,R21
	lea.l	sc_mes,a6
	add.l	sc_rol_pointer,a6
	move.w	#46,d6			;d6.l=Ｘ座標
	move.w	#401,d7			;d7.l=Ｙ座標
	jsr	print_sc

*---------------------------------------*
scstr_main:
	move.w	#%01_0101_0000,R21
	tst.b	flg_gsinst(a5)		;メッセージ変わってる？
	beq	chk_scinfo
	clr.b	flg_gsinst(a5)

	clr.b	sc_rol_count
	clr.l	sc_rol_pointer
	movea.l	a5,a0
	adda.l	#gs_inst,a0		;a0.l=文字列データ先頭

	jsr	strlen
	move.w	d0,gsinst_ren
	cmp.w	#16,d0
	bhi	str_hi16
	bra	str_lw16
chk_scinfo:
	tst.b	sc_rol_count		;スクロール中ならスキップ
	bne	@f
	tst.b	flg_gsinfo(a5)
	beq	scst_break
	clr.b	flg_gsinfo(a5)
	move.w	#%01_1100_0000,R21
	movea.l	a5,a6			;-SOUND CANVAS-
	adda.l	#gs_info,a6
	move.w	#46,d6			;d6.l=Ｘ座標
	move.w	#401,d7			;d7.l=Ｙ座標
	jsr	print_sc
	bra	scst_break
@@:
	bsr	rewright_strbuf
	bra	scst_break

*---------------------------------------*
*１６文字以下の場合の処理
str_lw16:
	move.l	d0,-(sp)
	IOCS	_ONTIME
	move.l	d0,sc_str_time		;表示スタート時間セット
	move.b	#1,sc_str_flag
	move.l	(sp)+,d0

	lea.l	sc_mes,a6
	move.l	#'    ',(a6)
	move.l	#'    ',4(a6)
	move.l	d0,d2
	divu.w	#2,d0			;センタリング処理
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
	move.w	#46,d6			;d6.l=Ｘ座標
	move.w	#401,d7			;d7.l=Ｙ座標
	jsr	print_sc
	bra	scst_break

*---------------------------------------*
*１６文字より大きい場合の処理
str_hi16:
	move.b	d0,sc_rol_count
	addi.b	#18,sc_rol_count

*	move.l	d0,-(sp)
	IOCS	_ONTIME
	move.l	d0,sc_rol_time		;表示スタート時間セット
*	move.l	(sp)+,d0

*	bsr	rewright_strbuf		;スクロール文字列セット

*---------------------------------------*
scst_break:
	movem.l	(sp)+,d0-d2/d6-d7/a0-a1/a3/a6
	rts

*---------------------------------------*
rewright_strbuf:
*バッファに文字列複写
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
*メッセージ
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
*	モーションポインタ
*
motion_pointer:
*********************************************************
	movem.l	d0-d5,-(sp)

	move.l	run_time,d2
	move.l	max_time,d1
	cmp.l	d2,d1
	bhi	@f

	move.l	d1,d2			;256ループに入った場合

*	divu.w	d1,d2			;256ループに入った場合
*	clr.w	d2
*	swap.w	d2
@@:
	lsl.l	#4,d2
	lsl.l	#4,d1
	divu.w	#171,d1
	divu.w	d1,d2
	andi.l	#$0000ffff,d2
	addi.l	#351,d2			;Ｘ座標

	move.l	#64,d3			;Ｙ座標
	move.l	#127,d1			;スプライトページ
	bset.l	#31,d1			;垂直帰線期間検出なし
	move.l	#$10+%0001_00_000000,d4	;パターンコード
	moveq.l	#3,d5			;プライオリティ
	IOCS	_SP_REGST

	movem.l	(sp)+,d0-d5
	rts

*********************************************************
*
*	メモ表示モードトグル切り替え
*
memo_togle:
*********************************************************
	tst.b	memo_mode		;０なら
	bne	@f
	bsr	memo_trk_memo
	rts
@@:
	cmpi.b	#1,memo_mode		;１なら
	bne	@f
	bsr	memo_memo
	rts
@@:
	cmpi.b	#2,memo_mode		;２なら
	bne	@f
	bsr	memo_note
@@:
	rts

*********************************************************
*
*	memo_mode=0 鍵盤モード
*
memo_note:
*********************************************************
	movem.l	d1/a1,-(sp)

	bsr	init_instrument
	cmpi.b	#1,memo_mode		;直前がTRACK MEMOモードならINST再表示
	bne	@f
	bsr	init_instrument
	jsr	clear_trk_memo
@@:
	jsr	clear_note_area
	clr.b	memo_mode		;モード番号セット
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
*	memo_mode=1 トラックメモモード
*
memo_trk_memo:
*********************************************************
	movem.l	d1-d2/d7/a6,-(sp)

	cmpi.b	#1,memo_mode		;同じモードならノート表示
	bne	@f
	jsr	memo_note
	bra	mt_bk
@@:
	jsr	clear_trk_memo
	move.b	#1,memo_mode		;モード番号セット
*---------------------------------------*
	jsr	draw_trk_memo_mode
	move.w	#%01_1111_0000,R21
	SSPRINT	#67,#69,#mes_trk_memo
*---------------------------------------*

	moveq.l	#45,d6			;表示Ｘ座標
	move.w	#18-1,d1
@@:
	move.w	d1,d2			;データ取り出し
	lsl.w	#2,d2
	movea.l	a5,a6
	adda.l	#top,a6
	adda.w	d2,a6
	movea.l	(a6),a6
	adda.l	#track_comment,a6

	move.l	d1,d7			;Ｙ座標＝トラック番号
	lsl.l	#4,d7			;トラック番号＊１６
	add.l	#83,d7			;オフセットを加える

	lea.l	tbuf,a2
	move.l	(a6),(a2)		;文字列をバッファへ
	move.l	4(a6),4(a2)
	move.l	4*2(a6),4*2(a2)
	move.l	4*3(a6),4*3(a2)
	move.l	4*4(a6),4*4(a2)
	move.l	4*5(a6),4*5(a2)
	move.l	4*6(a6),4*6(a2)
	move.l	4*7(a6),4*7(a2)
	move.l	4*8(a6),4*8(a2)
	move.l	4*9(a6),4*9(a2)
	clr.b	36(a2)			;エンドコード書き込み
	lea.l	tbuf,a6
	jsr	prs_print_12x12
	clr.l	(a2)			;バッファ初期化
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
*	memo_mode=2 メモモード
*
memo_memo:
*********************************************************
	movem.l	d1-d2/d7/a5-a6,-(sp)

	bsr	init_instrument
	cmpi.b	#2,memo_mode		;同じモードならノート表示
	bne	@f
	jsr	memo_note
	bra	mm_bk
@@:
	cmpi.b	#1,memo_mode		;直前がTRACK MEMOモードならINST再表示
	bne	@f
	bsr	init_instrument
	jsr	clear_trk_memo
@@:
	jsr	clear_note_area
	move.b	#2,memo_mode		;モード番号セット
*---------------------------------------*
	jsr	draw_memo_mode
	move.w	#%01_1111_0000,R21
	SSPRINT	#84,#69,#mes_memo
*---------------------------------------*

	moveq.l	#57,d6			;表示Ｘ座標
	move.l	#16*8-8,d7		;Ｙオフセット

	movea.l	data_adr(a5),a5
	adda.l	#rcp_memo,a5

	move.w	#12-1,d1
@@:
	lea.l	tbuf,a2
	move.l	(a5),(a2)		;文字列をバッファへ
	move.l	4(a5),4(a2)
	move.l	4*2(a5),4*2(a2)
	move.l	4*3(a5),4*3(a2)
	move.l	4*4(a5),4*4(a2)
	move.l	4*5(a5),4*5(a2)
	move.l	4*6(a5),4*6(a2)
	move.l	4*7(a5),4*7(a2)
	clr.b	28(a2)			;エンドコード書き込み
	lea.l	tbuf,a6
	jsr	prs_print_12x16
	clr.l	(a2)			;バッファ初期化
	clr.l	4(a2)
	clr.l	4*2(a2)
	clr.l	4*3(a2)
	clr.l	4*4(a2)
	clr.l	4*5(a2)
	clr.l	4*6(a2)
	clr.l	4*7(a2)
	adda.l	#4*7,a5
	addi.l	#16,d7			;Ｙ座標＋１６

	dbra	d1,@b
*---------------------------------------*
mm_bk:
	movem.l	(sp)+,d1-d2/d7/a5-a6
	rts

*********************************************************
*
*	memo_mode=3 オンラインヘルプ
*
help:
*********************************************************
	movem.l	d1-d2/d7/a5-a6,-(sp)

	bsr	init_instrument
	cmpi.b	#3,memo_mode		;同じモードならノート表示
	bne	@f
	jsr	memo_note
	bra	hlp_bk
@@:
	cmpi.b	#1,memo_mode		;直前がTRACK MEMOモードならINST再表示
	bne	@f
	bsr	init_instrument
	jsr	clear_trk_memo
@@:
	jsr	clear_note_area
	move.b	#3,memo_mode		;モード番号セット
*---------------------------------------*
	jsr	draw_memo_mode
	move.w	#%01_1111_0000,R21
	SSPRINT	#84,#69,#mes_help_b
*---------------------------------------*

	moveq.l	#56,d6			;表示Ｘ座標
	move.l	#16*5,d7		;Ｙオフセット

	move.w	#18-1,d1
	lea.l	mes_help,a6
@@:
	jsr	prs_print_12x16
	addi.l	#16,d7			;Ｙ座標＋１６
	adda.l	#31,a6			;文字列アドレス＋３１

	dbra	d1,@b

*---------------------------------------*
hlp_bk:
	movem.l	(sp)+,d1-d2/d7/a5-a6
	rts

*********************************************************
*
*	メモ表示部分テキスト消去
*
clear_note_area:
*********************************************************
	movem.l	d1/a1,-(sp)

	move.w	#%01_1111_0000,R21
	move.l	#TVRAM+(1024*16*5/8+41),a1	;書き始めアドレス

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
*	トラックメモ表示部分テキスト消去
*
clear_trk_memo:
*********************************************************
	movem.l	d0-d1/a1,-(sp)

	move.w	#%01_1111_0000,R21
	move.l	#TVRAM+(1024*16*5/8+34),a1	;書き始めアドレス

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
*	INSTRUMENTパラメータ初期化
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
*	ミキサーを描く
*
draw_mixer:
*********************************************************
	movem.l	d0-d4/a0,-(sp)

	moveq.l	#0,d1			;テキストページ
	moveq.l	#0,d2			;Ｘ座標＝左端
	moveq.l	#0,d3			;Ｙ座標＝上
	lea.l	mixer_map,a0		;a0.l=マップデータ先頭
@@:
	move.l	#%0001_00_000000,d4	;パレットコード１
	cmp.b	#$6f,(a0)
	bcs	@f
	move.l	#%0010_00_000000,d4	;パレットコード２
@@:
	add.b	(a0)+,d4		;パターンーンコード

	IOCS	_BGTEXTST		;プット
	addq.l	#1,d2			;Ｘ座標＋＋
	cmpi.l	#32,d2			;右端まできてなければループ
	bne	@@b

	moveq.l	#0,d2			;Ｘ座標＝左端
	addq.l	#1,d3			;Ｙ座標＋＋
	cmpi.l	#64,d3			;下まできてなければループ
	bne	@@b

	movem.l	(sp)+,d0-d4/a0
	rts

*********************************************************
*
*	スクロールアップ（セレクタモード）
*
scroll_up:
*********************************************************
	movem.l	d0-d4/a1,-(sp)

;	bra	hs_rup		**

*---------------------------------------*
lw_rup:
	moveq.l	#0,d1			;テキストページ
	moveq.l	#0,d2			;Ｘ座標＝左端
	moveq.l	#0,d3			;Ｙ座標＝上
@@:
	addi.l	#32,d3			;Ｙ座標＋＋
	IOCS	_BGSCRLST		;BGスクロール
	move.w	d3,TXT_Y		;テキストスクロール

	lea.l	$eb0002,a1		;スプライトスクロール
	move.w	#128-1,d4		;
@@:	subi.w	#32,(a1)		;
	addq.l	#8,a1			;
	dbra	d4,@b			;

	cmpi.l	#512,d3			;下まできてなければループ
	bne	@@b

	bra	9f

*---------------------------------------*
hs_rup:
	moveq.l	#0,d1			;テキストページ
	moveq.l	#0,d2			;Ｘ座標＝左端
	move.l	#512,d3			;Ｘ座標＝下

	IOCS	_BGSCRLST		;BGスクロール
	move.w	d3,TXT_Y		;テキストスクロール
	lea.l	$eb0002,a1		;スプライトスクロール
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
*	スクロールダウン（ディスプレイモード）
*
scroll_down:
*********************************************************
	movem.l	d0-d4/a1,-(sp)

	tst.b	memo_mode		;鍵盤モードなら鍵盤部分をTEXT消去
	bne	@f
	bsr	clear_note_area
	bsr	init_instrument
@@:
;	bra	hs_rwn		**

*---------------------------------------*
lw_rwn:
	moveq.l	#0,d1			;テキストページ
	moveq.l	#0,d2			;Ｘ座標＝左端
	move.l	#512,d3			;Ｙ座標＝下
@@:
	subi.l	#32,d3			;Ｙ座標－－
	IOCS	_BGSCRLST		;BGスクロール
	move.w	d3,TXT_Y		;テキストスクロール

	lea.l	$eb0002,a1		;スプライトスクロール
	move.w	#128-1,d4		;
@@:	addi.w	#32,(a1)		;
	addq.l	#8,a1			;
	dbra	d4,@b			;

	cmpi.l	#0,d3			;上まできてなければループ
	bne	@@b

	bra	9f

*---------------------------------------*
hs_rwn:
	moveq.l	#0,d1			;テキストページ
	moveq.l	#0,d2			;Ｘ座標＝左端
	moveq.l	#0,d3			;Ｘ座標＝上

	IOCS	_BGSCRLST		;BGスクロール
	move.w	d3,TXT_Y		;テキストスクロール
	lea.l	$eb0002,a1		;スプライトスクロール
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
*	メモの背景を描く
*
draw_memo_mode:
*********************************************************
	movem.l	d1-d4,-(sp)

	moveq.l	#0,d1			;テキストページ
	move.l	#20,d2			;Ｘ座標
	moveq.l	#6,d3			;Ｙ座標
@@:
	move.l	#$20+%0001_00_000000,d4	;パターンコード
	IOCS	_BGTEXTST		;プット
	addq.l	#1,d2			;Ｘ座標＋＋
	cmpi.l	#20+11,d2		;右端まできてなければループ
	bne	@b
	move.l	#$48+%0001_00_000000,d4	;右パターンコード
	IOCS	_BGTEXTST		;プット

	move.l	#20,d2			;Ｘ座標リセット
	move.l	#$64+%0001_00_000000,d4	;左パターンコード
	IOCS	_BGTEXTST		;プット
	addq.l	#1,d3			;Ｙ座標＋＋
	cmpi.l	#6+17,d3		;下まできてなければループ
	bne	@b
*---------------------------------------*
	move.l	#20,d2			;Ｘ座標
	moveq.l	#5,d3			;Ｙ座標
	move.l	#$65+%0001_00_000000,d4	;左上パターンコード
	IOCS	_BGTEXTST		;プット
	addq.l	#1,d2			;Ｘ座標＋＋
@@:
	move.l	#$21+%0001_00_000000,d4	;上パターンコード
	IOCS	_BGTEXTST		;プット
	addq.l	#1,d2			;Ｘ座標＋＋
	cmpi.l	#20+11,d2		;右端まできてなければループ
	bne	@b
	move.l	#$26+%0001_00_000000,d4	;右上パターンコード
	IOCS	_BGTEXTST		;プット
*---------------------------------------*
	move.l	#20,d2			;Ｘ座標
	moveq.l	#23,d3			;Ｙ座標
	move.l	#$49+%0001_00_000000,d4	;左下パターンコード
	IOCS	_BGTEXTST		;プット
	addq.l	#1,d2			;Ｘ座標＋＋
@@:
	move.l	#$2e+%0001_00_000000,d4	;下パターンコード
	IOCS	_BGTEXTST		;プット
	addq.l	#1,d2			;Ｘ座標＋＋
	cmpi.l	#20+11,d2		;右端まできてなければループ
	bne	@b
	move.l	#$06+%0001_00_000000,d4	;右下パターンコード
	IOCS	_BGTEXTST		;プット
*---------------------------------------*
	move.l	#20,d2			;Ｘ座標
	moveq.l	#4,d3			;Ｙ座標
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
*	トラックメモの背景を描く
*
draw_trk_memo_mode:
*********************************************************
	movem.l	d1-d4,-(sp)

	moveq.l	#0,d1			;テキストページ
	move.l	#19,d2			;Ｘ座標
	moveq.l	#5,d3			;Ｙ座標
@@:
	move.l	#$03+%0001_00_000000,d4	;パターンコード
	IOCS	_BGTEXTST		;プット
	addq.l	#1,d2			;Ｘ座標＋＋
	cmpi.l	#20+11,d2		;右端まできてなければループ
	bne	@b
	move.l	#$0a+%0001_00_000000,d4	;右パターンコード
	IOCS	_BGTEXTST		;プット

	move.l	#19,d2			;Ｘ座標リセット

	addq.l	#1,d3			;Ｙ座標＋＋
	cmpi.l	#5+18,d3		;下まできてなければループ
	bne	@b
*---------------------------------------*
	move.l	#19,d2			;Ｘ座標
	moveq.l	#23,d3			;Ｙ座標
@@:
	move.l	#$03+%0001_00_000000,d4	;下パターンコード
	IOCS	_BGTEXTST		;プット
	addq.l	#1,d2			;Ｘ座標＋＋
	cmpi.l	#20+11,d2		;右端まできてなければループ
	bne	@b
	move.l	#$0a+%0001_00_000000,d4	;右下パターンコード
	IOCS	_BGTEXTST		;プット
*---------------------------------------*
	move.l	#20,d2			;Ｘ座標
	moveq.l	#4,d3			;Ｙ座標
@@:
	move.l	#$2e+%0001_00_000000,d4
	IOCS	_BGTEXTST
*---------------------------------------*
tmemo_ret:
	movem.l	(sp)+,d1-d4
	rts

*********************************************************
*
*	１６ｃｈレベルメーター
*
level_meter:
*********************************************************
	movem.l	d1/d3/a1,-(sp)

	moveq.l	#0,d1
	move.b	d3,d1			;ベロシティ値
	moveq.l	#0,d3

	moveq.l	#0,d7
	movea.l	a5,a1
	adda.l	#midich,a1
	move.b	(a1,d2.w),d7		;d7.b=チャンネル番号

	movea.l	a5,a1
	adda.l	#ch_vol,a1
	move.b	(a1,d7.w),d3		;ボリューム値乗算
	mulu.w	d3,d1
	lsr.w	#7,d1			;掛けたのを割る /128

	movea.l	a5,a1
	adda.l	#ch_expr,a1
	move.b	(a1,d7.w),d3		;エクスプレッション値乗算
	mulu.w	d3,d1
	lsr.w	#7,d1			;掛けたのを割る /128

	move.b	GS_VOL(a5),d3		;マスターボリューム値乗算
	mulu.w	d3,d1
	lsr.w	#7,d1			;掛けたのを割る /128

	lea.l	level,a1
	move.b	d1,(a1,d7.w)		;ワークに書き込む

	movem.l	(sp)+,d1/d3/a1
	rts

*********************************************************
*
*	１６ｃｈレベルメーター減退
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

	move.w	#%01_0110_0000,R21	;同時アクセス
	lea.l	level,a1
	move.w	#16-1,d2
lm_ch_lp:
	move.b	(a1,d2.w),d1
	lsr.b	#3,d1
	sub.b	d1,(a1,d2.w)		;値を減退
	tst.b	(a1,d2.w)		;メーターが落ち切ったらスキップ
	bge	@f
	clr.b	(a1,d2.w)
	bra	lm_ch_brk
@@:
	moveq.l	#0,d3
	move.b	(a1,d2.w),d3		;値を読み込む
	lsr.w	#3,d3			;８で割る
	lea.l	TVRAM,a2		;初期座標設定
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
*	スペクトラムアナライザー
*
speana:
*********************************************************
	movem.l	d0-d7/a1-a3,-(sp)

	moveq.l	#0,d4
	movea.l	a5,a1			;a1.l=RCDワーク先頭
	adda.l	#vel,a1			;a1.l=ベロシティデータ先頭
	move.b	(a1,d2.w),d4		;d4.b=ベロシティ値
	moveq.l	#0,d3

	moveq.l	#0,d7
	movea.l	a5,a1
	adda.l	#midich,a1
	move.b	(a1,d2.w),d7		;d7.b=チャンネル番号

	movea.l	a5,a1
	adda.l	#ch_vol,a1
	move.b	(a1,d7.w),d3		;ボリューム値乗算
	mulu.w	d3,d4
	lsr.w	#7,d4			;掛けたのを割る /128

	movea.l	a5,a1
	adda.l	#ch_expr,a1
	move.b	(a1,d7.w),d3		;エクスプレッション値乗算
	mulu.w	d3,d4
	lsr.w	#7,d4			;掛けたのを割る /128

	move.b	GS_VOL(a5),d3		;マスターボリューム値乗算
	mulu.w	d3,d4
	lsr.w	#7,d4			;掛けたのを割る /128

	add.b	#16,d4			;すこし値を加算
	cmpi.b	#128,d4
	bls	@f
	move.b	#127,d4
@@:
	RANDOM	#9*3,d0			;乱数減算
	sub.b	d0,d4

	tst.b	d4			;計算結果が範囲を越えていたらカット
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
*右
sp_right_set:
	move.l	d4,-(sp)

	movea.l	a5,a3			;a1.l=RCDワーク先頭
	adda.l	#ch_panpot,a3		;a1.l=パンポットデータ先頭
	moveq.l	#0,d3
	move.b	(a3,d7.w),d3		;d3.b=パンポット値
	move.l	d3,-(sp)
	cmpi.b	#64,d3
	bcc	@f
	add.w	d3,d3
	mulu.w	d3,d4
	lsr.w	#7,d4			;掛けたのを割る
@@:
*---------------------------------------*
*右斜面
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
*左斜面
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
*左
sp_left_set:
	move.l	(sp)+,d3
	move.l	(sp)+,d4

	subi.b	#64,d3
	bls	@f
	move.b	#64,d5
	sub.b	d3,d5
	add.w	d5,d5
	mulu.w	d5,d4
	lsr.w	#7,d4			;掛けたのを割る
@@:
*---------------------------------------*
*右斜面
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
*左斜面
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
*	スペクトラムアナライザー減退
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

	move.w	#%01_0110_0000,R21	;同時アクセス
	lea.l	speana_r,a1
	move.w	#13-1,d2
spr_hz_lp:
	move.b	(a1,d2.w),d1
	lsr.b	#3,d1
	sub.b	d1,(a1,d2.w)		;値を減退
	tst.b	(a1,d2.w)		;メーターが落ち切ったらスキップ
	bge	@f
	clr.b	(a1,d2.w)
	bra	spr_hz_brk
@@:
	moveq.l	#0,d3
	move.b	(a1,d2.w),d3		;値を読み込む
	lsr.w	#3,d3			;８で割る
	lea.l	TVRAM,a2		;初期座標設定
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
	sub.b	d1,(a1,d2.w)		;値を減退
	tst.b	(a1,d2.w)		;メーターが落ち切ったらスキップ
	bge	@f
	clr.b	(a1,d2.w)
	bra	spl_hz_brk
@@:
	moveq.l	#0,d3
	move.b	(a1,d2.w),d3		;値を読み込む
	lsr.w	#3,d3			;８で割る
	lea.l	TVRAM,a2		;初期座標設定
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
*	各種パラメータを初期化
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
*配列
	lea.l	rhy_flags,a1
	move.w	#64*6/4-1,d1
@@:	clr.l	(a1)+
	dbra	d1,@b
*---------------------------------------*
*ミキサー画面書き直し

	move.w	#%01_1111_0000,R21
	move.l	#TVRAM+(1024*16*5/8+7),a1	;書き始めアドレス

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
*	再演奏開始
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
*	演奏開始
*
play:
*********************************************************
	clr.l	sts(a5)
	rts

*********************************************************
*
*	演奏終了
*
music_end:
*********************************************************
	movea.l	end(a5),a1
	jsr	(a1)
	rts

*********************************************************
*
*	一時停止
*
stop:
*********************************************************
	move.l	#1,sts(a5)
	rts

*********************************************************
*
*	一時停止／演奏開始トグル
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
*	早送り
*
cue:
*********************************************************
	move.l	#3,sts(a5)
	rts

*********************************************************
*
*	早送り／演奏開始トグル
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
*	バッファ演奏
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
*	フェードアウト
*
fade_out:
*********************************************************
	move.w	#15,fade_time(a5)
	move.b	#128,fade_count(a5)

	rts

*********************************************************
*
*	ＲＣＤバージョンエラー終了
*
rcd_ver_err:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_ver_err
	move.w	#1,(sp)
	DOS	_EXIT2

*********************************************************
*
*	ＲＣＤが常駐していないエラー終了
*
rcd_no_stay:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_no_rcd
	move.w	#1,-(sp)
	DOS	_EXIT2

*********************************************************
*
*	演奏していないエラー終了
*
no_playing:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_no_playing
	move.w	#1,-(sp)
	DOS	_EXIT2

*********************************************************
*
*	MCP未対応エラー終了
*
mcp_err:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_mcp_err
	move.w	#1,-(sp)
	DOS	_EXIT2

*********************************************************
*
*	音源種類エラー終了
*
gs_err:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_gs_err
	move.w	#1,-(sp)
	DOS	_EXIT2

*********************************************************
*
*	使用法表示終了
*
usage:
*********************************************************
	PRINT	#mes_title
	PRINT	#mes_usage
	move.w	#2,-(sp)
	DOS	_EXIT2

*********************************************************
*
*	演奏停止終了
*
stop_and_quit:
*********************************************************
	bsr	music_end
	bra	quit

*********************************************************
*
*	常駐終了
*
quit:
*********************************************************
	move.l	ssp_buf,sp

	lea.l	tpalet_buf,a1		;テキストパレット復帰
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

	move.l	crt_mode,d1		;画面モード復帰
	IOCS	_CRTMOD

	move.w	fn_mode,-(sp)		;ファンクション表示復帰
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
*	データ領域
*
data_section:
*********************************************************
	.data
		.even
		.include	mixser.s
*---------------------------------------*
*スライダーテーブル
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
*明るさ可変なパレット指定
lightflg_tbl:
		.dc.b	0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		.dc.b	0,1,1,1,1,0,0,0,0,0,0,0,0,1,1,0
		.dc.b	0,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,2
*---------------------------------------*
*調文字列
key:		.dc.b	'c* ',0,'g* ',0,'d* ',0,'a* ',0,'e* ',0
		.dc.b	'b* ',0,'f#*',0,'c#*',0,'c* ',0,'f* ',0
		.dc.b	'b$*',0,'e$*',0,'a$*',0,'d$*',0,'g$*',0
		.dc.b	'c$*',0,'am ',0,'em ',0,'bm ',0,'f#m',0
		.dc.b	'c#m',0,'g#m',0,'d#m',0,'a#m',0,'am ',0
		.dc.b	'dm ',0,'gm ',0,'cm ',0,'fm ',0,'b$m',0
		.dc.b	'e$m',0,'abm',0
*---------------------------------------*
*文字列データ
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
*メッセージ
mes_titlebar:	.dc.b	'ver.1.12 Copyright 1993,94 T-miyamae',0
mes_title:	.dc.b	'X68k GSR:  RC Selector & Display for GS v1.12 (C)1993,94 by T-miyamae',CR,LF,0
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
mes_no_rcd:	.dc.b	'RCD が常駐していません。',CR,LF,0
mes_no_playing:	.dc.b	'演奏していません。',CR,LF,0
mes_ver_err:	.dc.b	'RCD のバージョンが違います。',CR,LF,0
mes_mcp_err:	.dc.b	'申し訳ありませんが MCPファイルには対応しておりません。',CR,LF,0
mes_gs_err:	.dc.b	'Module TypeがSC-55に設定(RCC -TS)されていません。',CR,LF,0
		.even
*---------------------------------------*
*ヘルプ
mes_help:
	.dc.b	'                              ',0
	.dc.b	'     ＧＳＲ version 1.12      ',0
	.dc.b	'                              ',0
	.dc.b	' ▼主な連絡先                 ',0
	.dc.b	'                              ',0
	.dc.b	'    MEET-NET    : MEET0001    ',0
	.dc.b	'    NIFTY-Serve : KHB15202    ',0
	.dc.b	'    KHB15202@niftyserve.or.jp ',0
	.dc.b	'                              ',0
	.dc.b	' ▼サポートＢＢＳ             ',0
	.dc.b	'                              ',0
	.dc.b	'    MEET-NET                  ',0
	.dc.b	'       (03)5384-1962 (24h)    ',0
	.dc.b	'       300～14400bps          ',0
	.dc.b	'                              ',0
	.dc.b	'                              ',0
	.dc.b	'   (C) by みやまえ Sep.1994   ',0
	.dc.b	'                              ',0
		.even
*---------------------------------------*
env_str:	.dc.b	'GSR',0
env_value:	.ds.b	256
tbuf:		.ds.b	128		;文字列用テンポラリ
tbuf2:		.ds.b	128		;文字列用テンポラリ
		.even
*---------------------------------------*
*各種変数
fstart_flag:	.dc.b	1
		.bss
		.even
crt_mode:	.ds.l	1		;起動時の画面モード
cnoteptr:	.ds.l	1		;ノートランニングポインタ２
start_time:	.ds.l	1		;ＧＳＲ起動時のONTIME値
vel_ontime	.ds.l	1		;ベロシティメーター用ONTIME値
lv_ontime:	.ds.l	1		;レベルメーター用ONTIME値
sp_ontime:	.ds.l	1		;スペアナ用ONTIME値
sc_ptn_time:	.ds.l	1		;液晶ディスプレイパターンの時間管理
sc_str_time:	.ds.l	1		;液晶ディスプレイ文字列の時間管理
sc_rol_time:	.ds.l	1		;液晶ディスプレイ文字列スクロールの時間管理
sc_rol_pointer:	.ds.l	1		;液晶ディスプレイスクロール文字ポインタ
loop_time:	.ds.l	1		;１ループに費やした時間
run_time:	.ds.l	1		;演奏時間
rhy_pointer:	.ds.l	1		;リズムパートノート表示管理用ポインタ
fn_mode:	.ds.l	1		;起動時のファンクション表示モード
max_step:	.ds.l	1		;最大総ステップ
max_time:	.ds.l	1		;総演奏時間
ssp_buf:	.ds.l	1		;システムスタックポインタバッファ
ps_trk:		.ds.w	1		;表示トラック
gsinst_ren	.ds.w	1		;液晶ディスプレイ文字列の長さ
light:		.ds.b	1		;パネルの明るさ
note_shift:	.ds.b	1		;表示オクターブシフト値
brink_flag:	.ds.b	1		;"PLAY"点滅フラグ
tcoron_flag:	.ds.b	1		;経過時間':'点滅フラグ
vel_flag:	.ds.b	1		;ベロシティーメーター落下許可フラグ
lv_flag:	.ds.b	1		;レベルメーター落下許可フラグ
sp_flag:	.ds.b	1		;スペアナ落下許可フラグ
memo_mode:	.ds.b	1		;0=note 1=track-memo 2=memo 3=help
kbclr_flag:	.ds.b	1		;キーボードバッファクリア要求フラグ
pause_flag	.ds.b	1		;一時停止フラグ
sc_ptn_flag:	.ds.b	1		;液晶ディスプレイパターン表示中フラグ
sc_str_flag:	.ds.b	1		;液晶ディスプレイ文字列表示中フラグ
sc_rol_count:	.ds.b	1		;液晶ディスプレイ文字列スクロールカウント
timebase:	.ds.b	1		;タイムベース値
opt_n:		.ds.b	1		;-nオプションフラグ
mode:		.ds.b	1		;0=セレクタモード 1=パネルモード
vel_speed:	.ds.b	TRK_NUM		;ベロシティー落下速度
		.even
*---------------------------------------*
*パラメータ
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
*バッファ
tpalet_buf:	.ds.w	16		;テキストパレット退避領域
rhy_flags:	.ds.b	(1+1+4)*64
sc_mes:		.ds.b	128		;55液晶ディスプレイ文字列バッファ
level:		.ds.b	16		;16chレベルメーター値
		.ds.b	10		;dummy
speana_r:	.ds.b	13		;スペクトラムアナライザー(right)値
		.ds.b	19		;dummy
speana_l:	.ds.b	13		;スペクトラムアナライザー(left)値
		.ds.b	19		;dummy
*---------------------------------------*
	.stack
	.even
		.ds.b	8*1024
u_sp:


	.end
