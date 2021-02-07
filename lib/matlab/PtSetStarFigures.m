function PtSetStarFigures(handle)
%PtSetStarFigures 
%       PtSetStarFigures(handle) will cause all newly generated
%	figures (images, plots, etc.) to be associated with handle.
%	Ptolemy calls this function to attach the name of a Matlab
%	star to all plots generated by that star.
%
%       See also PtCloseStarFigures.

%
%	@(#) $Source: /cvs/wlv/src/hptolemyaddons/src/matrix/lib/matlab/PtSetStarFigures.m,v $ $Revision: 100.2 $ $Date: 1998/01/28 14:19:44 $
%

%       Author: B. L. Evans
%       (c) Copyright 1994-1996 The Regents of the University of California
%	All rights reserved.

set(0, 'DefaultFigureUserData', handle);
