# @(#) $Source: /cvs/china/src/WLAN/mk/sdfwlan.mk,v $ $Revision: 1.4 $ $Date: 2004/04/23 00:49:29 $

ifdef SDFwlan 
	PTOLEMY_INCLUDEPATH += $(sdfwlanstars_dir)
	STARS += sdfwlanstars
	PTLIBS += libsdfwlanstars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFwlansubckt 
        PTOLEMY_INCLUDEPATH += $(sdfwlansubckt_dir)
        PTLIBS += libsdfwlansubckt.sl
endif
