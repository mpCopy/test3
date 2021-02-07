function matlabqamSetup(ModType);
global m_M;
% Boundary Check                       
   % check NumberOfBurst        
   if ((ModType < 0) || (ModType > 3))        
      error('QAM modulation type should be in the range of [0, 3] for options BPSK, QPSK, 16 QAM, 64 QAM');
   end
if ModType==0 m_M = 2;
elseif ModType==1 m_M = 4;
elseif ModType==2 m_M = 16;
else m_M = 64;
end