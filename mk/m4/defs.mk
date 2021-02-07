# begin here
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

SetShell
ECHO = Echo
MKDIR = Mkdir
RM = Rm
CP = Cp
MV = Mv
PERL = Perl

ifndef PERL_VER
PERL_VER = 5.8.7
endif

CDSENV = CdsEnv
SKILLPP = Skillpp

####################
# Suffixes

OBJSUFFIX = ObjSuffix
ARSUFFIX = ArSuffix
SLSUFFIX = SlSuffix
EXESUFFIX = ExeSuffix

####################
# Librarypatterns

_LIBPATTERNS = ArPattern SlPattern 
.LIBPATTERNS = $(_LIBPATTERNS)

####################
# Lex & Yacc

LEX = Lex
LEX.l = $(LEX) $(LFLAGS) -t
YACC = Yacc
YACC.y = $(YACC) $(YFLAGS)

####################
#  Temprary fix for bison error
BISON = Bison

####################
# Compilation

CC = CcCompiler
CXX = CxxCompiler

CPPFLAGS = CppFlags
CPPFLAGS_DEBUG = CppFlagsDebug
CPPFLAGS_OPT = CppFlagsOpt

PLATFORM_CCFLAGS = CcFlags
PLATFORM_CXXFLAGS = CxxFlags

ifdef CEDA_64_BIT
CFLAGS += -DCEDA_64_BIT
CXXFLAGS += -DCEDA_64_BIT
CPPFLAGS += -DCEDA_64_BIT
endif 

CFLAGS = $(LOCAL_BUILD_CFLAGS) $(TARGET_CFLAGS) $(ADDITIONAL_BUILD_CFLAGS) $(PLATFORM_CCFLAGS)
CFLAGS_DEBUG = CcFlagsDebug
CFLAGS_OPT = CcFlagsOpt
CFLAGS_OPT_LESSER = CcFlagsOptLesser

CXXFLAGS = $(LOCAL_BUILD_CXXFLAGS) $(TARGET_CXXFLAGS) $(ADDITIONAL_BUILD_CXXFLAGS) $(PLATFORM_CXXFLAGS)
CXXFLAGS_DEBUG = CxxFlagsDebug
CXXFLAGS_OPT = CxxFlagsOpt
CXXFLAGS_OPT_LESSER = CxxFlagsOptLesser

CXXLINKFLGS = CxxLinkFlgs

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

SystemIncludePath
INCLUDEPATHOPTION = $(LOCAL_BUILD_INCLUDEPATH:%=IncludeOption%)
INCLUDEPATHOPTION += $(EXTRA_INCLUDEPATH:%=IncludeOption%)
INCLUDEPATHOPTION += $(INCLUDEPATH:%=IncludeOption%)
PREINCLUDEPATHOPTION += $(PREINCLUDEPATH:%=IncludeOption%)
CINCLUDEPATHOPTION = $(CINCLUDEPATH:%=IncludeOption%)
CXXINCLUDEPATHOPTION = $(CXXINCLUDEPATH:%=IncludeOption%)
CFLAGS += $(TARGET_INCLUDEPATH:%=IncludeOption%) $(PREINCLUDEPATHOPTION) $(INCLUDEPATHOPTION) $(CINCLUDEPATHOPTION)
CXXFLAGS += $(TARGET_INCLUDEPATH:%=IncludeOption%) $(PREINCLUDEPATHOPTION) $(INCLUDEPATHOPTION) $(CXXINCLUDEPATHOPTION)

COMMON_SYSTEM_LIBS = CommonSystemLibs
COMMON_SYSTEM_ARCHIVE_LIBS = CommonSystemArchiveLibs
COMMON_SYSTEM_SHLIBS = CommonSystemShLibs

INCLUDELIBDIROPTION = IncludeLibdirOption

LOCAL_BUILD_LIBSPATH += .
LIBSPATHOPTION += $(LOCAL_BUILD_LIBSPATH:%=IncludeLibdirOption%)
LIBSPATHOPTION += $(EXTRA_LIBSPATH:%=IncludeLibdirOption%)
LIBSPATHOPTION += $(LOCAL_LIBSPATH:%=IncludeLibdirOption%)
LIBSPATHOPTION += $(LIBSPATH:%=IncludeLibdirOption%)
LIBSOPTION += $(LOCAL_BUILD_LIBS:%=LibOptionPrefix%LibOptionSuffix)
LIBSOPTION += $(EXTRA_LIBS:%=LibOptionPrefix%LibOptionSuffix)
LIBSOPTION += $(LOCAL_LIBS:%=LibOptionPrefix%LibOptionSuffix)
LIBSOPTION += $(LIBS:%=LibOptionPrefix%LibOptionSuffix)

CompilerSetup


####################
# Static libraries

AR = ArLinker
ARFLAGS = ArFlags
LIBPREFIX = LibPrefix
LIBBASENAME = LibBaseName

ArDefs

####################
# Shared libraries

SHLIBPATHVAR = ShlibPathVar
SYSTEMSHLIBPATH = SystemShlibPath

SlDefs

####################
# Targets

OBJS = $(patsubst %.c, %ObjSuffix, $(filter %.c, $(SRCS)))
OBJS += $(patsubst %.cc, %ObjSuffix, $(filter %.cc, $(SRCS)))
OBJS += $(patsubst %.cpp, %ObjSuffix, $(filter %.cpp, $(SRCS)))
OBJS += $(patsubst %.cxx, %ObjSuffix, $(filter %.cxx, $(SRCS)))
OBJS += $(filter %ObjSuffix, $(SRCS))

NONLIBOBJS = $(patsubst %.c, %ObjSuffix, $(filter %.c, $(NONLIBSRCS)))
NONLIBOBJS += $(patsubst %.cc, %ObjSuffix, $(filter %.cc, $(NONLIBSRCS)))
NONLIBOBJS += $(patsubst %.cpp, %ObjSuffix, $(filter %.cpp, $(NONLIBSRCS)))
NONLIBOBJS += $(patsubst %.cxx, %ObjSuffix, $(filter %.cxx, $(NONLIBSRCS)))
NONLIBOBJS += $(filter %ObjSuffix, $(NONLIBSRCS))

INSTALL_ROOT = $(LOCAL_ROOT)
INSTALL_BINDIR = $(LOCAL_ROOT)/bin.$(ARCH)
INSTALL_LIBDIR = $(LOCAL_ROOT)/lib.$(ARCH)
INSTALL_INCLUDEDIR = $(LOCAL_ROOT)/include

REALCLEAN = core *~

####################
# Executables

ExeDefs

ExecFlags
