CEDA_STL_INC=1

ifdef MSRVSIMSTARS
        PTOLEMY_INCLUDEPATH += $(msrvsimstars_dir) \
	$(HPEESOF_DEV_ROOT)/include \
	$(HPEESOF_DEV_ROOT)/include/adsptolemy/include/adsptolemy/src/signal-studio/ssfile \
	$(HPEESOF_DEV_ROOT)/include/adsptolemy/include/adsptolemy/src/signal-studio/ssfile/falcon_src \
	$(HPEESOF_DEV_ROOT)/include/adsptolemy/include/adsptolemy/src/signal-studio/ssfile/exporter \

        STARS += msrvsimstars
        PTLIBS += libmsrvsimstars.sl
        # dependencies
	SDFKERNEL = 1
	TSDFKERNEL = 1
	TSDFSTARS = 1
ifneq ($(ARCH), win32_64)
	SDFINSTKERNEL = 1
endif
        SSFILE = 1
        MSRVSIMKERNEL = 1
	PTDSP=1
	NSPR=1
endif

ifdef SSFILE
       PTOLEMY_INCLUDEPATH += $(HPEESOF_DEV_ROOT)/include/adsptolemy/include/adsptolemy/src/msrvsimcomponents/ssfile \
			$(HPEESOF_DEV_ROOT)/include/adsptolemy/include/adsptolemy/src/msrvsimcomponents/ssfile/falcon_src \
			$(HPEESOF_DEV_ROOT)/include/adsptolemy/include/adsptolemy/src/msrvsimcomponents/ssfile/exporter \
		#	$(HPEESOF_DEV_ROOT)/include/adsptolemy/include/adsptolemy/src/msrvsimcomponents/ssfile/importer

        PTLIBS += libssfile.sl
        ifeq ($(ARCH),win32)
          CPPFLAGS += -DLITTLE_ENDIAN_CPU 
        endif
        ifeq ($(ARCH),linux_x86)
          CPPFLAGS += -DLITTLE_ENDIAN_CPU 
        endif
        CPPFLAGS += -DWFM_PKG_LIB -DINCLUDE_ENCRYPTION
endif

ifdef MSRVSIMKERNEL
        PTOLEMY_INCLUDEPATH += 	$(msrvsimkernel_dir) \
				$(HPEESOF_DEV_ROOT)/include \
				$(HPEESOF_DEV_ROOT)/include/soap \

	LIBS += MServClient expat_easysoap easysoap

ifneq ($(ARCH), win32_64)
	LIBS += sdfinstkernel
endif

        PTLIBS += libmsrvsimkernel.sl
        # dependencies
        KERNEL = 1
endif
