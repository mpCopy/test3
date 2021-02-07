# Copyright Keysight Technologies 2013 - 2017  
#
# $Id $ 
#
# This script performs the necessary modifications to a set of pre ADS 2011.01 
# Momentum components in an old ADS project's networks directory to allow 
# the automatic conversion to an ADS 2012.08+ workspace while maintaining 
# the file based simulation options on these converted Momentum components.
#

import os
import os.path
import sys
import fnmatch
import string

from optparse import OptionParser

def createFileNames(pathName,fName):
    sfName=os.path.join( pathName, fName )
    bfName=None
    if not os.path.isfile( sfName ):
        return (None, None)
    for extN in range(1,20):
        bfName = sfName + str(extN)
        if not os.path.exists( bfName ):
            break
    else:
        #skip
        return (None, None)
    return (sfName, bfName)

def fromOldToNew (pathName, finalList):
    processed=[]
    for fName in finalList:
        (sfName, bfName) = createFileNames(pathName, fName)
        if sfName==None or bfName==None:
            continue

        lines=[]
        try:
            rFile = open( sfName, "r")
            lines = rFile.readlines()
            rFile.close()
        except:
            raise

        res=string.join(lines)
        try:
            res.index('momCmpt_netlist_cb')
        except:
            continue
        
        try:
            os.rename(sfName, bfName)
        except:
            raise

        try:
            oFile = open( sfName, "w")
            oFile.write('// Prepared for use with momDataCmpt netlisting in ADS 2012.08\n')
            for line in lines:
                line=line.replace('MomCmpt','MomDataCmpt')
                line=line.replace('\"Momentum Component\"','standard_dialog')
                line=line.replace('momCmpt_netlist_cb','momDataCmpt_netlist_cb')
                oFile.write(line)
            oFile.close()
        except:
            raise
        processed.append(fName)
    return processed


def fromNewToOld (pathName, finalList):
    processed=[]
    for fName in finalList:
        (sfName, bfName) = createFileNames(pathName, fName)
        if sfName==None or bfName==None:
            continue

        lines=[]
        try:
            rFile = open( sfName, "r")
            lines = rFile.readlines()
            rFile.close()
        except:
            raise

        res=string.join(lines)
        try:
            res.index('momDataCmpt_netlist_cb')
        except:
            continue
        
        try:
            os.rename(sfName, bfName)
        except:
            raise

        try:
            oFile = open( sfName, "w")
            for line in lines:
                if line == '// Prepared for use with momDataCmpt netlisting in ADS 2012.08\n':
                    continue
                line=line.replace('MomDataCmpt','MomCmpt')
                line=line.replace('standard_dialog','\"Momentum Component\"')
                line=line.replace('momDataCmpt_netlist_cb','momCmpt_netlist_cb')
                oFile.write(line)
            oFile.close()
        except:
            raise
        processed.append(fName)
    return processed



def main():
    usage = "usage: python %prog [options] path"
    parser = OptionParser(usage)
    parser.add_option("-i", "--include", dest="iPattern", action="append",
                      help="pattern for files to include (can be repeated)", metavar="PATTERN")
    parser.add_option("-e", "--exclude", dest="ePattern", action="append",
                      help="pattern for files to exclude (can be repeated)", metavar="PATTERN")
    parser.add_option("-r", "--revert", dest="revert", action="store_true",
                      help="revert to original state")

    (options, args) = parser.parse_args()
    if len(args) < 1:
        parser.error("Incorrect number of arguments")

    pathName = '.'
    if len(args) == 1:
        pathName = args[0]
        
    dirList = os.listdir(pathName)
    matchedAelFiles = fnmatch.filter(dirList, "*.ael")

    included = set()
    if options.iPattern == None:
        included = included.union( matchedAelFiles )
    else:
        for iP in options.iPattern:
            included=included.union( fnmatch.filter( matchedAelFiles, iP ) )
    
    excluded = set()
    try: 
        for eP in options.ePattern:
            excluded=excluded.union( fnmatch.filter( matchedAelFiles, eP ) )
    except:
        pass

    if len(included) == 0:
        print 'No ael files found'
        sys.exit(0)

    finalList = included
    if len(excluded) > 0:
        finalList = included.difference( excluded )
    
    if len(finalList) == 0:
        sys.exit(0)

    processed=None
    try:
        if options.revert==None or options.revert==False:
            processed=fromOldToNew(pathName, finalList)
        else:
            processed=fromNewToOld(pathName, finalList)
    except Exception, err:
        errorString = "Cannot process files.\n%s" % str(err)
        print errorString
        exit(1)
    if processed!=None:
        print str(processed)
    exit(0)


if __name__ == "__main__":
    main()

