# @(#) $Source: /cvs/china/src/HSDPA/mk/sdfhsdpa.mk,v $

ifdef SDFhsdpa
	PTOLEMY_INCLUDEPATH += $(sdfhsdpastars_dir)
	STARS += sdfhsdpastars
	PTLIBS += libsdfhsdpastars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFhsdpasubckt
        PTOLEMY_INCLUDEPATH += $(sdfhsdpasubckt_dir)
        PTLIBS += libsdfhsdpasubckt.sl
endif
