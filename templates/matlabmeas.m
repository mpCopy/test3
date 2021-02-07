function [outR, outI]=matlabmeas(x);
global delayDisplay;

% x is an input random digital signal
% outR and outI are output I, Q signals
% scatterplot to display constellation for x
% The constellation start from startSample

z= scatterplot(x,1,delayDisplay);
ss = get(0,'ScreenSize');
fp = get(z,'position');
set(z,'position',[5 ss(4)*.9-fp(4) fp(3:4)]);

outR=real(x);
outI=imag(x);

