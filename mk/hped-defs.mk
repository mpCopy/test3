# $Header: /cvs/wlv/src/cedamk/mk/hped-defs.mk,v 1.174 2010/02/17 17:37:59 build Exp $

ifndef HPED_DEFS_INCLUDED
# Mark that we're included this file
HPED_DEFS_INCLUDED = 1
###############################################################################
ifdef PTOLEMY_INSTALL
SLLIBVER=
CEDALIBVER=
endif



ifdef CEDA_64_BIT
VPATH +=:/usr/lib64:/usr/lib/64:$(SRCPATH)
else
VPATH +=:$(SRCPATH)
endif

ifndef CEDA_BIN_DIR
ifdef CEDA_64_BIT
CEDA_BIN_DIR=bin/$(ARCH)
else
CEDA_BIN_DIR=bin
endif
endif

ifeq (win,$(findstring win,$(ARCH)))
ifndef NO_EXTENDED_DEBUG_FLAGS
ifdef CEDA_64_BIT
CXXFLAGS_DEBUG +=  /Gm /EHsc /RTC1 
CFLAGS_DEBUG += /Gm /EHsc /RTC1 
else
CXXFLAGS_DEBUG += /GS /RTC1
CFLAGS_DEBUG += /GS /RTC1
endif
endif
endif


CPPFLAGS += $(INCL)
CFLAGS += $(MYCFLAGS)
CXXFLAGS += $(MYCPLUSFLAGS)
LIBSPATHOPTION += $(EXTRA_LINK_FLAGS)

PREINCLUDEPATH += $(SRCPATH)

INCLUDEPATH += $(INSTALL_INCLUDEDIR)
INCLUDEPATH += $(LOCAL_BUILD_MIRROR_INCLUDEPATH)
INCLUDEPATH += $(HPEESOF_DEV_ROOT)/include

LIBSPATH += $(LOCAL_ROOT)/lib.$(ARCH)
LIBSPATH += $(LOCAL_BUILD_MIRROR_LIBSPATH)
LIBSPATH += $(HPEESOF_DEV_ROOT)/lib.$(ARCH)

# Variable to define comparison tool used (dsdiff/mafia)
COMPARISONTOOL +=

# cedaversion.h which defines VER and REV.  Others just include that
# file as needed.
CPPFLAGS += -DVER=\"$(BLDVER)\" -DREV=\"$(BLDREV)\" -DPROD_IS_$(PRODDESIG)

# This can be improved by building a package instead
ifndef DEVEL_LIBRARYTYPE
HPEESOF_LIBDIR=$(dir $(HPEESOF_DIR))/lib
installtoprod:
ifeq (win,$(findstring win,$(ARCH)))
	$(MKDIR) $(HPEESOF_DIR)/bin
	eecopy $(INSTALL_LIBDIR)/$(LIBBASENAME)$(SLLIBVER)$(SLSUFFIX) $(HPEESOF_DIR)/bin
	eecopy $(INSTALL_LIBDIR)/$(LIBBASENAME).lib $(HPEESOF_LIBDIR)
else
	$(MKDIR) $(HPEESOF_DIR)/lib/$(ARCH)
	eecopy $(INSTALL_LIBDIR)/$(LIBBASENAME)$(SLSUFFIX) $(HPEESOF_DIR)/lib/$(ARCH)
	eecopy $(INSTALL_LIBDIR)/$(LIBBASENAME)$(SLSUFFIX) $(HPEESOF_LIBDIR)
ifeq ($(ARCH),aix4)
	eecopy $(INSTALL_LIBDIR)/$(LIBBASENAME).a $(HPEESOF_LIBDIR)
endif
endif
else
installtoprod:
	@echo "Installtoprod empty now"
endif


#################### 
# Default System Settings
#


ifndef CEDA_SITE
CEDA_SITE=$(shell hped-site)
endif

ifeq (win,$(findstring win,$(ARCH)))
ifndef CEDA_DRIVE
CEDA_DRIVE=s:
endif
endif

ifeq (win,$(findstring win,$(ARCH)))
ifndef debug
SLFLAGS += -s
endif
endif

