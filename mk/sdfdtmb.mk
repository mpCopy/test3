# @(#) $Source: /cvs/china/src/DTMB/mk/sdfdtmb.mk,v $

ifdef SDFdtmb 
	PTOLEMY_INCLUDEPATH += $(sdfdtmbstars_dir)
	STARS += sdfdtmbstars
	PTLIBS += libsdfdtmbstars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFdtmbsubckt 
        PTOLEMY_INCLUDEPATH += $(sdfdtmbsubckt_dir)
        PTLIBS += libsdfdtmbsubckt.sl
endif
ifdef TSDFdtmbsubckt 
        PTOLEMY_INCLUDEPATH += $(tsdfdtmbsubckt_dir)
        PTLIBS += libtsdfdtmbsubckt.sl
endif