# $Header: /cvs/wlv/src/hptolemyaddons/src/sp-modelbuilder/mk/package.mk,v 100.90 2009/04/01 17:54:45 ikoyfman Exp $

# product name
ifndef PRODNAME
PRODNAME=$(shell basename `pwd`)
endif

# examples directory name
ifndef PRODNAMEEXAMPLES
PRODNAMEEXAMPLES=$(PRODNAME)
endif

# doc examples directory name
ifndef PRODNAMEDOCEXAMPLES
PRODNAMEDOCEXAMPLES=PtolemyDocExamples
endif

# source header directory name
ifndef PRODSRCLOC
PRODSRCLOC=$(PRODNAME)
endif

# default directories
ifndef PRODBITMAPSDIR
PRODBITMAPSDIR=bitmaps
endif
ifndef PRODSYMBOLSDIR
PRODSYMBOLSDIR=symbols
endif
ifndef PRODDESIGNSDIR
PRODDESIGNSDIR=designs
endif
ifndef PRODTEMPLATESDIR
PRODTEMPLATESDIR=templates
endif
ifndef PRODAELDIR
PRODAELDIR=ael
endif

# name of component index file
indexfile=hshpeesofsim_index

ifeq (win,$(findstring win,$(ARCH)))
DPKG-NAME=$(HPEESOF_DIR)/tools/bin/dpkg-name
else
DPKG-NAME=ksh $(HPEESOF_DIR)/tools/bin/dpkg-name
endif

ROOT_DIR=root
ROOTDEV_DIR=rootdev
ROOTDOC_DIR=rootdoc

ifndef ROOTBASE
ROOTBASE=$(SRCPATH)
endif

ROOT=$(ROOTBASE)/$(ROOT_DIR)
ROOTDEV=$(ROOTBASE)/$(ROOTDEV_DIR)
ROOTDOC=$(ROOTBASE)/$(ROOTDOC_DIR)

SETCMD=set -e -x

ifeq ($(findstring linux,$(ARCH)),linux)
TAR=tar
else
TAR=$(HPEESOF_DIR)/tools/bin/tar
endif
ifeq (win,$(findstring win,$(ARCH)))
TAR_IN = sed -e "" | $(TAR) cf - -T -
# the empty sed is needed to strip ^M, which tar -T will not like
else
TAR_IN = $(TAR) cf - -T -
endif
TAR_OUT = $(TAR) xf -
ifndef DPKG-GENCONTROL
DPKG-GENCONTROL = $(PERL) $(project_mk_dir)/bin/dpkg-gencontrol
endif

ifdef CEDA_64_BIT
ifeq ($(ARCH),win32_64)
ARCH_32BIT=win32_64
packagebuild: packagebuild_install packagebuild_ael packagebuild_subckt_ael packagebuild_bitmaps_qt packagebuild_bitmaps_compile_qt packagebuild_symbols packagebuild_designs packagebuild_templates packagebuild_example_projects packagebuild_sources packagebuild_mk packagebuild_postpackagehook packagebuild_cleanup
else  # CEDA_64_BIT non-Windows 
packagebuild: packagebuild_install_64bit packagebuild_example_projects packagebuild_postpackagehook
endif # win32_64 check
else
packagebuild: packagebuild_install packagebuild_ael packagebuild_subckt_ael packagebuild_bitmaps_qt packagebuild_bitmaps_compile_qt packagebuild_symbols packagebuild_designs packagebuild_templates packagebuild_example_projects packagebuild_sources packagebuild_mk packagebuild_postpackagehook packagebuild_cleanup
endif

packagebuild_initialize:
	$(RM) -r $(ROOT)

