# $Id: Makefile,v 1.1 2004/08/25 20:34:04 cvs Exp $
#
# GNU Makefile - psql_service
# For MinGW + MSYS
#
# (c) 2004 Hans Oesterholt-Dijkema <hdnews -at- gawab.com>
#

VERSION=0.01
PACKAGE=spodcxx

### Define variables here!

### Prefixes

### Targets

T1=$(OS)/libspod$(LIB)
T1_OBJ=$(OS)/spod_parser.cxx$(OBJ) $(OS)/spod_html.cxx$(OBJ) $(OS)/md5.cxx$(OBJ)
T1_C_OBJ=$(OS)/md5.c$(OBJ)
T1_HDRS=spod_parser.h spod_html.h md5.h

T2=$(OS)/spod2html$(EXE)
T2_OBJ=$(OS)/spod2html.cxx$(OBJ)
T2_LIBS=-lspod $(LIBS)

HEADERS=$(T1_HDRS)

#TEST=test/critsec_test$(EXE)
#TEST_OBJ=test/critsec_test.cxx$(OBJ)
#TEST_LIBS=-lhcritsec $(LIBS)

DOC_SOURCES=

TARGET_LIBS=$(T1)
TARGET_BINS=$(T2)

### Include generic Makefile.in part here!

include Makefile.in

### Start Specific makefile part here!

all: $(TARGET_LIBS) $(TARGET_BINS) $(TEST) doc
	@echo done $(NEED_PTHREADS)
	
### critsec
	
$(T1): $(T1_OBJ) $(T1_C_OBJ)
	$(AR) $(ARFLAGS) $(T1) $(T1_OBJ) $(T1_C_OBJ)
	$(RANLIB) $(T1)

$(T1_OBJ): $(OS)/%.cxx$(OBJ): %.cxx 
	$(CXX) $(CFLAGS) -c $< -o $@

$(T1_C_OBJ): $(OS)/%.c$(OBJ): %.c
	$(CC) $(CFLAGS) -c $< -o $@
	
$(T2): $(T2_OBJ) $(T1)
	$(LD) -o $(T2) $(T2_OBJ) $(LDFLAGS) $(T2_LIBS)
	
$(T2_OBJ): $(OS)/%.cxx$(OBJ): %.cxx
	$(CXX) $(CFLAGS) -c $< -o $@
	
#$(TEST): $(TEST_OBJ) $(T1) 
#	$(LD) -o $(TEST) $(TEST_OBJ) $(LDFLAGS) $(TEST_LIBS)
	
#$(TEST_OBJ): test/%.cxx$(OBJ): %.cxx
#	if [ ! -d test ]; then $(mkdir_p) test; fi
#	$(CXX) $(CFLAGS) -c $< -o $@
	
#test: $(TEST)
#	$(TEST)

	
### clean

clean: stdclean
	$(rm) -r test
	$(rm) $(T2_C)

### install

install: all docinst
	$(mkdir_p) $(PREFIX_LIB)
	$(mkdir_p) $(PREFIX_INC)
	$(mkdir_p) $(PREFIX_BIN)
	for t in $(TARGET_BINS); do $(cp) $$t $(PREFIX_BIN); done
	for t in $(TARGET_LIBS); do $(cp) $$t $(PREFIX_LIB); done
	for h in $(HEADERS); do $(cp) $$h $(PREFIX_INC); done

