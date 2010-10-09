%Class for log-File management
classdef clog <handle
   properties
      Parent
      SignalObj %//Besser: obj. Struct!
   end
   methods
      %Constructor:
      function obj = clog(h,src1)
         obj.Parent = h.main;
         obj.SignalObj = src1;
         
         addlistener(obj.SignalObj,'NewCalcAlert',@(src,evt)UpdateLog(obj,src,evt));
         
         %Check for log-File: //SEE ALSO UIPUTFILE!
         if exist('seq.log','file') ~= 2
            head = [];
            save seq.log head -ascii;
            clear title;
         end
         
         obj.UpdateLog();
      end
      function UpdateLog(obj,src,evt)
         %//Implement time stamp in major data structure!
         APPDATloc = getappdata(obj.Parent,'appdata');
         fn = fieldnames(obj.SignalObj.Signal);
         fID = fopen('seq.log','A');
         fprintf(fID,'%s\r\n',['--',datestr(clock())]);
         fprintf(fID,'%s\r\n',['Researcher: ',APPDATloc.researcher]);
         fprintf(fID,'%s\r\n',['Subject: ',APPDATloc.subject]);
         
         for i=1:length(fn)
            str = fn{i};
            trigint = num2str(obj.SignalObj.TrigSq(2*i-1)-(i-1)*10000); %//Offset to corresponding level begin
            trigtime = num2str(obj.SignalObj.TrigSq(2*i-1)-3000); %//Offset to sq begin
            fprintf(fID,'%s',[num2str(2*i-1),'; ',str,'; ',trigtime]);fprintf(fID,'%s\r\n',['; ',trigint,'; P1']);
            trigint = num2str(obj.SignalObj.TrigSq(2*i)-(i-1)*10000); %//Offset to corresponding level begin
            trigtime = num2str(obj.SignalObj.TrigSq(2*i)-3000); %//Offset to sq begin
            fprintf(fID,'%s',[num2str(2*i),'; ',str,'; ',trigtime]);fprintf(fID,'%s\r\n',['; ',trigint,'; P2']);
         end
         fclose(fID);
      end
   end
end