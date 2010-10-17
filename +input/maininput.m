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
      function obj = maininput(h,src1,pedit,plbl,pevt)
         obj.Parent = h.main;
         obj.ListeningTo = src1;
         obj.InputState = pevt(1);
         obj.IniData = struct('pedit',{pedit},'plbl',{plbl},'pevt',{pevt});
         Hloc = getappdata(obj.Parent,'uihandles');
         
         cdat.setobj(h,obj,'MODAL');
         
         for i=1:length(pedit{1}(:,1))
            stredit = ['edit',num2str(i)];
            strEntry = ['Entry',num2str(i)];
         
            Hloc.(stredit) = uicontrol('Style','edit','String',pedit{2}(i,:),'Position',pedit{1}(i,:),'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt));
            
            obj.UserInput.(strEntry) = str2double(get(Hloc.(stredit),'String'));
         end
         
         for i=1:length(plbl{1}(:,1))
            strlbl = ['lbl',num2str(i)];
            
            Hloc.(strlbl) = uicontrol('Style','text','String',plbl{2}{i,:},'Position',plbl{1}(i,:),'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         end
         
         setappdata(obj.Parent,'uihandles',Hloc);
         
         %Rearrange graphic components:
         for i=1:length(pedit{1}(:,1))
            stredit = ['edit',num2str(i)];
            strlbl = ['lbl',num2str(i)];
            
            align([Hloc.(strlbl),Hloc.(stredit)],'VerticalAlignment','Middle');
         end
         
         notify(obj,'NewInputAlert');
         
         if pevt(2) == 1;
            addlistener(obj.ListeningTo,'SelRadio1',@(src,evt)RefreshGUI(obj,src,evt,1));
            addlistener(obj.ListeningTo,'SelRadio2',@(src,evt)RefreshGUI(obj,src,evt,2));
         end
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
         
         for i=1:length(obj.IniData.pedit{1}(:,1))
            fieldlist{i} = ['edit',num2str(i)];
         end
         
         if isfield(Hloc,fieldlist) == 1
            for i=1:length(obj.IniData.pedit{1}(:,1))
               stredit = ['edit',num2str(i)];
               strEntry = ['Entry',num2str(i)];            
               
               obj.UserInput.(strEntry) = str2double(get(Hloc.(stredit),'String'));
            end
         elseif isfield(Hloc,{'edit','lbl'}) == 1 %Matters only if object is registered for radio event; reconsider for reuse!
            obj.UserInput.Entry1 = str2double(get(Hloc.edit,'String'));
         end
         
         notify(obj,'NewInputAlert');
      end
      %Destructor:
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         for i=1:length(obj.IniData.pedit{1}(:,1))
            fieldlist{i} = ['edit',num2str(i)];
         end
         
         if isfield(Hloc,fieldlist) == 1
            for i=1:length(obj.IniData.pedit{1}(:,1))
               stredit = ['edit',num2str(i)];
               strlbl = ['lbl',num2str(i)];            
               
               delete(Hloc.(stredit));
               delete(Hloc.(strlbl));
               Hloc = rmfield(Hloc,stredit);
               Hloc = rmfield(Hloc,strlbl);
            end
         elseif isfield(Hloc,{'edit','lbl'}) == 1 %Matters only if object is registered for radio event; reconsider for reuse!
            delete([Hloc.edit,Hloc.lbl]);
            Hloc = rmfield(Hloc,{'edit','lbl'});
         end

         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end