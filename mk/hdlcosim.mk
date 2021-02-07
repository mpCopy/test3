
# HDL Cosimulation kernel
ifdef SDFHDLCOSIM
        SDFKERNEL = 1
        TSDFKERNEL = 1
        TSDFSTARS = 1
        HDLPARSER = 1
        PTOLEMY_INCLUDEPATH += $(sdfhdlcosim_dir)
        PTLIBS+=libsdfhdlcosim.sl
endif

# HDL Parser
ifdef HDLPARSER
        KERNEL = 1
        PTOLEMY_INCLUDEPATH += $(hdlparser_dir)
        PTLIBS+=libhdlparser.sl
endif

