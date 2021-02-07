# @(#) $Source: /cvs/china/src/SERDES/sdfserdes.mk.cmake,v $

ifdef SDFserdes 
	PTOLEMY_INCLUDEPATH += $(sdfserdesstars_dir)
	STARS += sdfserdesstars
	PTLIBS += libsdfserdesstars.sl
	# dependencies
	SDFKERNEL = 1
endif
