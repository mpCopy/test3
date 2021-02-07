T:TMP1
T:AWKF1
T:AWKF2

F:Open New '$(AWKF1)'
F:Open Existing '$(GAWKPATH)/getgap.awk'
F:Append '$(AWKF1)' BEGIN{\n
F:Append '$(AWKF1)' TMPFILE="$(TMP1)"\n
F:ConCat '$(AWKF1)' '$(GAWKPATH)/getgap.awk' 
F:Close '$(AWKF1)'
F:Close '$(GAWKPATH)/getgap.awk'
X:'$(GAWKPATH)/WINAWK.EXE' -f '$(AWKF1)' '$(IMPORTNAME1)'
WF:$(TMP1)

F:Open New '$(AWKF2)'
F:Open Existing '$(GAWKPATH)/cvtgap.awk'
F:Append '$(AWKF2)' BEGIN{\n
F:Append '$(AWKF2)' DSNFILE="$(IMPORTNAME1)"\n
F:Append '$(AWKF2)' APTFILE="$(APTOUTNAME)"\n
F:ConCat '$(AWKF2)' '$(GAWKPATH)/cvtgap.awk'
F:Close '$(AWKF2)'
F:Close '$(GAWKPATH)/cvtgap.awk'
X:'$(GAWKPATH)/WINAWK.EXE' -f '$(AWKF2)' '$(IMPORTNAME2)'
WF:$(APTOUTNAME)
F:Erase '$(TMP1)'
F:Erase '$(AWKF1)'
WF:$(AWKF2)
F:Erase '$(AWKF2)'
