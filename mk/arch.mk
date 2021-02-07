# arch.mk - set ARCH variable
# $Header: /cvs/wlv/src/cedamk/mk/arch.mk,v 1.16 2008/03/14 23:43:55 dbjornba Exp $


ifndef ARCH
# Evaluate this ONCE ONLY!
export ARCH_32BIT:=$(shell hpeesofarch -b)
export ARCH_64BIT:=$(shell hpeesofarch -B)
export ARCH:=$(shell hpeesofarch)
ifeq ($(strip $(ARCH)),)
export ARCH_32BIT:=$(shell hped-arch -b)
export ARCH_64BIT:=$(shell hped-arch -B)
export ARCH:=$(shell hped-arch)
endif
ifeq ($(strip $(ARCH)),)
export ARCH_32BIT:=$(shell bash hped-arch -b)
export ARCH_64BIT:=$(shell bash hped-arch -B)
export ARCH:=$(shell bash hped-arch)
endif
endif

ifndef ARCH_32
# Evaluate this ONCE ONLY!
export ARCH_32BIT:=$(shell hpeesofarch -b)
ifeq ($(strip $(ARCH)),)
export ARCH_32BIT:=$(shell hped-arch -b)
endif
ifeq ($(strip $(ARCH)),)
export ARCH_32BIT:=$(shell bash hped-arch -b)
endif
endif

ifndef ARCH_64
# Evaluate this ONCE ONLY!
export ARCH_64BIT:=$(shell hpeesofarch -B)
ifeq ($(strip $(ARCH)),)
export ARCH_64BIT:=$(shell hped-arch -B)
endif
ifeq ($(strip $(ARCH)),)
export ARCH_64BIT:=$(shell bash hped-arch -B)
endif
endif



ifeq (($strip $(ARCH)),)
dummy := $(error Sorry, unable to determine ARCH!)
endif

ifeq (win,$(findstring win,$(ARCH)))
HPEESOF_DIR:=$(subst \,/,$(HPEESOF_DIR))
endif
