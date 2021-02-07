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


ECHO = echo -e
MKDIR = mkdir -p
RM = rm -f
CP = cp -f -p
MV = mv -f
PERL = perl

ifndef PERL_VER
PERL_VER = 5.8.7
endif

CDSENV = /hped/builds/bin/cds-env
SKILLPP = $(CPP) -C -P

####################
# Suffixes

OBJSUFFIX = .obj
ARSUFFIX = .lib
SLSUFFIX = .dll
EXESUFFIX = .exe

####################
# Librarypatterns

_LIBPATTERNS = %.lib %.dll 
.LIBPATTERNS = $(_LIBPATTERNS)

####################
# Lex & Yacc

LEX = flex
LEX.l = $(LEX) $(LFLAGS) -t
YACC = byacc
YACC.y = $(YACC) $(YFLAGS)

####################
#  Temprary fix for bison error
BISON = bison

####################
# Compilation

CC = cl
CXX = cl

CPPFLAGS =  /D_AFXDLL /DNO_MALLOC_MACRO /DWIN32 /D_WIN32 /U_WINDOWS /DWINVER=0x0500 /D_MBCS 
CPPFLAGS_DEBUG = 
CPPFLAGS_OPT = /DOPT_BUILD /DNDEBUG

PLATFORM_CCFLAGS =  /Zi /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_WARNINGS  /favor:blend /D_WIN64 /D_MACHINE:x64  /Wp64  /W4 /nologo /Dfar=far_p /Dnear=near_p /Fd$(PROJECT_NAME).pdb /TC
PLATFORM_CXXFLAGS =  /Zi /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_WARNINGS  /favor:blend /D_WIN64 /D_MACHINE:x64  /Wp64  /W4 /nologo /Dfar=far_p /Dnear=near_p /Fd$(PROJECT_NAME).pdb /TP

ifdef CEDA_64_BIT
CFLAGS += -DCEDA_64_BIT
CXXFLAGS += -DCEDA_64_BIT
CPPFLAGS += -DCEDA_64_BIT
endif 

CFLAGS = $(LOCAL_BUILD_CFLAGS) $(TARGET_CFLAGS) $(ADDITIONAL_BUILD_CFLAGS) $(PLATFORM_CCFLAGS)
CFLAGS_DEBUG =  /MD /Zi /D _DEBUG /D DEBUG
CFLAGS_OPT =  /MD /O2  /Oy- /D NDEBUG
CFLAGS_OPT_LESSER =  /MD /O1  /Oy- /D NDEBUG

CXXFLAGS = $(LOCAL_BUILD_CXXFLAGS) $(TARGET_CXXFLAGS) $(ADDITIONAL_BUILD_CXXFLAGS) $(PLATFORM_CXXFLAGS)
CXXFLAGS_DEBUG =  /MD /Zi /D _DEBUG /D DEBUG
CXXFLAGS_OPT =  /MD /O2  /Oy- /D NDEBUG
CXXFLAGS_OPT_LESSER =  /MD /O1  /Oy- /D NDEBUG

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


INCLUDEPATHOPTION = $(LOCAL_BUILD_INCLUDEPATH:%=/I%)
INCLUDEPATHOPTION += $(EXTRA_INCLUDEPATH:%=/I%)
INCLUDEPATHOPTION += $(INCLUDEPATH:%=/I%)
PREINCLUDEPATHOPTION += $(PREINCLUDEPATH:%=/I%)
CINCLUDEPATHOPTION = $(CINCLUDEPATH:%=/I%)
CXXINCLUDEPATHOPTION = $(CXXINCLUDEPATH:%=/I%)
CFLAGS += $(TARGET_INCLUDEPATH:%=/I%) $(PREINCLUDEPATHOPTION) $(INCLUDEPATHOPTION) $(CINCLUDEPATHOPTION)
CXXFLAGS += $(TARGET_INCLUDEPATH:%=/I%) $(PREINCLUDEPATHOPTION) $(INCLUDEPATHOPTION) $(CXXINCLUDEPATHOPTION)

COMMON_SYSTEM_LIBS = 
COMMON_SYSTEM_ARCHIVE_LIBS = 
COMMON_SYSTEM_SHLIBS = WSock32 kernel32 user32 gdi32 winspool comdlg32 advapi32 shell32 ole32 oleaut32 uuid odbc32 odbccp32

INCLUDELIBDIROPTION = /LIBPATH:

