#include <basic0.h>
#include <doslib.h>
#include "c:/develop/rc/rcddef.h"

/******************************************/
/*  global variables external definitions */
/******************************************/

extern struct RCD_HEAD	*rcd;
extern char version[5];

int	tm_stco[256];
int	tm_sttm[256];
int	tm_stcc;
int	tm_btmp;
int	tm_base;

/* 24072:25926| 26/33*/
/*
main()
{
	int co,tm,a,b,c,i;
	rcd_check();

	a=ONTIME();for(i=0;i<2;i++){co=max_step();}	b_iprint(co);
	b=ONTIME();for(i=0;i<512;i++){tm=tm_caluc(co);}	b_iprint(tm);
	c=ONTIME();b_iprint(b-a);b_iprint(c-b);
	b_sprint("\r\n");

	EXIT();
}
*/
/*******************/
/* total step read */
/*******************/
/*
int	step_cluc2(unsigned char *ptr,int len)
{
	int	i,b,pp,a,ct;
	unsigned char	c,d,ls,le,lt;
static int	lx[32];

	if(rcd->fmt==0){ls=0xfc;le=0xfb;lt=0xfa;}else{ls=0xf9;le=0xf8;lt=0xe7;}

	pp=0;a=0;b=1;i=0;
	while(i<len){
		c=ptr[i];
		if( c<0xf0 ){
			if( c==lt ){
				if(tm_stcc<255){
					d=ptr[i+2];
					tm_stco[tm_stcc]=a;tm_sttm[tm_stcc]=(d*tm_btmp)>>6;tm_stcc++;
				}
			}
			d=ptr[i+1];a=a+d;

		}else{
			if( c==ls ){
				if(pp<16){
					lx[pp]=a;a=0;pp++;
				}
			}
			if( c==le ){
				if(pp>0){pp--;
					d=ptr[i+1];if(ct==0||ct==255){ct=1;}
					a=lx[pp]+(a*ct);
				}
			}
			if( c==0xfc && ls!=c ){
				int	ii,jj,ct;
				jj=i;
resame:
				ii=ptr[jj+3]*256+(ptr[jj+2]&0xfc)-44;

				if(ii<len && jj!=ii){
					jj=ii;if(ptr[ii]==0xfc){goto resame;}
					while(ii<len){
						c=ptr[ii];
						if( c<0xf0 ){
							if( c==lt){
								if(tm_stcc<255){
									d=ptr[ii+2];
									tm_stco[tm_stcc]=a;tm_sttm[tm_stcc]=(d*tm_btmp)>>6;tm_stcc++;
								}
							}
							d=ptr[ii+1];a=a+d;
						}else{
							if( c==ls ){
								if(pp<16){
									lx[pp]=a;a=0;pp++;
								}
							}
							if( c==le ){
								if(pp>0){pp--;
									ct=ptr[ii+1];if(ct==0||ct==255){ct=1;}
									a=lx[pp]+(a*ct);
								}
							}
							if( c>=0xfc ){break;}
						}
						ii+=4;
					}
				}
			}
		}
		i+=4;
	}

	for(i=0;i<pp;i++){
		a+=lx[i];
	}
	return(a);
}
*/
/*******************/
/* total step read */
/*******************/
int	step_cluc2(unsigned char *ptr,int len)
{
	int	i,tst,retad,loopnst;
	unsigned char	ls,le,lt;
static	int	loopad[17],looprad[17];
static	unsigned char	loopco[17];

	if(rcd->fmt==0){ls=0xfc;le=0xfb;lt=0xfa;}else{ls=0xf9;le=0xf8;lt=0xe7;}

	tst=0;i=0;loopnst=0;retad=0;
	while(i<len){
		unsigned char c=ptr[i];
		if( c<0xf0 ){
			unsigned char d;
			if( c==lt ){
				if(tm_stcc<256){
					unsigned char d=ptr[i+2];
					tm_stco[tm_stcc]=tst;tm_sttm[tm_stcc]=(d*tm_btmp)>>6;
					tm_stcc++;
				}
			}
			d=ptr[i+1];tst=tst+d;
		}else{
			if( c==ls ){
				if(loopnst<16){
					loopnst++;
					loopco[loopnst]=0;
					loopad[loopnst]=i;looprad[loopnst]=retad;
				}
			}
			if( c==le ){
				if(loopnst>0){
					unsigned char d=ptr[i+1];
					loopco[loopnst]++;
					if(loopco[loopnst]==d ||d==255 || d==0){
						loopnst--;
					}else{
						i=loopad[loopnst];retad=looprad[loopnst];
					}
				}
			}

			if( c==0xfc ){
				if(retad!=0){
					i=retad;retad=0;
				}else{
					retad=i;
next:
					i=(ptr[i+3]<<8)+(ptr[i+2]&0xfc)-44;
					if(retad==i){retad=0;}else{
						if(ptr[i]==0xfc){goto next;}
						i-=4;
					}
				}
			}

			if( c==0xfd ){
				if(retad!=0){i=retad;retad=0;}
			}
		}
		i+=4;
	}
	return(tst);
}

/***************************/
int	max_step()
{
	int	st,max=0,i,ln,lc;
	unsigned char	*p,*pp;
	pp=rcd->data_adr;
	tm_stcc=0;

	if(rcd->fmt==0){
		tm_btmp=pp[0x21];tm_base=pp[0x20];
		lc=9;
		pp+=0x100;
	}else{
		tm_btmp=pp[0x1c1];tm_base=pp[0x1c0];
		if(pp[0x1e6]!=0){tm_base+=pp[0x1e7]*256;}
		if(rcd->fmt==1){lc=18;}else{lc=36;}
		pp+=0x586;
	}

	for(i=0;i<lc;i++){
		if(rcd->fmt==0){
			ln=0;while(pp[ln]<0xfe){ln+=4;}
			p=pp;ln+=4;pp+=ln;
		}else{
			ln=(pp[0]&0xfc)+((pp[0]&3)*256+pp[1])*256;
			p=pp+44;pp+=ln;ln-=44;
		}
		st=step_cluc2(p,ln);
		if( st>max ){max=st;}
	}

	tm_sort();

	return max;
}

/***************************/
/*
void tm_sort()
{
	int a,i,j;

	for(i=0;i<tm_stcc-1;i++){
		for(j=i+1;j<tm_stcc;j++){
			if(tm_stco[i]>tm_stco[j]){
				a=tm_stco[i];tm_stco[i]=tm_stco[j];tm_stco[j]=a;
				a=tm_sttm[i];tm_sttm[i]=tm_sttm[j];tm_sttm[j]=a;
			}
		}
	}
	for(i=tm_stcc-1;i>0;i--){tm_stco[i]=tm_stco[i]-tm_stco[i-1];}
}
*/
/***************************/
/*
int	tm_caluc(int co)
{
	int	i=0,tim=0,tempo,st,tbase;

	tbase=tm_base>>4;tempo=tm_btmp*tbase;

	while(co>0 && i<tm_stcc){
		st=tm_stco[i];
		if(co>st){
			if(st>0){co-=st;tim+= st*750/tempo;}
		}else{
			break;
		}
		tempo=tm_sttm[i++]*tbase;
	}
	if(co>0){tim+= co*750/tempo;}

	return tim;
}
*/
/******************/
/* end of program */
/******************/
