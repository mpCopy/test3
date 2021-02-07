# $Header: /cvs/wlv/src/cedamk/mk/hped-rules.mk,v 1.153 2008/11/04 20:03:15 build Exp $

# Support for a adsprod directory for ADS only product area
ADSPROD_ON=off

ifdef TPRODO
TPROD=1
endif
ifndef debug
TPROD_CDROMCOPY_ON=1
endif

DPKG=hpeesofpkg

# dummy target for pre_compile
pre_compile::
	if [ -f  $(OBJPATH)/make-depends ] ; then  \
	rm -rf $(OBJPATH)/make-depends ; fi

# development library 
ifdef DEVEL_LIBRARYTYPE

###############################################################################
# Placeholders for dummy targets.

# Developers should add code in make-defs to test their projects.
check::


###############################################################################

####################
#  libraries default rules

install-localdevelroot::
	@echo "Default install-localdevelroot target"

install-localcustroot::
	@echo "Default install-localcustroot target"

pre_compile::
	@echo "Default pre_compile target"

testbuild::
	@echo "Default testbuild target"

install-devpkg::
	@echo "Default install-devpkg target"

install-custpkg::
	@echo "Default install-custpkg target"

notify::
	@echo "Default notify target"

pre_install::
	@echo "Default pre_install target"

####################
# Special libraries rules

INSTLIBPATH=$(LOCAL_ROOT)/lib.$(ARCH)
ifeq (win,$(findstring win,$(ARCH)))
ifeq ($(suffix $(TARGET)),.a)
        DEVELINSTLIBS=$(INSTLIBPATH)/$(LIBBASENAME).lib
else	# !archive lib
ifeq ($(suffix $(TARGET)),.sl)
ifdef PTOLEMY_INSTALL
        DEVELINSTLIBS=$(INSTLIBPATH)/$(LIBBASENAME).lib $(INSTLIBPATH)/$(LIBBASENAME).dll
        CUSTINSTLIBS=$(OBJPATH)/$(LIBBASENAME).dll
ifeq (_64,$(findstring _64,$(ARCH)))
        CUSTINSTLIBS +=$(OBJPATH)/$(LIBBASENAME).dll.manifest
        DEVELINSTLIBS +=$(OBJPATH)/$(LIBBASENAME).dll.manifest
endif

else	# !PTOLEMY_INSTALL
        DEVELINSTLIBS=$(INSTLIBPATH)/$(LIBBASENAME).lib $(INSTLIBPATH)/$(LIBBASENAME)$(SLLIBVER).dll
        CUSTINSTLIBS=$(INSTLIBPATH)/$(LIBBASENAME)$(SLLIBVER).dll
ifeq (_64,$(findstring _64,$(ARCH)))
        CUSTINSTLIBS +=$(OBJPATH)/$(LIBBASENAME)$(SLLIBVER).dll.manifest
        DEVELINSTLIBS +=$(OBJPATH)/$(LIBBASENAME)$(SLLIBVER).dll.manifest
endif

endif	# !PTOLEMY_INSTALL
endif	# shared lib
endif	# !archive lib
else	# !win32
ifeq ($(ARCH),aix4)
        DEVELINSTLIBS=$(INSTLIBPATH)/$(LIBBASENAME)$(SLSUFFIX) $(INSTLIBPATH)/$(LIBBASENAME).a
else
        DEVELINSTLIBS=$(INSTLIBPATH)/$(LIBBASENAME)$(SLSUFFIX)
endif
ifeq ($(suffix $(TARGET)),.a)
        DEVELINSTLIBS=$(INSTLIBPATH)/$(LIBBASENAME).a
endif
        CUSTINSTLIBS=$(DEVELINSTLIBS)
endif	# !win32

PLIBBASENAME:=$(shell echo $(LIBBASENAME) | tr "_" "-" )
DEVTARGET=$(PLIBBASENAME)-devel
CUSTTARGET=$(PLIBBASENAME)-suplib
DEVELROOT=$(dir $(HPEESOF_DIR))/build

ifdef BUILD_USER

