T:AWKF2
F:Open New '$(AWKF2)'
F:Open Existing '$(GAWKPATH)\protel.awk'
F:Append '$(AWKF2)' BEGIN{\n
F:Append '$(AWKF2)' APTFN="$(APTOUTNAME)"\n
F:Append '$(AWKF2)' GBRFN="$(IMPORTNAME1)"\n
F:ConCat '$(AWKF2)' '$(GAWKPATH)\protel.awk'
F:Close '$(AWKF2)'
F:Close '$(GAWKPATH)\protel.awk'
X:'$(GAWKPATH)\WINAWK.EXE' -f '$(AWKF2)' '$(IMPORTNAME2)'
WF:$(AWKF2)
F:Erase '$(AWKF2)'
