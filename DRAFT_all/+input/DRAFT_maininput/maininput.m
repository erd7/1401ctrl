%Implementation of main GUI input class as userinput subclass
%Code reusable due to initialization arguments
classdef maininput < input.userinput
   properties
      Parent
      Properties = {...
         'IniInputEdit',...
         'IniInputLbl',...
         'AddListener',...
         'EventData'};
      InputState
      IniData
   end
   methods
      %Constructor:
      function obj = maininput(h,varargin) %//Error abfangen, wenn varargin ungerade!
         obj.Parent = h.main;
         
         Hloc = getappdata(obj.Parent,'uihandles');
         
         cdat.setobj(h,obj,'MODAL');
         
         if mod(length(varargin),2) == 0
            arglist = {}; %//Or preallocate and employ additional increment var
            
            for i=1:length(obj.Properties)
               for j=1:length(varargin)
                  if strcmp(obj.Properties{i},varargin{j}) == 1
                     arglist{length(arglist)+1} = obj.Properties{i};
                  end
               end
            end
         
         for i=1:length(arglist)
               switch arglist{i}
                  case 'IniInputEdit'
                     obj.IniData.inputedit = varargin{i+1};
                     Hloc = getappdata(obj.Parent,'uihandles');
                  
                     for j=1:length(obj.IniData.inputedit{1}(:,1))
                        stredit = ['edit',num2str(i)];
                        strEntry = ['Entry',num2str(i)];
         
                        Hloc.(stredit) = uicontrol('Style','edit','String',obj.IniData.inputedit{2}(i,:),'Position',obj.IniData.inputedit{1}(i,:),'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt));
            
                        obj.UserInput.(strEntry) = str2double(get(Hloc.(stredit),'String'));
                        setappdata(obj.Parent,'uihandles',Hloc);
                    end
                  case 'IniInputLbl'
                     obj.IniData.inputlbl = varargin{i+1};
                     Hloc = getappdata(obj.Parent,'uihandles');
                  
                     for i=1:length(obj.IniData.inputlbl{1}(:,1))
                        strlbl = ['lbl',num2str(i)];
            
                        Hloc.(strlbl) = uicontrol('Style','text','String',obj.IniData.inputlbl{2}{i,:},'Position',obj.IniData.inputlbl{1}(i,:),'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
                        setappdata(obj.Parent,'uihandles',Hloc);
                     end
                  case 'AddListener' %//Improve reuse! --> RADIO VOLLST AUSLAGERN (in eigene Klasse/ Kein evt!)?
                     for j=1:length(varargin{i+1})/2
                        fieldstr = ['listeningto',num2str(j)];
                        evtstr = ['evt',num2str(j)];
                        obj.IniData.(fieldstr) = varargin{i+1}(j); %Store handle of obj. listening to
                        obj.IniData.(evtstr) = varargin{i+1}(j); %Store name of event listening to
                        addlistener(obj.IniData.(fieldstr),obj.IniData.(evtstr),@(src,evt)RefreshGUI(obj,src,evt,j));
                     end
                  case 'EventData'
                     obj.InputState = varargin{i+1}(1);
               end
            end         
         else
            error('Function only accepts pairs of values');
         end  
         
         %Rearrange graphic components: //VON INPUT ABHÄNGIG MACHEN!
         for i=1:length(pedit{1}(:,1))
            stredit = ['edit',num2str(i)];
            strlbl = ['lbl',num2str(i)];
            
            align([Hloc.(strlbl),Hloc.(stredit)],'VerticalAlignment','Middle');
         end
         
         notify(obj,'NewInputAlert');
         
         %if pevt(2) == 1;
         %   addlistener(obj.ListeningTo,'SelRadio1',@(src,evt)RefreshGUI(obj,src,evt,1));
         %   addlistener(obj.ListeningTo,'SelRadio2',@(src,evt)RefreshGUI(obj,src,evt,2));
         %end
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