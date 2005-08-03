CC=xlC
CXX=xlC

EXE=
OBJ=.o
LIB=.a
SHL=.so
D_SHL_EXT:=-DSHL_EXT=\"$(SHL)\"

CFLAGS=-c -O -I.
CPPFLAGS=-c -O -I.
LDFLAGS=-L. -L$(OS)
LD=xlC
SHLD=xlC
SHLDFLAGS=-shared

AR=ar
ARFLAGS=cr
RANLIB=ranlib
