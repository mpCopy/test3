F:ChgSlashes APTOUT2 '$(APTOUTNAME)'
X:'$(GAWKPATH)/winawk' -f '$(GAWKPATH)/lavenir.awk' -v 'APTFN=$(APTOUT2)' '$(IMPORTNAME1)'
