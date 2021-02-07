T:TMP1
T:TMP2
V:OPENCAPTION Open GBR (RS274-X Format) Files
V:OPENEXT gbr
V:OPENFILTER RS274-X Files (*.GBR;*.GBF)\0*.gbr;*.gbf\0All Files (*.*)\0*.*\0
D:GetFiles GBFFILE $(TMP1) 256 $(OPENCAPTION) $(OPENEXT) $(OPENFILTER)
F:CvtExt APTOUT '$(GBFFILE)' .APT
F:CvtExt JOBOUT '$(GBFFILE)' .JOB
F:SetPath APTOUT '$(APTOUT)'
F:SetPath JOBOUT '$(JOBOUT)'
F:ChgSlashes APTOUT2 '$(APTOUT)'

CW:
X:'$(GAWKPATH)/rs274xjb.exe' -job '$(JOBOUT)' -apt '$(APTOUT)' -lst '$(TMP1)'
CR:
F:Erase '$(TMP1)'
