# documentation generation and display

ifeq (win,$(findstring win,$(ARCH)))
PERL_INSTALL_ROOT = "$(shell cygpath -w $(INSTALL_ROOT))"
else
PERL_INSTALL_ROOT = $(INSTALL_ROOT)
endif

# more
ifdef STAR_MK

# generate htm files from xml files
createhtm::
	$(at)$(MKDIR) $(INSTALL_ROOT)/doc/compsp
	$(PERL) $(project_mk_dir)/bin/eesofdocgen \
	 --lpdir=$(HPTOLEMY_DEV_ROOT)/doc/temp_html $(STAR_MK)Index	\
	$(PERL_INSTALL_ROOT) $(PRODNAME)

createtemplate::
	$(at)$(MKDIR) html/images
	$(CP) $(project_mk_dir)/lib/docgen/sample.html html/.
	$(CP) $(project_mk_dir)/lib/docgen/sample.fm html/.
	$(CP) $(project_mk_dir)/lib/docgen/README html/.

endif

createindex::
	$(at)$(MKDIR) $(INSTALL_ROOT)/doc/compsp
	$(PERL) $(project_mk_dir)/bin/eesofindexgen $(PERL_INSTALL_ROOT)


# generate files needed to display doc
displaydoc:
	$(at)$(MKDIR) $(INSTALL_ROOT)/doc/compsp
	$(PERL) $(project_mk_dir)/bin/eesoftocgen $(PERL_INSTALL_ROOT)/doc



# create a master file for updating doc
createmaster::
	$(at)$(MKDIR) $(INSTALL_ROOT)/doc   
	$(PERL) $(project_mk_dir)/bin/eesofmastergen $(PRODNAME) $(PERL_INSTALL_ROOT)
