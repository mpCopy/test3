T:TMP1
T:AWKF1
T:AWKF2

F:Open New '$(AWKF1)'
F:Open Existing '$(GAWKPATH)/mntrkey.awk'
F:Append '$(AWKF1)' BEGIN{\n
F:Append '$(AWKF1)' APTOUT="$(APTOUTNAME)"\n
F:ConCat '$(AWKF1)' '$(GAWKPATH)/mntrkey.awk'
F:Close '$(AWKF1)'
F:Close '$(GAWKPATH)/mntrkey.awk'

X:'$(GAWKPATH)/winawk' -f '$(AWKF1)' '$(IMPORTNAME1)'
WF:$(APTOUTNAME)
F:Open New '$(AWKF2)'
F:Open Existing '$(GAWKPATH)/mntrdcod.awk'
F:Append '$(AWKF2)' BEGIN{\n
F:Append '$(AWKF2)' TMPFILE="$(TMP1)"\n
F:ConCat '$(AWKF2)' '$(GAWKPATH)/mntrdcod.awk'
F:Close '$(AWKF2)'
F:Close '$(GAWKPATH)/mntrdcod.awk'

X:'$(GAWKPATH)/winawk' -f '$(AWKF2)' '$(IMPORTNAME1)'
WF:$(TMP1)
F:Open Existing '$(APTOUTNAME)'
F:Open Existing '$(TMP1)'
F:ConCat '$(APTOUTNAME)' '$(TMP1)'
F:Close '$(APTOUTNAME)'
F:Close '$(TMP1)'
WF:$(APTOUTNAME)
F:Erase '$(TMP1)'
F:Erase '$(AWKF1)'
WF:$(AWKF2)
F:Erase '$(AWKF2)'
