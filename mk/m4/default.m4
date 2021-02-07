# default rules
# $Header: /cvs/wlv/src/cedamk/mk/m4/default.m4,v 1.56 2007/10/17 21:02:27 dbjornba Exp $

####################
# Utilities
define(`SetShell',`SHELL = /bin/sh')
define(`Echo',`echo -e')
define(`Mkdir',`mkdir -p')
define(`Rm',`rm -f')
define(`Cp',`cp -f -p')
define(`Mv',`mv -f')
define(`Perl',`perl')
define(`Lex',`lex')
define(`Yacc',`yacc')
define(`CdsEnv',`/hped/builds/bin/cds-env')
define(`Skillpp',`$(CPP) -C -P')
define(`Bison',`bison')

####################
# Suffixes
define(`ObjSuffix',`.o')
define(`ArSuffix',`.a')
define(`SlSuffix',`.sl')
define(`ExeSuffix',)

####################
# Compilation
define(`CcCompiler',`cc')
define(`CxxCompiler',`CC')

define(`CppFlags',)
define(`CppFlagsDebug',)
define(`CppFlagsOpt',`-DOPT_BUILD -DNDEBUG')
define(`IncludeOption',`-I')

define(`CcFlags',)
define(`CcFlagsDebug',`-g')
define(`CcFlagsOpt',`-O -DNDEBUG')
define(`CcFlagsOptLesser',`-O -DNDEBUG')
define(`CcCompileOption',`-c')
define(`CcTargetOption',`-o')
define(`CcTarget',`-o $`'@')

define(`CxxFlags',)
define(`CxxFlagsDebug',`-g')
define(`CxxFlagsOpt',`-O -DNDEBUG')
define(`CxxFlagsOptLesser',`-O -DNDEBUG')
define(`CxxCompileOption',`-c')
define(`CxxTargetOption',`-o')
define(`CxxTarget',`-o $`'@')

define(`CxxLinkFlgs',)

define(`SystemIncludePath',)

define(`CommonSystemLibs',`')
define(`CommonSystemArchiveLibs',`')
define(`CommonSystemShLibs',`')


define(`CompilerSetup',)
define(`ExecFlags',)

####################
# MultiMk
define(`MultimkRule', `$(at)$(PERL) $(ceda_mk_dir)/bin/multimk $(TARGETS) > $`'@');

define(`MultimkLongLineRule', `$(at)echo "" > $`'@; for i in $(TARGETS); do $(PERL) $(ceda_mk_dir)/bin/multimk $$i >> $`'@; done');


####################
# Static libraries
define(`ArDefs',`
LINK.a = $(AR) $(ARFLAGS)

define UPDATE_LIBRARY_COMMAND
$(LINK.a) LinkaTargetOption $(1) $(2)
endef
')
define(`ArLinker',`ar')
define(`ArFlags',`rc')
define(`LinkaTargetOption',)
define(`LibPrefix',lib)
define(`LinkLibBaseName',LibPrefix$(basename $(TARGET)))
define(`LibBaseName',LibPrefix$(basename $(TARGET)))

define(`ArPattern',LibPrefix%ArSuffix)

define(`ArNewBuildRule',
`
ifeq ($(suffix $(TARGET)),.a)
LIBCOBJS  =${addprefix $(LIBBASENAME)ArSuffix`'(, ${addsuffix ), $(patsubst   %.c, %ObjSuffix,$(filter %.c, $(SRCS)))}}
ifneq (,$(LIBCOBJS))
(%ObjSuffix): %.c ;
$(OBJPATH)/$(LIBBASENAME)ArSuffix :: $(LIBCOBJS)
	${call COMPILE.c, ${addprefix $(SRCPATH)/, $(?:ObjSuffix=.c)}}
	$(call UPDATE_LIBRARY_COMMAND,$`'@,${notdir $(?:.c=ObjSuffix)});
	$(RM) ${notdir $(?:.c=ObjSuffix)}
endif
LIBCCOBJS =${addprefix $(LIBBASENAME)ArSuffix`'(, ${addsuffix ), $(patsubst  %.cc, %ObjSuffix,$(filter %.cc, $(SRCS)))}}
ifneq (,$(LIBCCOBJS))
(%ObjSuffix): %.cc ;
$(OBJPATH)/$(LIBBASENAME)ArSuffix :: $(LIBCCOBJS)
	$(call COMPILE.cxx, $(addprefix $(SRCPATH)/, ${?:ObjSuffix=.cc}))
	$(call UPDATE_LIBRARY_COMMAND,$`'@,${notdir $(?:.cc=ObjSuffix)});
	$(RM) ${notdir $(?:.cc=ObjSuffix)}
endif
LIBCPPOBJS=${addprefix $(LIBBASENAME)ArSuffix`'(, ${addsuffix ), $(patsubst %.cpp, %ObjSuffix,$(filter %.cpp, $(SRCS)))}}
ifneq (,$(LIBCPPOBJS))
(%ObjSuffix): %.cpp ;
$(OBJPATH)/$(LIBBASENAME)ArSuffix :: $(LIBCPPOBJS)
	$(call COMPILE.cxx, $(addprefix $(SRCPATH)/, ${?:ObjSuffix=.cpp}))
	$(call UPDATE_LIBRARY_COMMAND,$`'@,${notdir $(?:.cpp=ObjSuffix)});
	$(RM) ${notdir $(?:.cpp=ObjSuffix)}
endif
LIBCXXOBJS=${addprefix $(LIBBASENAME)ArSuffix`'(, ${addsuffix ), $(patsubst %.cxx, %ObjSuffix,$(filter %.cxx, $(SRCS)))}}
ifneq (,$(LIBCXXOBJS))
(%ObjSuffix): %.cxx ;
$(OBJPATH)/$(LIBBASENAME)ArSuffix :: $(LIBCXXOBJS)
	$(call COMPILE.cxx, $(addprefix $(SRCPATH)/, ${?:ObjSuffix=.cxx}))
	$(call UPDATE_LIBRARY_COMMAND,$`'@,${notdir $(?:.cxx=ObjSuffix)});
	$(RM) ${notdir $(?:.cxx=ObjSuffix)}
endif
.SPECIAL: $(LIBCOBJS) $(LIBCCOBJS) $(LIBCPPOBJS) $(LIBCXXOBJS)
endif')


####################
# Shared libraries
define(`ShlibPathVar',`LD_LIBRARY_PATH')
define(`SystemShlibPath',)
define(`IncludeLibdirOption',`-L')
define(`LibOptionPrefix',`-l')
define(`LibOptionSuffix',)

define(`SlPattern',$(LIBPREFIX)%$(SLSUFFIX))

define(`SlTargetSuffix',`SlSuffix')

define(`LinkCcSl',`$(CC)')
define(`LinkCxxSl',`$(CXX)')
define(`CcSlFlags',`-G')
define(`CxxSlFlags',`-G')

define(`SlDefs',
`LINK.csl = LinkCcSl CcSlFlags $(SLFLAGS)
LINK.cxxsl = LinkCxxSl CxxSlFlags $(SLFLAGS)

SLLIBVER =

define SL_LINK_C
SlPreRule
$(LINK.csl) $(TARGET_C_LDFLAGS) $(C_LDFLAGS) -o $(1) $(2) $(TARGET_C_LDFLAGS_POST) $(C_LDFLAGS_POST) $(LIBSPATHOPTION) $(3:%=LibOptionPrefix%LibOptionSuffix) $(LIBSOPTION) $(COMMON_SYSTEM_LIBS:%=LibOptionPrefix%LibOptionSuffix) $(COMMON_SYSTEM_SHLIBS:%=LibOptionPrefix%LibOptionSuffix)
SlPostRule
endef

define SL_LINK_CXX
SlPreRule
$(LINK.cxxsl) $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) -o $(1) $(2) $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(LIBSPATHOPTION) $(3:%=LibOptionPrefix%LibOptionSuffix) $(LIBSOPTION) 
SlPostRule
endef

define SL_MAKE_OBJFILES
	@$(ECHO) "Prepare to Link"
endef 

define SL_MAKE_EXP
touch $(3)
endef

')

define(`TargetDllHRuleDefs',
`# arg 1: target name, arg 2: template file, arg 3: .h file to create
define MAKE_TARGET_DLL_H
$(PERL) -p -e "s/LIBNAME/$(basename $(1))/g" $(2) > $(3)
endef
')

define(`SlBuildAddlRules',)

define(`SlPreRule',)
define(`SlPostRule',)

####################
# Executables
define(`ExeFlags',)
define(`CcExeFlags',)
define(`CxxExeFlags',)

define(`ExeDefs',
`EXEFLAGS += ExeFlags
EXEPREFIX =
LINK.ccexe = $(CC) CcExeFlags $(EXEFLAGS)
LINK.cxxexe = $(CXX) CxxExeFlags $(EXEFLAGS)

ifndef RATIONAL_FLAGS
RATIONAL_FLAGS = -recursion-depth-limit=20000 -cache-dir=$(shell pwd)  -always-use-cache-dir=yes  
endif
ifndef PURIFY
PURIFY = purify $(RATIONAL_FLAGS)  
endif
ifndef QUANTIFY
QUANTIFY = quantify  $(RATIONAL_FLAGS)
endif
ifndef PURECOV
PURECOV = purecov  $(RATIONAL_FLAGS)
endif

define CCLINKEXE
$(CC_LINKPREFIX) $(LINK.ccexe) $(TARGET_C_LDFLAGS) $(C_LDFLAGS) CcTargetOption $(1) $(2) $(LIBSPATHOPTION) $(3:%=LibOptionPrefix%LibOptionSuffix) $(LIBSOPTION) $(TARGET_C_LDFLAGS_POST) $(C_LDFLAGS_POST) $(COMMON_SYSTEM_LIBS:%=LibOptionPrefix%LibOptionSuffix) $(COMMON_SYSTEM_SHLIBS:%=LibOptionPrefix%LibOptionSuffix)
ExePostRule
endef

define CXXLINKEXE
$(CXX_LINKPREFIX) $(LINK.cxxexe) $(TARGET_CXX_LDFLAGS) $(CXX_LDFLAGS) CxxTargetOption $(1) $(2) $(LIBSPATHOPTION) $(3:%=LibOptionPrefix%LibOptionSuffix) $(LIBSOPTION) $(CXXLINKFLGS) $(TARGET_CXX_LDFLAGS_POST) $(CXX_LDFLAGS_POST) $(COMMON_SYSTEM_LIBS:%=LibOptionPrefix%LibOptionSuffix) $(COMMON_SYSTEM_SHLIBS:%=LibOptionPrefix%LibOptionSuffix)
ExePostRule
endef

')

define(`ExeBuildAddlRules',

purify: ADDITIONAL_BUILD_CFLAGS += -DPURIFY=1
purify: ADDITIONAL_BUILD_CXXFLAGS += -DPURIFY=1
purify:
	$(at)$(MAKE) CC_LINKPREFIX="$(PURIFY)" CXX_LINKPREFIX="$(PURIFY)" \
		EXEPREFIX=purify- EXEPREFIX=purify- \
		ADDITIONAL_BUILD_CFLAGS="$(ADDITIONAL_BUILD_CFLAGS)" \
		ADDITIONAL_BUILD_CXXFLAGS="$(ADDITIONAL_BUILD_CXXFLAGS)" \
		compile

quantify:
	$(at)$(MAKE) CC_LINKPREFIX="$(QUANTIFY)" CXX_LINKPREFIX="$(QUANTIFY)" \
		EXEPREFIX=quantify- EXEPREFIX=quantify- compile

purecov:
	$(at)$(MAKE) CC_LINKPREFIX="$(PURECOV)" CXX_LINKPREFIX="$(PURECOV)" \
		EXEPREFIX=purecov- EXEPREFIX=purecov- compile
)

define(`ExePostRule',)

####################
# Dependencies
define(`MakeDependFlags',`-M -- $(CPPFLAGS) -- $(INCLUDEPATHOPTION) $(CINCLUDEPATHOPTION) $(CXXINCLUDEPATHOPTION)')

####################
# Targets
define(`SlInstallObjects',
`ifelse(`$#',0, ,
        `$#',1,`$(INSTALL_LIBDIR)/$(LIBBASENAME)$1',
        `$(INSTALL_LIBDIR)/$(LIBBASENAME)$(SLLIBVER)`$1' SlInstallObjects(shift($@))')')
