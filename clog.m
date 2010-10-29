%Class for log-File management
classdef clog <handle
   properties
      Parent
      SignalObj %//Besser: obj. Struct!
   end
   methods
      %Constructor:
      function obj = clog(hmain,src1)
         obj.Parent = hmain;
         obj.SignalObj = src1;
         
         cdat.setobj(hmain,obj,'MODAL');
         
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
         
         %Reconvert signalstruct to array:
         for i=1:length(fn)
            NSIG((i-1)*10000+1:i*10000) = obj.SignalObj.Signal.(fn{i});
         end
         
         save(['SIGNAL_',APPDATloc.subject,'.mat'],'NSIG');
         clear NSIG;
         
         fID = fopen('seq.log','A');
         fprintf(fID,'%s\r\n',['--',datestr(clock())]);
         fprintf(fID,'%s\r\n',['Researcher: ',APPDATloc.researcher]);
         fprintf(fID,'%s\r\n',['Subject: ',APPDATloc.subject]);
         
         for i=1:length(fn)
            str = fn{i};
            lvlID = str(4:length(str)-2);
            trigint = num2str(obj.SignalObj.TrigSq(2*i-1)-(i-1)*10000); %//Offset to corresponding level begin
            trigtime = num2str(obj.SignalObj.TrigSq(2*i-1)-3000); %//Offset to sq begin
            fprintf(fID,'%s',[num2str(2*i-1),'; ',lvlID,'; ',str,'; ',trigtime]);fprintf(fID,'%s\r\n',['; ',trigint,'; P1']);
            trigint = num2str(obj.SignalObj.TrigSq(2*i)-(i-1)*10000); %//Offset to corresponding level begin
            trigtime = num2str(obj.SignalObj.TrigSq(2*i)-3000); %//Offset to sq begin
            fprintf(fID,'%s',[num2str(2*i),'; ',lvlID,'; ',str,'; ',trigtime]);fprintf(fID,'%s\r\n',['; ',trigint,'; P2']);
         end
         fclose(fID);
      end
   end
end