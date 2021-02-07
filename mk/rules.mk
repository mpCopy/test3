# Ptolemy make system rules

LOCAL_BUILD_INCLUDEPATH += $(PTOLEMY_INCLUDEPATH)

# backward compatibility
ifdef PTLIB
TARGET = $(PTLIB).sl
endif
ifndef STAR_MK			# default STAR_MK
ifdef PL_SRCS
STAR_MK = usermodels
endif
endif
ifdef STAR_MK
TARGET = $(STAR_MK).sl
PTLIB = $(STAR_MK)
LIB_STAR_MK = -lib $(STAR_MK)
endif
ifdef CCNONVISUALTARGET
TARGET = $(CCNONVISUALTARGET)
endif

# ptolemy library interdependencies
LIBS += $(filter-out $(basename $(TARGET)),$(patsubst lib%.sl,%,$(PTLIBS)))

include $(project_mk_dir)/mk/package.mk
include $(project_mk_dir)/mk/dependencies.mk
include $(project_mk_dir)/mk/docgen.mk

# regression tests
ifdef BASELINE
include $(project_mk_dir)/mk/regression.mk
endif
ifdef NETS
include $(project_mk_dir)/mk/regression.mk
endif

ifdef SOURCEROOT
TOP_SRC_DIR=$(SOURCEROOT)
else
ifdef DEFAULT_SOURCEROOT
TOP_SRC_DIR=$(DEFAULT_SOURCEROOT)
else
TOP_SRC_DIR=src
endif
endif

# added for CEDAMK build

# On all architectures, Ptolemy may define -I for local include directives
#PTOLEMY_LIBSPATH=$(patsubst -I%,%,$(SRCPATH) $(INCL) $(INCLUDEPATH))

# On PC, /I may be used as well
#ifeq (win,$(findstring win,$(ARCH)))
#PTOLEMY_LIBSPATH=$(patsubst /I%,%,$(PTOLEMY_LIBSPATH))
#endif

#PTOLEMY_LIBSPATH=$(subst /$(TOP_SRC_DIR)/,/obj.$(ARCH)/,$(filter ..%,$(PTOLEMY_LIBSPATH))

PTOLEMY_LIBSPATH=$(subst ../$(TOP_SRC_DIR),../obj.$(ARCH),$(filter ..%,$(SRCPATH) $(PTOLEMY_INCLUDEPATH) $(INCL) $(INCLUDEPATH)  ))

PTOLEMY_LIBSPATH += $(LOCAL_ROOT)/lib.$(ARCH) $(LOCAL_ROOT)/bin.$(ARCH)
LOCAL_LIBSPATH=$(PTOLEMY_LIBSPATH)

empty:=
space:=$(empty) $(empty)
PTOLEMY_SHLIBPATH=$(subst $(space),:,$(PTOLEMY_LIBSPATH))

AELGENERATE = $(SHLIBPATHVAR)="$(PTOLEMY_SHLIBPATH):$($(SHLIBPATHVAR))" $(HPEESOFSIM)
SYMBOLGENERATE = $(SHLIBPATHVAR)="$(PTOLEMY_SHLIBPATH):$($(SHLIBPATHVAR))" $(HPEESOFSIM)
BITMAPGENERATE = $(SHLIBPATHVAR)="$(PTOLEMY_SHLIBPATH):$($(SHLIBPATHVAR))" $(HPEESOFSIM)
XMLGENERATE = $(SHLIBPATHVAR)="$(PTOLEMY_SHLIBPATH):$($(SHLIBPATHVAR))" $(HPEESOFSIM)
HPEESOF_BIN_DIR=$(HPEESOF_DIR)/bin

# stars
SRCS += $(PL_SRCS:.pl=.cc)
REALCLEAN += $(PL_SRCS:.pl=.cc) $(PL_SRCS:.pl=.h)  $(PL_SRCS:.pl=.xml)\
 $(PL_SRCS:.pl=.pl.xml) $(STAR_MK)Index  $(PL_SRCS:.pl=.htm) starIndex.htm 

%.h %.cc %.xml: $(SRCPATH)/%.pl make-defs $(PTLANGFILE)
	$(PTLANG) $(PTLANGFLAGS) $(LIB_STAR_MK) $<


# ael
AELGENERATEFLAGS = -S -ael
BITMAPGENERATEFLAGS = -S -bitmap
SYMBOLGENERATEFLAGS = -S -symbol 
XMLGENERATEFLAGS = -S -xml

