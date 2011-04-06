%Class collects and manages critical program control data //oder nur statische methoden?
%FIRST CLASS TO IMPLEMENT!
%AUCH 1401 STATUS! //FKT ZUR ROUTINEMÄSSIGEN DEF VON DATASTRUCT!
classdef cdat < handle
   properties (SetAccess = private)
      TimeStamp
      Stat1401
   end
   methods
      %Overload standard class constructor:
      function obj = cdat(hmain)         
         cdat.setobj(hmain,obj,'GENERAL');
      end
      function r = get.TimeStamp(obj)
         tmp = clock;
         r = [num2str(tmp(1)),'-',num2str(tmp(2)),'-',num2str(tmp(3)),'_',[num2str(tmp(4)),num2str(tmp(5))]];
      end
      function r = get.Stat1401(obj)
         %r =
      end
   end
   methods (Static)
      function r = classname(src)
         r = class(src);
         dotpos = strfind(r,'.');
         
         if dotpos ~= 0
            r = r(dotpos+1:end);
         end
      end
      function r = uistr(hmain,src,prop)
         Hloc = getappdata(hmain,'uihandles');
         
         m = 0;
         callingobj = cdat.classname(src);
         fn = fieldnames(Hloc);
                  
         for i=1:length(fn)         
            if isempty(strfind(fn{i},callingobj)) == 0 && isempty(strfind(fn{i},prop)) == 0 %//Currently constrained to once and only the very first
               m = m+1;
            end
         end
         r = [callingobj,'_',prop,int2str(m+1)];
      end
      function getobj()
      end
      function setobj(hmain,src,cat)
         APPDATloc = getappdata(hmain,'appdata');
         cname = cdat.classname(src);
         instnum = 1;
         
         if length(fieldnames(APPDATloc.CURRENTOBJ.(cat))) > 0
            fn = fieldnames(APPDATloc.CURRENTOBJ.(cat));
            
            for i=1:length(fn) %//Consider numbers bigger than one digit!
               if sum(strfind(fn{i},cname)) ~= 0 && str2double(cname(end)) >= instnum
                  instnum = instnum+1;
               end
            end
            
         else
            fn = {};
         end
         
         objstr = [cname,'_',num2str(instnum)];
         APPDATloc.CURRENTOBJ.(cat).(objstr) = src;
         setappdata(hmain,'appdata',APPDATloc);
         clear fn APPDATloc;
      end
      function delobj(hmain,cat) %//mache var arg: lösche ganze cat oder einzelnes obj!
         APPDATloc = getappdata(hmain,'appdata');
         
         if isempty(APPDATloc.CURRENTOBJ.(cat)) == 0
            fn = fieldnames(APPDATloc.CURRENTOBJ.(cat));
            
            for i=1:length(fn)
               if isobject(APPDATloc.CURRENTOBJ.(cat).(fn{i})) == 1
                  delete(APPDATloc.CURRENTOBJ.(cat).(fn{i}));
                  APPDATloc.CURRENTOBJ.(cat) = rmfield(APPDATloc.CURRENTOBJ.(cat),fn{i});
               end
            end
         end
            setappdata(hmain,'appdata',APPDATloc);
            clear fn APPDATloc;
      end
      function r = mansmplrt(input) %Sample rate management
         downdiv = [0,0];
         
         if mod(4000000,input) == 0
            downdiv(1) = 1;
            downdiv(2) = 4000000/input;
            r = downdiv;
         else
            r = 0;
         end
      end
      function r = chance(p,acc)
         %A minimum of 100 for acc is recommended.
         %NOTE: To avoid exceeding the MATLAB function limit or program crash due to memory overflow, for very low and high probabilities the cut off is set to 10^6 probability array elements; note floating probability threshold at different accuracies; for example, at a accuracy of 100 minimum probability is 10^-4!
         if p < 0 || p > 1
            errordlg('Probability has to be a real number between 0 and 1.');
            r = -1;
         else
            p = round(acc/p);
            
            if p < 1000000
               stream = randperm(p);
            else
               stream = randperm(1000000);
            end
               
            if ismember(stream(1),[1:acc]) == 1
               r = 1;
            else
               r = 0;
            end
         end
         clear stream;
      end
      function r = onhazard(pf,tick)
         % ONHAZARD performs hazard event occurance online
         % pf should express a function depicting the time course of probabilities, tick is rate in ms
         % Funktionsargument so, dass startw'keit so angepasst wird, dass nach einer bestimmten anzahl von ticks eine bestimmte kumulative w'keit erreicht wird?

         event = 0;
         cumul = 0;
         pfinv = [1,(pf-1)*-1];
         
         for i=1:length(pf)
            %if cdat.chance(pf(i),100) == 0
            if event == 0
               event = cdat.chance(pf(i),100);
               pause(tick/1000);
               cumul = cumul + prod(pfinv(1:i))*pf(i); %General way of simple cumulative bernoulli (verif.); SEE NOTES
               display(['Run ',num2str(i),': p is ',num2str(pf(i)*100),'%; Cumulative chance was: ',num2str(cumul*100),'%']);
            else
               break;
            end
         end
         
         r = event;
      end
      function [r1,r2] = offhazard(pf,tickres)
         % OFFHAZARD precalculates event occurance delay dependent on input time scale (ms); length of pf * tickres determines full cycle time
         % pf should express a function depicting the time course of probabilities, tick is rate in ms
         
%          i=1;
         event = 0;
         delay = 0;
         cumul = 0;
         pfinv = [1,(pf-1)*-1];
         
%          while i <= length(pf) && cdat.chance(pf(i),100) == 0
%             delay = delay + tickres;
%             cumul = cumul + (1-pf(i))^(i-1)*pf(i);
%             %display(['Run ',num2str(i),': p is ',num2str(pf(i)*100),'%; Cumulative chance: ',num2str(cumul*100),'%']);
%             i=i+1;
%          end
         
         for i=1:length(pf)
            if event == 0
               event = cdat.chance(pf(i),100);
               delay = tickres*(i-1);
               %cumul = cumul + (1-pf(i))^(i-1)*pf(i);
               cumul = cumul + prod(pfinv(1:i))*pf(i); %General way of simple cumulative bernoulli (verif.); SEE NOTES
            else
               break;
            end
         end
         
         r1 = delay;
         r2 = cumul;
      end
   end
end