LOCAL_BUILD_LIBSPATH += .
LIBSPATHOPTION += $(LOCAL_BUILD_LIBSPATH:%=/LIBPATH:%)
LIBSPATHOPTION += $(EXTRA_LIBSPATH:%=/LIBPATH:%)
LIBSPATHOPTION += $(LOCAL_LIBSPATH:%=/LIBPATH:%)
LIBSPATHOPTION += $(LIBSPATH:%=/LIBPATH:%)
LIBSOPTION += $(LOCAL_BUILD_LIBS:%=%.lib)
LIBSOPTION += $(EXTRA_LIBS:%=%.lib)
LIBSOPTION += $(LOCAL_LIBS:%=%.lib)
LIBSOPTION += $(LIBS:%=%.lib)




####################
# Static libraries

AR = ar
ARFLAGS = rc
LIBPREFIX = 
LIBBASENAME = $(basename $(TARGET))


LINK.a = $(AR) $(ARFLAGS)

define UPDATE_LIBRARY_COMMAND
if [ -f $(1) ] ; then $(LIBCMD) $(1) $(2); else $(LIBCMD) /out:$(1) $(2); fi
endef


####################
# Shared libraries

SHLIBPATHVAR = PATH
SYSTEMSHLIBPATH = 

LINK=link  /MAP /DEBUG /FIXED:NO /INCREMENTAL:NO /OPT:REF  
LIBCMD = lib
WINDUMPEXTS = $(PERL) '$(shell cygpath -w $(ceda_mk_dir)/bin/winDumpExts)'
LIBLINK = $(LIBSPATHOPTION) $(LIBSOPTION)
CPPFLAGS += /D$(basename $(TARGET))_DLL_BUILD

SLLIBVER = $(CEDALIBVER)

ifdef debug
DEBUGOPTION = /debug   
endif

define SL_LINK_C

	if [ "X$(MANAGES_WIN32_EXPORTS)" != "X" ] ; then \
	echo "Linking without using dumpbin.  Creating simple def file using ."; \
	echo "NAME $(4)$(SLLIBVER).dll" > $(4)$(SLLIBVER).def ; \
	echo "$(LIBCMD) /nologo $(2) $(LIBLINK)" ; \
	$(LIBCMD) /nologo $(2) $(LIBLINK) ; \ 
	else
	$(WINDUMPEXTS) $(4)$(SLLIBVER).dll $(2) > $(4)$(SLLIBVER).def ; \
	if [ "X$(WIN32EXTRADEFS)" != "X" ] ; then cat $(WIN32EXTRADEFS) >> $(4)$(SLLIBVER).def ; fi ; \
	if [ "X$(WIN32EXTRADEFS)" != "X" ] ; then $(LIBCMD) /nologo /def:$(4)$(SLLIBVER).def $(2) $(LIBLINK) $(3:%=%.lib) ; fi ; \
	if [ "X$(WIN32EXTRADEFS)" = "X" ] ; then $(LIBCMD) /nologo /def:$(4)$(SLLIBVER).def $(2) $(LIBLINK) ; fi ; \
	fi
	$(LINK) /nologo $(DEBUGOPTION) /dll $(TARGET_C_LDFLAGS) $(C_LDFLAGS) /out:$(1) $(4)$(SLLIBVER).exp $(2) $(TARGET_C_LDFLAGS_POST) $(C_LDFLAGS_POST) $(LIBLINK) $(3:%=%.lib) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib) $(MSVCRT)
	cp -f  $(4)$(SLLIBVER).exp $(4).exp
	cp -f  $(4)$(SLLIBVER).lib $(4).lib

endef

define SL_LINKLIB_CXX

	if [ "X$(MANAGES_WIN32_EXPORTS)" != "X" ] ;  then \
	echo "MANAGES_WIN32_EXPORTS is set, SL_LINKLIB_CXX does nothing."; \
	else \
	$(WINDUMPEXTS) $(4)$(SLLIBVER).dll @objfiles.txt > $(4)$(SLLIBVER).def ; \
	if [ "X$(WIN32EXTRADEFS)" != "X" ] ; then cat $(WIN32EXTRADEFS) >> $(4)$(SLLIBVER).def ; fi ; \
	if [ "X$(WIN32EXTRADEFS)" != "X" ] ; then $(LIBCMD) /nologo /def:$(4)$(SLLIBVER).def @objfiles.txt $(LIBLINK) $(3:%=%.lib) ; fi ;\
	if [ "X$(WIN32EXTRADEFS)" = "X" ] ; then $(LIBCMD) /nologo /def:$(4)$(SLLIBVER).def @objfiles.txt $(LIBLINK) ; fi ; \
	if [ "X$(SLLIBVER)" != "X" ] ; then cp -f  $(4)$(SLLIBVER).exp $(4).exp ; \
	cp -f  $(4)$(SLLIBVER).lib $(4).lib ; fi ; \
	fi
