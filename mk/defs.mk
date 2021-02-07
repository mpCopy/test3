# Ptolemy make system defs

# Do not copy header files to top level include directory
DO_NOT_INSTALL_HDRS=1
NO_STL_INC=1

ifdef NO_STL_INC
CEDA_STL_INC= 
else
CEDA_STL_INC=1
endif

# install is default target
install::

PTOLEMY_INSTALL=1
ifeq ($(findstring sun,$(ARCH)),sun)
PERL=$(HPEESOF_DIR)/tools/bin/perl
endif

# programs
PTLANG = $(project_mk_dir)/bin.$(ARCH)/hpeesoflang
HPEESOFSIM = hpeesofsim
AELGENERATE = $(HPEESOFSIM)
PROCESSSTARAEL = $(PERL) $(project_mk_dir)/bin/processStarAel

BMPCONVERT = $(PERL) $(project_mk_dir)/bin/bmpconvert $(BMPCONVERTFLAGS)
WINBMPRC = $(PERL) $(project_mk_dir)/bin/winbmprc

ifndef BLDVER
BLDVER=332
endif

ifeq (win,$(findstring win,$(ARCH)))
symbolemxflags=-emx_debug -emx_noconsole
BMPCONVERTFLAGS = -w
PTLANGFILE = $(PTLANG).exe
else
symbolemxflags=-emx_debug
BMPCONVERTFLAGS = -u
PTLANGFILE = $(PTLANG)
endif

# backward compatibility
HPTOLEMY_ARCH = $(ARCH)
CFLAGS += $(MYCFLAGS)
CXXFLAGS += $(MYCPLUSFLAGS)
LIBSPATHOPTION += $(EXTRA_LIBS) $(EXTRA_LINK_FLAGS)
HPTOLEMY_MAKE_VERSION = 3

# turn off some warnings on HP-UX
ifeq ($(ARCH),hpux11)
CXXFLAGS += +W361,469,655,740,749,392
endif

# define DEBUG preprocessor symbol when debug is defined
ifeq (win,$(findstring win,$(ARCH)))
   ifdef debug
      CXXFLAGS += /DDEBUG
   endif
else
   ifdef debug
      CXXFLAGS += -DDEBUG
   endif
endif

# a new variable getting set by internal developers (CEDAMK required)
# if set points at the standard hped stuff
ifdef INTERNAL_DEV_ROOT

HPEESOF_DEV_ROOT=$(INTERNAL_DEV_ROOT)
ifndef HPEESIMSRC 
HPEESIMSRC = $(HPEESOF_DEV_ROOT)/include/gemini
endif

ifndef HPTOLEMY_DEV_ROOT
HPTOLEMY_DEV_ROOT = $(HPEESOF_DEV_ROOT)/include/adsptolemy$(HPTOLEMY_DEV_VERSION)/include/adsptolemy
endif
LIBSPATH += $(LOCAL_ROOT)/lib.$(ARCH) $(HPEESOF_DEV_ROOT)/include/adsptolemy$(HPTOLEMY_DEV_VERSION)/adsptolemy/lib.$(ARCH)

else   # ifdef INTERNAL_DEV_ROOT settings for external developers and customers
INCLUDEPATH += $(HPEESOF_DIR)/adsptolemy/src/gsl
MAKEDEPENDFLAGS += -S
LIBSPATH += $(LOCAL_ROOT)/lib.$(ARCH)

# the cedamk scripts require this setting
CEDA_SITE = Keysight 

# Signal_Proc.3591
PLATUC:=$(shell hpeesofarch | tr a-z A-Z)


endif


# ptolemy headers for customers
ifndef HPTOLEMY_DEV_ROOT
HPTOLEMY_DEV_ROOT=$(HPEESOF_DIR)/adsptolemy
endif
MASTER_ROOT = $(HPTOLEMY_DEV_ROOT)

# link with installed libraries
LIBSPATH += $(HPEESOF_DIR)/adsptolemy/lib.$(ARCH) $(HPEESOF_DIR)/lib/$(ARCH)

# ptolemy recursion
PROJECT_RECURSE_TARGETS = ael regression bitmap bitmaps symbol symbols createxml createhtm

# run the simulator and utilities
ifndef PTSETVARS
ifeq (win,$(findstring win,$(ARCH)))
ifndef UNIXHPEESOF_DIR
UNIXHPEESOF_DIR := $(subst \,/,$(HPEESOF_DIR))
export UNIXHPEESOF_DIR := $(shell cygpath -u $(UNIXHPEESOF_DIR))
export UNIXHPEESOF_DEV_ROOT := $(shell cygpath -u $(HPEESOF_DEV_ROOT))
endif
else
UNIXHPEESOF_DIR=$(HPEESOF_DIR)
UNIXHPEESOF_DEV_ROOT=$(HPEESOF_DEV_ROOT)
endif

ifeq (win,$(findstring win,$(ARCH)))
export PATH := $(UNIXHPEESOF_DIR)/bin/$(ARCH):$(UNIXHPEESOF_DIR)/bin:$(UNIXHPEESOF_DIR)/adsptolemy/bin.$(ARCH):$(PATH)
else
export PATH := $(UNIXHPEESOF_DIR)/bin/$(ARCH):$(UNIXHPEESOF_DIR)/tools/bin:$(UNIXHPEESOF_DIR)/bin:$(UNIXHPEESOF_DIR)/adsptolemy/bin.$(ARCH):$(PATH)
endif
ifeq ($(ARCH),hpux11)
export PATH := $(PATH):/opt/aCC/bin
endif
ifeq ($(findstring sun,$(ARCH)),sun)
#export PATH := /usr/bin:$(PATH):/opt/SUNWspro/bin
endif


export SHLIBPATHBASE := $(UNIXHPEESOF_DIR)/lib/$(ARCH):$(UNIXHPEESOF_DIR)/adsptolemy/lib.$(ARCH):$(SYSTEMSHLIBPATH):$($(SHLIBPATHVAR))

export $(SHLIBPATHVAR) := $(LOCAL_ROOT)/lib.$(ARCH):$(SHLIBPATHBASE):$(UNIXHPEESOF_DEV_ROOT)/lib.$(ARCH)
export PTSETVARS = 1
endif
