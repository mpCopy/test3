###############################################################################

# check whether HPEESOF_DIR and SIMARCH are set

ifeq ($(SIMARCH),)
dummy_SIMARCH:=$(error SIMARCH is not set. Please set SIMARCH)
endif

ARCH = $(SIMARCH)

ifeq (win32,$(findstring win32,$(ARCH)))
HPEESOF_DIR:=$(subst \,/,$(HPEESOF_DIR))
endif

###############################################################################

C_SRCS =$(subst \,/,$(CURRENT_CIRCUIT) $(CUI_C_SRCS) \
         $(CUI_CIRCUITS) $(USER_C_SRCS))

EXTRA_C_INCLUDES = $(USER_C_INCLS) $(CUI_C_INCLS) -I$(PROJ_DIR)/networks -I$(PROJ_DIR)/userCompiledModel/source
EXTRA_CPLUS_INCLUDES = $(USER_CPLUS_INCLS) $(CUI_CPLUS_INCLS) -I$(PROJ_DIR)/networks -I$(PROJ_DIR)/userCompiledModel/source
EXTRA_LIBSPATH = $(subst \,/,$(CUI_LIBS) $(USER_LIBS))

UCM_PATH = $(PROJ_DIR)/userCompiledModel

OBJNAMES = $(C_SRCS:.c=$(OBJSUFFIX)) $(CXX_SRCS:.cxx=$(OBJSUFFIX)) $(USER_OBJ)
USER_OBJS = $(foreach obj, $(OBJNAMES), $(addsuffix $(notdir $(obj)), $(dir $(obj))obj.$(SIMARCH)/ ))

OBJS = $(USER_OBJS)

DEPENDENCY_MK=dynamic-dependencies_$(SIMARCH).mk

ifeq ($(findstring _64,$(SIMARCH)),_64)
ARCH_MODE=64-bit
else
ARCH_MODE=32-bit
endif

###############################################################################
.SUFFIXES: .cxx .c

OBJ_FILE_FLAG = -o 
COMPILE_ONLY_FLAG = -c

define COMPILE.c
$(CC) $(CFLAGS) $(CPPFLAGS) $(COMPILE_ONLY_FLAG) $(1) $(2) $(3)
endef

define COMPILE.cxx
$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(COMPILE_ONLY_FLAG) $(1) $(2) $(3)
endef

###############################################################################

# Windows

ifeq (win,$(findstring win,$(ARCH)))

    ifeq ($(SHLIB_VERSION),)
        ifdef DEBUG_INTERNAL_BUILD
            SHLIB_VERSION = 51d
        else
            SHLIB_VERSION = 51
        endif
    endif

.SUFFIXES: .obj

OBJ_FILE_FLAG = /Fo
COMPILE_ONLY_FLAG = /c

ifdef DEBUG_INTERNAL_BUILD
DEBUG_OPT_DEBUG = /MDd /Zi /Yd
DEBUG_OPT_OPT = /MDd /O2 /Op /Oy- /D NDEBUG
else
DEBUG_OPT_DEBUG = /MD /Zi /Yd
DEBUG_OPT_OPT = /MD /O2 /Op /Oy- /D NDEBUG
endif

ifdef debug
DEBUG_OPT = $(DEBUG_OPT_DEBUG)
LINKDEBUGOPTION = /DEBUG
else
DEBUG_OPT = $(DEBUG_OPT_OPT)
LINKDEBUGOPTION = 
endif

CC = cl /W4 /nologo /TC
CXX = cl /W4 /nologo /TP /EHs

CPPFLAGS = /Dfar=far_p /Dnear=near_p /DNO_MALLOC_MACRO /DWIN32 /U_WINDOWS /D_CONSOLE /D_MBCS /DWIN32_LEAN_AND_MEAN /D_AFXDLL /DWINVER=0x0500

CFLAGS = $(DEBUG_OPT) $(EXTRA_C_INCLUDES) -I"$(HPEESOF_DIR)/modelbuilder/include"
CXXFLAGS = $(DEBUG_OPT) $(EXTRA_C_INCLUDES) $(EXTRA_CPLUS_INCLUDES) -I"$(HPEESOF_DIR)/modelbuilder/include"

ifeq ($(findstring _64,$(SIMARCH)),_64)
ARCH_FLAG = /D_CRT_SECURE_NO_DEPRECATE /favor:blend /D_WIN64 /D_MACHINE:x64 /Wp64
CFLAGS += $(ARCH_FLAG)
CXXFLAGS += $(ARCH_FLAG)
endif

OBJSUFFIX = .obj

endif  # end Windows


###############################################################################

# Linux

ifeq ($(findstring linux,$(ARCH)),linux)

.SUFFIXES: .o

ifdef debug
DEBUG_OPT = -g
else
DEBUG_OPT = -O2
endif