packagebuild_install_64bit:
	$(MAKE) CEDA_64_BIT=1 INSTALL_ROOT=$(ROOT)/adsptolemy INSTALL_LIBDIR=$(ROOT)/adsptolemy/lib.$(ARCH_64BIT) INSTALL_BINDIR=$(ROOT)/adsptolemy/bin.$(ARCH_64BIT) install
	$(RM) $(ROOT)/adsptolemy/lib.$(ARCH_64BIT)/*subckt*

packagebuild_install:
	$(MAKE) INSTALL_ROOT=$(ROOT)/adsptolemy INSTALL_LIBDIR=$(ROOT)/adsptolemy/lib.$(ARCH_32BIT) INSTALL_BINDIR=$(ROOT)/adsptolemy/bin.$(ARCH_32BIT) install
	$(RM) $(ROOT)/adsptolemy/lib.$(ARCH_32BIT)/*subckt*

packagebuild_ael:
	echo "Inside packagebuild_ael..."
	$(MAKE) INSTALL_ROOT=$(ROOT)/adsptolemy ael
	$(SETCMD); for i in $(PRODAELDIR); do if [ -d $$i ] ; then \
	  [ -d $(ROOT)/adsptolemy/ael ] || $(MKDIR) $(ROOT)/adsptolemy/ael ;\
	  $(CP) $$i/*.ael $(ROOT)/adsptolemy/ael ; fi ; done
	$(SETCMD); if [ -d $(ROOT)/adsptolemy/ael ] ; then cd $(ROOT)/adsptolemy/ael ;\
	  for i in *.ael ; do if [ -f $$i ] ; then \
	    $(HPEESOF_BIN_DIR)/aelcomp $$i $${i%ael}atf ; fi ; done ; fi

packagebuild_subckt_ael:
	$(RM) $(ROOT)/adsptolemy/ael/$(PRODNAME)subcircuits.adf
	$(SETCMD); for i in $(PRODDESIGNSDIR); do \
	  if ls $$i/*.ael >/dev/null ; then \
	  [ -d $(ROOT)/adsptolemy/ael ] || $(MKDIR) $(ROOT)/adsptolemy/ael ; \
	  cat $$i/*.ael >> \
	    $(ROOT)/adsptolemy/ael/$(PRODNAME)subcircuits.adf; \
	fi ; done
	$(SETCMD); if [ -f $(ROOT)/adsptolemy/ael/$(PRODNAME)subcircuits.adf ]; then \
	  $(MAKE) INSTALL_ROOT=$(ROOT)/adsptolemy \
	    IDFLIB=$(PRODNAME)subcircuits DIRS= ael ; \
	  $(RM) $(ROOT)/adsptolemy/ael/*bak; \
	  chmod 755 $(ROOT)/adsptolemy/ael/*atf ; fi

#
# Just copies the bitmaps.  Doesn't perform any translation of bitmap formats
# because Qt doesn't need that.
#
packagebuild_bitmaps_qt:
	$(SETCMD); for i in $(PRODBITMAPSDIR) ; do if [ -d $$i ] ; then \
	  [ -d $(ROOT)/adsptolemy/bitmaps/$(PRODNAME) ] || $(MKDIR) \
	    $(ROOT)/adsptolemy/bitmaps/$(PRODNAME) ;\
	  for j in $$i/*.bmp ; \
	      do $(CP) $$j $(ROOT)/adsptolemy/bitmaps/$(PRODNAME)/$$(basename $$j) ; \
	  done ; \
	fi ; done

packagebuild_bitmaps_compile_qt:
	$(call qt4-build-bitmap-resource-file,$(PRODNAME),$(wildcard $(notdir $(ROOT))/adsptolemy/bitmaps/$(PRODNAME)/*.bmp),$(ROOT)/adsptolemy/bitmaps)
	if [ -f $(ROOT)/adsptolemy/bitmaps/$(call qt4-bitmap-resource-filename,$(PRODNAME)) ] ; then \
	    $(RM) -r $(ROOT)/adsptolemy/bitmaps/$(PRODNAME) ; \
	fi

packagebuild_symbols:
	$(SETCMD); for i in $(PRODSYMBOLSDIR) ; do if [ -d $$i ] ; then \
	  [ -d $(ROOT)/adsptolemy/symbols ] || $(MKDIR) $(ROOT)/adsptolemy/symbols ;\
	  for j in $$i/*.dsn ; do \
	    $(CP) $$j $(ROOT)/adsptolemy/symbols/ ; done ;\
	fi ; done

packagebuild_designs:
	$(SETCMD); for i in $(PRODDESIGNSDIR) ; do if [ -d $$i ] ; then \
	  [ -d $(ROOT)/adsptolemy/designs ] || $(MKDIR) $(ROOT)/adsptolemy/designs ;\
	  for j in $$i/*.dsn ; do \
	    $(CP) $$j $(ROOT)/adsptolemy/designs/ ; done ;\
	fi ; done

packagebuild_templates:
	$(SETCMD); for i in $(PRODTEMPLATESDIR); do if [ -d $$i ] ; then \
	  [ -d $(ROOT)/adsptolemy/templates ] || $(MKDIR) $(ROOT)/adsptolemy/templates; \
	  (cd $$i; find . -type f -print | grep -v CVS | $(TAR_IN) ) | \
	  (cd $(ROOT)/adsptolemy/templates ; $(TAR_OUT)); fi ; done

packagebuild_example_projects:
	$(SETCMD); if [ -d projects ] ; then \
	  cd projects; \
	     if  ls | grep -v CVS | grep -v $(PRODNAMEDOCEXAMPLES) >/dev/null  ;then \
	        $(MKDIR) $(ROOT)/examples/$(PRODNAMEEXAMPLES)/ ;\
	        find . -type f -print | grep -v CVS | grep -v $(PRODNAMEDOCEXAMPLES) | \
	        $(TAR_IN) | (cd $(ROOT)/examples/$(PRODNAMEEXAMPLES); $(TAR_OUT)) ;\
	     fi ;\
	  if [ -d  $(PRODNAMEDOCEXAMPLES) ] ; then \
	     $(MKDIR) $(ROOT)/examples/$(PRODNAMEDOCEXAMPLES)/ ;\
	     cd $(PRODNAMEDOCEXAMPLES); find . -type f -print | grep -v CVS | \
	     $(TAR_IN) | (cd $(ROOT)/examples/$(PRODNAMEDOCEXAMPLES); $(TAR_OUT)) ;\
	  cd ..; \
	  fi; \
	  for i in $$(find $(ROOT)/examples -name *.ael -print) ; do \
	     $(HPEESOF_BIN_DIR)/aelcomp $$i $${i%ael}atf ;\
	  done ;\
	  cd $(ROOT)/examples ;\
	  for i in $$(find . -name networks -type d -print);do \
	    PRJDIR=$${i%/networks} ;\
	    $(MKDIR) $$PRJDIR/data ;\
	    if [ ! -f $$PRJDIR/de_sim.cfg ] ; then \
	      echo PROJECT_VERSION=1000 > $$PRJDIR/de_sim.cfg ;\
	    fi ;\
	  done ;\
	fi

ifeq (win,$(findstring win,$(ARCH)))
DOCPL = cat package/docpl | sed -e ""
else
DOCPL = cat package/docpl
endif
ifeq (win,$(findstring win,$(ARCH)))
SHIPH = cat package/shipheaders | sed -e ""
else
SHIPH = cat package/shipheaders
endif
packagebuild_sources:
# example .pls, headers
ifndef NO_DOC_PL
	$(SETCMD); if [ -f package/docpl ] ; then \
	  $(MKDIR) $(ROOT)/doc/sp_items ;\
	  for i in $$($(DOCPL)) ; do \
	    grep -v 'Source:.*Revision:.*Date:' $$i > $(ROOT)/doc/sp_items/$$(basename $$i) ; \
	    $(MKDIR) $(ROOT)/adsptolemy/src/$(PRODSRCLOC)/$$(dirname $$i) ;\
	    grep -v 'Source:.*Revision:.*Date:' $${i%pl}h > $(ROOT)/adsptolemy/src/$(PRODSRCLOC)/$${i%pl}h ;\
	  done ;\
	fi
endif
ifndef NO_SHIP_HEADERS
	$(SETCMD); if [ -f package/shipheaders ] ; then \
	  for i in $$($(SHIPH)) ; do \
	      if [ ! -f $$i ] ; then echo "$$i does not exist!!\n"; false; fi\
	  done;\
	  $(MKDIR) $(ROOT)/adsptolemy/src/$(PRODSRCLOC) ; cat package/shipheaders| \
	  $(TAR_IN) | (cd $(ROOT)/adsptolemy/src/$(PRODSRCLOC); $(TAR_OUT));\
	  find . -name *Dll.h | grep -v $(ROOT_DIR) | $(TAR_IN) | (cd $(ROOT)/adsptolemy/src/$(PRODSRCLOC); $(TAR_OUT)) ;\
	fi
endif

packagebuild_mk:
# any mk files and misc scripts
	$(MKDIR) $(ROOT)/adsptolemy
	if [ -d mk ] ; then \
	  find mk -type f | grep -v CVS | grep -v dirname.mk | grep -v packagemk.mk | $(TAR_IN) | (cd $(ROOT)/adsptolemy; $(TAR_OUT)) ;\
	fi
	if [ -d lib ] ; then \
	  find lib -type f | grep -v CVS | $(TAR_IN) | (cd $(ROOT)/adsptolemy; $(TAR_OUT)) ;\
	fi
	if [ -d bin ] ; then \
	  find bin -type f | grep -v CVS | $(TAR_IN) | (cd $(ROOT)/adsptolemy; $(TAR_OUT)) ;\
	fi
	if [ -d lib.$(ARCH) ] ; then \
	  find lib.$(ARCH) -type f | grep -v CVS | $(TAR_IN) | (cd $(ROOT)/adsptolemy; $(TAR_OUT)) ;\
	fi

packagebuild_postpackagehook:
	$(postpackagebuildhook32and64bit)
ifndef COMBINE_BUILD_64_BIT_PASS
	$(postpackagebuildhook)
else
	$(postpackagebuildhook64bit)
endif

packagebuild_cleanup:
	$(MKDIR) $(ROOT)/DEBIAN
	$(DPKG-GENCONTROL) package/control $(ROOT) > $(ROOT)/DEBIAN/control
	$(SETCMD); for i in preinst prerm postinst postrm ; do \
	  if [ -f package/$$i ] ; then \
	    $(CP) package/$$i $(ROOT)/DEBIAN ; chmod +x $(ROOT)/DEBIAN/$$i ; fi ;\
	done
	find $(ROOT) -type d -print | xargs chmod 755
	find $(ROOT) -type d -print | xargs chmod -s
	find $(ROOT) -print | xargs chmod g-w,o-w,a+r
	hpeesofpkg --build $(ROOT)
	$(MKDIR) $(LOCAL_ROOT)/packages
	$(DPKG-NAME) -s $(LOCAL_ROOT)/packages/ -o root.deb
	$(RM) -r $(ROOT)

packagebuild-dev:
	echo "ROOTDEV = $(ROOTDEV)"
	$(RM) -r $(ROOTDEV)
	$(MKDIR) $(ROOTDEV)/include/adsptolemy/src/$(PRODSRCLOC)
	$(MKDIR) $(ROOTDEV)/doc/xml/$(PRODNAME)
	$(MAKE) INSTALL_ROOT=$(ROOTDEV) PRODNAME=$(PRODNAME) createxml
	$(SETCMD); for i in `find . -name *.xml -print`; do \
	  if [ -f $$i ]; then \
	    $(CP) $$i $(ROOTDEV)/doc/xml/$(PRODNAME)/$$(basename $$i); \
	  fi ; done
	$(SETCMD); for i in `find . -name *Index -print`; do \
	  if [ -f $$i ]; then \
	    $(CP) $$i rootdev/doc/xml/$(PRODNAME)/$$(basename $$i); \
	  fi ; done
	$(SETCMD); if [ -f package/docpl ] ; then \
	   $(CP) package/docpl $(ROOTDEV)/doc/xml/$(PRODNAME)/ ;\
	   $(MKDIR) $(ROOTDEV)/doc/xml/$(PRODNAME)/sp_items ; \
	   for i in $$($(DOCPL)) ; do \
	     $(MKDIR) tmp_html; \
	     grep -v 'Source:.*Revision:.*Date:' $$i > tmp_html/$$(basename $$i); \
	     $(PERL) $(project_mk_dir)/bin/eesofspihtmgen tmp_html/$$(basename $$i) $(ROOTDEV)/doc/xml/$(PRODNAME)/sp_items; \
	   done; \
	   $(RM) -r tmp_html; \
	fi ;
	(find $(DIRS) -name *.h -print ; \
	if [ -f package/shipheaders ] ; then \
	  cat package/shipheaders; \
	fi; ) | sort -u | $(TAR_IN) | \
	(cd $(ROOTDEV)/include/adsptolemy/src/$(PRODSRCLOC); $(TAR_OUT))
	if [ -d mk ] ; then \
	  find mk -type f | grep -v CVS | $(TAR_IN) | (cd $(ROOTDEV)/include/adsptolemy; $(TAR_OUT)) ;\
	fi
ifneq (win,$(findstring win,$(ARCH)))
	$(MAKE) INSTALL_ROOT=$(ROOTDEV)/include/adsptolemy createmaster
endif
	$(postpackagedevbuildhook32and64bit)
ifndef COMBINE_BUILD_64_BIT_PASS
	$(postpackagedevbuildhook)
else
	$(postpackagedevbuildhook64bit)
endif
	mkdir $(ROOTDEV)/DEBIAN
	$(DPKG-GENCONTROL) package/control $(ROOTDEV) | \
	$(PERL) -pe 's/$$/-dev/ if /^package:/i; $$_="" if /^depends:/i;' > $(ROOTDEV)/DEBIAN/control
	$(SETCMD); for i in preinst-dev prerm-dev postinst-dev postrm-dev ; do \
	  if [ -f package/$$i ] ; then \
	    j=$${i%-dev} ; $(CP) package/$$i $(ROOTDEV)/DEBIAN/$$j ;\
	    chmod +x $(ROOTDEV)/DEBIAN/$$j ; fi ;\
	done
	find $(ROOTDEV) -type d -print | xargs chmod 755
	  if [ -f $(ROOTDEV)/DEBIAN/postinst ] ; then \
		find $(ROOTDEV) -name postinst -print | xargs chmod 755 ;\
	fi
	  if [ -f $(ROOTDEV)/DEBIAN/postrm ] ; then \
		find $(ROOTDEV) -name postrm -print | xargs chmod 755 ;\
	fi
	find $(ROOTDEV) -type d -print | xargs chmod -s
	hpeesofpkg --build $(ROOTDEV)
	$(MKDIR) $(LOCAL_ROOT)/packages
	$(DPKG-NAME) -s $(LOCAL_ROOT)/packages/ -o $(ROOTDEV).deb
	$(RM) -r $(ROOTDEV)

list-unshipped:
	@$(ECHO) Unshipped stars:
	$(at)find . -name *.pl | $(PERL) $(project_mk_dir)/bin/listunshipped \
		package/docpl
	@$(ECHO) Unshipped headers:
	$(at)find . -name *.h | $(PERL) $(project_mk_dir)/bin/listunshipped \
		package/shipheaders
