function PtCloseStarFigures(handle)
%PtCloseStarFigures
%	PtCloseStarFigures(handle) closes all figures (images, plots,
%	etc.) associated with handle.  Ptolemy calls this function to
%	close all figures associated with a particular star.
%
%	See also PtSetStarFigures.

%
%	@(#) $Source: /cvs/wlv/src/hptolemyaddons/src/matrix/lib/matlab/PtCloseStarFigures.m,v $ $Revision: 100.2 $ $Date: 1998/01/28 14:19:56 $
%

%	Author: B. L. Evans
%	(c) Copyright 1994-1996 The Regents of the University of California.
%	All rights reserved.

h = get(0, 'children');
len = length(h);
for i = 1:len
  if strcmp( get(h(i), 'UserData'), handle )
    delete(h(i));
  end
end
