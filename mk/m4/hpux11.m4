# hpux11 rules
$Header: /cvs/wlv/src/cedamk/mk/m4/hpux11.m4,v 1.21 2006/06/28 22:26:44 brianand Exp $


####################
# Utilities
define(`Echo',`echo')

####################
# Compilation
define(`CxxCompiler',`aCC -AA ')

define(`CppFlags',` -D_HPUX_SOURCE -DSYSV -DHPUX_11 'defn(`CppFlags'))

#define(`CcFlags',`-Aa -D_HPUX_SOURCE -z +Z +DS871 +w1')
define(`CcFlags',`-Ae -z +Z +DS871 +w1')
define(`CcFlagsOpt',`+O2')
define(`CcFlagsOptLesser',`+O1')

define(`CxxFlags',` -z +Z +DS871 +w')
define(`CxxFlagsDebug',`-g0 +d')
define(`CxxFlagsOpt',`+O2')
define(`CxxFlagsOptLesser',`+O1')

define(`CommonSystemLibs',`m')

define(`CompilerSetup',
`
ifdef CEDA_64_BIT
CFLAGS += +DD64 +M2
CXXFLAGS += +DD64
EXEFLAGS += +DD64
SLFLAGS += +DD64
else
CFLAGS += +DAportable
CXXFLAGS += +DAportable
ifndef debug
SLFLAGS += -s
endif
endif
')

define(`ExecFlags',
`
ifndef debug
EXEFLAGS += -s 
endif
')

####################
# Shared libraries
define(`ShlibPathVar',`SHLIB_PATH')
define(`LinkCxxSl',`aCC')
define(`CcSlFlags',`-b')
define(`CxxSlFlags',`-b -lCsup_v2')

define(`SlPreRule',
`	$(RM) $(1)')
define(`SlPostRule',
`	chatr -s +s enable $(1)')

####################
# Executables
define(`ExeFlags',`-z -q')
define(`ExePostRule',
`	if [ $(XRT_AUTH) ] ; then   eexrt_auth $(OBJPATH)/$(1); fi ; chatr -s +s enable $(OBJPATH)/$(1)
	$(if $(debug), pxdb -s enable $(OBJPATH)/$(1))')

