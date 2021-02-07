# linux_x86 rules
# $Header: /cvs/wlv/src/cedamk/mk/m4/linux_x86_64.m4,v 1.14 2009/07/24 19:18:20 build Exp $

####################
# Utilities
define(`Lex',`/usr/bin/flex -l')
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

define(`CcFlags',` -fPIC -pipe -D__USE_XOPEN2K8  ')
define(`CcFlagsOpt',`-O2 -DNDEBUG -DOPT_BUILD')
define(`CcFlagsOptLesser',`-O1 -DNDEBUG -DOPT_BUILD')

define(`CxxFlags',` -fPIC -std=c++11 -pipe -D__USE_XOPEN2K8  ')
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
define(`CppFlags',`-Dlinux -Dlinux64 'defn(`CppFlags'))


define(`ExePostRule',
`       if [ $(XRT_AUTH) ] ; then   eexrt_auth $(OBJPATH)/$(1); fi')
