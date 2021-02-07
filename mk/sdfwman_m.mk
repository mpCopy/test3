# @(#) $Source: /cvs/china/src/WMAN_M/mk/sdfwman_m.mk,v $

ifdef SDFwman_m 
	PTOLEMY_INCLUDEPATH += $(sdfwman_mstars_dir)
	STARS += sdfwman_mstars
	PTLIBS += libsdfwman_mstars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFwman_msubckt 
        PTOLEMY_INCLUDEPATH += $(sdfwman_msubckt_dir)
        PTLIBS += libsdfwman_msubckt.sl
endif
