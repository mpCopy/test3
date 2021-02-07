#!/usr/bin/env python
###############################################################################
# THERE IS NO WARRANTY OR SUPPORT ASSOCIATED WITH THIS EXPERIMENTAL PROGRAM!
###############################################################################
#
# File:         spectre_nodes.py
# Description:  Print the list of nodes in the given spectre netlist file.
# Created:      Thu Jan 2 14:14:14 PST 2014
# Modified: 
# Language:     Python
# Package:      N/A
# Status:       Experimental (Do Not Distribute)
#
###############################################################################
#
# Usage: spectre_nodes.py <input.scs> [options]
#     e.g.,   spectre_nodes.py input.scs -d .DL -m 128 -p Vin,Vout,GND
# 
# option:
#   -h, --help            
#       Show the help message and exit.
#
#   -l, --lowest_subckt_level
#        Lowest sub-circuit level to include; default 0, i.e., only top-level circuit.
#
#   -m, --maximum_number_of_characters (256)
#        Node list string longer than this number will not be displayed in STDERR.
#
#   -d, --output_directory (./)
#        Directory to save the output file.
#

import sys
import re
import os
import platform
import shutil
import array
import copy
from tempfile import NamedTemporaryFile
from datetime import datetime
import time
import random

parametersLine=re.compile(r'''^\s*parameters\s+(\w+)\s*=''',re.VERBOSE)
instanceLine=re.compile(r'''^\s*\w+\s+\((?P<nodeList>[^)]*)\)\s+\w+.*''',re.VERBOSE)
unnamedNodes=re.compile(r'''^[_]?net\d+''',re.VERBOSE)

ahdlIncludeLine=re.compile(r'''^\s*ahdl_include\s.*''',re.VERBOSE)
includeLine=re.compile(r'''^\s*include\s.*''')


def is_linux_platform():
    from sys import platform as _platform
    if _platform == "linux" or _platform == "linux2":
        return True
    else:
        # assuming "win32"
        return False  


def file_exists(aFile):
    return os.access(aFile, os.F_OK)


def create_dir_if_it_does_not_exist( dir ):
    """create given directory if it does not exist."""
    if not os.path.exists( dir ):
        os.makedirs( dir )


endWithBackslashe=re.compile(r'''(.*)\\\s*$''',re.VERBOSE)
# HSPICE uses \\ while spectre uses \ for line-continuation?
def joinBackslashedLines( inList ):
    # join lines end with \ with lines following them
    newList=[]
    idx = -1
    continued = False
    for line in inList:
        if endWithBackslashe.search(line, 1):
            if (continued is False):
                tmpline = re.sub( r'''(.*)\\\s*$''', r'''\1''', line)
            else:
                tmpline += re.sub( r'''(.*)\\\s*$''', r'''\1''', line)
            continued = True
        else:
            if (continued is False):
                tmpline = line
            else:
                tmpline += line
            continued = False
        if (continued is False):
            idx += 1
            newList.append(tmpline)
    return newList


beginWithPlus=re.compile(r'''^\+(.*)''',re.VERBOSE)
def joinAddedLines( inList ):
    #### TO DO: VERIFY IT: join lines followed by lines begin with +
    newList=[]
    hasPlus = False
    allAppended = False
    thisLine = ""
    lastLine = ""
    for line in inList:
        thisLine = line
        allAppended = False
#        if beginWithPlus.search(line):
#            tmpline = re.sub( r'''^\+(.*)''', r''' \1''', line)
            # " " is necessary in case + is followed by none-space char and
            # last char of the line above is also non-space.
        if len(line)>0 and line[0] == '+':
            tmpline = line[1:]
            if ( len( tmpline ) > 0 ) and (tmpline[0] != ' ' or tmpline[0] != '\t'):
                tmpline = " " + tmpline
            lastLine += tmpline
            hasPlus = True
        else:
            hasPlus = False
    
        if (hasPlus is False):
            if ( len( lastLine ) > 0 ):
                newList.append(lastLine)
                allAppended = True
            lastLine = line
    
    if ( allAppended is False or lastLine == thisLine ):
        # Changed > 1 to > 0 because last line of DL netlist is often 
        # just one character - the closing parenthesis of the 'mapping' block.
        if ( len( lastLine ) > 0 ):
            newList.append( lastLine )
        elif ( len( thisLine ) > 0 ):
            newList.append( thisLine )

    return newList


