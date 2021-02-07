# @(#) $Source: /cvs/china/src/UMB/mk/sdfumb.mk,v $

ifdef SDFumb
	PTOLEMY_INCLUDEPATH += $(sdfumbstars_dir)
	STARS += sdfumbstars
	PTLIBS += libsdfumbstars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFumbsubckt 
        PTOLEMY_INCLUDEPATH += $(sdfumbsubckt_dir)
        PTLIBS += libsdfumbsubckt.sl
endif
