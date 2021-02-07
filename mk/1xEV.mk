# @(#) $Header: /cvs/china/src/1xEV/mk/1xEV.mk,v 1.2 2001/10/18 06:48:40 cn569337 Exp $

ifdef SDF1xEV 
	PTOLEMY_INCLUDEPATH += $(sdf1xevstars_dir)
	STARS += sdf1xEVstars
	PTLIBS += libsdf1xevstars.sl
	# dependencies
	SDFKERNEL = 1
endif
