1401 access mechanism through MATLAB:
- 1401 can be controlled by sending certain command strings, which 1401 hardware interpretes according to a proprietary syntax
- Additionally, CED provides compiled interface functions/ interaction routines (USE1401.DLL) for high-level language support
- There is a user contributed C-written function library (MATCED32.DLL), employing the CED programming interface, to embed 1401 access into MATLAB
- By calling the "binding function" it is possible to access the CED native language support interface through the user defined functions within MATCED32.DLL
- 1401 string commands and scripts can be tested directly through INTERACT
- For further knowledge study carefully the documentations provided (PROGMANW.pdf, USE1401.pdf); additional support could be obtained at the CED user community