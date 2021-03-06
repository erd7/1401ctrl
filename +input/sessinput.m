%Implementation of session setings-GUI input class as userinput subclass
classdef sessinput < input.userinput
   properties
      Settings
   end
   methods
      %Constructor:
      function obj = sessinput(hmain)
         obj = obj@input.userinput(hmain);
         
         Hloc = getappdata(hmain,'uihandles');
         obj.Settings = getappdata(obj.Parent,'appdata');
         
         stredit = cdat.uistr(hmain,obj,'edit');
         Hloc.(stredit) = uicontrol('Style','edit','String',obj.Settings.researcher,'Position',[25,350,200,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(hmain,'uihandles',Hloc);
         
         stredit = cdat.uistr(hmain,obj,'edit');
         Hloc.(stredit) = uicontrol('Style','edit','String',obj.Settings.subject,'Position',[25,300,200,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(hmain,'uihandles',Hloc);
         
         stredit = cdat.uistr(hmain,obj,'edit');
         Hloc.(stredit) = uicontrol('Style','edit','String',obj.Settings.sesstag,'Position',[25,250,200,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(hmain,'uihandles',Hloc);
         
         Hloc.lbls1 = uicontrol('Style','text','String','Researcher:','Position',[25,375,200,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         Hloc.lbls2 = uicontrol('Style','text','String','Subject:','Position',[25,325,200,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         Hloc.lbls3 = uicontrol('Style','text','String','Session Tag:','Position',[25,275,200,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(obj.Parent,'uihandles',Hloc);
         
         %obj.UserInput.Entry1 = get(Hloc.sessinput_edit1,'String');
         %Appdata update regarding preferences redundant at this point
         
         notify(obj,'NewInputAlert'); %probably redundant
      end
      function UpdateInput(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         obj.UserInput.Entry1 = get(Hloc.sessinput_edit1,'String');
         obj.UserInput.Entry2 = get(Hloc.sessinput_edit2,'String');
         obj.UserInput.Entry3 = get(Hloc.sessinput_edit3,'String');
         
         %Verarbeitungsschritt vorübergehend hier einfügen:
         obj.Settings = getappdata(obj.Parent,'appdata');
         obj.Settings.researcher = obj.UserInput.Entry1;
         obj.Settings.subject = obj.UserInput.Entry2;
         obj.Settings.sesstag = obj.UserInput.Entry3;
         setappdata(obj.Parent,'appdata',obj.Settings);
         
         notify(obj,'NewInputAlert'); %//allgemeine ausgabeklasse mit entsprechenden subklassen? verarbeitungsfunktion wäre an dieser stelle allein das update der prefs
                                      %--> vorübergehend als close request?
      end
   end
end