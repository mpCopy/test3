;* N-Channel Level 3 MOSFET Model 

model nmoslvl3 MOSFET NMOS=yes Idsmod=3 Vto=1 Kp=3.1e-05 Gamma=0.37 Phi=0.65 Lambda=0.02 \
    Rd=1 Rs=1 Cbd=20ff Cbs=20ff Is=1fa Pb=0.87 Cgso=40pF Cgdo=40pf \
    Rsh=10 Cj=0.0002 Mj=0.5 Cjsw=1e-09 Mjsw=0.33 Js=1e-08 \
    Tox=1e-07 Nsub=4e+15 Nss=10000000000 Tpg=1 Xj=1u Ld=.8u Uo=700 \
    Ucrit=10000 Uexp=0.1 Vmax=50000 Neff=5 \
    Kf=1.2 Af=1 Fc=0.5 Delta=1 Theta=0.1 Eta=1 Kappa=0.5 Tnom=27 
 

