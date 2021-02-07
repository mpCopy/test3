# @(#) $Source: /cvs/china/src/HSUPA/mk/sdfhsupa.mk,v $

ifdef SDFhsbase 
	PTOLEMY_INCLUDEPATH += $(sdfhsupabasestars_dir)
	STARS += sdfhsupabasestars
	PTLIBS += libsdfhsupabasestars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFhsupa 
	PTOLEMY_INCLUDEPATH += $(sdfhsupastars_dir)
	STARS += sdfhsupastars
	PTLIBS += libsdfhsupastars.sl
	# dependencies
	SDFKERNEL = 1
endif
ifdef SDFhsupaderived 
	PTOLEMY_INCLUDEPATH += $(sdfhsupaderivedstars_dir)
	STARS += sdfhsupaderivedstars
	PTLIBS += libsdfhsupaderivedstars.sl
	# dependencies
	SDFKERNEL = 1
endif
ifdef SDFhsupasubckt 
        PTOLEMY_INCLUDEPATH += $(sdfhsupasubckt_dir)
        PTLIBS += libsdfhsupasubckt.sl
endif
ifdef TSDFhsupasubckt 
        PTOLEMY_INCLUDEPATH += $(tsdfhsupasubckt_dir)
        PTLIBS += libtsdfhsupasubckt.sl
endif