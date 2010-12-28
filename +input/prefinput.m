%Implementation of preferences GUI input class as userinput subclass
classdef prefinput < input.userinput
   properties
      Prefs
   end
   methods
      %Constructor:
      function obj = prefinput(hmain)
         %As superclass constructor requires arguments, call explicitly:
         obj = obj@input.userinput(hmain);
         
         obj.Prefs = getappdata(obj.Parent,'preferences');
         
         %Find general routine; take maininput as template
         Hloc = getappdata(obj.Parent,'uihandles');
         stredit = cdat.uistr(hmain,obj,'edit');
         Hloc.(stredit) = uicontrol('Style','edit','String',obj.Prefs.langpath,'Tag','STRING','Position',[25,350,200,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(hmain,'uihandles',Hloc);
         
         Hloc = getappdata(obj.Parent,'uihandles');
         stredit = cdat.uistr(hmain,obj,'edit');
         Hloc.(stredit) = uicontrol('Style','edit','String',obj.Prefs.samplerate,'Tag','NUM','Position',[150,325,35,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(hmain,'uihandles',Hloc);
         
         Hloc = getappdata(obj.Parent,'uihandles');
         stredit = cdat.uistr(hmain,obj,'edit');
         Hloc.(stredit) = uicontrol('Style','edit','String',obj.Prefs.mepdelay,'Tag','NUM','Position',[150,300,35,25],'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         setappdata(hmain,'uihandles',Hloc);
         
         Hloc = getappdata(obj.Parent,'uihandles');
         strlbl = cdat.uistr(hmain,obj,'lbl');
         Hloc.(strlbl) = uicontrol('Style','text','String','Specify 1401 language support path:','Position',[25,375,200,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(obj.Parent,'uihandles',Hloc);
         
         Hloc = getappdata(obj.Parent,'uihandles');
         strlbl = cdat.uistr(hmain,obj,'lbl');
         Hloc.(strlbl) = uicontrol('Style','text','String','Output sample rate (Hz):','Position',[25,325,120,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(obj.Parent,'uihandles',Hloc);
         
         Hloc = getappdata(obj.Parent,'uihandles');
         strlbl = cdat.uistr(hmain,obj,'lbl');
         Hloc.(strlbl) = uicontrol('Style','text','String','MEP trig. delay (ms):','Position',[25,300,120,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(obj.Parent,'uihandles',Hloc);
         
         align(Hloc.prefinput_edit2,Hloc.prefinput_lbl2,'VerticalAlignment','Middle');
         
         obj.UserInput.Entry1 = get(Hloc.prefinput_edit1,'String');
         %Appdata update regarding preferences redundant at this point
         
         notify(obj,'NewInputAlert'); %probably redundant
      end
      function UpdateInput(obj,src,evt)
         %Hloc = getappdata(obj.Parent,'uihandles');
         
         %obj.UserInput.Entry1 = get(Hloc.prefinput_edit1,'String');
         
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
         %//MAKE TAG CHECK MANDATORY FOR SUPERCLASS UPDATE ROUTINE!
         for i=1:m
            stredit = [cdat.classname(obj),'_','edit',num2str(i)];
            strEntry = ['Entry',num2str(i)];
            
            if strcmp(get(Hloc.(stredit),'Tag'),'STRING') == 1
               obj.UserInput.(strEntry) = get(Hloc.(stredit),'String');
            elseif strcmp(get(Hloc.(stredit),'Tag'),'NUM') == 1
               obj.UserInput.(strEntry) = str2double(get(Hloc.(stredit),'String'));
            end
         end
         
         %Verarbeitungsschritt vorübergehend hier einfügen (gemeinsame UpdateInput Superfunktion und verarbeiten auf notify hin!):
         obj.Prefs = getappdata(obj.Parent,'preferences');
         obj.Prefs.langpath = obj.UserInput.Entry1;
         
         if cdat.mansmplrt(obj.Parent,obj.UserInput.Entry2) ~= 0
            obj.Prefs.samplerate = obj.UserInput.Entry2;
         else
            msgbox('Sample rate not valid! Please specify value that is integer divisor of 4000000.','ERROR: Invalid sample rate','error');
         end
         obj.Prefs.mepdelay = obj.UserInput.Entry3;
         setappdata(obj.Parent,'preferences',obj.Prefs);
         
         notify(obj,'NewInputAlert'); %//allgemeine ausgabeklasse mit entsprechenden subklassen? verarbeitungsfunktion wäre an dieser stelle allein das update der prefs
                                      %--> vorübergehend als close request?
      end
   end
end