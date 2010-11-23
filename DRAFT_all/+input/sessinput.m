%Implementation of session setings-GUI input class as userinput subclass
classdef sessinput < input.userinput
   properties
      Parent
      Settings
   end
   methods
      %Constructor:
      function obj = sessinput(hmain)
         obj.Parent = hmain;
         Hloc = getappdata(hmain,'uihandles');
         obj.Settings = getappdata(obj.Parent,'appdata');
         
         stredit = cdat.uistr(hmain,'edit');
         Hloc.(stredit) = uicontrol('Style','edit','String',obj.Settings.researcher,'Position',[25,350,200,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(hmain,'uihandles',Hloc);
         
         stredit = cdat.uistr(hmain,'edit');
         Hloc.(stredit) = uicontrol('Style','edit','String',obj.Settings.subject,'Position',[25,300,200,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(hmain,'uihandles',Hloc);
         
         Hloc.lbls1 = uicontrol('Style','text','String','Researcher:','Position',[25,375,200,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         Hloc.lbls2 = uicontrol('Style','text','String','Subject:','Position',[25,325,200,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(obj.Parent,'uihandles',Hloc);
         
         obj.UserInput.Entry1 = get(Hloc.edit1,'String');
         %Appdata update regarding preferences redundant at this point
         
         notify(obj,'NewInputAlert'); %probably redundant
      end
      function UpdateInput(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         obj.UserInput.Entry1 = get(Hloc.edits1,'String');
         obj.UserInput.Entry2 = get(Hloc.edits2,'String');
         
         %Verarbeitungsschritt vorübergehend hier einfügen:
         obj.Settings = getappdata(obj.Parent,'appdata');
         obj.Settings.researcher = obj.UserInput.Entry1;
         obj.Settings.subject = obj.UserInput.Entry2;
         setappdata(obj.Parent,'appdata',obj.Settings);
         
         notify(obj,'NewInputAlert'); %//allgemeine ausgabeklasse mit entsprechenden subklassen? verarbeitungsfunktion wäre an dieser stelle allein das update der prefs
                                      %--> vorübergehend als close request?
      end
   end
end