
###############################################################################

# check whether static exectuable hpeesofsim exists in the 
# <current_prj>/useCompiledModel/bin.$(SIMARCH) directory

ifneq ($(wildcard $(BIN_PATH)/hpeesofsim),)
dummy:=$(error Sorry, hpeesofsim exists in the $(BIN_PATH) directory. Please either rename it or remove it and then try again.)
endif

# check whether TARGET_DYNAMIC_LIB is defined in makefile or not

ifeq ($(TARGET_DYNAMIC_LIB),)
dummy1:=$(error TARGET_DYNAMIC_LIB is not specified in makefile or user.mak, so no shared library will be created. If you only want to create the device database file, "deviceidx.db", for existing shared libraries, please use the command "hpeesofim -X")
endif

# check whether CUI_CPLUS_DYNAMIC is defined in makefile or not

ifeq ($(CUI_CPLUS_DYNAMIC),)
dummy2:=$(error CUI_CPLUS_DYNAMIC is not specified in makefile or user.mak, so no shared library will be created, since the information of devices to be included in the library is missing)
endif

###############################################################################

CXX_SRCS =$(subst \,/,$(CUI_CPLUS_DYNAMIC) $(USER_CPLUS_SRCS) $(CUI_CPLUS_SRCS))

BIN_PATH = $(UCM_PATH)/lib.$(SIMARCH)

###############################################################################

# Windows

ifeq (win,$(findstring win,$(ARCH)))

MODELBUILDER_LIB_PATH=$(HPEESOF_DIR)/lib/$(SIMARCH)

DEBUG_DLL_PCLINK =
define LINK
perl '$(HPEESOF_DIR)/adsptolemy/bin/winDumpExts' $(1).dll $(2) > $(1).def
link /nologo /def:$(1).def $(DEBUG_DLL_PCLINK) /pdb:$(1).pdb /dll /out:$(1).dll $(2) /LIBPATH:"$(MODELBUILDER_LIB_PATH)" $(EXTRA_LIBSPATH) hpeesofsim_private$(SHLIB_VERSION).lib
endef

SLSUFFIX = .dll

endif 

###############################################################################

# Linux

ifeq ($(findstring linux,$(ARCH)),linux)

define LINK
c++ -shared $(ARCH_FLAG) -o $(1)$(SLSUFFIX) $(2) $(EXTRA_LIBSPATH)
endef

SLSUFFIX = .so

endif # linux

###############################################################################

# Solaris

ifeq ($(findstring sun,$(ARCH)),sun)

define LINK
CC -G -library=iostream $(ARCH_FLAG) -o $(1)$(SLSUFFIX) $(2) $(EXTRA_LIBSPATH)
endef

SLSUFFIX = .so

endif

###############################################################################

# TARGET

LIBRARY = $(addprefix $(BIN_PATH)/, $(subst \,/,$(TARGET_DYNAMIC_LIB)))
TARGET=$(LIBRARY)$(SLSUFFIX)

all: compile-pre $(TARGET)    

$(TARGET):	$(OBJS)
	@echo ""
	@echo "Building $(ARCH_MODE) mode shared library $(TARGET)"
	$(call LINK,$(LIBRARY), $(subst \,/,$^))
	cd $(BIN_PATH); hpeesofsim -X
	@echo "Shared library $(LIBRARY)$(SLSUFFIX) has been successfully created."
	@echo
	@echo "===== Compilation finished ====="
