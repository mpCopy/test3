# $Header: /cvs/wlv/src/cedamk/mk/m4/defs.mk,v 1.92 2011/04/20 16:46:17 jont Exp $


ifndef VERBOSE
npd = --no-print-directory
at = @
endif

.DELETE_ON_ERROR:

#some general variables to be abto to substitute spaces

empty:= 
space:= $(empty) $(empty)


# This really doesn't belong here, but this is the one place that is
# used by just about everything.
DEFAULT_SOURCEROOT = projects

# Another item that might be better elsewhere...
# Define whether a 64-bit pass or a 32-bit pass in a combined 
# build is happening
ifdef COMBINE_BUILD
ifdef CEDA_64_BIT
COMBINE_BUILD_64_BIT_PASS=1
else
COMBINE_BUILD_32_BIT_PASS=1
endif
else
NOT_COMBINE_BUILD=1
endif

ifndef MAKE_DEFS_MK
MAKE_DEFS_MK=make-defs-$(ARCH).mk
endif

###############################################################################

ifndef HPEESOF_DEV_ROOT
HPEESOF_DEV_ROOT = $(dir $(HPEESOF_DIR))build
endif

ifndef TRUMPET_DIR
TRUMPET_DIR=tprod
endif

ifndef TPROD_DIR
TPROD_DIR=$(dir $(HPEESOF_DIR))/$(TRUMPET_DIR)
endif

ifndef TPRODCD_DIR
TPRODCD_DIR=$(TPROD_DIR)cd
endif

ifndef ADSPROD_DIR
ADSPROD_DIR=$(dir $(HPEESOF_DIR))/adsprod
endif

ifndef MARKETING_VER
MARKETING_VER=370
VER=370
endif


ifndef RELEASE_VER
RELEASE_VER=2009U1
endif

ifndef IC_RELEASE_VER
IC_RELEASE_VER=2009
endif

ifndef GG_MARKETING_VER
GG_MARKETING_VER=434
endif

ifndef IC_MARKETING_VER
IC_MARKETING_VER=650
endif

ifndef AM_MARKETING_VER
AM_MARKETING_VER=210
endif



# HPEESOF_DEV_ROOT_UNIX is used in targets (only), as GNU make needs Unix
# paths in target names.
ifndef HPEESOF_DEV_ROOT_UNIX
ifeq (win,$(findstring win,$(ARCH)))
HPEESOF_DEV_ROOT_UNIX := $(shell cygpath -u $(HPEESOF_DEV_ROOT))
else
HPEESOF_DEV_ROOT_UNIX := $(HPEESOF_DEV_ROOT)
endif
endif

ifndef BUILD_PREFIX
BUILD_PREFIX=/hped/builds
endif

ifndef SITE_ROOT
SITE_ROOT=$(BUILD_PREFIX)/$(CEDA_SITE)
endif


ifndef BLDVER
ifdef VER
BLDVER=$(VER)
else
# This is a weird value, to show developers that they have not set BLDVER.
BLDVER=666
endif
endif

ifndef BLDREV
ifdef REV
BLDREV=$(REV)
else
BLDREV=rday
endif
endif

# Make sure VER and REV are set
ifndef VER
# Incestuous, yes.
VER=$(BLDVER)
endif
ifndef REV
# Incestuous, yes.
REV=$(BLDREV)
endif


ifndef CEDALIBVER
ifeq (win,$(findstring win,$(ARCH)))
ifdef debug
CEDALIBVER := $(shell  echo  ${BLDVER} | cut -c1-2  )d
endif
endif
ifndef CEDALIBVER
CEDALIBVER := $(shell  echo ${BLDVER} | cut -c1-2  )
endif
endif

# default versions for Cadence builds
ifndef CDS_VERSIONS
ifeq (hpux,$(findstring hpux,$(ARCH)))
CDS_VERSIONS=5.1.0 
else
# We will just use 6.1.0 context file for Cadence IC 6.1.1 and 6.1.2.
# CDS_VERSIONS=5.1.0 6.1.0 6.1.1 6.1.2
# 6.1.4 requires a 64bit context in addition to the 32bit context.
CDS_VERSIONS=5.1.0 6.1.0 6.1.4 6.1.5
endif
endif


###############################################################################

####################
# Utilities

SHELL = /bin/ksh
ECHO = echo
MKDIR = mkdir -p
RM = rm -f
CP = cp -f -p
MV = mv -f
PERL = perl

ifndef PERL_VER
PERL_VER = 5.8.7
endif

CDSENV = /hped/builds/bin/cds-env
SKILLPP = /hped/local/bin/cpp -traditional -C -P

####################
# Suffixes

OBJSUFFIX = .o
ARSUFFIX = .a
SLSUFFIX = .so
EXESUFFIX = 

####################
# Librarypatterns

_LIBPATTERNS = lib%.a $(LIBPREFIX)%$(SLSUFFIX) 
.LIBPATTERNS = $(_LIBPATTERNS)

