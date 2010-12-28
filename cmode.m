%Main initialization class of program mode
classdef cmode < handle
   properties
   end
   methods
      %Constructor:
      function obj = cmode(hmain)
         %Generate, process or load icon data:
         icon = load('ICON_dot.mat','icon');
         icon = icon.icon;
         
         cdat.setobj(hmain,obj,'GENERAL');
         
         Hloc = getappdata(hmain,'uihandles');
         
         Hloc.tool = uitoolbar(hmain);
         Hloc.tmode1 = uipushtool(Hloc.tool,'CData',icon,'UserData','1','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,hmain));
         Hloc.tmode2 = uipushtool(Hloc.tool,'CData',icon,'UserData','2','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,hmain));
         Hloc.tmode3 = uipushtool(Hloc.tool,'CData',icon,'UserData','3','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,hmain));
         Hloc.tmode4 = uipushtool(Hloc.tool,'CData',icon,'UserData','4','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,hmain));
         setappdata(hmain,'uihandles',Hloc);
         
         APPDATloc = getappdata(hmain,'appdata');
         APPDATloc.ModeCheck = 1;
         setappdata(hmain,'appdata',APPDATloc);
         clear APPDATloc;
         
         obj.ToolCall(Hloc.tmode1,0,hmain);
      end
      function ToolCall(obj,src,evt,hmain) %s.a. Lösungsvariante in maininput
         Hloc = getappdata(hmain,'uihandles');
         
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
               inievt = [1];
               initggl =...
                  {[225,15,50,25],...
                  'SAMPLE',...
                  1};
               
               %Reset default sample rate: //Find more appropriate implementation point/ reorganize signal class so that it won't be called on every update if implemented there
               PREFSloc = getappdata(hmain,'preferences');
               PREFSloc.samplerate = 40000;
               setappdata(hmain,'preferences',PREFSloc);
            
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(hmain,'MODAL');
                       
               %Invoke instances of control classes (with private GUI elements due to user interface function):
               MAININPUT = input.mainredraw(hmain,iniedit,inilbl,inievt,[0.738,0.85,0.16,0.1],'SIN','CC');
               SIGNAL = cgen_signal(hmain,MAININPUT,40000); %Make data length independent from user requirements! 1s at 40kHz for mode 1.
               GUIOUT = output.guiout_m1(hmain,SIGNAL);
               ACCESS1401 = caccess1401(hmain,initggl,SIGNAL); %Klasse als allgemeine Stimulations-Ouputklasse? --> obj-handle- sammelstruktur nötig!

               APPDATloc = getappdata(hmain,'appdata');
               APPDATloc.ModeCheck = 1;
               setappdata(hmain,'appdata',APPDATloc);
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
               inievt = [3];
               initggl =...
                  {[200,25,100,25],...
                  'START SEQ.',...
                  0};
               
               %Reset default sample rate: //Find more appropriate implementation point/ reorganize signal class so that it won't be called on every update if implemented there
               PREFSloc = getappdata(hmain,'preferences');
               PREFSloc.samplerate = 1280;
               setappdata(hmain,'preferences',PREFSloc);
            
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(hmain,'MODAL');

               %Invoke instances of control classes (with private GUI elements with respect to user interface function):
               %Second param is dummy argument because of not having finished complete reusability yet:

               MAININPUT = input.maininput(hmain,iniedit,inilbl,inievt);
               SIGNAL = cgen_signal(hmain,MAININPUT,10000); %10s at 1kHz for mode 2
               LOAD = setup.setup1(hmain,SIGNAL);
               LOG = clog(hmain,SIGNAL);
               EXEC1401 = crun1401(hmain,initggl,SIGNAL,MAININPUT,LOAD);
               GUIOUT = output.guiout_m2(hmain,SIGNAL);

               APPDATloc = getappdata(hmain,'appdata');
               APPDATloc.ModeCheck = 2;
               setappdata(hmain,'appdata',APPDATloc);
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
               inievt = [4];
               initggl =...
                  {[200,25,100,25],...
                  'START SEQ.',...
                  0};
               
               %Reset default sample rate: //Find more appropriate implementation point/ reorganize signal class so that it won't be called on every update if implemented there
               PREFSloc = getappdata(hmain,'preferences');
               PREFSloc.samplerate = 1280;
               setappdata(hmain,'preferences',PREFSloc);
               
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(hmain,'MODAL');
               
               %Invoke instances of control classes (with private GUI elements with respect to user interface function):
               %Second param is dummy argument because of not having finished complete reusability yet:
               MAININPUT = input.maininput(hmain,iniedit,inilbl,inievt);
               SIGNAL = cgen_signal(hmain,MAININPUT,1280);
               LOAD = setup.setup2(hmain,SIGNAL);
               EXEC1401 = crun1401(hmain,initggl,SIGNAL,MAININPUT,LOAD);
               GUIOUT = output.guiout_m3(hmain,SIGNAL);
               
               APPDATloc = getappdata(hmain,'appdata');
               APPDATloc.ModeCheck = 3;
               setappdata(hmain,'appdata',APPDATloc);
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
               inievt = [4];
               
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(hmain,'MODAL');
               
               %Invoke instances of control classes (with private GUI elements with respect to user interface function):
               %Second param is dummy argument because of not having finished complete reusability yet:
               MAININPUT = input.maininput(hmain,iniedit,inilbl,inievt);
               SIGNAL = cgen_signal(hmain,MAININPUT,1280);
               EXEC1401 = setup.setup3(hmain,SIGNAL);
               %GUIOUT = output.guiout_m3(hmain,SIGNAL);
               
               APPDATloc = getappdata(hmain,'appdata');
               APPDATloc.ModeCheck = 4;
               setappdata(hmain,'appdata',APPDATloc);
               clear fn APPDATloc;
         end
      end
   end
end