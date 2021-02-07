# @(#) $Source: /cvs/china/src/WMAN/mk/sdfwman.mk,v $

ifdef SDFwman 
	PTOLEMY_INCLUDEPATH += $(sdfwmanstars_dir)
	STARS += sdfwmanstars
	PTLIBS += libsdfwmanstars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFwmansubckt 
        PTOLEMY_INCLUDEPATH += $(sdfwmansubckt_dir)
        PTLIBS += libsdfwmansubckt.sl
endif
