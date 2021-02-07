# @(#) $Source: /cvs/china/src/LTE/mk/sdflte.mk,v $

ifdef SDFlte
	PTOLEMY_INCLUDEPATH += $(sdfltestars_dir)
	STARS += sdfltestars
	PTLIBS += libsdfltestars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFltesubckt
        PTOLEMY_INCLUDEPATH += $(sdfltesubckt_dir)
        PTLIBS += libsdfltesubckt.sl
endif