pre_compile:: 
	@echo "Install for  $(DEVTARGET) $(shell pwd)"
	- rm -rf $(SRCPATH)/root
	@echo "Install for  $(DEVTARGET) $(shell pwd)"
	cd $(SRCPATH) ; eemkdir $(SRCPATH)/root/include ; eecopy  $(PUBLIC-HDRS) $(SRCPATH)/root/include 
	eemkdir $(SRCPATH)/root/DEBIAN
	rm -f $(SRCPATH)/control.devel-precompile 
	if [ ! -f  $(SRCPATH)/control.devel-precompile ] ; then  \
	echo "package:  $(DEVTARGET)" >  $(SRCPATH)/control  ; \
	echo "Version:  $(MARKETING_VER).$(REV) " >>  $(SRCPATH)/control ; \
	echo "Architecture: $(ARCH) " >>  $(SRCPATH)/control ; \
	echo "Maintainer: Keygith Technologies " >>  $(SRCPATH)/control ; \
	echo "Depends: " >>  $(SRCPATH)/control ; \
	echo "Description: $(LIBBASENAME)-precompile files" >>  $(SRCPATH)/control ; \
	cd $(SRCPATH) ; cp -f $(SRCPATH)/control $(SRCPATH)/control.devel-precompile ; fi
	$(PERL) $(CEDA_DRIVE)$(BUILD_PREFIX)/bin/hpeesofpkg-gencontrol  $(SRCPATH)/control.devel-precompile >  $(SRCPATH)/root/DEBIAN/control
	eemkdir  $(INSTLIBPATH)
	 - find $(SRCPATH)/root -type d -print | xargs chmod 755
	 - find $(SRCPATH)/root -type d -print | xargs chmod -s
	$(DPKG)  --build $(SRCPATH)/root $(INSTLIBPATH)/$(DEVTARGET)_precompile.deb
	- rm -rf $(SRCPATH)/root
	hpeesofpkg -i --force-overwrite  --instdir=$(DEVELROOT) --admindir=$(dir $(HPEESOF_DIR))/build/include/dpkg $(INSTLIBPATH)/$(DEVTARGET)_precompile.deb
	- rm -rf $(SRCPATH)/root

install-custpkg:: install-localcustroot
	@echo "Install for  $(DEVTARGET) $(shell pwd)"
ifneq ($(suffix $(TARGET)),.a)
ifeq (win,$(findstring win,$(ARCH)))
	mkdir -p $(SRCPATH)/root/lib/$(ARCH)
	cd $(SRCPATH) ; cp   -f  $(INSTLIBPATH)/$(LIBBASENAME).lib $(SRCPATH)/root/lib/$(ARCH)
ifdef CEDA_64_BIT
	mkdir -p $(SRCPATH)/root/bin/$(ARCH)
	eemkdir $(SRCPATH)/root/bin ; cp -f  $(CUSTINSTLIBS) $(SRCPATH)/root/bin/$(ARCH)
else
	eemkdir $(SRCPATH)/root/bin ; cp -f  $(CUSTINSTLIBS) $(SRCPATH)/root/bin 
endif
else
	eemkdir $(SRCPATH)/root/lib/$(ARCH) ; cp -f   $(CUSTINSTLIBS) $(SRCPATH)/root/lib/$(ARCH) 
endif
endif
	eemkdir $(SRCPATH)/root/DEBIAN
	rm -f $(SRCPATH)/control.cust
	if [ ! -f  $(SRCPATH)/control.cust ] ; then  \
	echo "package: $(CUSTTARGET)" >  $(SRCPATH)/control  ; \
	echo "Version:  $(MARKETING_VER).$(REV) " >>  $(SRCPATH)/control ; \
	echo "Architecture: $(ARCH) " >>  $(SRCPATH)/control ; \
	echo "Maintainer: Keygith Technologies " >>  $(SRCPATH)/control ; \
	echo "Depends: " >>  $(SRCPATH)/control ; \
	echo "Description: $(LIBBASENAME) library " >>  $(SRCPATH)/control ; \
	cp -f $(SRCPATH)/control $(SRCPATH)/control.cust; fi
	$(PERL) $(CEDA_DRIVE)$(BUILD_PREFIX)/bin/hpeesofpkg-gencontrol  $(SRCPATH)/control.cust >  $(SRCPATH)/root/DEBIAN/control
	 - find $(SRCPATH)/root -type d -print | xargs chmod 755
	 - find $(SRCPATH)/root -type d -print | xargs chmod -s
	$(DPKG) --build $(SRCPATH)/root $(INSTLIBPATH)/$(CUSTTARGET).deb
	- rm -rf $(SRCPATH)/root
ifneq (win32,$(findstring win32,$(ARCH)))
ifeq ($(ADSPROD_ON),1)
	hpeesofpkg -i --force-overwrite --instdir=$(ADSPROD_DIR) --admindir=$(ADSPROD_DIR)/tools/lib/dpkg   $(INSTLIBPATH)/$(CUSTTARGET).deb
endif
endif

ifndef TPRODO
	$(DPKG) -i --force-overwrite   $(INSTLIBPATH)/$(CUSTTARGET).deb
endif
ifdef TPROD
	hpeesofpkg -i --force-overwrite --instdir=$(TPROD_DIR) --admindir=$(TPROD_DIR)/tools/lib/dpkg   $(INSTLIBPATH)/$(CUSTTARGET).deb
endif

	eecopy $(INSTLIBPATH)/$(CUSTTARGET).deb $(GOODPKGDIR)
	- rm -rf $(SRCPATH)/root