####################
# Lex & Yacc

LEX = lex
LEX.l = $(LEX) $(LFLAGS) -t
YACC = yacc
YACC.y = $(YACC) $(YFLAGS)

####################
#  Temprary fix for bison error
BISON = bison

####################
# Compilation

CC = cc
CXX = CC

CPPFLAGS = -DSYSV -DSUN_57 -D_solaris26
CPPFLAGS_DEBUG = 
CPPFLAGS_OPT = -DOPT_BUILD -DNDEBUG

PLATFORM_CCFLAGS = -Aa -KPIC
PLATFORM_CXXFLAGS = -KPIC  +w2

ifdef CEDA_64_BIT
CFLAGS += -DCEDA_64_BIT
CXXFLAGS += -DCEDA_64_BIT
CPPFLAGS += -DCEDA_64_BIT
endif 

CFLAGS = $(LOCAL_BUILD_CFLAGS) $(TARGET_CFLAGS) $(ADDITIONAL_BUILD_CFLAGS) $(PLATFORM_CCFLAGS)
CFLAGS_DEBUG = -g -xs
CFLAGS_OPT = -xO2 -DNDEBUG -DOPT_BUILD
CFLAGS_OPT_LESSER = -xO1 -DNDEBUG -DOPT_BUILD

CXXFLAGS = $(LOCAL_BUILD_CXXFLAGS) $(TARGET_CXXFLAGS) $(ADDITIONAL_BUILD_CXXFLAGS) $(PLATFORM_CXXFLAGS)
CXXFLAGS_DEBUG = -g -xs
CXXFLAGS_OPT = -xO2 -DNDEBUG -DOPT_BUILD
CXXFLAGS_OPT_LESSER = -xO1 -DNDEBUG -DOPT_BUILD

CXXLINKFLGS = 

ifndef CEDA_QT_DEBUG_FLG
ifdef debug
CEDA_QT_DEBUG_FLG = -DQT_DEBUG
else
CEDA_QT_DEBUG_FLG = -DQT_NO_DEBUG
endif # debug
endif # CEDA_QT_DEBUG_FLG

ifdef debug
CPPFLAGS += $(CPPFLAGS_DEBUG) $(CEDA_QT_DEBUG_FLG)
CFLAGS += $(CFLAGS_DEBUG) $(CEDA_QT_DEBUG_FLG) 
CXXFLAGS += $(CXXFLAGS_DEBUG) $(CEDA_QT_DEBUG_FLG)
else
CPPFLAGS += $(CPPFLAGS_OPT) $(CEDA_QT_DEBUG_FLG)
CFLAGS += $(CFLAGS_OPT) $(CEDA_QT_DEBUG_FLG) 
CXXFLAGS += $(CXXFLAGS_OPT) $(CEDA_QT_DEBUG_FLG)
endif


INCLUDEPATHOPTION = $(LOCAL_BUILD_INCLUDEPATH:%=-I%)
INCLUDEPATHOPTION += $(EXTRA_INCLUDEPATH:%=-I%)
INCLUDEPATHOPTION += $(INCLUDEPATH:%=-I%)
PREINCLUDEPATHOPTION += $(PREINCLUDEPATH:%=-I%)
CINCLUDEPATHOPTION = $(CINCLUDEPATH:%=-I%)
CXXINCLUDEPATHOPTION = $(CXXINCLUDEPATH:%=-I%)
CFLAGS += $(TARGET_INCLUDEPATH:%=-I%) $(PREINCLUDEPATHOPTION) $(INCLUDEPATHOPTION) $(CINCLUDEPATHOPTION)
CXXFLAGS += $(TARGET_INCLUDEPATH:%=-I%) $(PREINCLUDEPATHOPTION) $(INCLUDEPATHOPTION) $(CXXINCLUDEPATHOPTION)

COMMON_SYSTEM_LIBS = socket nsl sunmath m
COMMON_SYSTEM_ARCHIVE_LIBS = 
COMMON_SYSTEM_SHLIBS = 

INCLUDELIBDIROPTION = -L

LOCAL_BUILD_LIBSPATH += .
LIBSPATHOPTION += $(LOCAL_BUILD_LIBSPATH:%=-L%)
LIBSPATHOPTION += $(EXTRA_LIBSPATH:%=-L%)
LIBSPATHOPTION += $(LOCAL_LIBSPATH:%=-L%)
LIBSPATHOPTION += $(LIBSPATH:%=-L%)
LIBSOPTION += $(LOCAL_BUILD_LIBS:%=-l%)
LIBSOPTION += $(EXTRA_LIBS:%=-l%)
LIBSOPTION += $(LOCAL_LIBS:%=-l%)
LIBSOPTION += $(LIBS:%=-l%)


