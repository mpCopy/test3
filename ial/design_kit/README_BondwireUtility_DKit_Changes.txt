The Bondwire Utility Design Kit has been split into a PBOND design kit and a Bondwire Utility Tools AEL add on.
The Bondwire Utility Tools now come as a separate AEL add-on.
Previously, the design kit mechanism was used for distribution of both the PBOND components and the bondwire utility tools.
In ADS 2014.01 and beyond the PBOND_lib is only needed for old designs that still use the PBOND components.
For all new bondwire design in ADS we advice to use the bondwires from the standard ads_bondwires library.
The PBOND_lib components are obsolete and only provided for compatibility reasons with earlier versions.
* Enable this add-on from the Tools > App Manager menu in the ADS Main Window.
* Remove the old BondwireUtility_DKit design kit from the libraries used by the workspace (open Design Kit > Manage Libraries...).
* Enable the split of PBOND_lib Design Kit if you still use PBOND<n> or PBondArray<n> components.
* Restart ADS.