install-devpkg:: install-localdevelroot
	@echo "Install for  $(DEVTARGET) $(shell pwd)"
	cd $(SRCPATH) ;  eemkdir $(SRCPATH)/root/include;  eecopy  $(PUBLIC-HDRS) $(SRCPATH)/root/include 
	cd $(SRCPATH) ; eemkdir $(SRCPATH)/root/lib.$(ARCH) ; cp -f  $(DEVELINSTLIBS) $(SRCPATH)/root/lib.$(ARCH)
	eemkdir $(SRCPATH)/root/DEBIAN
	rm -f $(SRCPATH)/control.devel 
	if [ ! -f  $(SRCPATH)/control.devel ] ; then  \
	echo "package: $(DEVTARGET)" >  $(SRCPATH)/control  ; \
	echo "Version:  $(MARKETING_VER).$(REV) " >>  $(SRCPATH)/control ; \
	echo "Architecture: $(ARCH) " >>  $(SRCPATH)/control ; \
	echo "Maintainer: Keygith Technologies " >>  $(SRCPATH)/control ; \
	echo "Depends: " >>  $(SRCPATH)/control ; \
	echo "Description: $(LIBBASENAME) library " >>  $(SRCPATH)/control ; \
	cp -f $(SRCPATH)/control $(SRCPATH)/control.devel ; fi
	$(PERL) $(CEDA_DRIVE)$(BUILD_PREFIX)/bin/hpeesofpkg-gencontrol  $(SRCPATH)/control.devel >  $(SRCPATH)/root/DEBIAN/control
	- find $(SRCPATH)/root -type d -print | xargs chmod 755
	- find $(SRCPATH)/root -type d -print | xargs chmod -s
	$(DPKG) --build $(SRCPATH)/root $(INSTLIBPATH)/$(DEVTARGET).deb
	- rm -rf $(SRCPATH)/root
	hpeesofpkg -r --instdir=$(DEVELROOT) --admindir=$(dir $(HPEESOF_DIR))/build/include/dpkg  $(DEVTARGET)-precompile
	hpeesofpkg -i  --force-overwrite --instdir=$(DEVELROOT)  --admindir=$(dir $(HPEESOF_DIR))/build/include/dpkg   $(INSTLIBPATH)/$(DEVTARGET).deb
	eecopy $(INSTLIBPATH)/$(DEVTARGET).deb $(GOODPKGDIR)
	- rm -rf $(SRCPATH)/root

lastgoodinst::
	hpeesofpkg -i  --force-overwrite --instdir=$(DEVELROOT)   --admindir=$(dir $(HPEESOF_DIR))/build/include/dpkg   $(GOODPKGDIR)/$(DEVTARGET).deb
	hpeesofpkg -i --force-overwrite   $(GOODPKGDIR)/$(CUSTTARGET).deb

endif # BUILD_USER

endif		# DEVEL_LIBRARYTYPE


###############################################################################
#
# Start of new project build rules
#
###############################################################################


ifdef NEW_PACKAGING

ifdef DEVEL_LIBRARYTYPE
badbad := $(error ***** Sorry, you cannot define both NEW_PACKAGING and DEVEL_LIBRARYTYPE!)
endif

#
# Hook args:
#	$(1)	- Package name
#	$(2)	- Base name of files that contains package file list and
#		  package control info.  Note that this name cannot have an
#		  embedded path, as this name is always referenced from
#		  the current source directory.  Basically, this name is used
#		  to reference the following files:
#
#			$(OBJPATH)/$(4).pkgcontrol
#			$(SRCPATH)/$(4).pkgfiles
#
define internal_custbuildhook
	$(call copy_packages,$(1),$(2),$(SRCPATH)/$(2).pkgfiles)
endef
define internal_devbuildhook
	$(call copy_packages,$(1),$(2),$(SRCPATH)/$(2).pkgfiles)
endef

endif		# NEW_PACKAGING


# Bah!  We can't have conditionals inside define's and so we have to
# resort to this ...
#
# Args:
#	$(1)	- Package name
#	$(2)	- Base name of files that contains package file list and
#		  package control info.  Note that this name cannot have an
#		  embedded path, as this name is always referenced from
#		  the current source directory.  Basically, this name is used
#		  to reference the following files:
#
#			$(OBJPATH)/$(4).pkgcontrol
#			$(SRCPATH)/$(4).pkgfiles
#	$(3)	- Pathname of config file
#
# IMPORTANT NOTE: DO NOT PUT "@" or "$(at)" IN FRONT OF THE COMMANDS
# IN THIS MACRO.  THE MACRO NESTING SEEMS TO TRIGGER A GNU MAKE BUG
# WHERE "@" IS TREATED AS PART OF THE COMMAND NAME.
#
ifeq (win,$(findstring win,$(ARCH)))
WIN32_MAKE_PKG_CONFIG := $(shell cygpath -w $(ceda_mk_dir)/bin/make-pkg-config)
define copy_packages
	cd $(OBJPATH) ; rm -f root.pkgfiles ; $(CP) $(3) root.pkgfiles ; chmod 644 root.pkgfiles
	cd $(OBJPATH) ; perl '$(WIN32_MAKE_PKG_CONFIG)' -d $(if $(strip $($(2)_PACKAGE_INCLUDES_DIR)),$($(2)_PACKAGE_INCLUDES_DIR),include) $($(2)_PACKAGE_INCLUDES) >> root.pkgfiles
	cd $(OBJPATH) ; perl '$(WIN32_MAKE_PKG_CONFIG)' -d $(if $(strip $($(2)_PACKAGE_ATF_DIR)),$($(2)_PACKAGE_ATF_DIR),$(1)/ael) $($(2)_PACKAGE_ATF) >> root.pkgfiles
	$(call invoke_package_copy_sequence)
