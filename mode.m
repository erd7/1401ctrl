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
         
         Hloc = getappdata(h.main,'uihandles');
         Hloc.tool = uitoolbar(h.main);
         Hloc.tmode1 = uipushtool(Hloc.tool,'CData',icon1,'UserData','1','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,Hloc));
         Hloc.tmode2 = uipushtool(Hloc.tool,'CData',icon2,'UserData','2','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,Hloc));
         setappdata(h.main,'uihandles',Hloc);
         
         obj.ToolCall(Hloc.tmode1,0,Hloc);
      end
      function ToolCall(obj,src,evt,h) %s.a. Lösungsvariante in maininput
         Hloc = getappdata(h.main,'uihandles');         
         if str2double(get(src,'UserData')) == 1
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
            TOGGLEBTTN = togglebutton(Hloc,[225,15,50,25],'SAMPLE');
            RADIOGRP = radiobuttongrp(Hloc,[0.738,0.85,0.16,0.1],'SIN','CC');
   
            %Invoke instances of control classes (with private GUI elements due to user interface function):
            MAININPUT = input.maininput(Hloc,RADIOGRP,iniedit,inilbl,inievt);
            SIGNAL = gen_signal(Hloc,MAININPUT);
            CALLINOUT = guiout(SIGNAL,Hloc);
            CALLTOGGLE = togglecallback(Hloc.main,TOGGLEBTTN,SIGNAL); %Klasse als allgemeine Stimulations-Ouputklasse? --> obj-handle- sammelstruktur nötig!
            
            APPDATloc = getappdata(Hloc.main,'appdata');
            APPDATloc.CURRENTOBJ = {TOGGLEBTTN,RADIOGRP,MAININPUT,SIGNAL,CALLINOUT,CALLTOGGLE};
            APPDATloc.ModeCheck = 1;
            setappdata(Hloc.main,'appdata',APPDATloc);
            %DO NOT UPDATE GFX HANDLE APPDATA HERE, AS THIS IS DONE WITHIN EVERY CLASSOBJECT INVOCATION!
         elseif str2double(get(src,'UserData')) == 2
            APPDATloc = getappdata(Hloc.main,'appdata');
            
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
         end
      end
   end
end