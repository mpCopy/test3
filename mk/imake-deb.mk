ifneq ($(PRODNAME),"")
ARCH=$(shell hped-arch)
PLAT=$(shell hped-arch -u)
DEBNAME=$(PRODNAME)_$(BLDVER).$(BLDREV).deb
PRODNAME:=$(shell echo $(PRODNAME) | tr "[:upper:]" "[:lower:]"  | tr "-" "_" )
UPPRODNAME:=$(shell echo $(PRODNAME) | tr "[:lower:]" "[:upper:]")
ifndef CEDA_SITE
CEDA_SITE=$(shell hped-site)
endif
ifeq ($(SITE),wlv)
RSYNCMACHINE=shasta.wlv.keysight.com
else
RSYNCMACHINE=usmint.soco.keysight.com
endif

ifeq (win,$(findstring win,$(ARCH)))
CEDA_CDROM=$(dir $(HPEESOF_DIR))/DISK5
else
CEDA_CDROM=$(dir $(HPEESOF_DIR))/cdrom/DISK5
endif
ifndef MYCDROM_DIR
MYCDROM_DIR=$(CEDA_CDROM)/$(PRODNAME)/$(PLAT)
endif

build_debian:: install_addon

install_addon::
	@echo "Using hpedmk imake-def.mk"
	$(RM) -rf $(shell echo `pwd`)/root
	eemkdir $(shell echo `pwd`)/root/DEBIAN
	$(MAKE) OUTDIR=$(shell echo `pwd`)/root install
	$(MAKE) make_addon
ifeq (win,$(findstring win,$(ARCH)))
	hpeesofmake.ksh build_deb 
else
	$(MAKE) build_deb 
endif
ifdef BUILD_USER
	hpeesofpkg -i  $(DEBNAME)
ifeq ($(BUILDTYPE),opt)
ifeq ($(CEDA_SITE),wlv)
	eemkdir  $(MYCDROM_DIR)
	cp -f  $(DEBNAME) $(MYCDROM_DIR)/$(UPPRODNAME).DEB
#ifeq ($(CEDA_SITE),wlv)
#	if cd $(MYCDROM_DIR) ; then   rrsyc.ksh  .  \
#	$(RSYNCMACHINE)::builds/dev$(BLDVER)/r$(BLDREV)/$(BUILDTYPE)/cdrom/DISK4/$(PRODNAME)/WIN32 ; fi
#endif

endif
endif
	eecopy $(DEBNAME) $(shell echo `pwd`)/goodpackages 
endif


make_addon::
	find root -type d -print | xargs chmod 755
	find root -type d -print | xargs chmod -s
	@echo "Creating control file"
	if [ -f  control  ] ; then  \
	cp -f control   $(shell echo `pwd`)/root/DEBIAN/control ; \
	else \
	echo "package: $(PRODNAME)" >  control  ; \
	echo "Version:  $(BLDVER).$(BLDREV) " >>  control ; \
	echo  "Architecture: $(ARCH) " >>  control ; \
	echo "Maintainer: Keygith EEsof " >>  control ; \
	echo "Depends: " >>  control ; \
	echo "Installed-Size: $(shell du -sk root | awk '{ print $$1 }') " >>  control ; \
	echo "Description: $(PRODNAME) files" >>  control ; \
	mv  -f   control   $(shell echo `pwd`)/root/DEBIAN/control ; fi 

build_deb::
	hpeesofpkg --build $(shell echo `pwd`)/root $(DEBNAME)

endif #PRODANME empty
