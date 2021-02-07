#CEDA_STL_INC=
#NO_STL_INC=1

ifdef PTSYSTEMC
	#All customer SystemC stars are required to used the new
	#enum syntax
	PTLANGFLAGS+=-newenum
ifeq (linux,$(findstring linux, $(ARCH)))
	#To avoid long long problem in ISO C++
	CXXFLAGS += -Wno-long-long
endif

        SDFKERNEL=1

	#By having ptolemy2systemc_dir in the include path, 
	#we automatically use a local build of the ptolemy2systemc 
	#executable
        PTOLEMY_INCLUDEPATH += $(ptsystemc_dir) $(ptolemy2systemc_dir) 
        PTLIBS+=libptsystemc.sl
	NSPR=1

#Placing it in the path will only work on PC - FIXME
ifndef PT2SYSC_GENERATION
PT2SYSC_GENERATION=$(SHLIBPATHVAR)="$(PTOLEMY_SHLIBPATH):$($(SHLIBPATHVAR))" $(project_mk_dir)/bin.$(ARCH)/ptolemy2systemc
endif

#FIXME: I thought there were potential problems including rules before 
#the rest of the definitions - seems to work however
.phony: pt2sysc

#We probably want a better name for this target
pt2sysc:
	$(PT2SYSC_GENERATION) $(STAR_MK)
endif


ifdef SYSTEMC_EXECUTABLE
  CEDA_STL_INC=
  NO_STL_INC=1
  ifndef SYSTEMC
   ifdef SYSTEMC_EXECUTABLE_IN_BUILD
       SYSTEMC=$(ptsystemc.mk_dir)/lib/$(ARCH)/systemc
   else 
       SYSTEMC=$(HPEESOF_DIR)/adsptolemy/lib/$(ARCH)/systemc
   endif
  endif
  
  PTOLEMY_INCLUDEPATH += $(SYSTEMC)/src $(ptsystemclib_dir)

	## check platforms

  ifeq (win,$(findstring win,$(ARCH)))
	CPPFLAGS+= -EHsc  -GR -Gm -vmg -D "_CONSOLE"
	LIBSPATH+= $(SYSTEMC)/lib-win32
	LIBSOPTION+=  /SUBSYSTEM:CONSOLE
	## End check for platform
  endif
  
  ifeq (linux,$(findstring linux,$(ARCH)))
	LIBSPATH+=$(SYSTEMC)/lib-linux
	CXXFLAGS+=-Wno-long-long
  endif

  ifeq (sun,$(findstring sun,$(ARCH)))
      LIBSPATH+=$(SYSTEMC)/lib-sparcOS5
  endif
	LIBS += systemc ptsystemclib

endif