endef
else
define copy_packages
	cd $(OBJPATH) ; rm -f root.pkgfiles ; $(CP) $(3) root.pkgfiles ; chmod 644 root.pkgfiles
	cd $(OBJPATH) ; perl $(ceda_mk_dir)/bin/make-pkg-config -d $(if $(strip $($(2)_PACKAGE_INCLUDES_DIR)),$($(2)_PACKAGE_INCLUDES_DIR),include) $($(2)_PACKAGE_INCLUDES) >> root.pkgfiles
	cd $(OBJPATH) ; perl $(ceda_mk_dir)/bin/make-pkg-config -d $(if $(strip $($(2)_PACKAGE_ATF_DIR)),$($(2)_PACKAGE_ATF_DIR),$(1)/ael) $($(2)_PACKAGE_ATF) >> root.pkgfiles
	$(call invoke_package_copy_sequence)
endef
endif

ifdef COMBINE_BUILD
define invoke_package_copy_sequence
	if [ ! -d $(OBJPATH_64BIT)/packages ] ; then eemkdir $(OBJPATH_64BIT)/packages ; fi
	echo "cd $(OBJPATH_64BIT) ; $(call package-copy-file-macro-64-into-32-bit,$(OBJPATH_32BIT)/root.pkgfiles,$(OBJPATH_32BIT))"	
	cd $(OBJPATH_64BIT) ; $(call package-copy-file-macro-64-into-32-bit,$(OBJPATH_32BIT)/root.pkgfiles,$(OBJPATH_32BIT))
	if [ ! -d $(OBJPATH_64BIT)/packages ] ; then eemkdir $(OBJPATH_64BIT)/packages ; fi
	echo "cd $(OBJPATH_32BIT) ; $(call package-copy-file-macro,$(OBJPATH_32BIT)/root.pkgfiles,$(OBJPATH_32BIT))"
	cd $(OBJPATH_32BIT) ; $(call package-copy-file-macro,$(OBJPATH_32BIT)/root.pkgfiles,$(OBJPATH_32BIT))
endef
else
define invoke_package_copy_sequence
	cd $(OBJPATH) ; $(call package-copy-file-macro,$(OBJPATH)/root.pkgfiles,$(OBJPATH))
endef
endif

# Bah!  We can't have conditionals inside define's and so we have to
# resort to this ...
ifeq (win,$(findstring win,$(ARCH)))
define package-copy-file-macro
	$(PERL) '$(shell cygpath -w $(ceda_mk_dir)/bin/copy-pkg-files)' '$(shell cygpath -w -p  $(LOCAL_ROOT))' $(2)/pkgroot $(SRCPATH) $(CEDALIBVER) $(if $(debug),0,opt) < $(1)
endef
define package-copy-file-macro-64-into-32-bit
	$(PERL) '$(shell cygpath -w $(ceda_mk_dir)/bin/copy-pkg-files)' -b '$(shell cygpath -w -p  $(LOCAL_ROOT))' $(2)/pkgroot $(SRCPATH) $(CEDALIBVER) $(if $(debug),0,opt) < $(1)
endef
else
define package-copy-file-macro
	$(PERL) $(ceda_mk_dir)/bin/copy-pkg-files $(LOCAL_ROOT) $(2)/pkgroot $(SRCPATH) $(CEDALIBVER) $(if $(debug),0,opt) < $(1)
endef
define package-copy-file-macro-64-into-32-bit
	$(PERL) $(ceda_mk_dir)/bin/copy-pkg-files -b $(LOCAL_ROOT) $(2)/pkgroot $(SRCPATH) $(CEDALIBVER) $(if $(debug),0,opt) < $(1)
endef
endif

#
# package-build-control:
#
#	$(1)	- Package name
#	$(2)	- Package version
#	$(3)	- Package architecture
#	$(4)	- Package dependencies
#	$(5)	- Package description
#	$(6)	- Package control file name (created)
#
define package-build-control
	$(at)rm -f $(6)
	$(at)echo "package: $(1)" > $(6)  ; \
	echo "Version:  $(MARKETING_VER).$(REV) " >> $(6) ; \
	echo "Architecture: $(3) " >> $(6) ; \
	echo "Maintainer: Keygith Technologies " >> $(6) ; \
	echo "Depends: " $(4) >> $(6) ; \
	echo "Description: " $(5) >> $(6)
endef