multipleBlanks=re.compile(r'''\s\s+''',re.VERBOSE)
def compressMultipleBlanks( inList ):
    # replace consecutive blanks with a single space character
    newList=[]
    idx = -1
    for line in inList:
# This takes a lot of time to run for large files !!!
#        while( multipleBlanks.search(line, 0) ):
#            line = re.sub( r'''^(.*)\s\s+(.*)''', r'''\1 \2''', line, 0)
        line = " ".join(line.split())
        newList.append(line)
    return newList


endWithBackSlash=re.compile(r'''(.*)\\\s*$''',re.VERBOSE)
twoSlashes=re.compile(r'''\/\/''',re.VERBOSE)
beginWithTwoSlashes=re.compile(r'''^\s*\/\/''',re.VERBOSE)
beginWithStar=re.compile(r'''^\s*\*''',re.VERBOSE)
blankLines=re.compile(r'''^\s*$''',re.VERBOSE)
def removeCommentsAndBlankLines( inList ):
    newList=[]
    idx = -1
    lastLineEndsWithBackSlash=False
    for line in inList:
        if ((lastLineEndsWithBackSlash==True) and blankLines.search(line)):
            line=" "    # empty line following \ would cause an error.
        if beginWithTwoSlashes.search(line) or \
            beginWithStar.search(line) or \
            ((lastLineEndsWithBackSlash==False) and blankLines.search(line)):

            continue
        elif line.find('$') >= 0 and not (includeLine.search(line) \
            or ahdlIncludeLine.search(line)):

            # remove everything after $ (any exceptions?)
            last = line.find('$')
            if last == 0:
                continue
            else:
                line = line[:last]
        elif twoSlashes.search(line):
            # remove everything after // in a line 
            line = re.sub('\/\/.*', '', line)
        newList.append(line)

        if endWithBackSlash.search(line):
            lastLineEndsWithBackSlash=True
        else:
            lastLineEndsWithBackSlash=False

    return newList


def writeList( inList, file=None ):
    '''Write a list of strings to the terminal or a file'''
    fp = None
    if file:
        fp = open(file, 'w')

    for line in inList:
        if fp:
            fp.write(line + '\n')
        else:
            print(line)

    if fp:
        fp.close()


# Skip this function to speed up or simply to keep the original format
def formatLines( inList ):
    newList = removeCommentsAndBlankLines( inList )
    newList = joinBackslashedLines( newList )
    newList = joinAddedLines( newList )
    newList = compressMultipleBlanks( newList )
    return newList


subcktLine=re.compile(r'''^\s*subckt\s+(\w+)[\s(]+''',re.VERBOSE)
inlineSubcktLine=re.compile(r'''^\s*inline\s+subckt\s+(\w+)[\s(]+''',re.VERBOSE)
endsLine=re.compile(r'''^\s*ends\s+(\w+)''',re.VERBOSE)
endsOnlyLine=re.compile(r'''^\s*ends\s*$''',re.VERBOSE)
def removeSubckts( inList, level=0 ):
    subcktLevel = 0
    subcktName = ""
    newList = []
    for line in inList:
        if subcktLine.search(line) or inlineSubcktLine.search(line):
            subcktLevel = subcktLevel + 1
        elif endsLine.search(line) or endsOnlyLine.search(line):
            subcktLevel = subcktLevel - 1

        if subcktLevel<=level:
            newList.append( line )
    return newList


def readFileAndSaveAsArrayOfLines( inputFile ):
    spectreFile=[]
    inFileP = open(inputFile, "r")
    for line in inFileP:
        line = line.rstrip()       # this is necessary to remove ^M at EOL 
        line = line.rstrip('\n')   # this is probably useless for removing ^M at EOL
        spectreFile.append( line )

    inFileP.close()

    return spectreFile


