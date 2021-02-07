
ifndef M4
M4 = m4
endif
ifdef debug
M4ARGS = -Dcedamkdebug
endif
ifeq  ($(BUILDTYPE),debug)
M4ARGS = -Dcedamkdebug
endif

archs = linux_x86 win32 hpux11 linux_x86_64  win32_64 sun_sparc sun_sparc_64

targets = $(foreach a,$(archs),rules-$(a).mk defs-$(a).mk)
defaultarch = m4/default.m4
buildrule = $(M4) $(M4ARGS) $+ | sed -e '1,/^\# begin here/d' > $@

all:: $(targets)

compile:: $(targets)

clean:
	$(RM) $(targets) defs-*.mk rules-*.mk

rules-%.mk: $(defaultarch) m4/%.m4 m4/rules.mk
	$(buildrule)

defs-%.mk: $(defaultarch) m4/%.m4 m4/defs.mk
	$(buildrule)

install::
	mkdir -p $(CEDAMK_ROOT)/mk
	cd .. ; find bin  lib -type f | grep -v CVS | cpio -pudm $(CEDAMK_ROOT)
	- chmod 755 $(CEDAMK_ROOT)/*
	- chmod +x $(CEDAMK_ROOT)/bin/*
	cp -f *.mk $(CEDAMK_ROOT)/mk
