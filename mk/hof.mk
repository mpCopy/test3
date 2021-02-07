# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hof/mk/hof.mk,v $ $Revision: 100.5 $ $Date: 2001/10/19 16:32:38 $

HOFDIR = $(ROOT)/src/domains/hof

ifdef HOF
	HOFSTARS=1
endif

ifdef HOFSTARS
	PTOLEMY_INCLUDEPATH += $(hofstars_dir)
	STARS += hofstars
	PTLIBS += libhofstars.sl
	# dependencies
	HOFKERNEL=1
endif

ifdef HOFKERNEL
	PTOLEMY_INCLUDEPATH += $(hof_dir)
	PTLIBS += libhof.sl
	KERNEL=1
endif