import sys
import subprocess
def output_node_list(nodeList, options, inputFile):
    if (nodeList and nodeList!=""):
        pwd = os.getcwd()
        if options.output_dir != "":
            create_dir_if_it_does_not_exist( options.output_dir )
            os.chdir( options.output_dir )
        nodeListString = " ".join( sorted( nodeList.keys()) )
        outfile = os.path.basename(inputFile) + ".nodes"
#        if os.path.isfile( outfile ):
#            os.remove( outfile )
        outf = open(outfile, 'w')
        outf.write( nodeListString )
        outf.close()
    
        if options.run_from_ael == False:
            sys.stdout = sys.stderr
            if len(nodeListString) < options.max_length:
                if is_linux_platform():
                    print nodeListString 
                else:
                    command = "cmd /k type " + outfile
                    subprocess.call( command )
    
        if options.output_dir != "":
            os.chdir( pwd )


def output_parameters(parameters, options, inputFile):
    if (parameters and parameters!=""):
        pwd = os.getcwd()
        if options.output_dir != "":
            create_dir_if_it_does_not_exist( options.output_dir )
            os.chdir( options.output_dir )
        outfile = os.path.basename(inputFile) + ".params"
#        if os.path.isfile( outfile ):
#            os.remove( outfile )
        outf = open(outfile, 'w')
        outf.write( parameters )
        outf.close()
    
        if options.run_from_ael == False:
            sys.stdout = sys.stderr
            # skip empty and long (>max_length characters) parameters
            if len(parameters) > 1 and len(parameters) < options.max_length:
                if is_linux_platform():
                    print parameters 
                else:
                    # This Microsoft command is useless, the window closes too quick.
                    command = "wordpad /e " + outfile
                    command = "cmd /k type " + outfile
                    subprocess.call( command )
    
        if options.output_dir != "":
            os.chdir( pwd )


import optparse
def parseOptions():
    parser = optparse.OptionParser("Usage: %prog <input.scs> [options]")

    parser.add_option("-l", "--lowest_subckt_level", type="int",
        dest="subckt_level", default=0,
        help="Lowest sub-circuit level to include; default 0, i.e., only return named nodes in top-level circuit.")

    parser.add_option("-m", "--maximum_number_of_characters", type="int", 
        dest="max_length", default=256,
        help="Node list string longer than this number (default 256) will not be displayed in STDERR.")

    parser.add_option("-d", "--output_directory", dest="output_dir",
        default="", type="string",
        help="Directory to save the output file.")

    parser.add_option("-a", "--run_from_ael", dest="run_from_ael",
        action="store_true", default=False,
        help="Indicates if this script was started from AEL system() call.")

    (options, args) = parser.parse_args() # There is currently no options.

    if len(args) != 1:
        parser.error("Incorrect usage")
        
    infilename = args[0]
    if (os.path.isfile(infilename)==False):
        parser.error(infilename + " does not exist!")

    return (options, infilename)



#### BEGIN MAIN PROGRAM ##########################################################

if __name__=="__main__":
    (options, inputFile) = parseOptions()
    statements = readFileAndSaveAsArrayOfLines( inputFile )
    statements = formatLines( statements )
    statements = removeSubckts( statements, options.subckt_level )

    parametersFound = False
    parameters = ""
    nodeList = {}
    for line in statements:
        if instanceLine.search(line):
            nodes = re.sub(r'^\s*\w+\s+\((\s*[^)]*)\)\s+\w+.*', r'\1', line.rstrip())
            for node in nodes.split(): 
                if node not in nodeList.keys() and not unnamedNodes.search(node) and node!='0':
                    nodeList[ node ] = True 
        elif parametersFound==False and parametersLine.search(line):
            parameters = line.replace('parameters ','', 1)
            parametersFound = True        # only get the first parameters line

    output_node_list(nodeList, options, inputFile)
    output_parameters(parameters.strip(), options, inputFile)

