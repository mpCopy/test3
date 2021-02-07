/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/kernel/TSDFStar.h,v $ $Revision: 1.11 $ $Date: 2011/08/25 01:47:49 $ */

#ifndef TSDFSTAR_H_INCLUDED
#define TSDFSTAR_H_INCLUDED
// Copyright  1996 - 2017 Keysight Technologies, Inc  

#ifndef _TSDFStar_h
#define _TSDFStar_h 1
#ifdef __GNUG__
#pragma interface
#endif

/*@(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/kernel/TSDFStar.h,v $ $Revision: 1.11 $ $Date: 2011/08/25 01:47:49 $ */
/******************************************************************
Copyright (c) 1996 Hewlett Packard
All rights reserved.

Programmer:  Jose Luis Pino
Date of creation: 10/16/96

TSDFStar is an SDFStar that has a notion of time

*******************************************************************/

#include "SDFStar.h"
#include "TSDFPortHole.h"
#include "TSDFParticle.h"




class TSDFStar : public SDFStar  {
public:
    TSDFStar(){};
      
  
    // my domain
    const char* domain() const;

    // class identification
    int isA(const char*) const;
    
  
    int run();

    virtual void propagateFc(double *);
};

class TSDFStarPortIter : public BlockPortIter {
public:
	TSDFStarPortIter(TSDFStar& s) : BlockPortIter(s) {}
	TSDFPortHole* next() { return (TSDFPortHole*)BlockPortIter::next();}
	TSDFPortHole* operator++(POSTFIX_OP) { return next();}
};

#endif


#endif   /* TSDFSTAR_H_INCLUDED */
