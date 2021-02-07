# @(#) $Source: /cvs/china/src/3GPP/mk/sdfwcdma3g.mk,v $ $Revision: 3.6 $ $Date: 2004/04/27 22:33:04 $

ifdef SDFwcdma3gfdd 
	PTOLEMY_INCLUDEPATH += $(sdfwcdma3gfddstars_dir)
	STARS += sdfwcdma3gfddstars
	PTLIBS += libsdfwcdma3gfddstars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFwcdma3gfddsubckt 
        PTOLEMY_INCLUDEPATH += $(sdfwcdma3gfddsubckt_dir)
        PTLIBS += libsdfwcdma3gfddsubckt.sl
endif
