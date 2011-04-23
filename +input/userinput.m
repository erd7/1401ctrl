%Interface class for collection and storage of user input data
classdef userinput < hgsetget
   properties
      Parent
      UserInput
      IniData
   end
   events
      NewInputAlert
   end
   methods
      %Constructor:
      function obj = userinput(hmain)
         obj.Parent = hmain;
         
         cdat.setobj(hmain,obj,'MODAL');
      end
      function r= recalluiobj(obj) %//IMPLEMENT IN DELETION ROUTINES!
         %Find every uicontrol obj that is related to constructing instance: 
         H = getappdata(obj.Parent,'uihandles');
         fn = fieldnames(H);
         m = 1;
         
         for i=1:length(fn)
            if isempty(strfind(fn{i},cdat.classname(obj))) == 0
               uiobjs(m) = H.(fn{i});
               m = m+1;
            end
         end
         
         r = uiobjs;
      end
      function deluiobj(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         fn = fieldnames(Hloc);
         
         %Destroy every uicontrol obj that is related to constructing instance specified:   
         %First destroy panel together with all child objects:
         for i=1:length(fn)
            if isempty(strfind(fn{i},[cdat.classname(obj),'_panel'])) == 0 %Just delete parent panel since uiobjs are grouped! //Find fct. for finding all current objects --> case of several maininputs!
               delete(Hloc.(fn{i}));
               Hloc = rmfield(Hloc,fn{i});
            end
         end
         
         %Now remove dead children:
         for i=1:length(fn)
            if isempty(strfind(fn{i},[cdat.classname(obj),'_edit'])) == 0 || isempty(strfind(fn{i},[cdat.classname(obj),'_lbl'])) == 0
               Hloc = rmfield(Hloc,fn{i});
            end
         end
         
         setappdata(obj.Parent,'uihandles',Hloc);
      end
%       function redraw(obj,mod) %auch für Wiederverwendung vom Initialisierungsargument abhängig machen! %//Mache privat und nur für das eigene objekt!
%          obj.deluiobj();
%       end
      %Destructor:
      function delete(obj)
         obj.deluiobj();
      end
   end
   methods (Abstract)
      UpdateInput(obj,src,evt)
   end
end