#
# package-build-macro:
#	$(1)	- Filename of package to create.  Path can be included.
#	$(2)	- Package name
#	$(3)	- Package version
#	$(4)	- Base name of files that contains package file list and
#		  package control info.  Note that this name cannot have an
#		  embedded path, as this name is always referenced from
#		  the current source directory.  Basically, this name is used
#		  to reference the following files:
#
#			$(OBJPATH)/$(4).pkgcontrol
#			$(SRCPATH)/$(4).pkgfiles
#
#	$(5)	- Package Architecture 
#	$(6)	- Dependencies, if any
#       $(7)    - Package description
#	$(8)	- (Optional) Name of macro to call after copying files, but
#		  before the package is made.
#	$(9)	- (Optional) Name of another macro to call after copying
#		  files, but before the package is made.
#	$(10)	- (Optional) Name of yet another macro to call after copying
#		  files, but before the package is made.
#
ifeq (win,$(findstring win,$(ARCH)))
define package-build-macro
	@echo
	@echo "Building package $(1) ..."
	$(at)rm -rf $(OBJPATH)/pkgroot
	$(at)eemkdir $(OBJPATH)/pkgroot/DEBIAN
	$(at)$(call $(8),$(2),$(4),$(OBJPATH)/pkgroot)
	$(at)$(call $(9),$(2),$(4),$(OBJPATH)/pkgroot)
	$(at)$(call $(10),$(2),$(4),$(OBJPATH)/pkgroot)
	$(at)$(call package-build-control,$(2),$(3),$(5),$(6),$(7),$(OBJPATH)/$(4).pkgcontrol)
	$(at)cd $(OBJPATH) ; $(PERL) '$(shell cygpath -w $(CEDA_DRIVE)$(BUILD_PREFIX)/bin/hpeesofpkg-gencontrol)' '$(shell cygpath -w $(OBJPATH)/$(4).pkgcontrol)' '$(shell cygpath -w $(OBJPATH)/pkgroot)' > $(OBJPATH)/pkgroot/DEBIAN/control
	$(at)- find $(OBJPATH)/pkgroot -type d -print | xargs chmod 755
	$(at)- find $(OBJPATH)/pkgroot -name postinst | xargs chmod 755
	$(at)- find $(OBJPATH)/pkgroot -type d -print | xargs chmod -s
	$(DPKG) --build $(OBJPATH)/pkgroot $(1)
	rm -rf $(OBJPATH)/pkgroot
	@echo
endef
else
define package-build-macro
	@echo
	@echo "Building package $(1) ..."
	$(at)rm -rf $(OBJPATH)/pkgroot
	$(at)eemkdir $(OBJPATH)/pkgroot/DEBIAN
	$(at)$(call $(8),$(2),$(4),$(OBJPATH)/pkgroot)
	$(at)$(call $(9),$(2),$(4),$(OBJPATH)/pkgroot)
	$(at)$(call $(10),$(2),$(4),$(OBJPATH)/pkgroot)
	$(call package-build-control,$(2),$(3),$(5),$(6),$(7),$(OBJPATH)/$(4).pkgcontrol)
	$(at)cd $(OBJPATH) ; $(PERL) $(CEDA_DRIVE)$(BUILD_PREFIX)/bin/hpeesofpkg-gencontrol $(OBJPATH)/$(4).pkgcontrol $(OBJPATH)/pkgroot > $(OBJPATH)/pkgroot/DEBIAN/control
	$(at) - find $(OBJPATH)/pkgroot -type d -print | xargs chmod 755
	$(at) - find $(OBJPATH)/pkgroot -name postinst | xargs chmod 755
	$(at) - find $(OBJPATH)/pkgroot -type d -print | xargs chmod -s
	$(at)$(DPKG) --build $(OBJPATH)/pkgroot $(1)
	$(at)rm -rf $(OBJPATH)/pkgroot
	@echo
endef
endif

#
# generic-packager:
#
#	$(1)	- Filename of package to create.  Path can be included.
#	$(2)	- Package name
#	$(3)	- Package version
#	$(4)	- Package architecture
#	$(5)	- Package dependencies
#	$(6)	- Package config file
#	$(7)	- (Optional) Name of macro to call after copying files, but
#		  before the package is made.
#

define generic-packager
	@echo
	@echo "Building generic package $(1) ..."
	$(at)rm -rf $(OBJPATH)/pkgroot
	$(at)eemkdir $(OBJPATH)/pkgroot/DEBIAN
	$(call package-build-control,$(2),$(3),$(4),$(5),"$(2) files",$(OBJPATH)/$(2).pkgcontrol)
	$(at) cd $(OBJPATH) ; $(call copy_packages,$(1),$(2),$(6))
	$(at)$(call $(7),$(2),$(3),$(OBJPATH)/pkgroot)
	$(at) cd $(OBJPATH) ; $(PERL) $(CEDA_DRIVE)$(BUILD_PREFIX)/bin/hpeesofpkg-gencontrol $(OBJPATH)/$(2).pkgcontrol $(OBJPATH)/pkgroot > $(OBJPATH)/pkgroot/DEBIAN/control
	$(at) - find $(OBJPATH)/pkgroot -type d -print | xargs chmod 755
	$(at) - find $(OBJPATH)/pkgroot -type d -print | xargs chmod -s
	$(at)$(DPKG) --build $(OBJPATH)/pkgroot $(1)
	$(at)rm -rf $(OBJPATH)/pkgroot
	@echo
