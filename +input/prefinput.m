%Implementation of preferences GUI input class as userinput subclass
classdef prefinput < input.userinput
   properties
      Parent
      Prefs
   end
   methods
      %Constructor:
      function obj = prefinput(hmain)
         obj.Parent = hmain;
         Hloc = getappdata(obj.Parent,'uihandles');
         obj.Prefs = getappdata(obj.Parent,'preferences');
         
         stredit = cdat.uistr(hmain,'edit');
         Hloc.(stredit) = uicontrol('Style','edit','String',obj.Prefs.langpath,'Position',[25,350,200,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(hmain,'uihandles',Hloc);
         
         stredit = cdat.uistr(hmain,'edit');
         Hloc.(stredit) = uicontrol('Style','edit','String',obj.Prefs.mepdelay,'Position',[125,325,25,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(hmain,'uihandles',Hloc);
         
         Hloc.lblp1 = uicontrol('Style','text','String','Specify 1401 language support path:','Position',[25,375,200,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         Hloc.lblp2 = uicontrol('Style','text','String','MEP trig. delay (ms):','Position',[25,325,100,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(obj.Parent,'uihandles',Hloc);
         
         align(Hloc.editp2,Hloc.lbl2,'VerticalAlignment','Middle');
         
         obj.UserInput.Entry1 = get(Hloc.editp1,'String');
         %Appdata update regarding preferences redundant at this point
         
         notify(obj,'NewInputAlert'); %probably redundant
      end
      function UpdateInput(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         obj.UserInput.Entry1 = get(Hloc.editp1,'String');
         
         %Verarbeitungsschritt vorübergehend hier einfügen:
         obj.Prefs = getappdata(obj.Parent,'preferences');
         obj.Prefs.langpath = obj.UserInput.Entry1;
         setappdata(obj.Parent,'preferences',obj.Prefs);
         
         notify(obj,'NewInputAlert'); %//allgemeine ausgabeklasse mit entsprechenden subklassen? verarbeitungsfunktion wäre an dieser stelle allein das update der prefs
                                      %--> vorübergehend als close request?
      end
   end
end