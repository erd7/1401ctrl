%Implementation of preferences GUI input class as userinput subclass
classdef prefinput < input.userinput
   properties
      Parent
      Prefs
   end
   methods
      %Constructor:
      function obj = prefinput(fig)
         obj.Parent = fig;
         Hloc = getappdata(obj.Parent,'uihandles');
         obj.Prefs = getappdata(obj.Parent,'preferences');
         
         Hloc.edit4 = uicontrol('Style','edit','String',obj.Prefs.langpath,'Position',[25,350,200,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(obj.Parent,'uihandles',Hloc);
         
         obj.UserInput.Entry4 = get(Hloc.edit4,'String');
         %Appdata update regarding preferences redundant at this point
         
         notify(obj,'NewInputAlert'); %probably redundant
      end
      function UpdateInput(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         obj.UserInput.Entry4 = get(Hloc.edit4,'String');
         
         %Verarbeitungsschritt vorübergehend hier einfügen:
         obj.Prefs = getappdata(obj.Parent,'preferences');
         obj.Prefs.langpath = obj.UserInput.Entry4;
         setappdata(obj.Parent,'preferences',obj.Prefs);
         
         notify(obj,'NewInputAlert'); %//allgemeine ausgabeklasse mit entsprechenden subklassen? verarbeitungsfunktion wäre an dieser stelle allein das update der prefs
                                      %--> vorübergehend als close request?
      end
   end
end