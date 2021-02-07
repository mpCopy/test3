T:TMP1
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
X:'$(GAWKPATH)/winawk' -f '$(GAWKPATH)/rs274job.awk' -v 'APTFN=$(APTOUT2)' '$(TMP1)'
WF:$(JOBOUT)
F:Erase $(TMP1)