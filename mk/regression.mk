# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/sp-modelbuilder/mk/regression.mk,v $ $Revision: 100.12 $ $Date: 2000/02/07 23:28:35 $

regression::

####################################################################
# Custom Executable Regression Test
#
# Variables:
#	BASELINE	List of logfiles to produce
#	<logfile>_arg	Argument to give CPLUSVISUALTARGET for the
#			<logfile> element in the BASELINE list.
#####################################################################

# fixme: I couldn't find a working example of _arg or a list of items
# in BASELINE, so wasn't sure how to implement.  The below is only for
# one item in BASELINE.
ifdef REGRESSIONTARGET
regression::
	$(MAKE) TARGET=$(REGRESSIONTARGET) INSTALL_BINDIR=$(LOCAL_ROOT)/regression.$(ARCH) install
	$(OBJPATH)/$(REGRESSIONTARGET) > $(OBJPATH)/$(BASELINE) 
	if [ ! -f $(BASELINE) ]; then \
	  cp $(OBJPATH)/$(BASELINE) $(BASELINE) ; \
	else \
	  diff $(OBJPATH)/$(BASELINE) $(BASELINE) ; \
	fi

endif #REGRESSIONTARGET

#####################################################################
# hpeesofsim netlist regression test
#
# Variable:
#	NETS		List of netlists to process (filename suffix
#			must be .net)
#####################################################################
ifdef NETS

RAWFILES=$(NETS:.net=.raw$(SUFFIX))

FORCE:

$(addprefix $(OBJPATH)/,$(RAWFILES)): FORCE

regression:: $(RAWFILES) $(addprefix $(OBJPATH)/,$(RAWFILES))

%.raw:
	-hpeesofsim $(@F:.raw$(SUFFIX)=.net)
	-$(MV) spectra.raw $@
	-if [ "$$(dirname $@)" = "$(OBJPATH)" ] ; then \
		diff $(@F) $@ ; fi
endif #NETS
