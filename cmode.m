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
         Hloc.tmode5 = uipushtool(Hloc.tool,'CData',icon,'UserData','5','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,hmain));
         Hloc.tmode6 = uipushtool(Hloc.tool,'CData',icon,'UserData','6','ClickedCallback',@(src,evt)ToolCall(obj,src,evt,hmain));
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
                  {[550,150,25,25;...
                  550,180,25,25;...
                  550,210,25,25;...
                  550,240,25,25],...
                  [2;1.5;10;30]};
               inilbl =...
                  {[500,150,50,15;...
                  500,180,50,15;...
                  500,210,50,15;...
                  500,240,50,15],...
                  {'OFF (V):';'AMP (V):';'FRQ (Hz):';'SWEEPS:'}};
               inievt = [1];
               initggl =...
                  {[225,15,50,25],...
                  'SAMPLE',...
                  1};
               
               iniedit2 =...
                  {[550,150,25,25;...
                  550,180,25,25;...
                  550,210,25,25;...
                  550,240,25,25],...
                  [2;1.5;10;30]};
               inilbl2 =...
                  {[500,150,50,15;...
                  500,180,50,15;...
                  500,210,50,15;...
                  500,240,50,15],...
                  {'OFF (V):';'AMP (V):';'FRQ (Hz):';'SWEEPS:'}};
               inievt2 = [1];
               
%                inipanel = [500,150,150,110];                  
%                iniinput =...
%                   {[25,25;...
%                   25,25;...
%                   25,25;...
%                   25,25;],...
%                   [2;1.5;10;30],...
%                   {'OFF (V):';'AMP (V):';'FRQ (Hz):';'SWEEPS:'}};
%                inievt = [1];
%                initggl =...
%                   {[225,15,50,25],...
%                   'SAMPLE',...
%                   1};
               
               %Reset default sample rate: //Find more appropriate implementation point/ reorganize signal class so that it won't be called on every update if implemented there
               PREFSloc = getappdata(hmain,'preferences');
               PREFSloc.samplerate = 40000;
               setappdata(hmain,'preferences',PREFSloc);
            
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(hmain,'MODAL');
                       
               %Invoke instances of control classes (with private GUI elements due to user interface function):
               MAININPUT = input.redraw_1(hmain,[490,280,140,30],'SIN','WGN');
               SIGNAL = cgen_signal(hmain,MAININPUT);
               GUIOUT = output.guiout_m1(hmain,SIGNAL);
               ACCESS1401 = drive1401.run1401(hmain,initggl,SIGNAL); %Klasse als allgemeine Stimulations-Ouputklasse?

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
               SIGNAL = cgen_signal(hmain,MAININPUT);
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
               SIGNAL = cgen_signal(hmain,MAININPUT);
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
               SIGNAL = cgen_signal(hmain,MAININPUT);
               EXEC1401 = setup.setup3(hmain,SIGNAL);
               %GUIOUT = output.guiout_m3(hmain,SIGNAL);
               
               APPDATloc = getappdata(hmain,'appdata');
               APPDATloc.ModeCheck = 4;
               setappdata(hmain,'appdata',APPDATloc);
               clear fn APPDATloc;
            case 5
               %Initialisation options:
               %//For OLDHAZARD:
%                iniedit =...
%                   {[150,25,50,25;...
%                   150,55,50,25;...
%                   150,85,50,25;...
%                   150,115,50,25]...
%                   [0.02;50;100;3]};
%                inilbl =...
%                   {[25,25,125,15;...
%                   25,55,125,15;...
%                   25,85,125,15;...
%                   25,115,125,15]...
%                   {'Initial probability:';'Ticklength (ms):';'Ticks:';'N of trials (per hemisph.):'}};
%                inievt = [0];
               
               iniedit =...
                  {[150,25,50,25;...
                  150,55,50,25;...
                  150,85,50,25;...
                  150,115,50,25]...
                  [0.6;50;160;3]};
               inilbl =...
                  {[25,25,125,15;...
                  25,55,125,15;...
                  25,85,125,15;...
                  25,115,125,15]...
                  {'Initial probability:';'Ticklength (ms):';'Ticks (per sq.):';'N of trials (per hemisph.):'}};
               inievt = [0];
               
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(hmain,'MODAL');
               
               %Invoke instances of control classes (with private GUI elements with respect to user interface function):
               MAININPUT = input.maininput(hmain,iniedit,inilbl,inievt);
               SIGNAL = cgen_signal(hmain,MAININPUT);
               SETUP = setup.setup4(hmain,SIGNAL); %//1401 driving object is defined in subclass constructor
               
               APPDAT = getappdata(hmain,'appdata');
               APPDAT.ModeCheck = 5;
               setappdata(hmain,'appdata',APPDAT);
               clear APPDAT;
            case 6
               %Initialisation options:
               %--> Defined in REDRAW-subclass
               
               %Delete all invoked objects (related to other program mode) and call new invocations:
               cdat.delobj(hmain,'MODAL');
               
               %Invoke instances of control classes (with private GUI elements with respect to user interface function):
               %Second param is dummy argument because of not having finished complete reusability yet:
               MAININPUT = input.redraw_2(hmain,[10,210,145,30],'Training','Stim');
               SIGNAL = cgen_signal(hmain,MAININPUT);
               SETUP = setup.setup5(hmain,SIGNAL);
               
               APPDATloc = getappdata(hmain,'appdata');
               APPDATloc.ModeCheck = 6;
               setappdata(hmain,'appdata',APPDATloc);
               clear APPDATloc;
         end
      end
   end
end