endef



define generic-custpkg-installer
	$(if $(strip $(1)), \
	echo "***** Installing cust pkg: $(1)"; \
	$(DPKG) -i  $(1); \
	cp -f $(1) $(GOODPKGDIR))
endef



define tprod-generic-custpkg-installer
	$(if $(strip $(1)), \
	echo "***** Installing cust pkg: $(1)"; \
	HPEESOF_DIR=$(TPROD_DIR); \
	export HPEESOF_DIR; \
	hpeesofpkg -i  --instdir=$(TPROD_DIR) --admindir=$(TPROD_DIR)/tools/lib/dpkg  $(1); \
	cp -f $(1) $(GOODPKGDIR))
endef


define adsprod-generic-custpkg-installer
	$(if $(strip $(1)), \
	echo "***** Installing cust pkg: $(1)"; \
	HPEESOF_DIR=$(ADSPROD_DIR); \
	export HPEESOF_DIR; \
	hpeesofpkg -i  --instdir=$(ADSPROD_DIR) --admindir=$(ADSPROD_DIR)/tools/lib/dpkg  $(1))
endef


define generic-devpkg-installer
	$(if $(strip $(1)), \
	echo "***** Installing dev pkg: $(1)"; \
	hpeesofpkg -i --instdir=$(HPEESOF_DEV_ROOT) --admindir=$(dir $(HPEESOF_DIR))/build/include/dpkg  --force-overwrite $(1); \
	eecopy $(1) $(GOODPKGDIR))
endef


.PHONY: package build-custpkg build-devpkg buildinstall-custpkg buildinstall-devpkg 
.PHONY: FORCE
.SUFFIXES: .deb .pkgfiles

# These are defined earlier -- typically, in make-defs
# CUSTPACKAGES +=
# DEVPACKAGES +=

TPROD_CUSTPACKAGES_FILES = $(foreach pkg, $(TPROD_CUSTPACKAGES), $(OBJPATH)/$(pkg)_$(CEDALIBVER)_$(ARCH).deb)
CUSTPACKAGES_FILES = $(foreach pkg, $(CUSTPACKAGES), $(OBJPATH)/$(pkg)_$(CEDALIBVER)_$(ARCH).deb)
LGOOD_CUSTPACKAGES_FILES = $(foreach pkg, $(CUSTPACKAGES), $(GOODPKGDIR)/$(pkg)_$(CEDALIBVER)_$(ARCH).deb)
DEVPACKAGES_FILES = $(foreach pkg, $(DEVPACKAGES), $(OBJPATH)/DEV_$(pkg)_D$(CEDALIBVER)_$(ARCH).deb)
DEVPACKAGES_FILES_COMBINE = $(foreach pkg, $(DEVPACKAGES), $(OBJPATH)/DEV_$(pkg)_D$(CEDALIBVER)_$(ARCH)_combine.deb)
LGOOD_DEVPACKAGES_FILES = $(foreach pkg, $(DEVPACKAGES), $(GOODPKGDIR)/DEV_$(pkg)_D$(CEDALIBVER)_$(ARCH).deb)

# Here, we leave off the dependency on *.pkgfiles, because adding them will
# cause a very misleading error message if the *.pkgfiles do not exist.  This
# is not really a problem, as an acceptable error message will be output
# elsewhere.

$(OBJPATH)/%_$(CEDALIBVER)_$(ARCH).deb : FORCE
	$(call package-build-macro,$@,$*,$(CEDALIBVER),$*,$(if $(strip $($*_PACKAGE_ARCH)),$($*_PACKAGE_ARCH),$(ARCH)),$($*_PACKAGE_DEPENDENCIES),$(if $(strip $($*_PACKAGE_DESCRIPTION)),$($*_PACKAGE_DESCRIPTION),$* files),internal_custbuildhook,cedamk_custpackagebuildhook,cedamk_$*_custpackagebuildhook)

# Here, we leave off the dependency on *.pkgfiles, because adding them will
# cause a very misleading error message if the *.pkgfiles do not exist.  This
# is not really a problem, as an acceptable error message will be output
# elsewhere.
$(OBJPATH)/DEV_%_D$(CEDALIBVER)_$(ARCH).deb : FORCE
	$(call package-build-macro,$@,$*,$(CEDALIBVER),DEV_$*,$(if $(DEV_$*_PACKAGE_ARCH),$(strip $(DEV_$*_PACKAGE_ARCH)),$(ARCH)),$(DEV_$*_PACKAGE_DEPENDENCIES),$(if $(strip $(DEV_$*_PACKAGE_DESCRIPTION)),$(DEV_$*_PACKAGE_DESCRIPTION),$* files),internal_devbuildhook,cedamk_devpackagebuildhook,cedamk_$*_devpackagebuildhook)