ifdef CEDA_64_BIT
CFLAGS += -m64
CXXFLAGS += -m64
EXEFLAGS += -m64
SLFLAGS += -m64
else
CFLAGS += -m32
CXXFLAGS += -m32
EXEFLAGS += -m32
SLFLAGS += -m32
endif



####################
# Static libraries

AR = CC -xar
ARFLAGS = -o
LIBPREFIX = lib
LIBBASENAME = lib$(basename $(TARGET))


LINK.a = $(AR) $(ARFLAGS)

define UPDATE_LIBRARY_COMMAND
$(LINK.a)  $(1) $(2)
endef


####################
# Shared libraries

SHLIBPATHVAR = LD_LIBRARY_PATH
SYSTEMSHLIBPATH = 

LINK.csl = $(CC) -G $(SLFLAGS)
LINK.cxxsl = $(CXX) -G  $(SLFLAGS)

SLLIBVER =

define SL_LINK_C

$(LINK.csl) $(TARGET_C_LDFLAGS) $(C_LDFLAGS) -o $(1) $(2) $(TARGET_C_LDFLAGS_POST) $(C_LDFLAGS_POST) $(LIBSPATHOPTION) $(3:%=-l%) $(LIBSOPTION) $(COMMON_SYSTEM_LIBS:%=-l%) $(COMMON_SYSTEM_SHLIBS:%=-l%)

endef

define SL_LINK_CXX

$(LINK.cxxsl) $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) -o $(1) $(2) $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(LIBSPATHOPTION) $(3:%=-l%) $(LIBSOPTION) 

endef

define SL_MAKE_OBJFILES
	@$(ECHO) "Prepare to Link"
endef 

define SL_MAKE_EXP
touch $(3)
endef



####################
# Targets

OBJS = $(patsubst %.c, %.o, $(filter %.c, $(SRCS)))
OBJS += $(patsubst %.cc, %.o, $(filter %.cc, $(SRCS)))
OBJS += $(patsubst %.cpp, %.o, $(filter %.cpp, $(SRCS)))
OBJS += $(patsubst %.cxx, %.o, $(filter %.cxx, $(SRCS)))
OBJS += $(filter %.o, $(SRCS))

NONLIBOBJS = $(patsubst %.c, %.o, $(filter %.c, $(NONLIBSRCS)))
NONLIBOBJS += $(patsubst %.cc, %.o, $(filter %.cc, $(NONLIBSRCS)))
NONLIBOBJS += $(patsubst %.cpp, %.o, $(filter %.cpp, $(NONLIBSRCS)))
NONLIBOBJS += $(patsubst %.cxx, %.o, $(filter %.cxx, $(NONLIBSRCS)))
NONLIBOBJS += $(filter %.o, $(NONLIBSRCS))

INSTALL_ROOT = $(LOCAL_ROOT)
INSTALL_BINDIR = $(LOCAL_ROOT)/bin.$(ARCH)
INSTALL_LIBDIR = $(LOCAL_ROOT)/lib.$(ARCH)
INSTALL_INCLUDEDIR = $(LOCAL_ROOT)/include

REALCLEAN = core *~

####################
# Executables

EXEFLAGS += 
EXEPREFIX =
LINK.ccexe = $(CC)  $(EXEFLAGS)
LINK.cxxexe = $(CXX)  $(EXEFLAGS)

ifndef RATIONAL_FLAGS
RATIONAL_FLAGS = -recursion-depth-limit=20000 -cache-dir=$(shell pwd)  -always-use-cache-dir=yes  
endif
ifndef PURIFY
PURIFY = purify $(RATIONAL_FLAGS)  
endif
ifndef QUANTIFY
QUANTIFY = quantify  $(RATIONAL_FLAGS)
endif
ifndef PURECOV
PURECOV = purecov  $(RATIONAL_FLAGS)
endif

define CCLINKEXE
$(CC_LINKPREFIX) $(LINK.ccexe) $(TARGET_C_LDFLAGS) $(C_LDFLAGS) -o $(1) $(2) $(LIBSPATHOPTION) $(3:%=-l%) $(LIBSOPTION) $(TARGET_C_LDFLAGS_POST) $(C_LDFLAGS_POST) $(COMMON_SYSTEM_LIBS:%=-l%) $(COMMON_SYSTEM_SHLIBS:%=-l%)
       if [ $(XRT_AUTH) ] ; then   eexrt_auth $(OBJPATH)/$(1); fi
endef

define CXXLINKEXE
$(CXX_LINKPREFIX) $(LINK.cxxexe) $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) -o $(1) $(2) $(LIBSPATHOPTION) $(3:%=-l%) $(LIBSOPTION) $(CXXLINKFLGS) $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(COMMON_SYSTEM_LIBS:%=-l%) $(COMMON_SYSTEM_SHLIBS:%=-l%)
       if [ $(XRT_AUTH) ] ; then   eexrt_auth $(OBJPATH)/$(1); fi
endef




ifndef debug
EXEFLAGS += -s
endif

