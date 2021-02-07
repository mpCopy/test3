; Copyright Keysight Technologies 2017 - 2017  
libId = ddGetObj( libName )
techBindTechFile(libId reflibName)
if( ddIsId( libId ) then
	libPath = ddGetObjReadPath( libId )
	printf( "Initializing from libInit.il for library %s...\n" libName )
	enclayersPath = strcat( libPath "/../skill/layers")
	encSkillPath = strcat( libPath "/../skill")
	unless( boundp( 'SPCLOADED)
	
	foreach( file setof(element getDirFiles(enclayersPath) 
                          equal(".il" index(element ".il"))
                    )
      printf( "   --  %s\n" file )
      load( strcat( enclayersPath sprintf(nil "/%s" file)))
    )
	foreach( file setof(element getDirFiles(encSkillPath) 
                          equal(".ile" index(element ".ile"))
                    )
      printf( "   --  %s\n" file )
      load( strcat( encSkillPath sprintf(nil "/%s" file)) "Keysight")
    )
	SPCLOADED = t
	)
)

