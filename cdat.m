%Class collects and manages critical program control data //oder nur statische methoden?
%FIRST CLASS TO IMPLEMENT!
%AUCH 1401 STATUS!
classdef cdat < handle
   properties (SetAccess = private)
      TimeStamp
      Stat1401
   end
   methods
      %Overload standard class constructor:
      function obj = cdat(h)
         cdat.setobj(h,obj,'GENERAL');
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
      function getobj()
      end
      function setobj(h,src,cat)
         APPDATloc = getappdata(h.main,'appdata');
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
         setappdata(h.main,'appdata',APPDATloc);
         clear fn APPDATloc;
      end
      function delobj(h,cat)
         APPDATloc = getappdata(h.main,'appdata');
         if isempty(APPDATloc.CURRENTOBJ.(cat)) == 0
            fn = fieldnames(APPDATloc.CURRENTOBJ.(cat));
            for i=1:length(fn)
               if isobject(APPDATloc.CURRENTOBJ.(cat).(fn{i})) == 1
                  delete(APPDATloc.CURRENTOBJ.(cat).(fn{i}));
                  APPDATloc.CURRENTOBJ.(cat) = rmfield(APPDATloc.CURRENTOBJ.(cat),fn{i});
               end
            end
         end
            setappdata(h.main,'appdata',APPDATloc);
            clear fn APPDATloc;
      end
      function gmf() %//vorher smf; besser: Property!
      end
   end
end