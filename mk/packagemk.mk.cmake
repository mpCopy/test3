 ifndef ptvsainterface.mk_dir
 ptvsainterface.mk_dir=$(HPTOLEMY_DEV_ROOT)
 include $(ptvsainterface.mk_dir)/mk/ptvsainterface.mk
 endif

 ifndef ptsystemc.mk_dir
 ptsystemc.mk_dir=$(HPTOLEMY_DEV_ROOT)
 include $(ptsystemc.mk_dir)/mk/ptsystemc.mk
 endif

 ifndef ptolemyapi.mk_dir
 ptolemyapi.mk_dir=$(HPTOLEMY_DEV_ROOT)
 include $(ptolemyapi.mk_dir)/mk/ptolemyapi.mk
 endif

 ifndef hof.mk_dir
 hof.mk_dir=$(HPTOLEMY_DEV_ROOT)
 include $(hof.mk_dir)/mk/hof.mk
 endif

 ifndef instruments.mk_dir
 instruments.mk_dir=$(HPTOLEMY_DEV_ROOT)
 include $(instruments.mk_dir)/mk/sdfinstruments.mk
 endif

 ifndef ptvsakernel.mk_dir
 ptvsakernel.mk_dir=$(HPTOLEMY_DEV_ROOT)
 include $(ptvsakernel.mk_dir)/mk/ptvsakernel.mk
 endif

