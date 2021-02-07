# win32 rules
# $Header: /cvs/wlv/src/cedamk/mk/m4/win32.m4,v 1.118 2012/05/30 21:00:09 build Exp $

####################
# Utilities
define(`SetShell',)
define(`Lex',`flex')
define(`Yacc',`byacc')

####################
# Suffixes
define(`ObjSuffix',`.obj')
define(`ArSuffix',`.lib')
define(`SlSuffix',`.dll')
define(`ExeSuffix',`.exe')
define(`EXEPREFIX',` ')

####################
# Librarypatterns

define(`ArPattern',%ArSuffix)
define(`SlPattern',%SlSuffix)

####################
# Compilation
define(`CcCompiler',`cl')
define(`CxxCompiler',`cl')


define(`NoLogo',`/nologo')
define(`pdbFile',`$(PROJECT_NAME).pdb')
define(`pdbflg',`/Fd$(PROJECT_NAME).pdb')

define(`CppFlags',` /D_AFXDLL /DNO_MALLOC_MACRO /DWIN32 /D_WIN32 /U_WINDOWS /DWINVER=0x0500 /D_MBCS ')
define(`CppFlagsOpt',`/DOPT_BUILD /DNDEBUG /DOPT_BUILD')
define(`IncludeOption',`/I')

define(`Win32Flags',` /Zi /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_WARNINGS  /W4  NoLogo /Dfar=far_p /Dnear=near_p pdbflg')

define(`MDFlag',ifdef(`cedamkdebug',/MDd,/MD))

define(`Manifest',` /MANIFEST')


define(`CcFlags',`Win32Flags /TC')
define(`CcFlagsDebug',`MDFlag /Zi /D _DEBUG /D DEBUG')
define(`CcFlagsOpt',`MDFlag /O2  /Oy- /D NDEBUG')
define(`CcFlagsOptLesser',`MDFlag /O1  /Oy- /D NDEBUG')
define(`CcCompileOption',`/c')
define(`CcTargetOption',`/o')
define(`CcTarget',`/Fo$`'@')

define(`CxxFlags',`Win32Flags /TP')
define(`CxxFlagsDebug',CcFlagsDebug)
define(`CxxFlagsOpt',CcFlagsOpt)
define(`CxxFlagsOptLesser',CcFlagsOptLesser)
define(`CxxCompileOption',CcCompileOption)
define(`CxxTargetOption',CcTargetOption)
define(`CxxTarget',`/Fo$`'@')

define(`CommonSystemShLibs',`WSock32  user32 advapi32 comdlg32 gdi32 netapi32 comctl32 winspool')
define(`MSVC_DIR',`msdev')
define(`RCINCLUDES',`/i./ /i$(SITE_ROOT)/$(MSVC_DIR)/include  /i$(SITE_ROOT)/$(MSVC_DIR)/mfc/include  /i$(SITE_ROOT)/$(MSVC_DIR)/mfc/src')

define(`EmbedManifestExe',mt -manifest $(1).manifest "-outputresource:$(1);1")
define(`EmbedManifestDll',mt -manifest $(1).manifest "-outputresource:$(1);2")

####################
# Static libraries
define(`IncludeLibdirOption',`/LIBPATH:')
define(`LibOptionPrefix',)
define(`LibOptionSuffix',ArSuffix)
define(`LibPrefix',)
define(`LibBaseName',$(basename $(TARGET)))
define(`LinkLibBaseName',$(basename $(TARGET)))

define(`ArDefs',`
LINK.a = $(AR) $(ARFLAGS)

define UPDATE_LIBRARY_COMMAND
if [ -f $(1) ] ; then $(LIBCMD) $(1) $(2); else $(LIBCMD) /out:$(1) $(2); fi
endef
')

define(`MultimkRule', `$(at)$(PERL) ''`$(shell cygpath -w $(ceda_mk_dir)/bin/multimk)''` $(TARGETS) > $`'@');

define(`MultimkLongLineRule', `$(at)echo "" > $`'@; for i in $(TARGETS); do $(PERL) ''`$(shell cygpath -w $(ceda_mk_dir)/bin/multimk)''` $$i >> $`'@; done');


####################
# Shared libraries

define(`ShlibPathVar',`PATH')
define(`SlTargetSuffix',`SlSuffix, .lib')


define(`SlDefs',
`LINK=link  /MAP /DEBUG /FIXED:NO /INCREMENTAL:NO  /OPT:REF 
LIBCMD = lib
WINDUMPEXTS = $(PERL) ''`$(shell cygpath -w $(ceda_mk_dir)/bin/winDumpExts)''`
LIBLINK = $(LIBSPATHOPTION) $(LIBSOPTION)
CPPFLAGS += /D$(basename $(TARGET))_DLL_BUILD

SLLIBVER = $(CEDALIBVER)

ifdef debug
DEBUGOPTION = /debug 
endif

define SL_LINK_C
SlPreRule
	if [ "X$(MANAGES_WIN32_EXPORTS)" != "X" ] ; then \
	echo "Linking without using dumpbin.  Creating simple def file using ."; \
	echo "NAME $(4)$(SLLIBVER).dll" > $(4)$(SLLIBVER).def ; \
	echo "$(LIBCMD) /nologo $(2) $(LIBLINK)" ; \
	$(LIBCMD) /nologo $(2) $(LIBLINK) ; \ 
	else
	$(WINDUMPEXTS) $(4)$(SLLIBVER).dll $(2) > $(4)$(SLLIBVER).def ; \
	if [ "X$(WIN32EXTRADEFS)" != "X" ] ; then cat $(WIN32EXTRADEFS) >> $(4)$(SLLIBVER).def ; fi ; \
	if [ "X$(WIN32EXTRADEFS)" != "X" ] ; then $(LIBCMD) NoLogo /def:$(4)$(SLLIBVER).def $(2) $(LIBLINK) $(3:%=LibOptionPrefix%LibOptionSuffix) ; fi ; \
	if [ "X$(WIN32EXTRADEFS)" = "X" ] ; then $(LIBCMD) NoLogo /def:$(4)$(SLLIBVER).def $(2) $(LIBLINK) ; fi ; \
	fi
	$(LINK) NoLogo $(DEBUGOPTION) /dll $(TARGET_C_LDFLAGS) $(C_LDFLAGS) /out:$(1) $(4)$(SLLIBVER).exp $(2) $(TARGET_C_LDFLAGS_POST) $(C_LDFLAGS_POST) $(LIBLINK) $(3:%=LibOptionPrefix%LibOptionSuffix) $(COMMON_SYSTEM_LIBS:%=LibOptionPrefix%LibOptionSuffix) $(COMMON_SYSTEM_SHLIBS:%=LibOptionPrefix%LibOptionSuffix) $(MSVCRT)
	cp -f  $(4)$(SLLIBVER).exp $(4).exp
	cp -f  $(4)$(SLLIBVER).lib $(4).lib
SlPostRule
endef

define SL_LINKLIB_CXX
SlPreRule
	if [ "X$(MANAGES_WIN32_EXPORTS)" != "X" ] ;  then \
	echo "MANAGES_WIN32_EXPORTS is set, SL_LINKLIB_CXX does nothing."; \
	else \
	$(WINDUMPEXTS) $(4)$(SLLIBVER).dll @objfiles.txt > $(4)$(SLLIBVER).def ; \
	if [ "X$(WIN32EXTRADEFS)" != "X" ] ; then cat $(WIN32EXTRADEFS) >> $(4)$(SLLIBVER).def ; fi ; \
	if [ "X$(WIN32EXTRADEFS)" != "X" ] ; then $(LIBCMD) /nologo /def:$(4)$(SLLIBVER).def @objfiles.txt $(LIBLINK) $(3:%=%.lib) ; fi ;\
	if [ "X$(WIN32EXTRADEFS)" = "X" ] ; then $(LIBCMD) /nologo /def:$(4)$(SLLIBVER).def @objfiles.txt $(LIBLINK) ; fi ; \
	if [ "X$(SLLIBVER)" != "X" ] ; then cp -f  $(4)$(SLLIBVER).exp $(4).exp ; \
	cp -f  $(4)$(SLLIBVER).lib $(4).lib ; fi ; \
	fi
endef

define SL_LINKDLL_CXX
SlPreRule
	if [ "X$(MANAGES_WIN32_EXPORTS)" != "X" ] ;  then \
	echo "$(LINK) /nologo $(DEBUGOPTION) /dll /NOENTRY  $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) /out:$(1) @objfiles.txt $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(LIBLINK) $(3:%=%.lib) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib) $(MSVCRT)"; \
	$(LINK) /nologo $(DEBUGOPTION) /dll /NOENTRY $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) /out:$(1) @objfiles.txt $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(LIBLINK) $(3:%=%.lib) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib) $(MSVCRT); \
	if [ "X$(SLLIBVER)" != "X" ] ; then cp -f  $(4)$(SLLIBVER).exp $(4).exp ; \
	cp -f  $(4)$(SLLIBVER).lib $(4).lib ; fi ; \
	else \
	echo "$(LINK) /nologo $(DEBUGOPTION) /dll $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) /out:$(1) $(4)$(SLLIBVER).exp @objfiles.txt $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(LIBLINK) $(3:%=%.lib) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib) $(MSVCRT)"; \
	$(LINK) /nologo $(DEBUGOPTION) /dll $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) /out:$(1) $(4)$(SLLIBVER).exp @objfiles.txt $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(LIBLINK) $(3:%=%.lib) $(COMMON_SYSTEM_LIBS:%=%.lib) $(COMMON_SYSTEM_SHLIBS:%=%.lib) $(MSVCRT); \
	fi
SlPostRule
endef

define SL_LINK_CXX
	$(call SL_LINKLIB_CXX,$(1),$(2),$(3),$(4))
	$(call SL_LINKDLL_CXX,$(1),$(2),$(3),$(4))
endef

define SL_MAKE_OBJFILES 
	@$(ECHO) $(strip $(1)) > objfiles.txt
endef

define SL_MAKE_EXP
touch $(3)
endef

')

define(`TargetDllHRuleDefs',
`# arg 1: target name, arg 2: template file, arg 3: .h file to create
define MAKE_TARGET_DLL_H
$(PERL) -p -e "s/LIBNAME/$(basename $(1))/g" ''`$(shell cygpath -w $(2))''` > $(3)
endef
')

define('SlBuildAddlRules',
`
ALL_OBJECTS += $(LIBBASENAME).lib
INSTALL_OBJECTS += $(INSTALL_LIBDIR)/$(LIBBASENAME).lib
')

####################
# Executables

define(`ExeDefs',
`
define CCLINKEXE
$(CC_LINKPREFIX) $(LINK) NoLogo Manifest $(DEBUGOPTION) $(TARGET_C_LDFLAGS) $(C_LDFLAGS) /out:$(EXEPREFIX)$(1) $(2) $(LIBLINK) $(3:%=LibOptionPrefix%LibOptionSuffix) $(TARGET_C_LDFLAGS_POST) $(C_LDFLAGS_POST) $(COMMON_SYSTEM_LIBS:%=LibOptionPrefix%LibOptionSuffix) $(COMMON_SYSTEM_SHLIBS:%=LibOptionPrefix%LibOptionSuffix)
ExePostRule
endef

define CXXLINKEXE
$(CXX_LINKPREFIX) $(LINK) NoLogo Manifest $(DEBUGOPTION) $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) /out:$(EXEPREFIX)$(1) $(2) $(LIBLINK) $(3:%=LibOptionPrefix%LibOptionSuffix) $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(COMMON_SYSTEM_LIBS:%=LibOptionPrefix%LibOptionSuffix) $(COMMON_SYSTEM_SHLIBS:%=LibOptionPrefix%LibOptionSuffix)
ExePostRule
endef')

define(`ExeBuildAddlRules',)



####################
# Dependencies
define(`MakeDependFlags',`-M -- $(filter-out /U%,$(CPPFLAGS:/D%=-D%)) -- $(patsubst /I%,-I%,$(INCLUDEPATHOPTION) $(CINCLUDEPATHOPTION) $(CXXINCLUDEPATHOPTION))  $(WIN_INCLUDE_VAR) ')
