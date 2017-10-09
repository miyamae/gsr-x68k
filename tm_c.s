	.text
	.even

	.xref	_tm_base
	.xref	_tm_btmp
	.xref	_tm_stcc
	.xref	_tm_sttm
	.xref	_tm_stco

	.xdef	_tm_sort
	.xdef	_tm_caluc


_tm_sort:
	movem.l	d3-d7,-(sp)
	moveq.l	#0,d5
	moveq.l	#0,d3
	move.w	_tm_stcc+2,d6
	beq	tms80

	move.w	d6,d7
	subq.w	#1,d7

	lea	_tm_stco,a1
	lea	_tm_sttm+2,a0
	bra	tms50
tms10:
	move.w	d5,d4
	move.w	d3,d1
	bra	tms30
tms20:
	move.l	(a1,d3.w),d2
	move.l	(a1,d1.w),d0
	cmp.l	d2,d0
	bge	tms30
	move.l	d0,(a1,d3.w)
	move.l	d2,(a1,d1.w)
	move.w	(a0,d3.w),d0
	move.w	(a0,d1.w),(a0,d3.w)
	move.w	d0,(a0,d1.w)
tms30:
	addq.w	#4,d1
	addq.w	#1,d4
	cmp.w	d4,d6
	bgt	tms20

	addq.w	#4,d3
	addq.w	#1,d5
tms50:
	dbra	d7,tms10

*diff
	lea	_tm_stco,a0
	move.w	_tm_stcc+2,d5

	move.w	d5,d0
	asl.w	#2,d0
	lea	(a0,d0.w),a1
	lea	-4(a0,d0.w),a0

	subq.w	#1,d5
	bra	tms70
tms60:
	move.l	-(a0),d1
	sub.l	d1,-(a1)
tms70:
	dbra	d5,tms60
tms80:
	movem.l	(sp)+,d3-d7
	rts


_tm_caluc:
	movem.l	d3-d7/a4-a5,-(sp)
	move.l	28+4(sp),d3	*step count
	moveq.l	#0,d5		*total time

*	move.l	d5,d7
	move.l	d5,d1
	move.l	d5,d0

	move.w	_tm_btmp+2,d7	*tempo
	move.w	_tm_base+2,d4	*timebase
	lsr.w	#4,d4
	mulu.w	d4,d7

*	cmp.w	#114,d7
*	bgt	@f
*	move.w	#115,d7
@@:

	lea	_tm_stco,a4
	lea	_tm_sttm,a5
	move.w	_tm_stcc+2,d6	*stcc

	bra	tmcl40
tmcl10:
	move.l	(a4)+,d1
	cmp.l	d3,d1
	bge	tmcl50
	tst.l	d1
	ble	tmcl20
	sub.l	d1,d3

	move.l	d1,d0	*6000/8=750
	add.l	d0,d0
	add.l	d1,d0
	asl.l	#4,d0
	sub.l	d1,d0
	asl.l	#3,d0
	sub.l	d1,d0

*	divu.w	d7,d0
*	ext.l	d0
*	add.l	d0,d5

	swap	d0		*divu.l	d7.w,d0.l
	clr.w	d1
	move.w	d0,d1
	beq	@f
	divu.w	d7,d1
	swap	d1
	move.w	d1,d0
@@:
	swap	d0
	divu.w	d7,d0
	move.w	d0,d1
	add.l	d1,d5

tmcl20:
	move.l	(a5)+,d7
	mulu.w	d4,d7

*	cmp.w	#114,d7
*	bgt	@f
*	move.w	#115,d7
@@:
tmcl40:
	tst.l	d3
	beq	tmcl60
	dbra	d6,tmcl10
tmcl50:
	move.l	d3,d0	*6000/16=375
	add.l	d0,d0
	add.l	d3,d0
	asl.l	#4,d0
	sub.l	d3,d0
	asl.l	#3,d0
	sub.l	d3,d0

*	divu.w	d7,d0
*	and.l	#$ffff,d0
*	add.l	d0,d5

	swap	d0		*divu.l	d7.w,d0.l
	clr.w	d1
	move.w	d0,d1
	beq	@f
	divu.w	d7,d1
	swap	d1
	move.w	d1,d0
@@:
	swap	d0
	divu.w	d7,d0
	move.w	d0,d1
	add.l	d1,d5

tmcl60:
	move.l	d5,d0

	movem.l	(sp)+,d3-d7/a4-a5
	rts

	.end
