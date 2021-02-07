# linux_x86 rules
# $Header: /cvs/wlv/src/cedamk/mk/m4/linux_x86.m4,v 1.28 2009/07/24 19:18:20 build Exp $

####################
# Utilities
define(`Lex',`flex -l')
define(`Yacc',`byacc')
define(`Skillpp',`cpp -traditional -C -P')

####################
# Temprary fix for bison error
define(`Bison',`/usr/bin/bison')

####################
# Suffixes
define(`SlSuffix',`.so')

####################
# Compilation
define(`CcCompiler',`gcc')
define(`CxxCompiler',`g++')

define(`CcFlagsDebug',`-D_DEBUG -DDEBUG')
define(`CxxFlagsDebug',`-D_DEBUG -DDEBUG')

define(`CcFlags',` -fPIC -pipe')
define(`CcFlagsOpt',`-O2 -DNDEBUG -DOPT_BUILD')
define(`CcFlagsOptLesser',`-O1 -DNDEBUG -DOPT_BUILD')

define(`CxxFlags',` -fPIC -pipe ')
define(`CxxFlagsOpt',`-O2 -DNDEBUG')
define(`CxxFlagsOptLesser',`-O1 -DNDEBUG')

define(`CommonSystemLibs',`pthread')

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

####################
# Shared libraries

define(`CcSlFlags',`-shared')
define(`CxxSlFlags',`-shared')

define(`ExePostRule',
`       if [ $(XRT_AUTH) ] ; then   eexrt_auth $(OBJPATH)/$(1); fi')
