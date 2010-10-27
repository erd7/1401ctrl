%Main initialization class of program mode
classdef cmode < handle
   properties
   end
   methods
      %Constructor:
      function obj = cmode(h)
         %Generate % process or load icon data:
         icon = load('ICON_dot.mat','icon');
         icon = icon.icon;
         
         cdat.setobj(h,obj,'GENERAL');
         
         Hloc = getappdata(h.main,'uihandles');
         
         Hloc.tool = uitoolbar(h.main);
         Hloc.tmode1 = uipushtool(Hloc.tool,'CData',icon,'UserData','1','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,Hloc));
         Hloc.tmode2 = uipushtool(Hloc.tool,'CData',icon,'UserData','2','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,Hloc));
         Hloc.tmode3 = uipushtool(Hloc.tool,'CData',icon,'UserData','3','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,Hloc));
         Hloc.tmode4 = uipushtool(Hloc.tool,'CData',icon,'UserData','4','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,Hloc));
         setappdata(h.main,'uihandles',Hloc);
         
         APPDATloc = getappdata(h.main,'appdata');
         APPDATloc.ModeCheck = 1;
         setappdata(h.main,'appdata',APPDATloc);
         clear APPDATloc;
         
         obj.ToolCall(Hloc.tmode1,0,Hloc);
      end
      function ToolCall(obj,src,evt,h) %s.a. Lösungsvariante in maininput
         Hloc = getappdata(h.main,'uihandles');
         
         switch str2double((get(src,'UserData')))
            case 1
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
               initggl =...
                  {[225,15,50,25],...
                  'SAMPLE',...
                  1};
            
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(Hloc,'MODAL');
            
               %Invoke GUI class objects:
               %TOGGLEBTTN = togglebutton(Hloc,[225,15,50,25],'SAMPLE',1);
               RADIOGRP = radiobuttongrp(Hloc,[0.738,0.85,0.16,0.1],'SIN','CC');
   
               %Invoke instances of control classes (with private GUI elements due to user interface function):
               MAININPUT = input.maininput(Hloc,RADIOGRP,iniedit,inilbl,inievt);
               SIGNAL = cgen_signal(Hloc,MAININPUT,40000); %Make data length independet from user requirementss! 1s at 40kHz for mode 1.
               GUIOUT = output.guiout_m1(Hloc,SIGNAL);
               ACCESS1401 = caccess1401(Hloc,initggl,SIGNAL); %Klasse als allgemeine Stimulations-Ouputklasse? --> obj-handle- sammelstruktur nötig!

               APPDATloc = getappdata(Hloc.main,'appdata');
               APPDATloc.ModeCheck = 1;
               setappdata(Hloc.main,'appdata',APPDATloc);
               clear APPDATloc;
               %DO NOT UPDATE GFX & CTRL HANDLE APPDATA HERE, AS THIS IS DONE WITHIN EVERY CLASSOBJECT INVOCATION!
            case 2            
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
               initggl =...
                  {[200,25,100,25],...
                  'START SEQ.',...
                  0};
            
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(Hloc,'MODAL');

               %Invoke instances of control classes (with private GUI elements with respect to user interface function):
               %Second param is dummy argument because of not having finished complete reusability yet:
               MAININPUT = input.maininput(Hloc,0,iniedit,inilbl,inievt);
               SIGNAL = cgen_signal(Hloc,MAININPUT,10000); %10s at 1kHz for mode 2
               LOAD = setup.setup1(Hloc,SIGNAL);
               LOG = clog(Hloc,SIGNAL);
               EXEC1401 = crun1401(Hloc,initggl,SIGNAL,MAININPUT,LOAD);
               GUIOUT = output.guiout_m2(Hloc,SIGNAL);

               APPDATloc = getappdata(Hloc.main,'appdata');
               APPDATloc.ModeCheck = 2;
               setappdata(Hloc.main,'appdata',APPDATloc);
               clear APPDATloc;
            case 3
               %Initialisation options:
               iniedit =...
                  {[75,25,50,25;...
                  75,55,50,25]...
                  [180;1]};
               inilbl =...
                  {[25,25,50,15;...
                  25,55,50,15]
                  {'DUR (s):';'LVL:'}};
               inievt = [4,0]; %//second param redundant?
               initggl =...
                  {[200,25,100,25],...
                  'START SEQ.',...
                  0};
               
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(Hloc,'MODAL');
               
               %Invoke instances of control classes (with private GUI elements with respect to user interface function):
               %Second param is dummy argument because of not having finished complete reusability yet:
               MAININPUT = input.maininput(Hloc,0,iniedit,inilbl,inievt);
               SIGNAL = cgen_signal(Hloc,MAININPUT,1280);
               LOAD = setup.setup2(Hloc,SIGNAL);
               EXEC1401 = crun1401(Hloc,initggl,SIGNAL,MAININPUT,LOAD);
               GUIOUT = output.guiout_m3(Hloc,SIGNAL);
               
               APPDATloc = getappdata(Hloc.main,'appdata');
               APPDATloc.ModeCheck = 3;
               setappdata(Hloc.main,'appdata',APPDATloc);
               clear fn APPDATloc;
            case 4
               %Initialisation options:
               iniedit =...
                  {[75,25,50,25;...
                  75,55,50,25]...
                  [180;10]};
               inilbl =...
                  {[25,25,50,15;...
                  25,55,50,15]...
                  {'DUR (s):';'Cycles:'}};
               inievt = [4,0]; %//second param redundant?
               
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(Hloc,'MODAL');
               
               %Invoke instances of control classes (with private GUI elements with respect to user interface function):
               %Second param is dummy argument because of not having finished complete reusability yet:
               MAININPUT = input.maininput(Hloc,0,iniedit,inilbl,inievt);
               SIGNAL = cgen_signal(Hloc,MAININPUT,1280);
               EXEC1401 = setup.setup3(Hloc,SIGNAL);
               %GUIOUT = output.guiout_m3(Hloc,SIGNAL);
               
               APPDATloc = getappdata(Hloc.main,'appdata');
               APPDATloc.ModeCheck = 4;
               setappdata(Hloc.main,'appdata',APPDATloc);
               clear fn APPDATloc;
         end
      end
   end
end