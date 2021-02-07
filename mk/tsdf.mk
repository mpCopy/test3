# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/sp-modelbuilder/mk/tsdf.mk,v $ $Revision: 100.14 $ $Date: 2004/03/26 02:24:07 $

ifdef TSDFGEMSTARS
	PTOLEMY_INCLUDEPATH += $(tsdfgemstars_dir)
	STARS += tsdfgemstars
	PTLIBS += libtsdfgemstars.sl
	# dependencies
	TSDFSINKS=1
	PTGEM = 1
endif

ifdef TSDFSINKS
	PTOLEMY_INCLUDEPATH += $(tsdfsinks_dir)
	STARS += tsdfsinks
	PTLIBS += libtsdfsinks.sl
	# dependencies
	TSDFSTARS=1
endif

ifdef TSDFSTARS
	PTOLEMY_INCLUDEPATH += $(tsdfstars_dir)
	STARS += tsdfstars
	PTLIBS += libtsdfstars.sl
	# dependencies
	TSDFKERNEL=1
	PTDSP = 1
	SDFOMNIKERNEL=1
endif

ifdef TSDFKERNEL
	PTOLEMY_INCLUDEPATH += $(tsdf_dir)
	PTLIBS += libtsdf.sl
	# dependencies
	SDFKERNEL=1
endif
