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
         %obj.ListeningTo = src1;
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
      %Following fct. is only called if object is registered for radio event; in this case edit code for individual reuse!
      function RefreshGUI(obj,src,evt,mod) %auch für Wiederverwendung vom Initialisierungsargument abhängig machen!
         if mod == 1
            Hloc = getappdata(obj.Parent,'uihandles');
            if isfield(Hloc,{'edit','lbl'}) == 1
               tmp = [Hloc.edit,Hloc.lbl];
               Hloc = rmfield(Hloc,{'edit','lbl'});
               setappdata(obj.Parent,'uihandles',Hloc);
               delete(tmp); %Handles erst hinterher bearbeiten und updaten?
               
               for i=1:length(obj.IniData.pedit{1}(:,1))
                  stredit = ['edit',num2str(i)];
         
                  Hloc.(stredit) = uicontrol('Style','edit','String',obj.IniData.pedit{2}(i,:),'Position',obj.IniData.pedit{1}(i,:),'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt));
               end
         
               for i=1:length(obj.IniData.plbl{1}(:,1))
                  strlbl = ['lbl',num2str(i)];
            
                  Hloc.(strlbl) = uicontrol('Style','text','String',obj.IniData.plbl{2}{i,:},'Position',obj.IniData.plbl{1}(i,:),'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
               end
         
               setappdata(obj.Parent,'uihandles',Hloc);
               
               %Rearrange graphic components:
                  for i=1:length(obj.IniData.pedit{1}(:,1))
                     stredit = ['edit',num2str(i)];
                     strlbl = ['lbl',num2str(i)];
            
                     align([Hloc.(strlbl),Hloc.(stredit)],'VerticalAlignment','Middle');
                  end
               
               obj.InputState = 1;
               obj.UpdateInput();
               notify(obj,'NewInputAlert');
            end
         elseif mod == 2
            Hloc = getappdata(obj.Parent,'uihandles');
            if isfield(Hloc,{'edit1','edit2','edit3','lbl1','lbl2','lbl3'}) == 1
               tmp = [Hloc.edit1,Hloc.edit2,Hloc.edit3,Hloc.lbl1,Hloc.lbl2,Hloc.lbl3];
               Hloc = rmfield(Hloc,{'edit1','edit2','edit3','lbl1','lbl2','lbl3'});
               setappdata(obj.Parent,'uihandles',Hloc);
               delete(tmp);
               
               Hloc.edit = uicontrol('Style','edit','String','1','Position',[550,240,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt));
               Hloc.lbl = uicontrol('Style','text','String','VOLT (V):','Position',[500,240,50,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
               setappdata(obj.Parent,'uihandles',Hloc);
               
               %Rearrange graphic components:
               align([Hloc.lbl,Hloc.edit],'VerticalAlignment','Middle');
               
               obj.InputState = 2;
               obj.UpdateInput();
               notify(obj,'NewInputAlert');
            end
         end
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
      %Destructor:
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         fn = fieldnames(Hloc);
         
         %Destroy every uicontrol obj that is related to constructing instance:         
         for i=1:length(fn)
            if isempty(strfind(fn{i},cdat.classname(obj))) == 0
               delete(Hloc.(fn{i}));
               Hloc = rmfield(Hloc,fn{i});
            end
         end
         
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end