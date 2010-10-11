function power1401shutdown()
%power1401 SHUTDOWN ROUTINE

stat=MATCED32('cedCloseX');
if (stat < 0)
   disp(['power1401 not shut down! ERROR CODE: ',int2str(stat)]);
   return;
end

end