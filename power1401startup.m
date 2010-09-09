function power1401startup()
%power1401 STARTUP ROUTINE

stat = 0;

%--TODO:
%CHECK: Error codes same as ROM built-in codes by CED? --> language support
%Split program to files/modules; main in main function (possible?); implement startup routine as first mandatory method

% cedOpenX sets up the connection to power1401 and returns an error code if it fails
stat=MATCED32('cedOpenX',0);
if (stat < 0)
   disp(['power1401 not opened! ERROR CODE: ' int2str(stat)]);
   return;
end

% reset power1401 to default; delete all loaded commands; error if fail
% CHECK: Isn't it enough just to CLEAR 1401 without deleting loaded commands?
stat=MATCED32('cedResetX');
if (stat < 0)
   disp(['power1401 not reset! ERROR CODE: ' int2str(stat)]);
   return;
end

% needed with latest version of the DLL (MEXW32- file); error if fail
% CLARIFY!
stat=MATCED32('cedWorkingSet',400,4000);
if (stat > 0)
    disp('Error with call to cedWorkingSet- try commenting it out.');
    return
end

end