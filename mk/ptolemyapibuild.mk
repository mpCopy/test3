ifdef PTOLEMYAPIBUILD
PTOLEMYAPI = 1
SRCS+=$(addsuffix .cc, $(APINAME))
TARGET=$(APINAME).sl

ifndef APIPRJ
APIPRJ=.
endif

$(APINAME).cc:$(APIPRJ)/data/$(APINAME).cc
	$(CP) -f $(basename $^)* $(SRCPATH)

ifndef APITMPLDIR
  APITMPLDIR=$(ptolemyapi.mk_dir)/lib/ptolemyapi
endif

ifdef IQSRCAPI
SRCS+=$(addsuffix IQSrc.cc, $(APINAME))
$(APINAME)IQSrc.cc:$(APINAME).xml $(APITMPLDIR)/xml2IQSrc.tmpl
	$(PERL) $(APITMPLDIR)/xmlToTmpl $^ > $@
endif

ifdef DSPSINKAPI
SRCS+=$(addsuffix Sink.cc, $(APINAME))
$(APINAME)Sink.cc:$(APINAME).xml $(APITMPLDIR)/xml2Sink.tmpl
	$(PERL) $(APITMPLDIR)/xmlToTmpl $^ > $@
endif
endif
