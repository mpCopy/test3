# sun56 rules
# $Header: /cvs/wlv/src/cedamk/mk/m4/sun_sparc.m4,v 1.8 2009/07/25 20:13:47 build Exp $

####################
# Utilities
define(`SetShell',`SHELL = /bin/ksh')
define(`Echo',`echo')
define(`Skillpp',`/hped/local/bin/cpp -traditional -C -P')

####################
# Suffixes
define(`SlSuffix',`.so')

####################
# Compilation

dnl It would be good to take out -D_solaris26
define(`CppFlags',`-DSYSV -DSUN_57 -D_solaris26'defn(`CppFlags'))

define(`CcFlagsDebug',`-D_DEBUG -DDEBUG')
define(`CxxFlagsDebug',`-D_DEBUG -DDEBUG')

define(`CcFlags',`-Aa -KPIC')
define(`CcFlagsOpt',`-xO2 -DNDEBUG -DOPT_BUILD')
define(`CcFlagsOptLesser',`-xO1 -DNDEBUG -DOPT_BUILD')

define(`CxxFlags',`-KPIC  +w2')
define(`CxxFlagsOpt',`-xO2 -DNDEBUG' -DOPT_BUILD)
define(`CxxFlagsOptLesser',`-xO1 -DNDEBUG -DOPT_BUILD')

define(`CxxSlFlags',`-G ')

define(`CcFlagsDebug',`-g -xs') 
define(`CxxFlagsDebug',`-g -xs') 


define(`CommonSystemLibs',`socket nsl sunmath m')


define(`CompilerSetup',
`
ifdef CEDA_64_BIT
CFLAGS += -m64
CXXFLAGS += -m64
EXEFLAGS += -m64
SLFLAGS += -m64
else
CFLAGS += -m32
CXXFLAGS += -m32
EXEFLAGS += -m32
SLFLAGS += -m32
endif
')
 

define(`ExecFlags',
`
ifndef debug
EXEFLAGS += -s
endif
')

ifndef debug
SLFLAGS += -s
endif

define(`ArLinker',`CC -xar')
define(`ArFlags',`-o')


####################
# Shared libraries
define(`ExePostRule',
`       if [ $(XRT_AUTH) ] ; then   eexrt_auth $(OBJPATH)/$(1); fi')
