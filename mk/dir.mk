# dir.mk - main makefile structure
# $Header: /cvs/wlv/src/cedamk/mk/dir.mk,v 1.44 2008/05/09 19:20:16 build Exp $

# This needs to be first, as there are dummy dependency rules, below.
# The following becomes the default make target.
all::

# There's no need for normal users to remake this file:
$(ceda_mk_dir)/mk/dir.mk: ;

ifdef SRCPATH
$(SRCPATH)/make-defs.pre: ;
-include $(SRCPATH)/make-defs.pre
endif

# set ARCH
$(ceda_mk_dir)/mk/arch.mk: ;
include $(ceda_mk_dir)/mk/arch.mk


 # definitions
$(ceda_mk_dir)/mk/defs-$(ARCH).mk: ;
include $(ceda_mk_dir)/mk/defs-$(ARCH).mk
ifdef project_mk_dir
# This might be remade (???), and so we can't use the speedup hack.
include $(project_mk_dir)/mk/defs.mk
endif

# dirname inclusion
# These can be remade, and so we can't use the speedup hack.
ifndef DIRNAME_BUILD
-include $(LOCAL_ROOT)/mk/dirname.mk
ifdef MASTER_ROOT
include $(MASTER_ROOT)/mk/dirname.mk
endif
endif

###############################################################################
#
# Include a project-local .mk
#

ifdef SOURCEROOT
_XUQ_SOURCEROOT=$(SOURCEROOT)
else
_XUQ_SOURCEROOT=$(DEFAULT_SOURCEROOT)
endif

ifndef PROJECT_NAME
ifneq ($(findstring $(_XUQ_SOURCEROOT)/,$(LOCATION)),)
PROJECT_NAME := $(subst $(_XUQ_SOURCEROOT)/,,$(LOCATION))
ifeq ( $(ARCH),win32)
PROJECT_NAME := $(shell echo $(PROJECT_NAME) | sed -e 's/\\/.*//')
else
ifeq ( $(ARCH),win32_64)
PROJECT_NAME := $(shell echo $(PROJECT_NAME) | sed -e 's/\\/.*//')
else
PROJECT_NAME := $(shell echo $(PROJECT_NAME) | sed -e 's/\/.*//')
endif
endif
endif
endif

ifndef PROJECT_NAME
# If you're seeing this, something is wrong with the build.
PROJECT_NAME = UNDEFINED_PROJECT_NAME
endif

# NOTE: at this point, PROJECT_NAME *MUST* be defined!

ifndef NO_LOCAL_PROJECTMK
$(LOCAL_ROOT)/$(_XUQ_SOURCEROOT)/$(PROJECT_NAME)/mk/$(PROJECT_NAME).mk: ;
-include $(LOCAL_ROOT)/$(_XUQ_SOURCEROOT)/$(PROJECT_NAME)/mk/$(PROJECT_NAME).mk
endif

###############################################################################

# what to build
ifdef SRCPATH
$(SRCPATH)/make-defs: ;
include $(SRCPATH)/make-defs
# make-defs.mk MUST, ABSOLUTELY, POSITIVELY, COME AFTER make-defs
# Multi-target dependencies will not work properly, otherwise.
# This is remade, and so we can't use the speedup hack.
ifndef NO_MAKE_DEFS_MK
-include $(SRCPATH)/$(MAKE_DEFS_MK)
endif
else		# not SRCPATH
include make-defs
endif

###############################################################################

ifndef NO_LOCAL_PROJECTMK
$(LOCAL_ROOT)/$(_XUQ_SOURCEROOT)/$(PROJECT_NAME)/mk/$(PROJECT_NAME)-post.mk: ;
-include $(LOCAL_ROOT)/$(_XUQ_SOURCEROOT)/$(PROJECT_NAME)/mk/$(PROJECT_NAME)-post.mk
endif

###############################################################################

ifndef HPED_DEFS_INCLUDED
# Ugh.  Yuk!  Ugh.  Yuk!  Ugh.  Yuk!
# Force inclusion of hped-defs if it hasn't already been included by the
# project's make-defs file.
$(ceda_mk_dir)/mk/hped-defs.mk: ;
include $(ceda_mk_dir)/mk/hped-defs.mk
endif

# subdirectory recursion 
CEDA_RECURSE_TARGETS = sources pre_compile compile install clean realclean
CEDA_RECURSE_TARGETS += makefiles dirname
CEDA_RECURSE_TARGETS += install-custpkg install-devpkg
CEDA_RECURSE_TARGETS += build-custpkg build-devpkg
CEDA_RECURSE_TARGETS += pre-build-custpkg pre-build-devpkg
CEDA_RECURSE_TARGETS += post-build-custpkg post-build-devpkg
CEDA_RECURSE_TARGETS += lastgoodinst
CEDA_RECURSE_TARGETS += quick
CEDA_RECURSE_TARGETS += night
CEDA_RECURSE_TARGETS += full

