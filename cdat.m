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
      function r = uistr(hmain,prop)
         Hloc = getappdata(hmain,'uihandles');
         
         m = 0;
         fn = fieldnames(Hloc);
         
         for i=1:length(fn)         
            if isempty(strfind(fn{i},prop)) == 0 && strfind(fn{i},prop) == 1 %//Currently constrained to once and only the very first
               m = m+1;
            end
         end
         r = [prop,int2str(m+1)];
      end
      function r = classname(src)
         r = class(src);
         dotpos = strfind(r,'.');
         
         if dotpos ~= 0
            r = r(dotpos+1:end);
         end
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
               if sum(strfind(fn{i},cname)) ~= 0 && str2num(cname(end)) >= instnum
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
      function delobj(hmain,cat)
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
   end
end