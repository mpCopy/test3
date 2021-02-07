# This file is streamed in as a python file, so mistakes
# Copyright Keysight Technologies 2008 - 2011  
# against python syntax will lead to execution errors.
# <- this is the comment symbol, anything on the line after this is ignored 

#------------------------------------------------------------------------------
#the hostname of the server (use '')
#should only be set if the host has multiple dns names
#HostName = 'myhostname'  # use only this host 
#HostName = '0.0.0.0'     # use all 

#------------------------------------------------------------------------------
#port used by server, default is 8000
#Port = 8000

#------------------------------------------------------------------------------
#Dictionary of how to communicate with the different remote servers
#The first value is the remote hostname, the second one has the following
#meaning:
#numbers define the portnumber on which eesofrcmdd will listen
#strings define the remote execution command (e.g. /bin/ssh)
#e.g.
#RemoteAccessDict = {
#   'my_windows' : 8000,
#   'my_linux1' : 'C:/cygwin/bin/ssh'
#}

RemoteAccessDict = {
}
