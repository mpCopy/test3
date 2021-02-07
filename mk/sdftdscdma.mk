# @(#) $Source: /cvs/china/src/TDSCDMA/mk/sdftdscdma.mk,v $ $Revision: 1.2 $ $Date: 2004/04/24 00:00:14 $

ifdef SDFtdscdma 
	PTOLEMY_INCLUDEPATH += $(sdftdscdmastars_dir)
	STARS += sdftdscdmastars
	PTLIBS += libsdftdscdmastars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFtdscdmasubckt 
        PTOLEMY_INCLUDEPATH += $(sdftdscdmasubckt_dir)
        PTLIBS += libsdftdscdmasubckt.sl
endif
