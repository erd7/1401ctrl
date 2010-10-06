%Main initialization class of program mode
classdef mode < handle
   properties
   end
   methods
      %Constructor:
      function obj = mode(h)
         %Generate % process icon data:
         %upicon = gen_upicon();
         %dwnicon = gen_dwnicon();
         [X,map] = imread('icon_A.gif');
         icon1 = ind2rgb(X,map);
         [X,map] = imread('icon_B.gif');
         icon2 = ind2rgb(X,map);
         clear('X','map');
         
         APPDATloc = getappdata(h.main,'appdata');
         Hloc = getappdata(h.main,'uihandles');
         Hloc.tool = uitoolbar(h.main);
         Hloc.tmode1 = uipushtool(Hloc.tool,'CData',icon1,'UserData','1','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,Hloc));
         Hloc.tmode2 = uipushtool(Hloc.tool,'CData',icon2,'UserData','2','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,Hloc));
         setappdata(h.main,'uihandles',Hloc);
         
         APPDATloc.ModeCheck = 1;
         setappdata(h.main,'appdata',APPDATloc);
         obj.ToolCall(Hloc.tmode1,0,Hloc);
      end
      function ToolCall(obj,src,evt,h) %s.a. Lösungsvariante in maininput
         Hloc = getappdata(h.main,'uihandles');
         APPDATloc = getappdata(Hloc.main,'appdata');
         
         if str2double(get(src,'UserData')) == 1            
            %Delete objects related to other program mode:            
            if APPDATloc.ModeCheck == 2;
               for i=1:length(APPDATloc.CURRENTOBJ)
                  if isobject(APPDATloc.CURRENTOBJ{i}) == 1
                     delete(APPDATloc.CURRENTOBJ{i});
                  end
               end
               APPDATloc = rmfield(APPDATloc,'CURRENTOBJ');
               APPDATloc.ModeCheck = 2;
               setappdata(Hloc.main,'appdata',APPDATloc);
            end
            
            %Initialisation options:
            iniedit =...
               {[550,180,25,25;...
               550,210,25,25;...
               550,240,25,25],...
               [2;1.5;10]};
            inilbl =...
               {[500,180,50,15;...
               500,210,50,15;...
               500,240,50,15],...
               {'OFF:';'AMP (V):';'FRQ (Hz):'}};
            inievt = [1,1];
            
            %Invoke GUI class objects:
            TOGGLEBTTN = togglebutton(Hloc,[225,15,50,25],'SAMPLE',1);
            RADIOGRP = radiobuttongrp(Hloc,[0.738,0.85,0.16,0.1],'SIN','CC');
   
            %Invoke instances of control classes (with private GUI elements due to user interface function):
            MAININPUT = input.maininput(Hloc,RADIOGRP,iniedit,inilbl,inievt);
            SIGNAL = gen_signal(Hloc,MAININPUT,40000); %Make data length independet from user requirementss! 1s at 40kHz for mode 1.
            CALLINOUT = guiout(SIGNAL,Hloc);
            CALLTOGGLE = togglecallback(Hloc,TOGGLEBTTN,SIGNAL); %Klasse als allgemeine Stimulations-Ouputklasse? --> obj-handle- sammelstruktur nötig!
            
            APPDATloc.CURRENTOBJ = {TOGGLEBTTN,RADIOGRP,MAININPUT,SIGNAL,CALLINOUT,CALLTOGGLE};
            APPDATloc.ModeCheck = 1;
            setappdata(Hloc.main,'appdata',APPDATloc);
            %DO NOT UPDATE GFX HANDLE APPDATA HERE, AS THIS IS DONE WITHIN EVERY CLASSOBJECT INVOCATION!
         elseif str2double(get(src,'UserData')) == 2            
            %Delete objects related to other program mode:            
            if APPDATloc.ModeCheck == 1;
               for i=1:length(APPDATloc.CURRENTOBJ)
                  if isobject(APPDATloc.CURRENTOBJ{i}) == 1
                     delete(APPDATloc.CURRENTOBJ{i});
                  end
               end
               APPDATloc = rmfield(APPDATloc,'CURRENTOBJ');
               APPDATloc.ModeCheck = 2;
               setappdata(Hloc.main,'appdata',APPDATloc);
            end
               
            %Initialisation options:
            iniedit =...
               {[75,25,50,25;...
               75,55,50,25;...
               75,85,50,25],...
               [60;10;6]};
            inilbl =...
               {[25,25,50,15;...
               25,55,50,15;...
               25,85,50,15],...
               {'DUR (s):';'STEPS:';'SUBDIV:'}};
            inievt = [3,0]; %//second param redundant?
            
            %Invoke GUI class objects:
            TOGGLEBTTN = togglebutton(Hloc,[200,25,100,25],'START SEQ.',0);
            
            %Invoke instances of control classes (with private GUI elements due to user interface function):
            %Second param is dummy argument because of not having finished complete reusability yet:
            MAININPUT = input.maininput(Hloc,0,iniedit,inilbl,inievt);
            SIGNAL = gen_signal(Hloc,MAININPUT,10000); %10s at 1kHz for mode 2
            LOAD = load1401(Hloc,SIGNAL);
            CALLTOGGLE = togglecallback_re(Hloc,TOGGLEBTTN,SIGNAL,MAININPUT,LOAD);
            
            APPDATloc.CURRENTOBJ = {TOGGLEBTTN,MAININPUT,SIGNAL,LOAD,CALLTOGGLE};
            APPDATloc.ModeCheck = 2;
            setappdata(Hloc.main,'appdata',APPDATloc);
         end
      end
   end
end