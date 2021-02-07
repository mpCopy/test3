p controls-displays
d 
f 
r ptk=src/controls-displays/tcltk/ptklib
r sdftclstars=src/controls-displays/tcltk/stars

p timed
d 
f 
r tsdf=src/timed/kernel
r tsdfstars=src/timed/base/stars
r tsdfsinks=src/timed/sinks/stars

p ptamscosim
d 
f 
r expt=src/ptamscosim/api
r exptstars=src/ptamscosim/stars
r vpi=src/ptamscosim/ptvpi

p ptvsainterface
d 
f ptvsainterface.mk
r ptvsainterface=src/ptvsainterface/kernel

p fixpt-analysis
d 
f 
r sdfsynthstars=src/fixpt-analysis/synth/stars
r fixbase=src/fixpt-analysis/base/stars

p timed-gemini
d 
f 
r tsdfgemstars=src/timed-gemini/base/stars

p matrix
d 
f 
r sdfmatrix=src/matrix/base/stars
r ptmatlab=src/matrix/matlab/libptmatlab
r sdfmatlabstars=src/matrix/matlab/stars

p ptsystemc
d 
f ptsystemc.mk
r ptsystemc=src/ptsystemc/kernel
r ptsystemclib=src/ptsystemc/ptsystemclib

p ptolemyapi
d 
f ptolemyapi.mk
r ptolemyapi=src/ptolemyapi/api
r dfapistars=src/ptolemyapi/stars
r apikernel=src/ptolemyapi/kernel

p hof
d 
f hof.mk
r hof=src/hof/kernel
r hofstars=src/hof/base/stars

p instruments
d 
f sdfinstruments.mk
r sdfinstkernel=src/instruments/kernel
r sdfinststars=src/instruments/stars

p numeric
d 
f 
r ptdsp=src/numeric/libptdsp
r sdf=src/numeric/kernel
r LS=src/numeric/loopscheduler
r sdfstars=src/numeric/base/stars
r sdfomnisys=src/numeric/omnisys/kernel
r sdfomnistars=src/numeric/omnisys/stars
r sdfdspstars=src/numeric/dsp/stars
r sdfadvcommstars=src/numeric/advanced/stars

p ptvsakernel
d 
f ptvsakernel.mk
r ptvsakernel=src/ptvsakernel

p hptolemy-kernel
d 
f 
r compat_unix=src/hptolemy-kernel/compat/unix
r compat_cfront=src/hptolemy-kernel/compat/cfront
r compat_ptolemy=src/hptolemy-kernel/compat/ptolemy
r compat_win32=src/hptolemy-kernel/compat/win32
r ptolemy=src/hptolemy-kernel/kernel
r ptpde=src/hptolemy-kernel/ptpde