ifdef SUBCKT
AELGENERATEFLAGS += -subckt
BITMAPGENERATEFLAGS += -subckt
SYMBOLGENERATEFLAGS += -subckt
ifdef WTB
AELGENERATEFLAGS += -wtb
XMLGENERATEFLAGS += -wtb
PROCESS_STAR_AEL_ARGS += -wtb
endif
ifdef ARF_SOURCE
AELGENERATEFLAGS += -arfSource
PROCESS_STAR_AEL_ARGS += -arfSource
endif
STAR_MK=$(SUBCKT)subckt
endif

ifdef BUILDAEL
STAR_MK=$(basename $(TARGET))
endif

ael::
ifdef STAR_MK
	$(at)$(MKDIR) $(INSTALL_ROOT)/ael
	$(AELGENERATE) $(AELGENERATEFLAGS) $(STAR_MK)
	$(MV) $(STAR_MK).ael $(INSTALL_ROOT)/ael/$(STAR_MK).adf
IDFLIB=$(STAR_MK)
endif

ael::
ifdef IDFLIB
	$(at)$(MKDIR) $(INSTALL_ROOT)/ael
	if [ -f locations ] ; then \
	  $(PERL) $(project_mk_dir)/bin/locationswrite locations >> $(INSTALL_ROOT)/ael/$(IDFLIB).adf ; fi
	$(RM) $(INSTALL_ROOT)/ael/$(IDFLIB)*.rec \
	  $(INSTALL_ROOT)/ael/$(IDFLIB).idf
	cd $(INSTALL_ROOT)/ael; $(PROCESSSTARAEL) $(PROCESS_STAR_AEL_ARGS) \
	  $(IDFLIB).adf
	$(RM) $(INSTALL_ROOT)/ael/$(IDFLIB).adf.bak
	set -e ; cd $(INSTALL_ROOT)/ael ; if [ -f $(IDFLIB)-bmp.ael ] ; then \
	$(HPEESOF_BIN_DIR)/aelcomp $(IDFLIB)-bmp.ael $(IDFLIB)-bmp.atf ; fi ;\
	$(HPEESOF_BIN_DIR)/hpedlibgen -in $(IDFLIB).adf -out $(IDFLIB).idf
endif
# FIXME: PROCESS_STAR_AEL_ARGS above should be PROCESSSTARAELFLAGS for
# consistency, but is it used anywhere?


# bitmaps
bitmaps bitmap::
ifdef STAR_MK
	$(at)$(MKDIR) ../bitmaps $(INSTALL_ROOT)/bitmaps
	$(BITMAPGENERATE) $(BITMAPGENERATEFLAGS) -out ../bitmaps $(STAR_MK)
ifeq (win,$(findstring win,$(ARCH)))
	$(MKDIR) ../bitmaps/win
	cd ../bitmaps/win ; for i in ../*.xbm ; do if [ -f $$i ] ; then $(BMPCONVERT) $$i $$(basename $$i .xbm).bmp ; $(RM) $$i ; fi; done
	cd ../bitmaps/win ; for i in *.bmp ; do if [ -f $$i ] ; then $(MV) $$i ../../bitmaps ; fi ; done
	rmdir ../bitmaps/win
ifneq ($(INSTALL_ROOT),..)
	for i in ../bitmaps/*.xbm ; do if [ -f $$i ] ; then $(BMPCONVERT) $$i $(INSTALL_ROOT)/bitmaps/$$(basename $$i .xbm).bmp ; $(RM) $$i ; fi; done
endif
endif
ifneq ($(INSTALL_ROOT),..)
	for i in ../bitmaps/*.bmp ../bitmaps/*.xbm ; do if [ -f $$i ] ; then $(CP) $$i $(INSTALL_ROOT)/bitmaps/$$(basename $$i) ; fi; done
endif
endif


# symbols
symbols symbol::
ifdef STAR_MK
	$(at)$(MKDIR) ../symbols $(INSTALL_ROOT)/symbols
	$(SYMBOLGENERATE) $(SYMBOLGENERATEFLAGS) -out ../symbols $(STAR_MK)
ifneq ($(INSTALL_ROOT),..)
	$(CP) ../symbols/*.dsn $(INSTALL_ROOT)/symbols/
endif
endif


# Invoke ADS to create OA libs
oalib oalibs: ael symbol bitmap
	$(PERL) $(project_mk_dir)/bin/processOAlib


# generate xml files
ifdef STAR_MK
createxml::
	$(XMLGENERATE) $(XMLGENERATEFLAGS) $(STAR_MK)
endif

#check dsn files for correct format
checkSymbol:
	$(PERL) $(project_mk_dir)/bin/checkSymbol $(INSTALL_ROOT)/symbols/*.dsn


# clean the current tree of model information
modelclean:
	$(RM) -r $(foreach i,lib.$(ARCH) ael bitmaps symbols doc,\
	  $(INSTALL_ROOT)/$(i))
