F:ChgSlashes APTOUT2 '$(APTOUTNAME)'
X:'$(GAWKPATH)/winawk' -f '$(GAWKPATH)/gav.awk' -v 'APTFN=$(APTOUT2)' '$(IMPORTNAME1)'
