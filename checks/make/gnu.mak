CC=gcc
CXX=g++

EXE=
OBJ=.o
LIB=.a
SHL=.so
D_SHL_EXT:=-DSHL_EXT=\"$(SHL)\"

CFLAGS=-c -O -Wall -I.
CPPFLAGS=-c -O -Wall -I.
LDFLAGS=-L. -L$(OS)
LD=g++
SHLD=g++
SHLDFLAGS=-shared

AR=ar
ARFLAGS=cr
RANLIB=ranlib
