function matlabMeasSetup(StartSample);
global delayDisplay;
% Boundary Check                       
   % check NumberOfBurst        
   if (StartSample < 0)        
      error('Start sample should be >= 0');
   end
delayDisplay = StartSample;
end