###########################################################################
### TARGETTYPE stuff
###
### supported TARGET-TYPES
###
### xrt, lapi, qt, lapi_qt, qt4

### do not change TARGET_TYPE below, without also changing multimk
### at 2 ${basename}_TARGET_TYPE occurences
ifdef TARGET_TYPE
ifeq ($(TARGET_TYPE),xrt)
XRT_AUTH=1
endif
$(TARGET_TYPE)-INCLUDES = 1
LIBSPATH += $($(TARGET_TYPE)-LIBSPATH)
CXX_LDFLAGS_POST = $($(TARGET_TYPE)-CXX_LDFLAGS_POST)
C_LDFLAGS_POST = $($(TARGET_TYPE)-C_LDFLAGS_POST)
LIBS += $($(TARGET_TYPE)-LIBS)
CPPFLAGS += $($(TARGET_TYPE)-CPPFLAGS)
CXXFLAGS += $($(TARGET_TYPE)-CXXFLAGS)
CFLAGS += $($(TARGET_TYPE)-CFLAGS)
endif

##########################################################################
### motif subsystem stuff
###

ifdef MOTIF_INCLUDES
motif-INCLUDES = 1;
endif

ifdef MOTIF_LIBS
$(warning "warning : MOTIF_LIBS variable not supported any more.")
$(warning "   Use [<target>_]TARGET_TYPE instead.")
endif

ifeq ($(ARCH),aix4)
	motif-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.aix43/include
else
  ifeq (hpux,$(findstring hpux,$(ARCH)))
	motif-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.3/include
  else
    ifeq (linux,$(findstring linux,$(ARCH)))
	motif-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.2.3/include /usr/X11R6/include
    else
	motif-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/include
    endif
  endif # hpux
endif # aix

ifdef motif-INCLUDES
INCLUDEPATH += $(motif-INCLUDEPATH)
endif


###########################################################################
### xrt TARGETTYPE stuff
###

ifeq (win,$(findstring win,$(ARCH)))
          xrt-INCLUDEPATH =
          xrt-LIBSPATH =
          xrt-C_LDFLAGS_POST = /SUBSYSTEM:windows apiw.res
          xrt-CXX_LDFLAGS_POST = /SUBSYSTEM:windows apiw.res
          xrt-LIBS = api gxvt gcls gsl gemx_vt ael tinyxml
else 
# !win32
  ifeq ($(ARCH), aix4)
          xrt-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.aix43/include
          xrt-LIBSPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.aix43/lib
          xrt-C_LDFLAGS_POST = 
          xrt-CXX_LDFLAGS_POST = 
          xrt-LIBS = apist gxvt gcls gsl gemx_vt ael tinyxml Xprinter xrttable
          xrt-LIBS += Xprinter ttf Xm Xpm Xt Xext X11
  else
