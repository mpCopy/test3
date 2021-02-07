# sun56 rules
# $Header: /cvs/wlv/src/cedamk/mk/m4/sun57.m4,v 1.11 2006/06/28 22:26:45 brianand Exp $

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

define(`CcFlags',`-Aa -KPIC')
define(`CcFlagsOpt',`-xO2')
define(`CcFlagsOptLesser',`-xO1')

define(`CxxFlags',`-KPIC -library=iostream +w2')
define(`CxxFlagsOpt',`-xO2')
define(`CxxFlagsOptLesser',`-xO1')


define(`CxxLinkFlgs',`-library=iostream')

define(`CxxSlFlags',`-G -library=iostream')

define(`CommonSystemLibs',`socket nsl sunmath m')

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
