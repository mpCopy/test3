# @(#) $Source: /cvs/china/src/WLAN_11N/mk/sdfwlan11n.mk,v $

ifdef SDFwlan11n 
	PTOLEMY_INCLUDEPATH += $(sdfwlan11nstars_dir)
	STARS += sdfwlan11nstars
	PTLIBS += libsdfwlan11nstars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFwlan11nsubckt 
        PTOLEMY_INCLUDEPATH += $(sdfwlan11nsubckt_dir)
        PTLIBS += libsdfwlan11nsubckt.sl
endif