# !win32 !aix4
    ifeq (hpux,$(findstring hpux,$(ARCH)))
	  ifndef IMAGE_CACHE
		IMAGE_CACHE = $(HPEESOF_DEV_ROOT)/lib.$(ARCH)/ImageCache.o
	  endif
          xrt-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.3/include
          xrt-LIBSPATH=
          xrt-C_LDFLAGS_POST = -L$(HPEESOF_DEV_ROOT)/lib.$(ARCH)
          xrt-C_LDFLAGS_POST += -lapist -lgsl -lgcls -lael -ltinyxml
          xrt-C_LDFLAGS_POST += -lxrttable
          xrt-C_LDFLAGS_POST += -lXpm -lgxvt -lgemx_vt -lXprinter -lttf 
          xrt-C_LDFLAGS_POST +=  $(IMAGE_CACHE)
          xrt-C_LDFLAGS_POST += -Wl,+s -L/usr/lib/X11R5 -L/usr/lib/X11R6
          xrt-C_LDFLAGS_POST += -L$(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.3/lib/
          xrt-C_LDFLAGS_POST += $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.3/lib/libXm.a 
          xrt-C_LDFLAGS_POST += -lXpm 
          xrt-C_LDFLAGS_POST += $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.3/lib/libXt.a 
          xrt-C_LDFLAGS_POST += -lXext -lX11 
          xrt-CXX_LDFLAGS_POST = $(xrt-C_LDFLAGS_POST)
          xrt-LIBS =  
    else
# !win32 !aix4 !hpux
      ifeq (linux,$(findstring linux,$(ARCH)))
          xrt-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.2.3/include /usr/X11R6/include
          ifdef CEDA_64_BIT
              xrt-LIBSPATH = $(HPEESOF_DEV_ROOT)/lib.$(ARCH)/X11R6 /usr/X11R6/lib64
          else
              xrt-LIBSPATH = $(HPEESOF_DEV_ROOT)/lib.$(ARCH)/X11R6 /usr/X11R6/lib
          endif
          xrt-LIBS = apist  gxvt gcls gsl gemx_vt ael tinyxml xrttable pdsutil  Xprinter ttf Xm Xpm Xmu Xp Xt Xext X11 SM ICE  
     else
# !win32 !aix4 !hpux !linux_x86
       ifeq (sun,$(findstring sun,$(ARCH)))
          xrt-INCLUDEPATH=
          xrt-LIBSPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/lib  
          xrt-C_LDFLAGS_POST = -lapist -lgxvt -lgcls -lgsl -lgemx_vt -lael -ltinyxml
          xrt-C_LDFLAGS_POST += -lxrttable 
#          xrt-C_LDFLAGS_POST += -L/usr/openwin/lib -lxrttable 
          xrt-C_LDFLAGS_POST += -lXprinter -lttf -lXpm  
          xrt-C_LDFLAGS_POST += $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/lib/libXm.a 
          xrt-C_LDFLAGS_POST += $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/lib/libXt.a
#          xrt-C_LDFLAGS_POST += /usr/openwin/lib/libX11.a /usr/openwin/lib/libXext.a
          xrt-C_LDFLAGS_POST += -L/usr/openwin/lib -lX11 -lXext
          xrt-C_LDFLAGS_POST += -lICE -lSM -ldl
          xrt-CXX_LDFLAGS_POST = $(xrt-C_LDFLAGS_POST)
          xrt-LIBS =  
        else
# default = !win32 !aix4 !hpux !linux_x86 !sun
          xrt-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/include
          xrt-LIBSPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/lib
          xrt-C_LDFLAGS_POST = 
          xrt-CXX_LDFLAGS_POST = 
          xrt-LIBS = apist gxvt gcls gsl gemx_vt ael tinyxml xrttable Xprinter ttf  Xm Xpm Xt Xext X11
       endif  #sun
      endif   #linux
    endif     #hpux
  endif       #aix
endif         #win32

ifdef xrt-INCLUDES
INCLUDEPATH += $(xrt-INCLUDEPATH)
endif

###########################################################################
### lapi TARGETTYPE stuff
###

ifeq (win,$(findstring win,$(ARCH)))
	  lapi-INCLUDEPATH =
	  lapi-LIBSPATH =
	  lapi-CXX_LDFLAGS_POST = /SUBSYSTEM:windows apiw.res
	  lapi-C_LDFLAGS_POST = /SUBSYSTEM:windows apiw.res
	  lapi-LIBS = api gxvt gcls gsl gemx_vt ael tinyxml
else 
  ifeq ($(ARCH), aix4)
          lapi-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.aix43/include
          lapi-LIBSPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.aix43/lib
          lapi-CXX_LDFLAGS_POST = 
          lapi-C_LDFLAGS_POST = 
          lapi-LIBS = api gxvt gcls gsl gemx_vt ael Xprinter tinyxml
          lapi-LIBS += ttf Xm Xpm Xt Xext X11
  else
# !win32 !aix4
    ifeq (hpux,$(findstring hpux,$(ARCH)))
	  ifndef IMAGE_CACHE
		IMAGE_CACHE = $(HPEESOF_DEV_ROOT)/lib.$(ARCH)/ImageCache.o
	  endif
          lapi-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.3/include
          lapi-LIBSPATH =
          lapi-C_LDFLAGS_POST = -L$(HPEESOF_DEV_ROOT)/lib.$(ARCH)
          lapi-C_LDFLAGS_POST += -lapi -lgsl -lgcls -lael -ltinyxml
          lapi-C_LDFLAGS_POST += -lXpm -lgxvt -lgemx_vt -lXprinter -lttf 
          lapi-C_LDFLAGS_POST += $(IMAGE_CACHE)
          lapi-C_LDFLAGS_POST += -Wl,+s -L/usr/lib/X11R5 -L/usr/lib/X11R6
          lapi-C_LDFLAGS_POST += -L$(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.3/lib/ 
          lapi-C_LDFLAGS_POST += $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.3/lib/libXm.a 
          lapi-C_LDFLAGS_POST += -lXpm   
          lapi-C_LDFLAGS_POST += $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0.3/lib/libXt.a
          lapi-C_LDFLAGS_POST += -lXext -lX11
          lapi-CXX_LDFLAGS_POST = $(lapi-C_LDFLAGS_POST)
          lapi-LIBS = 
    else
# !win32 !aix4 !hpux
      ifeq (linux,$(findstring linux,$(ARCH)))
          lapi-INCLUDEPATH = $(HPEESOF_DEV_ROOT)/include/X11R6/X11 $(HPEESOF_DEV_ROOT)/include/X11R6
          lapi-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.2.3/include /usr/X11R6/include
          ifdef CEDA_64_BIT
              lapi-LIBSPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.2.3/lib $(HPEESOF_DEV_ROOT)/lib.$(ARCH)/X11R6 /usr/X11R6/lib64
          else
             lapi-LIBSPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.2.3/lib $(HPEESOF_DEV_ROOT)/lib.$(ARCH)/X11R6 /usr/X11R6/lib
          endif
          lapi-CXX_LDFLAGS_POST = 
          lapi-C_LDFLAGS_POST = 
          lapi-LIBS = api gxvt gcls gsl gemx_vt ael Xprinter ttf tinyxml Xm Xpm Xmu Xp Xt Xext X11 SM ICE dl
      else
# !win32 !aix4 !hpux !linux_x86
        ifeq (sun,$(findstring sun,$(ARCH)))
          lapi-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/include  
          lapi-LIBSPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/lib
          lapi-CXX_LDFLAGS_POST = -lapi -lgxvt -lgcls -lgsl -lgemx_vt -lael -ltinyxml
          lapi-CXX_LDFLAGS_POST += -lxrttable 
          lapi-CXX_LDFLAGS_POST += -lXprinter -lttf -lXpm  
          lapi-CXX_LDFLAGS_POST += $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/lib/libXm.a 
          lapi-CXX_LDFLAGS_POST += $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/lib/libXt.a 
#          lapi-CXX_LDFLAGS_POST += /usr/openwin/lib/libX11.a /usr/openwin/lib/libXext.a
          lapi-CXX_LDFLAGS_POST += -L/usr/openwin/lib -lX11 -lXext
          lapi-CXX_LDFLAGS_POST += -lICE -lSM -ldl
          lapi-C_LDFLAGS_POST = $(lapi-CXX_LDFLAGS_POST)
          lapi-LIBS = 
        else
# default = !win32 !aix4 !hpux !linux_x86 !sun
          lapi-INCLUDEPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/include
          lapi-LIBSPATH = $(BUILD_PREFIX)/$(CEDA_SITE)/Motif_2.0/lib
          lapi-CXX_LDFLAGS_POST = 
          lapi-C_LDFLAGS_POST = 
          lapi-LIBS = api gxvt gcls gsl gemx_vt ael tinyxml Xprinter ttf Xm Xpm Xt Xext X11
       endif  #sun
      endif   #linux
    endif     #hpux
  endif       #aix
endif         #win32

ifdef lapi-INCLUDES
    INCLUDEPATH += $(lapi-INCLUDEPATH)
endif


##############################################################################
### QT TARGETTYPE specific stuff
###

qt-INCLUDEPATH = /usr/include/X11R5 /usr/include/X11R6 $(INSTALL_INCLUDEDIR)/qt  $(HPEESOF_DEV_ROOT)/include/qt

qt-LIBSPATH = /usr/lib $(INSTALL_LIBDIR)/qt  $(HPEESOF_DEV_ROOT)/lib.$(ARCH)/qt

qt-CXX_LDFLAGS_POST = 
qt-C_LDFLAGS_POST = 

QT_VER=3.3.5
QT_LIB_VER=335
qt3-MOC=$(dir $(HPEESOF_DIR))bin/moc
qt3-UIC=$(dir $(HPEESOF_DIR))bin/uic

ifeq (win,$(findstring win,$(ARCH)))
    qt-LIBS = qt-mt$(QT_LIB_VER) qtmain
else
    qt-LIBS = qt
endif

ifeq (linux,$(findstring linux,$(ARCH)))
    ifdef CEDA_64_BIT
        qt-LIBSPATH  +=  /usr/X11R6/lib64
     else
        qt-LIBSPATH  +=  /usr/X11R6/lib
    endif
    qt-CXXFLAGS += -Wno-long-long
    qt-CFLAGS += -Wno-long-long
    qt-LIBS +=   Xt X11 Xext
endif

ifdef qt-INCLUDES
    INCLUDEPATH += $(qt-INCLUDEPATH)
endif



### QT4 TARGET_TYPE
###
### This is a rough draft.  I don't know whether the library/include stuff is
### right.  In fact, I'm pretty sure it isn't.   tparker

#
# By default, the nightly build's version of Qt 4 (set up by the qt4_install
# CVS project) is used.
#
# Use qt4-QTDIR to point to a Qt installation different from the nightly build's.
#
# Or define qt4-USE_LOCAL_QT_INSTALL to use a local version of qt4_install.
#
qt4-MOC         = $(HPEESOF_DEV_ROOT)/bin.$(ARCH)/qt4/moc$(EXESUFFIX)
qt4-RCC         = $(HPEESOF_DEV_ROOT)/bin.$(ARCH)/qt4/rcc$(EXESUFFIX)
qt4-UIC         = $(HPEESOF_DEV_ROOT)/bin.$(ARCH)/qt4/uic$(EXESUFFIX)
qt4-INCLUDEPATH = $(HPEESOF_DEV_ROOT)/include/qt4-$(ARCH)/include 	$(HPEESOF_DEV_ROOT)/include/qt4/include
qt4-LIBSPATH    = $(HPEESOF_DEV_ROOT)/lib.$(ARCH)/qt4
qt4-LIBS        =

ifdef qt4-QTDIR
    qt4-MOC         = $(qt4-QTDIR)/bin/moc$(EXESUFFIX)
    qt4-RCC         = $(qt4-QTDIR)/bin/rcc$(EXESUFFIX)
    qt4-UIC         = $(qt4-QTDIR)/bin/uic$(EXESUFFIX)
    qt4-INCLUDEPATH = $(qt4-QTDIR)/include
    qt4-LIBSPATH    = $(qt4-QTDIR)/lib
endif

ifdef qt4-USE_LOCAL_QT_INSTALL
    qt4-MOC         = $(LOCAL_ROOT)/bin.$(ARCH)/qt4/moc$(EXESUFFIX)
    qt4-RCC         = $(LOCAL_ROOT)/bin.$(ARCH)/qt4/rcc$(EXESUFFIX)
    qt4-UIC         = $(LOCAL_ROOT)/bin.$(ARCH)/qt4/uic$(EXESUFFIX)
    qt4-INCLUDEPATH = $(INSTALL_INCLUDEDIR)/qt4-$(ARCH)/include $(INSTALL_INCLUDEDIR)/qt4/include
    qt4-LIBSPATH    = $(INSTALL_LIBDIR)/qt4
endif

qt4-CXX_LDFLAGS_POST =
qt4-C_LDFLAGS_POST   =

ifeq (win,$(findstring win,$(ARCH)))
    ifdef debug
        qt4-LIBS += QtCored4 QtGuid4
    else
        qt4-LIBS += QtCore4 QtGui4
    endif
else    # not Windows
    qt4-LIBS += QtCore QtGui
    #
    # Xt is needed by gemx_qt4 for some reason.
    #
    qt4-LIBS += Xt
ifeq (sun,$(findstring sun,$(ARCH)))
    # we need the rendering X libraries too when we implement
    # the vnc font workaround
    #
    qt4-LIBS += X11
    qt4-LIBS += Xrender
endif
endif

ifeq (linux,$(findstring linux,$(ARCH)))
    ifdef CEDA_64_BIT
        qt4-LIBSPATH += /usr/X11R6/lib64
    else
        qt4-LIBSPATH += /usr/X11R6/lib
    endif
    qt4-CXXFLAGS += -Wno-long-long
    qt4-CFLAGS += -Wno-long-long
endif

ifeq (sun,$(findstring sun,$(ARCH)))
    #
    # Qt4 uses some X libraries that are in /usr/sfw/lib on Sun.
    #
ifdef CEDA_64_BIT
    qt4-LIBSPATH += /usr/sfw/lib/64
else
    qt4-LIBSPATH += /usr/sfw/lib
endif
endif

ifdef qt4-INCLUDES
    INCLUDEPATH += $(qt4-INCLUDEPATH)
endif



###########################################################################
### lapi_qt TARGETTYPE
###
### I try to pick up values from the qt4 target's settings as much as I can.
###

lapi_qt-INCLUDEPATH = $(qt4-INCLUDEPATH)
lapi_qt-LIBSPATH    = $(qt4-LIBSPATH)
lapi_qt-CXXFLAGS    = $(qt4-CXXFLAGS)
lapi_qt-CFLAGS      = $(qt4-CFLAGS)

#
# GXVT_NATIVE turns on the native mode of GXVT, which is the version
# of GXVT that uses native X11 or Win32 graphics (rather than Qt
# graphics) in the drawing area.
#
lapi_qt-CPPFLAGS = -DQT -DGXVT_NATIVE

lapi_qt-LIBS = api_qt gxvt_qt gcls gsl gemx_qt4 ael tinyxml $(qt4-LIBS)

ifeq (win,$(findstring win,$(ARCH)))
    lapi_qt-CXX_LDFLAGS_POST = /SUBSYSTEM:console apiq.res
    lapi_qt-C_LDFLAGS_POST   = /SUBSYSTEM:console apiq.res
else   # !win32 
    lapi_qt-LIBS += Xprinter ttf Xm Xpm ICE SM dl
endif

ifeq (linux,$(findstring linux,$(ARCH)))
    #
    # I'm commenting out Xmu and Xp.
    # They aren't needed by my test program, but
    # they might be needed by a more complicated program.
    #  --tparker 2/14/07
    #
    #lapi_qt-LIBS += Xmu Xp
endif  # linux

ifdef lapi_qt-INCLUDES
    INCLUDEPATH += $(lapi_qt-INCLUDEPATH)
endif



### Perl specific stuff
###

perl-INCLUDEPATH = $(INSTALL_INCLUDEDIR)/perl-$(ARCH) $(HPEESOF_DEV_ROOT)/include/perl-$(ARCH)

perl-LIBS += perl

ifndef PERL
PERL = $(HPEESOF_DIR)/tools/bin/perl
endif

PERL_CCOPTS = $(shell $(PERL) -MExtUtils::Embed -e ccopts)
perl-CPPFLAGS = $(filter -D%,$(PERL_CCOPTS))

ifdef perl-INCLUDES
INCLUDEPATH += $(perl-INCLUDEPATH)
endif

ifdef EMBED_PERL
INCLUDEPATH += $(perl-INCLUDEPATH)
LIBS += $(perl-LIBS)
CPPFLAGS += $(perl-CPPFLAGS)
endif

#################################
# Python Includes
##################################

ifdef py-USE_LOCAL_BUILD_PATH
    py-INCLUDEPATH = $(LOCAL_ROOT)/include/python2.5-$(ARCH) $(LOCAL_ROOT)/include/python2.5
endif
 
py-INCLUDEPATH += $(HPEESOF_DEV_ROOT)/include/python2.5-$(ARCH) $(HPEESOF_DEV_ROOT)/include/python2.5
ifdef py-INCLUDES
    INCLUDEPATH += $(py-INCLUDEPATH)
endif

##############################################################################
##### flexlm securitytype stuff
#####

flexlm-LIBS +=  gsec agsl gsl



# do not change SECURITY_TYPE rules without changing multimk
# at 2 ${basename}_SECURITY_TYPE occurences ...

ifdef SECURITY_TYPE
LIBS += $(${SECURITY_TYPE}-LIBS)
endif

ifeq (win,$(findstring win,$(ARCH)))
ifndef WIN_INCLUDE_VAR
WIN_INCLUDE_VAR=$(shell perl -e ' foreach $$dir ( split ( /\;/ , $$ENV{include}) ) {$$dir=`cygpath -s -w  \"$$dir\"`; $$dir =~ s/\\/\\\\/g ; print "-I$$dir  "; }')
endif
endif

ifeq (sun,$(findstring sun,$(ARCH)))
LIBSPATH +=  /opt/SUNWspro12/lib
LIBS +=  Crun
endif


#############################################################################
## STL libs
ifdef CEDA_STL_INC

CXXINCLUDEPATH += $(HPEESOF_DEV_ROOT)/include/stlport  

ifeq (sun,$(findstring sun,$(ARCH)))
STL_COMPILER = sunpro
endif


ifeq (linux,$(findstring linux,$(ARCH)))
CXXFLAGS += -Wno-long-long
CPPFLAGS += -Wno-long-long
STL_COMPILER = gcc
endif # linux_x86


ifeq (hpux,$(findstring hpux,$(ARCH)))
STL_COMPILER = aCC
endif

ifeq (win,$(findstring win,$(ARCH)))
STL_COMPILER = vc
endif

#ifndef STLPORT_LIB
#ifeq (win,$(findstring win,$(ARCH)))
#ifdef debug
#LIBS += stlport_$(STL_COMPILER)_debug
#else
#LIBS += stlport_$(STL_COMPILER)
#endif # debug win32
#else # win32
#LIBS += stlport_$(STL_COMPILER)
#endif 
#else
#LIBS += $(STLPORT_LIB)
#endif

ifndef STLPORT_LIB
ifdef debug
LIBS += stlport_$(STL_COMPILER)_debug
else
LIBS += stlport_$(STL_COMPILER)
endif
else
LIBS += $(STLPORT_LIB)
endif


endif # !CEDA_STL_INC
#############################################################################

ADDONDIR=$(dir $(HPEESOF_DIR))/build/addonpkgs

WEBDIR=$(CDROMROOT)/web_images
RFDE_CDROM=$(CDROMROOT)/$(PLATUC)/RFDE
RAW_CDROMDIR=$(dir $(RAW_CDROMDIR))/install
CDROMDIR=$(dir $(CDROMROOT))/install
RAW_WEBDIR=$(RAW_UNIX_DIR)/$(PRODDESIG)v$(VERSION)/r$(REVISION)/$(BUILDTYPE)/web_images
RAW_ISODIR=$(RAW_UNIX_DIR)/$(PRODDESIG)v$(VERSION)/r$(REVISION)/$(BUILDTYPE)/iso_images
ISODIR=$(CDROMDIR)/iso_images
RAW_DVDDIR=$(RAW_UNIX_DIR)/$(PRODDESIG)v$(VERSION)/r$(REVISION)/$(BUILDTYPE)/dvd
DVDDIR=$(CDROMDIR)/dvd
ADS_DVDDIR=$(CDROMDIR)/dvd/ads
RFDE_DVDDIR=$(CDROMDIR)/dvd/rfde

ifneq (win,$(findstring win,$(ARCH)))
CDROMROOT=$(dir $(HPEESOF_DIR))/install
else
CDROMROOT=$(dir $(HPEESOF_DIR))/cdrom/DISK1
CDROMROOT_DISK2=$(dir $(HPEESOF_DIR))/cdrom/DISK2
endif

ifdef CEDA_64_BIT
BASE_VERSION=$(shell perl -e ' $$short= $$ENV{VERSION}; $$short =~ s/-.*//; print $$short;')
RELEASECDPATH=$(PRODDESIG)v$(BASE_VERSION)/r$(REVISION)/$(BUILDTYPE)/install
else
RELEASECDPATH=$(PRODDESIG)v$(VERSION)/r$(REVISION)/$(BUILDTYPE)/install
endif

ifeq ($(CEDA_SITE),wlv)
RAW_UNIX_DIR=/gfs/wlv/electron/d2/build/rel_images
endif
ifeq ($(CEDA_SITE),sr)
RAW_UNIX_DIR=/gfs/sr/electron/d12/build/rel_images
endif
ifeq ($(CEDA_SITE),gent)
RAW_UNIX_DIR=/tmps/dev250/cdimages
endif
ifeq ($(CEDA_SITE),scs)
RAW_UNIX_DIR=/gfs/scs/spectre/d1/build/rel_images
endif
ifeq ($(CEDA_SITE),ind)
RAW_UNIX_DIR=/gfs/ind/tcsnas02/eesof/india/build/build/rel_images
endif

RAW_CDROMDIR=$(RAW_UNIX_DIR)/$(RELEASECDPATH)

GOODPKGDIR=$(HPEESOF_DEV_ROOT)/goodpackages

ifndef REL_NAME
REL_NAME=ADS
ifeq ($(PRODDESIG),ic)
REL_NAME=ICCAP
endif
endif

CDROMPLATDIR=$(CDROMROOT)/$(PLATUC)/$(REL_NAME)/DISK1/UNIX/$(PLATUC)
COMMON_CDROMPLATDIR=$(CDROMROOT)/$(PLATUC)/$(REL_NAME)/DISK2/UNIX/COMMON


ifndef PLATUC
PLATUC:=$(shell hped-arch -u)
endif
ifeq (win,$(findstring win,$(ARCH)))
CDROMPLATDIR=$(CDROMROOT)
else
CDROMPLATDIR=$(CDROMROOT)/$(PLATUC)/$(REL_NAME)/DISK1/UNIX/$(PLATUC)
COMMON_CDROMPLATDIR=$(CDROMROOT)/$(PLATUC)/$(REL_NAME)/DISK2/UNIX/COMMON
endif

TPROD_CDROMPLATDIR=$(CDROMROOT)/$(PLATUC)/$(TPROD_REL_NAME)/CDROM1/IMAGES_DIR


ifndef TPROD_REL_NAME
TPROD_REL_NAME=RFDE
endif

ifndef debug
ifdef TPROD
TPROD_CDROM_ON=1
endif
endif

TPROD_CDROMPLATDIR=$(CDROMROOT)/$(PLATUC)/$(TPROD_REL_NAME)/CDROM1/IMAGES_DIR

# IC-CAP product build must have +Onomoveflops for opt builds
ifeq ($(PRODDESIG),ic)
ifeq (hpux, $(findstring hpux,$(ARCH)))
ifndef debug
CFLAGS += +Onomoveflops
CXXFLAGS += +Onomoveflops
endif
endif
endif


##################################
# Genesys override of defauts
##################################
ifeq (win,$(findstring win,$(ARCH)))
ifeq ($(PRODDESIG),genesys)

CFLAGS_DEBUG = /MDd /Zi /Yd /D _DEBUG /DGENESYS
CFLAGS_OPT = /MT /O2 /Op /Oy- /D NDEBUG /DGENESYS

CXXFLAGS = $(LOCAL_BUILD_CXXFLAGS) $(TARGET_CXXFLAGS) $(ADDITIONAL_BUILD_CXXFLAGS) $(PLATFORM_CXXFLAGS)
CXXFLAGS_DEBUG = /MDd /Zi /Yd /D _DEBUG /DGENESYS
CXXFLAGS_OPT = /MT /O2 /Op /Oy- /D NDEBUG /DGENESYS

endif
endif


###############################################################################

endif	# ifndef HPED_DEFS_INCLUDED, above
