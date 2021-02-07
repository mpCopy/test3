T:AWKF2
F:Open New '$(APTF2)'
F:Open Existing '$(IMPORTNAME1)'
F:ConCat '$(APTF2)' '$(IMPORTNAME1)'
F:Close '$(IMPORTNAME1)'
F:Open Existing '$(IMPORTNAME2)'
F:ConCat '$(APTF2)' '$(IMPORTNAME2)'
F:Close '$(IMPORTNAME2)'
F:Close '$(APTF2)'
F:Open New '$(AWKF2)'
F:Open Existing '$(GAWKPATH)\allapt.awk'
F:Append '$(AWKF2)' BEGIN{\n
F:Append '$(AWKF2)' APTFN="$(APTOUTNAME)"\n
F:ConCat '$(AWKF2)' '$(GAWKPATH)\allapt.awk'
F:Close '$(AWKF2)'
F:Close '$(GAWKPATH)\allapt.awk'
X:'$(GAWKPATH)\WINAWK.EXE' -f '$(AWKF2)' '$(APTF2)'
WF:$(AWKF2)
F:Erase '$(AWKF2)'
F:Erase '$(APTF2)'
