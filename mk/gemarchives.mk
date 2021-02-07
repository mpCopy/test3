# gemarchives.mk

GEM_OBJS = circuits/hpeesofsim$(OBJSUFFIX) circuits/main$(OBJSUFFIX)

GEM_ARCHIVES = $(addprefix gem_, \
  simael admin preprocessor parser devices senior analyses optimizer builtins \
  newoutput output utilities Coplanar Interconnect Microstrip Stripline \
  SuspendedSub T_Lines EMS2 MultiLayer tqmodel rfmodel PMLG PMLE  \
  lumped lineardevs pcboard libra_stripline rf suspsub waveguide \
  libra_microstrip finline transline libra_utils sml_linear transer tran \
  linpackd linpackz sparse fourier sym seclib interface utils user admin \
  parser utilities transer MomCmpt MomCmptDLL )

OLD = MOMG MOME

GEM_LIBS = genfun genserver optpak clapack blas f77 gcls dataset \
  datasetint gendata dio
