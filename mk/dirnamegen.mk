# dirnamegen.mk - local, master management
# $Header: /cvs/wlv/src/cedamk/mk/dirnamegen.mk,v 1.13 2001/08/03 18:34:36 darrylo Exp $

ifdef DIRNAME_BUILD

ifdef TARGET
DIRNAME=$(basename $(TARGET))
endif

ifdef DIRNAME
dnc = \n\
ifndef $(DIRNAME)_dir\n\
$(DIRNAME)_dir=$$(LOCAL_ROOT)/$(LOCATION)\n\
endif
endif

ifdef PACKAGEMK
pmc += \n\
ifndef $(PACKAGEMK)_dir\n\
$(PACKAGEMK)_dir=$$(LOCAL_ROOT)/$(LOCATION)\n\
include $$($(PACKAGEMK)_dir)/mk/$(PACKAGEMK)\n\
endif
endif

dirname::
ifdef dnc
	$(at)$(MKDIR) $(LOCAL_ROOT)/mk
	$(at)$(ECHO) '$(dnc)' >> $(LOCAL_ROOT)/mk/dirname.mk
	$(at)touch  $(LOCAL_ROOT)/mk/packagemk.mk
endif
ifdef pmc
	$(at)cd $(LOCAL_ROOT)/mk && ($(ECHO) '$(pmc)' ; cat packagemk.mk) > tmp
	$(at)$(MV) $(LOCAL_ROOT)/mk/tmp $(LOCAL_ROOT)/mk/packagemk.mk
endif

else				# not DIRNAME_BUILD

# Hack, gag, barf ...
ifeq ($(SOURCEROOT),)
XSOURCEROOT=$(DEFAULT_SOURCEROOT)
else
XSOURCEROOT=$(SOURCEROOT)
endif

$(LOCAL_ROOT)/mk/packagemk.mk \
$(LOCAL_ROOT)/mk/dirname.mk: $(LOCAL_ROOT)/$(XSOURCEROOT)/make-defs
	@echo Building dirname.mk and packagemk.mk
	$(at)$(MKDIR) $(LOCAL_ROOT)/mk
	$(at): > $(LOCAL_ROOT)/mk/dirname.mk
	$(at): > $(LOCAL_ROOT)/mk/packagemk.mk
ifndef NODIRNAME
	$(at)$(MAKE) -C $(LOCAL_ROOT) DIRNAME_BUILD=1 $(npd) dirname
endif
	@echo Done building dirname.mk and packagemk.mk

endif				# not DIRNAME_BUILD