CC = cc -fPIC -pipe -pedantic -D__USE_XOPEN2K8
CXX = c++ -fPIC -pipe -pedantic -D__USE_XOPEN2K8

CFLAGS = $(DEBUG_OPT) $(EXTRA_C_INCLUDES) -I"$(HPEESOF_DIR)/modelbuilder/include"
CXXFLAGS = $(DEBUG_OPT) $(EXTRA_CPLUS_INCLUDES) -I"$(HPEESOF_DIR)/modelbuilder/include"

ifeq ($(findstring _64,$(SIMARCH)),_64)
ARCH_FLAG = -m64
else
ARCH_FLAG = -m32
endif

CFLAGS += $(ARCH_FLAG)
CXXFLAGS += $(ARCH_FLAG)

OBJSUFFIX = .o

endif # end linux

###############################################################################

# Solaris

ifeq ($(findstring sun,$(ARCH)),sun)

.SUFFIXES: .o

ifdef debug
DEBUG_OPT = -g
else
DEBUG_OPT = -O
endif

CC = cc -Aa -KPIC
CXX = CC -KPIC -library=iostream

CFLAGS = $(DEBUG_OPT) -I$(EXTRA_C_INCLUDES) -I"$(HPEESOF_DIR)/modelbuilder/include"
CXXFLAGS = $(DEBUG_OPT) $(EXTRA_CPLUS_INCLUDES) -I"$(HPEESOF_DIR)/modelbuilder/include"

ifeq ($(findstring _64,$(SIMARCH)),_64)
ARCH_FLAG = -xarch=v9
endif

CFLAGS += $(ARCH_FLAG)
CXXFLAGS += $(ARCH_FLAG)

OBJSUFFIX = .o

endif # end Solaris

###############################################################################

# include dynamic.mk, $(TARGET) is defined in it respectively 

ifdef LOCAL_MAKE_DEBUG
MAKE_DIR=.
else
MAKE_DIR=$(HPEESOF_DIR)/modelbuilder/lib
endif

MAKE_DEFS=dynamic.mk
DEPENDENCY_MK=dynamic-dependencies_$(SIMARCH).mk

MAKE_RULES=$(MAKE_DIR)/make-rules.mk

# Fixup MAKE_DIR, just in case it contains spaces
MAKE_DIR:=$(shell perl -e '$$x = @ARGV[0]; $$x =~ s| |\\ |g; print $$x;' '$(MAKE_DIR)')

include $(MAKE_DIR)/$(MAKE_DEFS)

###############################################################################

# Rules. Note that all: is the first rule. 
# all: and $(TARGET): are defined in dynamic.mk 

echoenv:
	@echo TARGET=$(TARGET)
	@echo OBJS=$(OBJS)


compile-pre :: $(UCM_PATH) $(BIN_PATH) 

$(UCM_PATH):
	$(shell mkdir $@)
$(BIN_PATH):
	$(shell mkdir $@)

clean:
	rm -f $(USER_OBJS) $(TARGET) $(DEPENDENCY_MK) core *~ \#* vc60.pdb


$(DEPENDENCY_MK): makefile
	-rm -f $(DEPENDENCY_MK)
# create dependencies rules
ifneq ($(strip $(C_SRCS)), ) 
	for f in $(C_SRCS) ; do echo `dirname $$f`/obj.$(SIMARCH)/`basename $$f .c`$(OBJSUFFIX):: $$f `dirname $$f`/obj.$(SIMARCH) ; echo '	$$(call COMPILE.c, $(OBJ_FILE_FLAG)$$@ $$<)'; echo `dirname $$f`/obj.$(SIMARCH): ; echo "	-@mkdir `dirname $$f`/obj.$(SIMARCH)"; echo " " ; done >> $(DEPENDENCY_MK)
endif
ifneq ($(strip $(CXX_SRCS)), )
	for f in $(CXX_SRCS) ; do echo `dirname $$f`/obj.$(SIMARCH)/`basename $$f .cxx`$(OBJSUFFIX):: $$f `dirname $$f`/obj.$(SIMARCH) ; echo '	$$(call COMPILE.cxx, $(OBJ_FILE_FLAG)$$@ $$<)'; echo `dirname $$f`/obj.$(SIMARCH): ; echo "	-@mkdir `dirname $$f`/obj.$(SIMARCH)"; echo " " ; done >>  $(DEPENDENCY_MK)
endif

include $(DEPENDENCY_MK)


# The following lovely spoo exists because of a bug in hpeesofmake.bat ...
ifeq (win,$(findstring win,$(ARCH)))

debug:	DEBUG_OPT=$(DEBUG_OPT_DEBUG)
debug:	DEBUG_DLL_PCLINK=/debug
debug:	compile-pre $(TARGET)

1:
	@echo '(Debug version created.)'

endif

####################   End   ##################################################

