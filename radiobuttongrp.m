%Class erzeugt eine Buttongroup aus zwei Radiobuttons; zu implementieren: dynamische Anpassung der Buttonzahl
%KONZEPT: Klasse als allg REDRAW classe- beerbt maininput! (TODO!!)
%+Subklasse: Konkrete implementierung erst in der Refreshfunktion in Subklasse!
classdef radiobuttongrp < handle
   properties
      RadioState = 1;
      ContainerPosition
      ButtonString1
      ButtonString2
      Parent
      Calling
   end
   events
      NewInputAlert
   end
   methods
      %Constructor: //Use position: [0.8,0.85,0.16,0.1] (testing)
      function obj = radiobuttongrp(hmain,src1,pos,lbl1,lbl2)
         Hloc = getappdata(hmain,'uihandles');
         obj.Parent = hmain;
         obj.Calling = src1;
         obj.ContainerPosition = pos;
         obj.ButtonString1 = lbl1;
         obj.ButtonString2 = lbl2;
         
         cdat.setobj(hmain,obj,'MODAL');
         
         Hloc.radiogrp = uibuttongroup('Position',obj.ContainerPosition,'BackgroundColor',[0.8,0.8,0.8],'SelectionChangeFcn',@(src,evt)RadioCheck(obj,hmain,src,evt));
         Hloc.radio1 = uicontrol('Style','Radio','String',lbl1,'pos',[10,8,40,15],'BackgroundColor',[0.8,0.8,0.8],'parent',Hloc.radiogrp,'Selected','on','SelectionHighlight','off'); %default selection
         Hloc.radio2 = uicontrol('Style','Radio','String',lbl2,'pos',[50,8,40,15],'BackgroundColor',[0.8,0.8,0.8],'parent',Hloc.radiogrp,'Selected','off');
         setappdata(hmain,'uihandles',Hloc);
      end
      %Internal callback:
      %RadioState redundant?
      %Selection switches are performed automatically by the button group!
      function RadioCheck(obj,hmain,src,evt)
         Hloc = getappdata(hmain,'uihandles');
         
         if evt.NewValue == Hloc.radio2
            obj.RadioState = 2;
            obj.redraw(obj.RadioState);
         elseif evt.NewValue == Hloc.radio1
            obj.RadioState = 1;
            obj.redraw(obj.RadioState);
         end
      end
      function redraw(obj,mod) %auch f�r Wiederverwendung vom Initialisierungsargument abh�ngig machen!
         Hloc = getappdata(obj.Parent,'uihandles');
         
         %Destroy every uicontrol obj that is related to maininput (make independent!) (call maininput destructor directly?):
         %Redundanz des Man�vers pr�fen?
         fn = fieldnames(Hloc);
                  
         for i=1:length(fn)
            if isempty(strfind(fn{i},cdat.classname(obj.Calling))) == 0
               delete(Hloc.(fn{i}));
               Hloc = rmfield(Hloc,fn{i});
            end
         end
         
         setappdata(obj.Parent,'uihandles',Hloc);
         
         %//Hier variabilit�t der cases im Argument ber�cksichtigen und mit schleife cases durchiterieren!
         if mod == 1               
            for i=1:length(obj.Calling.IniData.pedit{1}(:,1))
               stredit = cdat.uistr(obj.Parent,obj.Calling,'edit');
     
               Hloc.(stredit) = uicontrol('Style','edit','String',obj.Calling.IniData.pedit{2}(i,:),'Position',obj.Calling.IniData.pedit{1}(i,:),'BackgroundColor',[1,1,1],'Callback',@(src,evt)obj.Calling.UpdateInput(src,evt));
               setappdata(obj.Parent,'uihandles',Hloc);
            end
    
            for i=1:length(obj.Calling.IniData.plbl{1}(:,1))
               strlbl = cdat.uistr(obj.Parent,obj.Calling,'lbl');
            
               Hloc.(strlbl) = uicontrol('Style','text','String',obj.Calling.IniData.plbl{2}{i,:},'Position',obj.Calling.IniData.plbl{1}(i,:),'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
               setappdata(obj.Parent,'uihandles',Hloc);
            end
         
            %Rearrange graphic components:
            for i=1:length(obj.Calling.IniData.pedit{1}(:,1))
               stredit = [cdat.classname(obj.Calling),'_','edit',num2str(i)];
               strlbl = [cdat.classname(obj.Calling),'_','edit',num2str(i)];
            
               align([Hloc.(strlbl),Hloc.(stredit)],'VerticalAlignment','Middle');
            end
               
            obj.Calling.InputState = 1;
            obj.Calling.UpdateInput();
            notify(obj,'NewInputAlert');
         elseif mod == 2
               
            stredit = cdat.uistr(obj.Parent,obj.Calling,'edit');               
            Hloc.(stredit) = uicontrol('Style','edit','String','1','Position',[550,240,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)obj.Calling.UpdateInput(src,evt));
            setappdata(obj.Parent,'uihandles',Hloc);
               
            strlbl = cdat.uistr(obj.Parent,obj.Calling,'lbl');
            Hloc.(strlbl) = uicontrol('Style','text','String','VOLT (V):','Position',[500,240,50,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
            setappdata(obj.Parent,'uihandles',Hloc);
               
            %Rearrange graphic components:
            align([Hloc.(stredit),Hloc.(strlbl)],'VerticalAlignment','Middle');
               
            obj.Calling.InputState = 2;
            obj.Calling.UpdateInput();
            notify(obj,'NewInputAlert');
         end
      end
      %Destructor:
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.radio1);
         delete(Hloc.radio2);
         delete(Hloc.radiogrp);
         Hloc = rmfield(Hloc,'radiogrp');
         Hloc = rmfield(Hloc,'radio1');
         Hloc = rmfield(Hloc,'radio2');
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end