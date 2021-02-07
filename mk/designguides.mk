# @(#) $Source: /cvs/wlv/src/designguides/dgbase/mk/designguides.mk,v $ $Revision: 1.23 $ $Date: 2008/03/15 00:38:36 $

ifdef DESIGNGUIDE_BUILD

define posthookbitmap
    $(dg_posthookbitmap)
    #
    # Move the bitmap file(s) to PDE's bitmap directory
    # so that PDE can find them.
    #
    mkdir -p root/de/bitmaps
    mv root/designguides/bitmaps/* root/de/bitmaps
    rm -rf root/designguides/bitmaps
endef

define postpackagebuildhook
    mv root/adsptolemy root/designguides
    mkdir -p root/custom/config
    if [ -d ael ]; then \
        mkdir -p root/designguides/ael; \
        cp -f ael/*.atf root/designguides/ael; \
    fi
    if [ -d root/examples ]; then \
        rm -f root/examples/$(PRODNAME)/*/ui/*.ael; \
        mkdir -p root/designguides/projects; \
        mv root/examples/$(PRODNAME)/* root/designguides/projects; \
        rm -rf root/examples; \
    fi
    $(dg_postpackagebuildhook)
    $(posthookbitmap)
endef

endif
