HPEESOFMB_EXEC=hpeesofmb
ifeq ($(ARCH),win32)
HPEESOFMB_EXEC=$(HPEESOF_DIR)/adsptolemy/bin/hpeesofmb
endif

ifndef APITMPLDIR
  APITMPLDIR=$(PTOLEMYAPI_MK_DIR)/lib/ptolemyapi
endif

RFDE_EXPORT_PRJ_EXPRS=$($(RFDE_EXPORT_PRJ)_EXPRS)
RFDE_EXPORT_PRJ_EXPRS:=$(strip $(RFDE_EXPORT_PRJ_EXPRS))
RFDE_EXPORT_PRJ_EXPR_HDRS=$(addprefix ../wtb/,$(addsuffix .h,$(RFDE_EXPORT_PRJ_EXPRS)))
RFDE_EXPORT_PRJ_EXPR_SRCS=$(addprefix ../wtb/,$(addsuffix .cc,$(RFDE_EXPORT_PRJ_EXPRS)))
RFDE_EXPORT_PRJ_EXPR_XML=$(addprefix ../wtb/,$(addsuffix .xml,$(RFDE_EXPORT_PRJ_EXPRS)))
RFDE_EXPORT_PRJ_EXPR_SINKSRCS=$(addprefix ../wtb/,$(addsuffix Sink.cc,$(RFDE_EXPORT_PRJ_EXPRS)))
RFDE_EXPORT_PRJ_EXPR_AELS=$(foreach expr,$(RFDE_EXPORT_PRJ_EXPRS),$(wildcard ../wtb/$(expr)*_Expr.ael))
RFDE_EXPORT_PRJ_EXPR_ATFS=$(subst .ael,.atf,$(RFDE_EXPORT_PRJ_EXPR_AELS))

ifneq ($(RFDE_EXPORT_PRJ_EXPRS),)

ifdef MASTER_BUILD

../wtb/%.h ../wtb/%.cc ../wtb/%.xml : ../wtb/%_Expr.net
	cd ../wtb; $(HPEESOFSIM_EXEC) $*_Expr.net

../wtb/%Sink.cc : ../wtb/%.xml ../wtb/%.h ../wtb/%.cc
	perl $(APITMPLDIR)/xmlToTmpl $< $(APITMPLDIR)/xml2Sink.tmpl > $@

.PRECIOUS :: $(RFDE_EXPORT_PRJ_EXPR_HDRS) $(RFDE_EXPORT_PRJ_EXPR_SRCS) $(RFDE_EXPORT_PRJ_EXPR_SINKSRCS) $(RFDE_EXPORT_PRJ_EXPR_XML)

all :: $(RFDE_EXPORT_PRJ_EXPR_SINKSRCS) ../../../make-defs

else #MASTER_BUILD

../wtb/%_Expr.atf : ../wtb/%_Expr.ael
	$(AELCOMP_EXEC) $^ $@

all :: $(RFDE_EXPORT_PRJ_EXPR_ATFS) ../make-defs ../../../make-defs
	rm -rf ../lib.$(ARCH)/*.* ../obj.$(ARCH)
	@echo DIRS= > make-defs
	@for i in $(RFDE_EXPORT_PRJ_EXPRS); do\
	  echo DIRS+=$$i >> make-defs;\
	  mkdir -p $$i;\
	  ( cd ../wtb; tar cvf - "$$i".cc "$$i".h "$$i"Sink.cc ) | ( cd $$i; tar xvf - );\
	  echo PTOLEMYAPI=1 > $$i/make-defs;\
	  echo TARGET="$$i".sl >> $$i/make-defs;\
	  echo SRCS="$$i".cc >> $$i/make-defs;\
	  echo SRCS+="$$i"Sink.cc >> $$i/make-defs;\
	done
	cd ..; $(MAKE)
	mkdir -p $(RFDE_EXPORT_LOCAL_ROOT)/lib.$(ARCH)
	cp -f ../lib.$(ARCH)/*.* $(RFDE_EXPORT_LOCAL_ROOT)/lib.$(ARCH)

../make-defs:
	cd ../../;$(HPEESOFMB_EXEC)
endif #MASTER_BUILD

else #RFDE_EXPORT_PRJ_EXPRS

all ::
	@echo No expressions to build for project $(RFDE_EXPORT_PRJ)

endif #RFDE_EXPORT_PRJ_EXPRS

