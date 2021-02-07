T:AWKF2
F:Open New '$(AWKF2)'
F:Open Existing '$(GAWKPATH)/cvtgap.awk'
F:Append '$(AWKF2)' BEGIN{\n
F:Append '$(AWKF2)' APTFILE="$(APTOUTNAME)"\n
F:ConCat '$(AWKF2)' '$(GAWKPATH)/cvtgap.awk'
F:Close '$(AWKF2)'
F:Close '$(GAWKPATH)/cvtgap.awk'
X:'$(GAWKPATH)/WINAWK.EXE' -f '$(AWKF2)' '$(IMPORTNAME1)'
WF:$(AWKF2)
F:Erase '$(AWKF2)'
