# @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/sp-modelbuilder/mk/sdf.mk,v $ $Revision: 100.40 $ $Date: 2006/12/13 22:15:06 $

# Tcl/Tk stars
ifdef SDFTK
	PTOLEMY_INCLUDEPATH += $(sdftclstars_dir)
	STARS += sdftclstars
	PTLIBS += libsdftclstars.sl
	TCLTK=1
	# dependencies
	SDFDSP = 1
	SDFKERNEL = 1 
	PTK=1
endif

# UCB Xgraph stars
ifdef SDFXGRAPH
	PTOLEMY_INCLUDEPATH += $(sdfxstars_dir)
	STARS += sdfxstars
	PTLIBS += libsdfxstars.sl
	SDFKERNEL = 1
	SDFDSP = 1
endif

# ADVCOMM stars
ifdef ADVCOMM
	PTOLEMY_INCLUDEPATH += $(sdfadvcommstars_dir)
	PTLIBS += libsdfadvcommstars.sl
	# dependencies
	SDFKERNEL = 1
endif

# DSP stars
ifdef SDFDSP 
	PTOLEMY_INCLUDEPATH += $(sdfdspstars_dir)
	STARS += sdfdspstars
	PTLIBS += libsdfdspstars.sl
	# dependencies
	SDFSTARS=1
	SDFKERNEL = 1
	PTDSP = 1
endif

# OMNISYS stars
ifdef SDFOMNI
	PTOLEMY_INCLUDEPATH += $(sdfomnistars_dir)
	STARS += sdfomnistars
	PTLIBS += libsdfomnistars.sl
	# dependencies
	SDFOMNIKERNEL = 1
	PTDSP = 1
endif

ifdef SDFOMNIKERNEL
	PTOLEMY_INCLUDEPATH += $(sdfomnisys_dir)
	PTLIBS += libsdfomnisys.sl
	# dependencies
	SDFKERNEL = 1
	PTDSP = 1
endif

# Image processing stars
ifdef SDFIMAGE
	PTOLEMY_INCLUDEPATH += $(sdfimagestars_dir)
	STARS += sdfimagestars
	PTLIBS += libsdfimagestars.sl
	# dependencies
	SDFKERNEL = 1
endif

# Matrix stars
ifdef SDFMATRIX 
	PTOLEMY_INCLUDEPATH += $(sdfmatrix_dir)
	STARS += sdfmatrix
	PTLIBS += libsdfmatrix.sl
	# dependencies
	SDFKERNEL = 1
endif

# Matlab interface stars
ifdef SDFMATLAB
	PTOLEMY_INCLUDEPATH += $(sdfmatlabstars_dir)
	STARS += sdfmatlabstars
	PTLIBS += libsdfmatlabstars.sl
	# dependencies
	SDFKERNEL = 1
	PTMATLAB = 1
endif

# Contributed stars by third-party users
ifdef SDFSYNTH
	PTOLEMY_INCLUDEPATH += $(sdfsynthstars_dir)
	STARS += sdfsynthstars
	PTLIBS += libsdfsynthstars.sl
	# dependencies
	SDFKERNEL = 1
endif

# Contributed stars by third-party users
ifdef SDFCONTRIB
	PTOLEMY_INCLUDEPATH += $(sdfcontribstars_dir)
	STARS += sdfcontribstars
	PTLIBS += libsdfcontribstars.sl
	# dependencies
	SDFCONTRIBKERNEL = 1
endif

ifdef SDFCONTRIBKERNEL
	PTOLEMY_INCLUDEPATH += $(sdfcontrib_dir)
	PTLIBS += libsdfcontrib.sl 
	# dependencies
	SDFKERNEL = 1
endif

# SDF Loop scheduler
ifdef SDFLOOP
	PTOLEMY_INCLUDEPATH += $(LS_dir)
	PTLIBS += libLS.sl
	# dependencies
	SDFKERNEL = 1
endif

# UCB Xgraph stars
ifdef SDFXGRAPH
	PTOLEMY_INCLUDEPATH += $(sdfxstars_dir)
	STARS += sdfxstars
	PTLIBS += libsdfxstars.sl
	SDFKERNEL = 1
endif

# kernel and stars
ifdef SDFSTARS
	PTOLEMY_INCLUDEPATH += $(sdfstars_dir)
	STARS += sdfstars 
	PTLIBS += libsdfstars.sl
	# dependencies
	SDFKERNEL = 1
endif

ifdef SDFKERNEL
	PTOLEMY_INCLUDEPATH += $(sdf_dir) 
	PTLIBS += libsdf.sl
	KERNEL=1
endif





