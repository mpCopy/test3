
To use the Momentum Module:

1/ Define the following two environment variables:
    For example, when using a c-shell:

      setenv MOM_MODULE_PATH <my_directory>
      setenv MOM_LTD_NAME <my_ltd_file>

    or when using a k-shell:

      export MOM_MODULE_PATH=<my_directory>
      export MOM_LTD_NAME=<my_ltd_file>

    MOM_MODULE_PATH must point to the directory where the Momentum Module is located.
    MOM_LTD_NAME is the name of the default LTD substrate file to use.
       This variable is optional. When the variable is not defined, the first .ltd file found in the module will be used by default.
       See <my_directory>/MomentumSDB/*.ltd to see what substrates are provided. Omit the .ltd extension in MOM_LTD_NAME!
        
     
    
2/ Add following lines in your .cdsinit file.

    printf("START OF Momentum Module CUSTOMIZATION\n")
    (if getShellEnvVar("MOM_MODULE_PATH")!=nil then
      (load (strcat (getShellEnvVar "MOM_MODULE_PATH") "/aa/cdsinit"))
    else
      printf(".cdsinit: Environment variable MOM_MODULE_PATH is not set!\n")
    );if
    printf("END OF Momentum Module CUSTOMIZATION\n")
    
    Loading the "aa/cdsinit" from the Momentum Module will configure Cadence environment variables specific for Momentum and load skill code for the Momentum utilities.
