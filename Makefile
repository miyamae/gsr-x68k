#
#	Makefile for GSR
#
#			by T-miyamae
#

ALL = GSR.x
OBJ = gsr_main.o font7seg.o font_mini.o font4x8.o font8x16.o font_sc.o \
      sub.o step.o tm_c.o gsr_sprite.o sc88map.o rcdcheck.o options.o \
      selector.o pp_12x12a.o pp_12x16a.o compare.o
LIB = libgnu.l libc.l libiocs.l libdos.l

$(ALL) : $(OBJ)
	hlk -s -l -o $(ALL) $(OBJ) $(LIB)
%.o : %.s
	has -u -b -w2 -g $<
#	has -u -b -w2 -g -p $<
%.o : %.c
	gcc -c -O -Wall -g \
	-fomit-frame-pointer \
	-fstrength-reduce \
	-fforce-mem  \
	-fcombine-regs \
	-finline-functions \
	$<
