# @(#) $Source: /cvs/china/src/UWB/mk/sdfuwb.mk,v $

ifdef SDFuwb 
	PTOLEMY_INCLUDEPATH += $(sdfuwbstars_dir)
	STARS += sdfuwbstars
	PTLIBS += libsdfuwbstars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFuwbsubckt 
        PTOLEMY_INCLUDEPATH += $(sdfuwbsubckt_dir)
        PTLIBS += libsdfuwbsubckt.sl
endif
ifdef TSDFuwbsubckt 
        PTOLEMY_INCLUDEPATH += $(tsdfuwbsubckt_dir)
        PTLIBS += libtsdfuwbsubckt.sl
endif