# Here, we leave off the dependency on *.pkgfiles, because adding them will
# cause a very misleading error message if the *.pkgfiles do not exist.  This
# is not really a problem, as an acceptable error message will be output
# elsewhere.
$(OBJPATH)/DEV_%_D$(CEDALIBVER)_$(ARCH)_combine.deb : FORCE
	$(call package-build-macro,$@,$*,$(CEDALIBVER),DEV_$*,$(if $(DEV_$*_PACKAGE_ARCH),$(strip $(DEV_$*_PACKAGE_ARCH)),$(ARCH)),$(DEV_$*_PACKAGE_DEPENDENCIES),$(if $(strip $(DEV_$*_PACKAGE_DESCRIPTION)),$(DEV_$*_PACKAGE_DESCRIPTION),$* files),internal_devbuildhook,cedamk_devpackagebuildhook,cedamk_$*_devpackagebuildhook)


# Main packaging target:
packages::	pre-build-packages build-packages post-build-packages


build-packages package:: build-custpkg build-devpkg


pre-build-packages:: pre-build-custpkg pre-build-devpkg


post-build-packages:: post-build-custpkg post-build-devpkg

build-custpkg:: $(CUSTPACKAGES_FILES) $(SPECIAL_CUSTPACKAGES)

build-devpkg-combine:: $(DEVPACKAGES_FILES_COMBINE) $(SPECIAL_DEVPACKAGES)

build-devpkg:: $(DEVPACKAGES_FILES) $(SPECIAL_DEVPACKAGES)

buildinstall-custpkg:: build-custpkg install-custpkg

buildinstall-devpkg:: build-devpkg install-devpkg

install-custpkg::
	$(call generic-custpkg-installer,$(CUSTPACKAGES_FILES) $(SPECIAL_CUSTPACKAGES))
ifneq (win32,$(findstring win32,$(ARCH)))
ifeq ($(ADSPROD_ON),1)
	$(call adsprod-generic-custpkg-installer,$(CUSTPACKAGES_FILES) $(SPECIAL_CUSTPACKAGES))
endif
endif
	$(call tprod-generic-custpkg-installer,$(TPROD_CUSTPACKAGES_FILES))
ifdef TPROD
	$(call tprod-generic-custpkg-installer,$(CUSTPACKAGES_FILES) $(SPECIAL_CUSTPACKAGES))
endif

install-devpkg::
	$(call generic-devpkg-installer,$(DEVPACKAGES_FILES) $(SPECIAL_DEVPACKAGES))


pre-build-custpkg::
	$(call pre-build-custpkg-hook-32and64bit)
ifdef COMBINE_BUILD_32_BIT_PASS
	$(call pre-build-custpkg-hook)
else
	$(call pre-build-custpkg-hook-64bit)
endif

post-build-custpkg::
	$(call post-build-custpkg-hook-32and64bit)
ifdef COMBINE_BUILD_32_BIT_PASS
	$(call post-build-custpkg-hook)
else
	$(call post-build-custpkg-hook-64bit)
endif

pre-build-devpkg::
	$(call pre-build-devpkg-hook-32and64bit)
ifdef COMBINE_BUILD_32_BIT_PASS
	$(call pre-build-devpkg-hook)
else
	$(call pre-build-devpkg-hook-64bit)
endif

post-build-devpkg::
	$(call post-build-devpkg-hook-32and64bit)
ifdef COMBINE_BUILD_32_BIT_PASS
	$(call post-build-devpkg-hook)
else
	$(call post-build-devpkg-hook-64bit)
endif


#
# build-pcbitmap-dll:
#
#	$(1)	- dllname
#	$(2)	- bitmaps
#	$(call build-pcbitmap-dll,$(DLLNAME),$(BITMAPS)
#
ifeq (win,$(findstring win,$(ARCH)))
define build-pcbitmap-dll
	make_rc   $(2)
	mv build_tmp.rc  dllfile.rc 	
	rc   /l 0x409 /fo dllfile.res  $(RCINCLUDES) /d "_DEBUG"  dllfile.rc 	
	link /OUT:$(1)  /DLL /NOENTRY /IMPLIB:implib $(DLLFLAGS)  dllfile.res
endef
else
define build-pcbitmap-dll
	echo "Bitmap dlls on PC only"
endef
endif

#
# qt4-bitmap-resource-filename
#
# A parameterized function that returns the name of the Qt bitmap resource file.
#
# There is one parameter, the name passed in as the first argument to
#   qt4-build-bitmap-resource-file.
#
# Example:
#     BITMAP_FILE_NAME = $(call, qt4-bitmap-resource-filename,geminiui)
#

qt4-bitmap-resource-filename = $(strip $(1))-bitmaps.rcc