endef

define SL_LINKDLL_CXX

	if [ "X$(MANAGES_WIN32_EXPORTS)" != "X" ] ;  then \
	echo "$(LINK) /nologo $(DEBUGOPTION) /dll /NOENTRY  $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) /out:$(1) @objfiles.txt $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(LIBLINK) $(3:%=%.lib) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib) $(MSVCRT)"; \
	$(LINK) /nologo /NOENTRY  $(DEBUGOPTION) /dll $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) /out:$(1) @objfiles.txt $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(LIBLINK) $(3:%=%.lib) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib) $(MSVCRT); \
	if [ "X$(SLLIBVER)" != "X" ] ; then cp -f  $(4)$(SLLIBVER).exp $(4).exp ; \
	cp -f  $(4)$(SLLIBVER).lib $(4).lib ; fi ; \
	else \
	echo "$(LINK) /nologo $(DEBUGOPTION) /dll $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) /out:$(1) $(4)$(SLLIBVER).exp @objfiles.txt $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(LIBLINK) $(3:%=%.lib) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib) $(MSVCRT)"; \
	$(LINK) /nologo $(DEBUGOPTION) /dll $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) /out:$(1) $(4)$(SLLIBVER).exp @objfiles.txt $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(LIBLINK) $(3:%=%.lib) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib) $(MSVCRT); \
	fi

endef

define SL_LINK_CXX
	$(call SL_LINKLIB_CXX,$(1),$(2),$(3),$(4))
	$(call SL_LINKDLL_CXX,$(1),$(2),$(3),$(4))
endef

define SL_MAKE_OBJFILES
	@$(ECHO) $(strip $(1)) > objfiles.txt
endef

define SL_MAKE_EXP
touch $(3)
endef



####################
# Targets

OBJS = $(patsubst %.c, %.obj, $(filter %.c, $(SRCS)))
OBJS += $(patsubst %.cc, %.obj, $(filter %.cc, $(SRCS)))
OBJS += $(patsubst %.cpp, %.obj, $(filter %.cpp, $(SRCS)))
OBJS += $(patsubst %.cxx, %.obj, $(filter %.cxx, $(SRCS)))
OBJS += $(filter %.obj, $(SRCS))

NONLIBOBJS = $(patsubst %.c, %.obj, $(filter %.c, $(NONLIBSRCS)))
NONLIBOBJS += $(patsubst %.cc, %.obj, $(filter %.cc, $(NONLIBSRCS)))
NONLIBOBJS += $(patsubst %.cpp, %.obj, $(filter %.cpp, $(NONLIBSRCS)))
NONLIBOBJS += $(patsubst %.cxx, %.obj, $(filter %.cxx, $(NONLIBSRCS)))
NONLIBOBJS += $(filter %.obj, $(NONLIBSRCS))

INSTALL_ROOT = $(LOCAL_ROOT)
INSTALL_BINDIR = $(LOCAL_ROOT)/bin.$(ARCH)
INSTALL_LIBDIR = $(LOCAL_ROOT)/lib.$(ARCH)
INSTALL_INCLUDEDIR = $(LOCAL_ROOT)/include

REALCLEAN = core *~

####################
# Executables



define CCLINKEXE
$(CC_LINKPREFIX) $(LINK) /nologo  /MANIFEST  /MACHINE:X64  $(DEBUGOPTION) $(TARGET_C_LDFLAGS) $(C_LDFLAGS) /out:$( )$(1) $(2) $(LIBLINK) $(3:%=%.lib) $(TARGET_C_LDFLAGS_POST) $(C_LDFLAGS_POST) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib)

endef

define CXXLINKEXE
$(CXX_LINKPREFIX) $(LINK) /nologo  /MANIFEST  /MACHINE:X64 $(DEBUGOPTION) $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) /out:$( )$(1) $(2) $(LIBLINK) $(3:%=%.lib) $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib)

endef


