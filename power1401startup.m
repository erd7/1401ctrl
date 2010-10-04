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

%reset power1401 to default; error if fail;
%From USE1401 doc: "This function performs a hardware reset of the 1401. This will stop any running commands and flush any input or output from the I/O buffers. Any DMA in progress is stopped. All loaded commands remain intact within the 1401. You can use this to get the 1401 out of a "hung" situation (for example when a dedicated 1401 command is waiting for a trigger which never comes), or for general-purpose initialisation."
stat=MATCED32('cedResetX');
if (stat < 0)
   disp(['power1401 not reset! ERROR CODE: ' int2str(stat)]);
   return;
end

%Set memory working set; see USE1401 documentation. //TRY TO INCREASE!
%stat=MATCED32('cedWorkingSet',400,4000);
stat=MATCED32('cedWorkingSet',400,1000000);
if (stat > 0)
    disp('Error with call to cedWorkingSet- try commenting it out.');
    return
end

end