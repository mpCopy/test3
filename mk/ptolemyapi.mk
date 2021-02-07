
ifdef RFDE_EXPORT
include $(ptolemyapi.mk_dir)/mk/rfdeexport.mk
endif

ifdef PTOLEMYAPIBUILD
include $(ptolemyapi.mk_dir)/mk/ptolemyapibuild.mk
endif

ifdef APIUNIVERSE
	PTOLEMY_INCLUDEPATH += $(apiuniverse_dir)
	PTLIBS += libapiuniverse.sl
	TDFAPISTARS=1
	PTGEM=1
endif

ifdef PTOLEMYAPI
	PTOLEMY_INCLUDEPATH += $(ptolemyapi_dir)
	PTLIBS += libptolemyapi.sl
	PTPARSER=1
	DFAPISTARS=1
endif

ifdef APIKERNEL
	PTOLEMY_INCLUDEPATH += $(dfapistars_dir)
	PTLIBS += libdfapistars.sl
	PTGEM=1
	SDFKERNEL=1
	TSDFKERNEL=1
	DFAPISTARS=1
endif

ifdef DFAPISTARS
	PTOLEMY_INCLUDEPATH += $(dfapistars_dir)
	PTLIBS += libdfapistars.sl
	SDFKERNEL=1
	TSDFKERNEL=1
endif

ifdef TDFAPISTARS
	PTOLEMY_INCLUDEPATH += $(dfapistars_dir) $(tdfapistars_dir)
	PTLIBS += libdfapistars.sl libtdfapistars.sl
	SDFKERNEL=1
	TSDFKERNEL=1
        DFAPISTARS=1
	PTTHREADAPI=1
endif

ifdef PTTHREADAPI
	PTOLEMY_INCLUDEPATH += $(ptThreadAPI_dir)
	PTLIBS += libptThreadAPI.sl
ifeq ($(ARCH),win32)
        LIBS+=libnspr4
else
        LIBS+=nspr4
endif
endif

ifdef PTPARSER
	PTOLEMY_INCLUDEPATH += $(ptParser_dir)
	PTLIBS += libptParser.sl
	KERNEL = 1
endif

ifeq ($(debug),2)
  CXXFLAGS+=-DDEBUG_LEVEL_2
endif
ifeq ($(debug),3)
  CXXFLAGS+=-DDEBUG_LEVEL_2 -DDEBUG_LEVEL_3
endif

