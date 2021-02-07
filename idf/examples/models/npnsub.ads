define npn ( c b e s )
parameters new=1.0 nel=1.0 ncells=1.0 nestripes=1.0 nbstripes=1.0 ncstripes=1.0 
model NPN BJT NPN=yes PNP=no Is=pis(new,nel,nestripes,ncells) Bf=0 Nf=1.000 Ise=0 Ne=1.60 Vaf=nvaf Ikf=0 Nk=0 Br=1 Nr=1.705 Var=0 Ikr=0 Nc=2 Rbm=0.15 Rb=0 Irb=0 Tf=0 Itf=0 Xtf=0 Vtf=0.8 Ptf=22.0 Cje=0 Mje=0 Vje=0.9907 Fc=0.6 Cjc=0 Mjc=0 Vjc=.6075 Xcjc=0 Tr=4e-9 Eg=1.19 Xtb=0.9 Xti=3.0 Tnom=25
R:rbx b b_in R=1e-5 TC1=0.140e-02
R:rcx c c_in R=1e-5 TC1=0.113e-02
C:ceox b_in e C=1e-5
C:ccox b c_in C=1e-5
BC:dbc b c_in
model BC Diode Is=0 N=1.00 Cjo=0 Vj=0.639 M=0.440 Fc=0.840 Tnom=25
CS:dcs s c_in
model CS Diode Is=1.000e-24 Rs=0 Cjo=0 Vj=0.690 M=0.410 Fc=0.800 Tnom=25
BE:dbe b_in e_in
model BE Diode Is=1.0e-24 N=1.0029 Cjo=0 Vj=0.8671 M=pzep Fc=0.800 Tnom=25
NPN:qin c_in b_in e_in s
end npn