#
# qt4-build-bitmap-resource-file
#
#	$(1) - resource file name (without a suffix)
#	$(2) - list of bitmap file names
#	$(3) - optional destination directory.  The default is $(OBJPATH).
#
#  If no bitmap file names are given, no resource file is generated.  This is
#  not an error condition.
#
#  If the RCC compiler is not available, no resource file is generated.  This
#  is not an error condition except in the nightly build (that is, when BUILD_USER
#  is defined).
#
#  Example --
#
#    $(call qt4-build-bitmap-resource-file,geminiui,one.bmp two.bmp three.bmp)
#
#        creates a Qt 4 resource file named "geminiui-bitmaps.rcc".  It contains the
#        three specified bitmaps.  The Qt resource path for all the bitmaps is
#        ":/icons/" and the bitmaps have no suffix (e.g., ":/icons/one", ":/icons/two").
#
#  The two perl commands are pretty opaque.  There is probably a better way.
#  The first perl command puts each bitmap name on a separate line.
#  The second perl command has several parts:
#      Remove leading whitespace, if any.
#      Remove trailing whitespace, if any.
#      Match the filename (without path and without extension).
#      Print the resource file entry using the just-found name as the name and using
#         the explicit path (i.e., in the source directory) of the bitmap.
#
#  rcc compression level 5 seems to give reasonably good (about 50%) compression.
#
#  We use grep -c instead of grep -q because Solaris doesn't support grep -q.
#
define qt4-build-bitmap-resource-file
	$(MKDIR) $(OBJPATH)
	$(RM) $(OBJPATH)/$(call qt4-bitmap-resource-filename,$(1)) $(OBJPATH)/$(1).qrc
	echo '<RCC>' > $(OBJPATH)/$(1).qrc
	echo '<qresource prefix="/icons">' >> $(OBJPATH)/$(1).qrc
	echo $(2) | \
	    perl -n -e 'print join("\n", split());' | \
	    perl -n -e 's!^\s+!!;' \
	            -e 's!\s+$$!!;' \
	            -e 'm!^(.*/)?(.+?)(\.[^./]*)?$$!;' \
		    -e 'print "<file alias=\"", $$2, "\">$(SRCPATH)/", $$_, "</file>\n";' \
			>> $(OBJPATH)/$(1).qrc
	echo '</qresource>' >> $(OBJPATH)/$(1).qrc
	echo '</RCC>' >> $(OBJPATH)/$(1).qrc
	if [ -n "$(BUILD_USER)" -a ! -x "$(qt4-RCC)" ] ; then \
	    echo ERROR -- Cannot find the Qt resource compiler $(qt4-RCC). ; \
	    false ; \
	fi
	if grep -c alias $(OBJPATH)/$(1).qrc && [ -x "$(qt4-RCC)" ] ; then \
	    $(qt4-RCC) -name $(1) -binary -compress 5 -o $(OBJPATH)/$(call qt4-bitmap-resource-filename,$(1)) $(OBJPATH)/$(1).qrc ; \
	fi
	if [ -f $(OBJPATH)/$(call qt4-bitmap-resource-filename,$(1)) -a -n "$(3)" ] ; then \
	    $(CP) $(OBJPATH)/$(call qt4-bitmap-resource-filename,$(1)) $(3) ; \
	fi
endef


ifneq (win,$(findstring win,$(ARCH)))

define cdrom-setup
	@echo "cdrom-setup UNIX"
	eemkdir $(RAW_CDROMDIR)
	rm -f $(CDROMROOT)
	ln -s   $(RAW_CDROMDIR) $(CDROMROOT)
	eemkdir $(CDROMPLATDIR)
	eemkdir $(COMMON_CDROMPLATDIR)
	eemkdir $(TPROD_CDROMPLATDIR)
	eemkdir $(RAW_CDROMDIR)
	eelink $(RAW_CDROMDIR)  $(CDROMDIR) 
	eemkdir  $(RAW_WEBDIR)
	eelink  $(RAW_WEBDIR) $(WEBDIR)
	eemkdir  $(RAW_ISODIR)
	eelink  $(RAW_ISODIR) $(ISODIR)
	eemkdir  $(RAW_DVDDIR)
	eelink  $(RAW_DVDDIR) $(DVDDIR)
endef

else
define cdrom-setup
	@echo "cdrom-setup PC"
	@echo "Making directories $(CDROMROOT) and $(CDROMROOT_DISK2)" 
	eemkdir $(CDROMROOT)
	eemkdir $(CDROMROOT_DISK2)
endef
endif


notify-lastgoodinst:: notify lastgoodinst

notify::
	eesendmail "buildfailed" "Build failure with $(notdir $(shell pwd)) with build $(HPEESOF_DEV_ROOT)"  $(NOTIFY)


lastgoodinst::
	$(call generic-devpkg-installer,$(LGOOD_DEVPACKAGES_FILES)) 
	$(call generic-custpkg-installer,$(LGOOD_CUSTPACKAGES_FILES))
ifdef TPROD
	$(call tprod-generic-custpkg-installer,$(LGOOD_DEVPACKAGES_FILES)) 
endif



