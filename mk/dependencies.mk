# Ptolemy dependencies

# The PACKAGEMK method of specifying dependencies isn't used because
# that would preclude building parts of packages separately.

include $(project_mk_dir)/mk/tsdf.mk
include $(project_mk_dir)/mk/sdf.mk

ifdef PTK
	PTOLEMY_INCLUDEPATH += $(ptk_dir) $(HPEESOF_DIR)/tools/include
	PTLIBS += ptk
	KERNEL = 1
endif

ifdef TCLTK
	ifdef TCL_INSTALL_DIR
		PTOLEMY_INCLUDEPATH += $(TCL_INSTALL_DIR)/include
		LIBSPATH += $(TCL_INSTALL_DIR)/lib
	else
		PTOLEMY_INCLUDEPATH += $(HPEESOF_DIR)/tools/include
		LIBSPATH += $(HPEESOF_DIR)/tools/lib
	endif
ifeq ($(findstring linux,$(ARCH)),linux)
	ifdef CEDA_64_BIT
	   LIBSPATH += /usr/X11R6/lib64
	else
	   LIBSPATH += /usr/X11R6/lib
	endif
endif
ifeq (win,$(findstring win,$(ARCH)))
	LIBS += tcl84 tk84
else
	LIBS += tcl8.4 tk8.4 X11
endif
endif

ifdef PTMATLAB
	PTOLEMY_INCLUDEPATH += $(ptmatlab_dir) $(HPEESOF_DEV_ROOT)/include/matlab
	PTLIBS += ptmatlab
	PTCOMPAT = 1
	KERNEL = 1
endif

ifdef PTDSP
	PTOLEMY_INCLUDEPATH += $(ptdsp_dir)
	PTLIBS += ptdsp gsl
endif

ifdef PTGEM
	PTOLEMY_INCLUDEPATH += $(ptgem_dir)
	PTLIBS += ptgem
ifeq (win,$(findstring win,$(ARCH)))
	PTLIBS += hpeesofsim_private
endif
	KERNEL = 1
	PTSTATIC = 1
endif

ifdef PTPDE
	PTOLEMY_INCLUDEPATH += $(ptpde_dir)
	PTLIBS += ptpde
	KERNEL = 1
endif

ifdef KERNEL
	PTOLEMY_INCLUDEPATH += $(ptolemy_dir)
	PTLIBS += ptolemy gsl linker 
	PTCOMPAT = 1
	ifeq ($(suffix $(TARGET)),)
	PTEXELIBS = 1
	endif
endif

ifdef PTSTATIC
	PTOLEMY_INCLUDEPATH += $(ptstatic_dir) $(HPEESIMSRC)
endif

ifdef PTCOMPAT
	PTOLEMY_INCLUDEPATH += $(compat_ptolemy_dir) $(compat_cfront_dir)
	ifeq (win,$(findstring win,$(ARCH)))
	PTOLEMY_INCLUDEPATH += $(compat_win32_dir)
	else
	PTOLEMY_INCLUDEPATH += $(compat_unix_dir)
	endif
endif

ifdef PTEXELIBS
	ifneq (win,$(findstring win,$(ARCH)))
		LIBS += gsec
	endif
endif

ifdef NSPR
	ifeq (win,$(findstring win,$(ARCH)))
		LIBS+=libnspr4
	else
        	LIBS+=nspr4
	endif

	ifdef LOCAL_NSPR
		PTOLEMY_INCLUDEPATH += $(LOCAL_ROOT)/src/nspr/nsprbuild-$(ARCH)/mozilla/nsprpub/dist/include/nspr
		LIBSPATH += $(LOCAL_ROOT)/src/nspr/nsprbuild-$(ARCH)/mozilla/nsprpub/dist/lib
	else

		ifdef INTERNAL_DEV_ROOT
			PTOLEMY_INCLUDEPATH += $(INTERNAL_DEV_ROOT)/include/nspr
		else
			PTOLEMY_INCLUDEPATH += $(HPEESOF_DIR)/adsptolemy/src/gsl/nspr
		endif #ifdef INTERNAL_DEV_ROOT

	endif #LOCAL_NSPR
endif

ifdef CEDA_STL_INC
ifndef INTERNAL_DEV_ROOT
CXXINCLUDEPATH += $(HPEESOF_DIR)/adsptolemy/src/gsl/stlport
endif
endif
