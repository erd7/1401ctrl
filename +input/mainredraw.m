%Class erzeugt eine Buttongroup aus zwei Radiobuttons; zu implementieren: dynamische Anpassung der Buttonzahl
%KONZEPT: Klasse als allg REDRAW klasse (selbst superklasse, untergeordnete implementierungsklassen erstellen!)- beerbt maininput
%+Subklasse: Konkrete implementierung erst in der Refreshfunktion in Subklasse!
classdef mainredraw < input.maininput
   properties
      RadioState = 1;
      ContainerPosition
      ButtonString1
      ButtonString2
      Calling
   end
   methods
      %Constructor: //Use position: [0.8,0.85,0.16,0.1] (testing)
      function obj = mainredraw(hmain,iniedit,inilbl,inievt,pos,lbl1,lbl2)
         %As superclass constructor requires arguments, call explicitly:
         obj = obj@input.maininput(hmain,iniedit,inilbl,inievt);
         
         Hloc = getappdata(obj.Parent,'uihandles');
         obj.Calling = obj;
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
            obj.redraw(obj.Calling,obj.RadioState);
         elseif evt.NewValue == Hloc.radio1
            obj.RadioState = 1;
            obj.redraw(obj.Calling,obj.RadioState);
         end
      end
      function redraw(obj,del,mod) %auch für Wiederverwendung vom Initialisierungsargument abhängig machen!
         obj.redraw@input.maininput(del,mod);
         
         %//Hier variabilität der cases im Argument berücksichtigen und mit schleife cases durchiterieren!
         if mod == 1               
            for i=1:length(del.IniData.pedit{1}(:,1))
               stredit = cdat.uistr(obj.Parent,del,'edit');
     
               Hloc.(stredit) = uicontrol('Style','edit','String',del.IniData.pedit{2}(i,:),'Position',del.IniData.pedit{1}(i,:),'BackgroundColor',[1,1,1],'Callback',@(src,evt)del.UpdateInput(src,evt));
               setappdata(obj.Parent,'uihandles',Hloc);
            end
    
            for i=1:length(del.IniData.plbl{1}(:,1))
               strlbl = cdat.uistr(obj.Parent,del,'lbl');
            
               Hloc.(strlbl) = uicontrol('Style','text','String',del.IniData.plbl{2}{i,:},'Position',del.IniData.plbl{1}(i,:),'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
               setappdata(obj.Parent,'uihandles',Hloc);
            end
         
            %Rearrange graphic components:
            for i=1:length(del.IniData.pedit{1}(:,1))
               stredit = [cdat.classname(del),'_','edit',num2str(i)];
               strlbl = [cdat.classname(del),'_','edit',num2str(i)];
            
               align([Hloc.(strlbl),Hloc.(stredit)],'VerticalAlignment','Middle');
            end
               
            del.InputState = 1;
            del.UpdateInput();
            notify(obj,'NewInputAlert');
         elseif mod == 2
               
            stredit = cdat.uistr(obj.Parent,del,'edit');               
            Hloc.(stredit) = uicontrol('Style','edit','String','1','Position',[550,240,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)del.UpdateInput(src,evt));
            setappdata(obj.Parent,'uihandles',Hloc);
               
            strlbl = cdat.uistr(obj.Parent,del,'lbl');
            Hloc.(strlbl) = uicontrol('Style','text','String','VOLT (V):','Position',[500,240,50,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
            setappdata(obj.Parent,'uihandles',Hloc);
               
            %Rearrange graphic components:
            align([Hloc.(stredit),Hloc.(strlbl)],'VerticalAlignment','Middle');
               
            del.InputState = 2;
            del.UpdateInput();
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