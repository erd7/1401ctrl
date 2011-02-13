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
         
         %MODIFY, SO THAT IT WON'T BE CALLED ON EVERY DATA CHANGE BUT ON EXPLICIT USER DATA LOGIN!
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
         PREFSloc = getappdata(obj.Parent,'preferences');
         fn = obj.SignalObj.Sequence;
         
         %dur = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry1;
         %steps = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry2;
         %subdiv = APPDATloc.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry3;
         %stepdur = dur/subdiv;
         
         %Reconvert signalstruct to array:
         %for i=1:length(fn)
         %   NSIG((i-1)*stepdur*PREFSloc.samplerate+1:i*stepdur*PREFSloc.samplerate) = obj.SignalObj.Signal.(fn{i});
         %end
         
         NSIG = obj.SignalObj.Signal;         
         save(['SIGNAL_',APPDATloc.subject,'.mat'],'NSIG');
         clear NSIG;
         
         fID = fopen('seq.log','A');
         fprintf(fID,'%s\r\n',['--',datestr(clock())]);
         fprintf(fID,'%s\r\n',['Researcher: ',APPDATloc.researcher]);
         fprintf(fID,'%s\r\n',['Subject: ',APPDATloc.subject]);
         fprintf(fID,'%s\r\n',['Sample rate was ',num2str(PREFSloc.samplerate),'Hz']);
         
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