ifndef NO_CHECK_RECURSE
CEDA_RECURSE_TARGETS += check
endif

# CEDA_RECURSE_TARGETS += package 
# CEDA_RECURSE_TARGETS += buildinstall-custpkg buildinstall-devpkg 


#### the following handles recursion into directories for certain targets
## recurse rules should be first rules

ifndef OBJBUILD
define TARGET_DIRS
$(if $(DIRS_$(1)), $(filter-out .,$(DIRS_$(1))), $(DIRS))
endef

ifdef DIRS
define RECURSE_DIRS
$(if $(strip $(call TARGET_DIRS,$(1))), 
$(at)set -e; for i in $(call TARGET_DIRS,$(1)) ; do $(MAKE) -C $$i $(1) $(2); done,
@echo recursing disabled for target $(1))
endef
else
define RECURSE_DIRS
$(if $(filter-out .,$(DIRS_$(1))), 
   $(at)set -e; for i in $(filter-out .,$(DIRS_$(1))) ; do $(MAKE) -C $$i $(2) ; done,)
endef
endif

ALLDIRS=$(sort $(DIRS) $(foreach target, $(CEDA_RECURSE_TARGETS) $(PROJECT_RECURSE_TARGETS), $(call TARGET_DIRS,$(target))))

ifneq ($(strip $(ALLDIRS)),)
$(CEDA_RECURSE_TARGETS) $(PROJECT_RECURSE_TARGETS):: $(foreach dir,$(ALLDIRS),$(dir)/makefile)
	$(call RECURSE_DIRS,$@,$@)

# Prevent CDPATH from screwing us over ...
CDPATH=
ifneq ($(strip $(wildcard projects)),)
projects:
	cd projects && $(MAKE) projects
else	# projects directory doesn't exist
ifneq ($(strip $(wildcard src)),)
projects:
	cd src && $(MAKE) projects
else	# src directory doesn't exist
# We must be in the projects/src directory
projects: $(foreach dir,$(DIRS),$(dir)/makefile)
	$(call RECURSE_DIRS,$@,all)
endif	# src directory doesn't exist
endif	# projects directory doesn't exist
else	# !def ALLDIRS
makefiles ::
endif	# !def ALLDIRS
endif	# !def OBJBULD

# hped-rules.mk is now always included.  The test for DEVEL_LIBRARYTYPE is
# now done inside of hped-rules.mk.
# THIS MUST BE INCLUDED AFTER THE PROJECT'S make-defs FILE!
$(ceda_mk_dir)/mk/hped-rules.mk: ;
include $(ceda_mk_dir)/mk/hped-rules.mk

# packagemk inclusion
# These can be remade, and so we can't use the speedup hack.
ifndef DIRNAME_BUILD
-include $(LOCAL_ROOT)/mk/packagemk.mk
ifdef MASTER_ROOT
include $(MASTER_ROOT)/mk/packagemk.mk
endif
endif



ifndef OBJBUILD
ifneq "$(LOCAL_ROOT)" "."
SUB_LOCAL_ROOT=$(LOCAL_ROOT)/
endif
ifneq "$(LOCATION)" "."
SUB_LOCATION=$(LOCATION)/
endif
ifneq ($(SOURCEROOT),)
SUB_SOURCEROOT=SOURCEROOT=$(SOURCEROOT)
endif

$(ceda_mk_dir)/mk/makefile.mk: ;

%/makefile: $(ceda_mk_dir)/mk/makefile.mk
	$(at)$(MAKE) -C $(@D) -f $(ceda_mk_dir)/mk/makefile.mk $(npd) \
	  LOCAL_ROOT=$(SUB_LOCAL_ROOT).. LOCATION=$(SUB_LOCATION)$(@D) \
	  'CEDAMK=$(subst $$,$$$$,$(CEDAMK))' \
	  'PROJECTMK=$(subst $$,$$$$,$(PROJECTMK))' $(SUB_SOURCEROOT)

endif   # !def OBJBULD

# rules
ifdef project_mk_dir
include $(project_mk_dir)/mk/rules.mk
endif

# $(ceda_mk_dir)/mk/rules-$(ARCH).mk MUST BE INCLUDED AFTER THE PROJECT'S
# make-defs FILE!
$(ceda_mk_dir)/mk/rules-$(ARCH).mk: ;
include $(ceda_mk_dir)/mk/rules-$(ARCH).mk

# dirname generation
$(ceda_mk_dir)/mk/dirnamegen.mk: ;
include $(ceda_mk_dir)/mk/dirnamegen.mk

.PHONY: all projects check $(CEDA_RECURSE_TARGETS) depend purify quantify purecov $(PROJECT_RECURSE_TARGETS)

ifdef SRCPATH
$(SRCPATH)/make-defs.post: ;
-include $(SRCPATH)/make-defs.post
endif







