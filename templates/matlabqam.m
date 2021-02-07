function [outR, outI]=matlabqam(x);
global m_M;

% x is an input random digital signal
% outR and outI are output I, Q signals
% Use QAM modulation to generate output data

y = qammod(x,m_M);

outR=real(y);
outI=imag(y);


