# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/domains/sdf/instruments/mk/sdfinstruments.mk,v $ $Revision: 1.12 $ $Date: 2004/04/01 18:54:25 $

ifdef SDFINSTSTARS
	PTOLEMY_INCLUDEPATH += $(sdfinststars_dir)
	STARS += sdfinststars
	PTLIBS += libsdfinststars.sl
	# dependencies
	TSDFKERNEL = 1
	SDFINSTKERNEL = 1
	SDFFILE = 1
endif

ifdef SDFFILE
	PTOLEMY_INCLUDEPATH += $(sdffile_dir)
	PTLIBS += libsdffile.sl
	CPPFLAGS += -DSDF_REV=5
endif

ifdef SDFINSTKERNEL
	PTOLEMY_INCLUDEPATH += $(sdfinstkernel_dir)
	PTLIBS += libsdfinstkernel.sl
	# dependencies
	KERNEL = 1
endif

