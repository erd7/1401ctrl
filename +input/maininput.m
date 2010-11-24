%Implementation of main GUI input class as userinput subclass
%Code reusable due to initialization arguments
classdef maininput < input.userinput
   properties
      Parent
      ListeningTo
      InputState
      IniData
   end
   methods
      %Constructor:
      function obj = maininput(hmain,pedit,plbl,pevt)
         obj.Parent = hmain;
         obj.InputState = pevt(1);
         obj.IniData = struct('pedit',{pedit},'plbl',{plbl},'pevt',{pevt});
         Hloc = getappdata(obj.Parent,'uihandles');
         
         cdat.setobj(hmain,obj,'MODAL');
         
         for i=1:length(pedit{1}(:,1))
           %stredit = ['edit',num2str(i)];
            stredit = cdat.uistr(hmain,obj,'edit');
            strEntry = ['Entry',num2str(i)];
         
            Hloc.(stredit) = uicontrol('Style','edit','String',pedit{2}(i,:),'Position',pedit{1}(i,:),'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt));
            setappdata(obj.Parent,'uihandles',Hloc);
            
            obj.UserInput.(strEntry) = str2double(get(Hloc.(stredit),'String'));
         end
         
         for i=1:length(plbl{1}(:,1))
            %strlbl = ['lbl',num2str(i)];
            strlbl = cdat.uistr(hmain,obj,'lbl');
            
            Hloc.(strlbl) = uicontrol('Style','text','String',plbl{2}{i,:},'Position',plbl{1}(i,:),'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
            setappdata(obj.Parent,'uihandles',Hloc);
         end
         
         %Rearrange graphic components:
         for i=1:length(pedit{1}(:,1))
            stredit = [cdat.classname(obj),'_','edit',num2str(i)];
            strlbl = [cdat.classname(obj),'_','lbl',num2str(i)];
            
            align([Hloc.(strlbl),Hloc.(stredit)],'VerticalAlignment','Middle');
         end
         
         notify(obj,'NewInputAlert');
         
      end
      function UpdateInput(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         m = 0;
         fn = fieldnames(Hloc);
         
         %Get number of input fields:
         for i=1:length(fn)         
            if isempty(strfind(fn{i},cdat.classname(obj))) == 0 && isempty(strfind(fn{i},'edit')) == 0 %//Currently constrained to once and only the very first
               m = m+1;
            end
         end
         
         %Update all input fields:
         for i=1:m
            stredit = [cdat.classname(obj),'_','edit',num2str(i)];
            strEntry = ['Entry',num2str(i)];
            
            obj.UserInput.(strEntry) = str2double(get(Hloc.(stredit),'String'));
         end
         
         notify(obj,'NewInputAlert');
      end
      function deluiobj(obj,del) %//nur auf eigene obj. beziehen, sodass del param redundant ist?
         Hloc = getappdata(obj.Parent,'uihandles');
         
         fn = fieldnames(Hloc);
         
         %Destroy every uicontrol obj that is related to constructing instance specified by del:         
         for i=1:length(fn)
            if isempty(strfind(fn{i},cdat.classname(del))) == 0
               delete(Hloc.(fn{i}));
               Hloc = rmfield(Hloc,fn{i});
            end
         end
         
         setappdata(obj.Parent,'uihandles',Hloc);
      end
      function redraw(obj,del,mod) %auch für Wiederverwendung vom Initialisierungsargument abhängig machen!
         obj.deluiobj(del);
      end
      %Destructor:
      function delete(obj)
         obj.deluiobj(obj);
      end
   end
end