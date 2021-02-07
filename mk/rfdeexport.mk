ifeq ($(RFDE_EXPORT),1)

###########################################################################
#
# list of SKILL, CDF, netlist and AEL  files
#
###########################################################################

ifdef LOCAL_BUILD_USR
PTOLEMYAPI_MK_DIR=$(ptolemyapi.mk_dir)
EXPRBLD_PTOLEMYAPI_MK_DIR=../../../$(ptolemyapi.mk_dir)
else
PTOLEMYAPI_MK_DIR=$(HPEESOF_DIR)/adsptolemy
EXPRBLD_PTOLEMYAPI_MK_DIR=$(HPEESOF_DIR)/adsptolemy
endif

SHPATH=LD_LIBRARY_PATH
BOOTSCRIPTSH=. bootscript.sh
ifeq ($(ARCH),win32)
SHPATH=PATH
BOOTSCRIPTSH=$(ECHO) No bootscript.sh
endif
ifeq ($(ARCH),hpux11)
SHPATH=SHLIB_PATH
endif

RFDE_EXPORT_DIR=/adsptolemy/wtb/

RFDE_EXPORT_CDFS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach src,$($(notdir $(addsuffix _SRCS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(src)_Src.cdf,$(prj))))
RFDE_EXPORT_CDFNETS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach src,$($(notdir $(addsuffix _SRCS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(src)_Src.net,$(prj))))
RFDE_EXPORT_SKILLS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach tb,$($(notdir $(addsuffix _TBS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(tb)_TB.il,$(prj))))
RFDE_EXPORT_SKILLNETS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach tb,$($(notdir $(addsuffix _TBS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(tb)_TB.net,$(prj))))
RFDE_EXPORT_TEMPLATES=$(foreach prj,$(RFDE_EXPORT_PRJS),$(wildcard $(prj)/adsptolemy/templates/*.ddt))
RFDE_EXPORT_AELS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach expr,$($(notdir $(addsuffix _EXPRS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(expr)_1d_Expr.ael,$(prj))))
RFDE_EXPORT_AELSKILLS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach expr,$($(notdir $(addsuffix _EXPRS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(expr)_Expr.il,$(prj))))
RFDE_EXPORT_AELNETS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach expr,$($(notdir $(addsuffix _EXPRS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(expr)_Expr.net,$(prj))))
RFDE_EXPORT_AELCCS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach expr,$($(notdir $(addsuffix _EXPRS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(expr).cc,$(prj))))
RFDE_EXPORT_AELSINKCCS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach expr,$($(notdir $(addsuffix _EXPRS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(expr)Sink.cc,$(prj))))
RFDE_EXPORT_AELHDRS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach expr,$($(notdir $(addsuffix _EXPRS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(expr).h,$(prj))))
RFDE_EXPORT_AELXMLS=$(foreach prj,$(RFDE_EXPORT_PRJS),$(foreach expr,$($(notdir $(addsuffix _EXPRS,$(prj)))),$(addsuffix /$(RFDE_EXPORT_DIR)/$(expr).xml,$(prj))))
RFDE_EXPORT_FILES=$(RFDE_EXPORT_CDFS)
RFDE_EXPORT_FILES+=$(RFDE_EXPORT_CDFNETS)
RFDE_EXPORT_FILES+=$(RFDE_EXPORT_SKILLS)
RFDE_EXPORT_FILES+=$(RFDE_EXPORT_SKILLNETS)
RFDE_EXPORT_FILES+=$(RFDE_EXPORT_AELS)
RFDE_EXPORT_FILES+=$(RFDE_EXPORT_AELSKILLS)
RFDE_EXPORT_FILES+=$(RFDE_EXPORT_AELNETS)
RFDE_EXPORT_FILES+=$(RFDE_EXPORT_AELCCS)
RFDE_EXPORT_FILES+=$(RFDE_EXPORT_AELSINKCCS)
RFDE_EXPORT_FILES+=$(RFDE_EXPORT_AELHDRS)
RFDE_EXPORT_FILES+=$(RFDE_EXPORT_AELXMLS)

export RFDE_SYS_LIB=adsLib

env::
	@echo RFDE_EXPORT_PRJS=$(RFDE_EXPORT_PRJS)
	@echo RFDE_EXPORT_CDFS=$(RFDE_EXPORT_CDFS)
	@echo RFDE_EXPORT_CDFNETS=$(RFDE_EXPORT_CDFNETS)
	@echo RFDE_EXPORT_SKILLS=$(RFDE_EXPORT_SKILLS)
	@echo RFDE_EXPORT_SKILLNETS=$(RFDE_EXPORT_SKILLNETS)
	@echo RFDE_EXPORT_AELS=$(RFDE_EXPORT_AELS)
	@echo RFDE_EXPORT_AELSKILLS=$(RFDE_EXPORT_AELSKILLS)
	@echo RFDE_EXPORT_AELNETS=$(RFDE_EXPORT_AELNETS)
	@echo RFDE_SYS_LIB=$(RFDE_SYS_LIB)

define rfde_update_expr_code
  unset INTERNAL_DEV_ROOT;\
  $(BOOTSCRIPTSH);\
  echo PATH=$$PATH;\
  echo $(SHPATH)=$$$(SHPATH);\
  HPEESOFSIM_EXEC=$(HPEESOF_DIR)/bin/hpeesofsim;\
  if [ -f $(LOCAL_ROOT)/bin.$(ARCH)/hpeesofsim ]; then\
    HPEESOFSIM_EXEC=../../../$(LOCAL_ROOT)/bin.$(ARCH)/hpeesofsim;\
  fi;\
  AELCOMP_EXEC=$(HPEESOF_DIR)/bin/aelcomp;\
  if [ -f $(LOCAL_ROOT)/bin.$(ARCH)/aelcomp ]; then\
    AELCOMP_EXEC=../../../$(LOCAL_ROOT)/bin.$(ARCH)/aelcomp;\
  fi;\
  for prj in $(RFDE_EXPORT_PRJS); do\
    echo Building expressions for project $$prj;\
    mkdir -p $$prj/adsptolemy/src;\
    $(MAKE) MASTER_BUILD=$(MASTER_BUILD) HPEESOFSIM_EXEC=$$HPEESOFSIM_EXEC AELCOMP_EXEC=$$AELCOMP_EXEC RFDE_EXPORT_LOCAL_ROOT=../../../$(LOCAL_ROOT) RFDE_EXPORT_PRJ=$$prj ARCH=$(ARCH) PTOLEMYAPI_MK_DIR=$(EXPRBLD_PTOLEMYAPI_MK_DIR) -f $(EXPRBLD_PTOLEMYAPI_MK_DIR)/mk/rfdeexportexprbuild.mk -C $$prj/adsptolemy/src || exit 1;\
  done
endef

ifdef MASTER_BUILD

###########################################################################
#
# Rules to export PDE designs as testbench, expressions or sources
#
###########################################################################

ifneq ($(RFDE_EXPORT_PRJS),)

ifndef hpeesofde_TIMEOUT
  hpeesofde_TIMEOUT=100
endif

EXTRA_PDE_ARGS=-ng

ifdef BUILD_USER
  RFDE_EXPORT_CHECKIN=1
else #BUILD_USER
ifndef PDE_WINDOWS
  EXTRA_PDE_ARGS += -nw
endif
endif #BUILD_USER

PDE_MACRO_FILE=rfdeSysExportMacro.ael
#PDE_EXEC_CMD=ads
emxargs+=-d daemon.log
PDE_EXEC_CMD=". bootscript.sh; hpeesofemx $(emxargs) hpeesofde -env de_sim"

define rfde_sys_export
  (\
    echo "Starting export process ...";\
    . bootscript.sh; \
    hpeesofemx $(emxargs) hpeesofde -env de_sim\
    $(EXTRA_PDE_ARGS) -m $(PDE_MACRO_FILE) ;\
    echo hpeesofde done;\
  )
endef

define wait_for_process
  export PROCESS_TIME_OUT=$($(addsuffix _TIMEOUT, $(1))); \
  until [ $$PROCESS_TIME_OUT -eq 0 ] || grep -i "ERROR" $(1).log || grep "^$(1) done" $(1).log ;\
  do \
    echo Waiting "$$PROCESS_TIME_OUT" minutes for $(1);\
    sleep 60;\
    export PROCESS_TIME_OUT=`expr $$PROCESS_TIME_OUT - 1`;\
    grep "ADS session log file" $(1).log && echo "ERROR: hpeesofde waiting for user input. See the error by setting PDE_WINDOWS=1" >> $(1).log;\
  done;\
  tail -1 $(1).log | grep "$(1) done">/dev/null || \
  ( [ $$PROCESS_TIME_OUT -eq 0 ] && echo "Wait for $(1) timing out. Try increasing $(1)_TIMEOUT";\
    grep -i "ERROR" $(1).log && echo "$(1) in bad state";\
    echo "Killing process $(1) ...";\
    kill -9 `ps -e | egrep $(1) | awk '{print $$1}'` > /dev/null 2>&1;\
    $(RM) -f $(1).log;\
    false;\
  )
endef

RFDE_EXPORT_MSG=$(shell echo Exported on `date`)
CVS_CMD=cvs

.FORCE:

$(PDE_MACRO_FILE):.FORCE
	@$(RM) -f $@
	@touch $@
	@$(foreach prj,$(RFDE_EXPORT_PRJS), \
          echo "exportADSPtolemy_prj(\"$(prj)\"," >> $(PDE_MACRO_FILE); \
          echo "  \"$($(prj)_TBS)\"," >> $(PDE_MACRO_FILE); \
          echo "  \"$($(prj)_SRCS)\"," >> $(PDE_MACRO_FILE); \
          echo "  \"$($(prj)_EXPRS)\"" >> $(PDE_MACRO_FILE); \
          echo ");" >> $(PDE_MACRO_FILE); \
        )
ifndef PDE_WINDOWS
	@echo "de_exit();" >> $(PDE_MACRO_FILE)
endif

rfde_sys_export_backup:
	$(foreach prj,$(RFDE_EXPORT_PRJS),$(shell $(MV) $(prj)/save_project_state.ael $(prj)/save_project_state.ael.tmp > /dev/null 2>&1 || true))
	$(foreach expf,$(RFDE_EXPORT_FILES),$(shell $(MV) $(expf) $(expf).bak > /dev/null 2>&1 || true))

rfde_sys_export:$(PDE_MACRO_FILE) rfde_sys_export_backup
	@$(RM) -f hpeesofde.log
	@touch hpeesofde.log
	@( $(call rfde_sys_export) 2>&1 | tee hpeesofde.log & )

rfde_export_checkin_add:
	for prj in $(RFDE_EXPORT_PRJS); do\
	  $(CVS_CMD) update -A $$prj; \
          $(CVS_CMD) add $$prj/adsptolemy $$prj/adsptolemy/wtb; \
	done
	$(foreach expf,$(RFDE_EXPORT_FILES),$(shell $(CVS_CMD) add $(expf)))

rfde_export_checkin_commit:rfde_export_checkin_add
	$(CVS_CMD) commit -m "$(RFDE_EXPORT_MSG)" $(addsuffix $(RFDE_EXPORT_DIR),$(RFDE_EXPORT_PRJS))

compile::rfde_sys_export
ifndef PDE_WINDOWS
	@$(call wait_for_process,hpeesofde)
ifneq ($(strip $(RFDE_EXPORT_AELNETS)),)
	@$(call rfde_update_expr_code)
endif
	$(foreach prj,$(RFDE_EXPORT_PRJS),$(shell $(MV) $(prj)/save_project_state.ael.tmp $(prj)/save_project_state.ael > /dev/null 2>&1 || true))

ifdef RFDE_EXPORT_CHECKIN
compile::rfde_export_checkin_commit

endif
endif

rfde_create_expr_code:#$(RFDE_EXPORT_AELNETS)
ifneq ($(strip $(RFDE_EXPORT_AELNETS)),)
	$(call rfde_update_expr_code)
endif
endif #RFDE_EXPORT_PRJS

else #MASTER_BUILD

###########################################################################
#
# Rules to copy relevant exported files under LOCAL_ROOT
#
###########################################################################

rfde_sys_mb_dirs:
	if [ -f $(LOCAL_ROOT)/wtb ]; then rm -rf $(LOCAL_ROOT)/wtb; fi
	mkdir -p $(LOCAL_ROOT)/wtb
	if [ -f $(LOCAL_ROOT)/templates ]; then rm -rf $(LOCAL_ROOT)/templates; fi
	mkdir -p $(LOCAL_ROOT)/templates

rfde_sys_export:rfde_sys_mb_dirs
	$(foreach i,$(RFDE_EXPORT_SKILLS),$(shell cp -f $(i) $(LOCAL_ROOT)/wtb/$(notdir $(i))))
	$(foreach i,$(RFDE_EXPORT_AELSKILLS),$(shell cp -f $(i) $(LOCAL_ROOT)/wtb/$(notdir $(i))))
	$(foreach i,$(RFDE_EXPORT_AELS),$(shell cp -f $(i) $(LOCAL_ROOT)/wtb/$(notdir $(i))))
	$(foreach i,$(RFDE_EXPORT_SKILLNETS),$(shell cp -f $(i) $(LOCAL_ROOT)/wtb/$(notdir $(i))))
	$(foreach i,$(RFDE_EXPORT_CDFNETS),$(shell cp -f $(i) $(LOCAL_ROOT)/wtb/$(notdir $(i))))
	$(foreach i,$(RFDE_EXPORT_TEMPLATES),$(shell cp -f $(i) $(LOCAL_ROOT)/templates/$(notdir $(i))))

compile::rfde_sys_export

###########################################################################
#
# Rules to create the expression shared library
#
###########################################################################

rfde_create_expr_shl:#$(RFDE_EXPORT_AELNETS)
ifneq ($(strip $(RFDE_EXPORT_AELNETS)),)
	$(call rfde_update_expr_code)
endif

compile::rfde_create_expr_shl

###########################################################################
#
# Rules to create the source components
#
###########################################################################

ifneq ($(ARCH),win32)
ifneq ($(strip $(RFDE_EXPORT_CDFS)),)

ICMS_REPLAY_FILE=rfdeSysCreateLib.il
ICMS_SETUP_FILE=setup.loc

ICMS_VER=5.1.0

ifeq ($(strip $(RFDE_SKILL_DIR)),)
  RFDE_SKILL_DIR=$(HPEESOF_DIR)/idf/skill/$(ICMS_VER)
endif

ifeq ($(strip $(ADS_SITE)),)
  ADS_SITE=$(HPEESOF_DIR)/idf/ads_site
endif

CDS_LOAD_ENV=CSF

define rfde_sys_create_lib
endef

rfde_sys_create_lib:#$(RFDE_EXPORT_CDFS)
	echo "Building library: $(RFDE_SYS_LIB) for Cadence versions $(ICMS_VER)"
	echo "\\i printf(\"Loading ads.ini\n\")" > $(ICMS_REPLAY_FILE)
	echo "\\i setShellEnvVar(\"CDS_LOAD_ENV=CSF\")" >> $(ICMS_REPLAY_FILE)
	echo "\\i load(\"$(RFDE_SKILL_DIR)/ads.ini\")" >> $(ICMS_REPLAY_FILE)
	for FILE in $(RFDE_EXPORT_CDFS); do\
	  echo "\\i load(\"$(SRCPATH)/$$FILE\")" >> $(ICMS_REPLAY_FILE);\
	done
	echo "\\i exit()" >> $(ICMS_REPLAY_FILE)
	$(RM) -rf 5.1.0 5.1.2 5.2.2 6.1.0 cds.lib
	echo "-- Requisite cds.lib" > cds.lib
	cds-env $(ICMS_VER) icms -replay $(ICMS_REPLAY_FILE) -nograph -log $(RFDE_SYS_LIB).$(ICMS_VER).log
	cat $(RFDE_SYS_LIB).$(ICMS_VER).log
	mkdir -p 5.1.2; cd 5.1.2; cds-env 5.1.2 cdb2oa -lib adsLib -cdslibpath ../cds.lib
	mkdir -p 5.2.2; cd 5.2.2; cds-env 5.2.2 cdb2oa -lib adsLib -cdslibpath ../cds.lib
ifneq ($(ARCH),hpux11)
	mkdir -p 6.1.0; cd 6.1.0; cds-env 6.1.0 cdb2oa -lib adsLib -cdslibpath ../cds.lib
endif #hpux11

compile::rfde_sys_create_lib

endif #RFDE_EXPORT_CDFS
endif #win32

endif #MASTER_BUILD

endif #RFDE_EXPORT==1

