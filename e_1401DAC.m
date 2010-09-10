function r = e_1401DAC()
%power1401 ANALOGUE OUTPUT
%ERDCONTROL main program & GUI file (construction routines % initialization)
%RBP (e), Bln2010

%TODO: entry (amp) max. 5volts/ min -5volts; mit offset vereinbaren! Graphen X-Achse von 0-1s skalieren (bei weiterhin 40k^-1 schrittweite)!
%FRQ: Nach unten gegen 0, nach oben gegen unendlich (Max value?)
%stets: Redundanzen verringern --> kommunizierende Objekte abkapseln!
%PARADIGMA: output stets erst am Ende einer Verarbeitungskette benachrichtigen, sobald intern alles berechnet ist!
%globale Datenstruktur f�r experimentelles Datenmaterial; Steuerdaten weiterhin objektorientiert handhaben
%DAC output als eigene klasse von togglecallback trennen? bisher nicht sinnvoll!
%grunds�tzlich die gesamte headerklasse/struktur �bergeben?
%Updateroutinen f�r alle Klassen (nicht allein abh. vom Construktor)?
%Argumente in der initialisierungsfunktion grunds�tzlich als erweiterbare strukturen, die im ganzen �bergeben werden? (z.B. f�r weitere bedienelemente)
%Implementieren (im zu implementierenden Optionsmen� mit pre sample data): um hostabh�ngige fehler abzufangen: increase datapacksize/ decrease sampling rate
%--> neue appdata struktur: preferences!

%--GLOBAL DATA STRUCTURES; via appdata accessible from every data encapsulation!
%--> H: uicontrol class object handles (to be handled as application data)
%--> APPDAT: Application data

%--USED CUSTOM CLASSES (in the order of invocation)
%--> togglebutton
%--> radiobuttongrp
%--> userinput
%--> gen_signal
%--> guiout
%--> togglecallback

%--CALLBACK FUNCTIONS
%�bergabe der handles d. Quellobjekts?
   %Define close request for 1401 shutdown:
   function closereq(src,evt)
      item = questdlg('Close and shut down power1401?','1401 Shutdown','Yes','No','Yes');
      switch item
         case 'Yes'
            power1401shutdown();
            delete(gcf());
         case 'No'
            return
      end
   end

   %Common callback for the arrowbuttons:
   function BUTTON_arrows(src,evt)
      switch get(src,'Tag')
         case 'UP1'
            in1 = str2double(get(H.edit1,'String')) + 0.5;
            set(H.edit1,'String',num2str(in1));
      
            GUIINPUT.UpdateInput(H.edit1,H.edit2,H.edit3);
         case 'UP2'
            in1 = str2double(get(H.edit2,'String')) + 1;
            set(H.edit2,'String',num2str(in1));
      
            GUIINPUT.UpdateInput(H.edit1,H.edit2,H.edit3);
         case 'DWN1'
            in1 = str2double(get(H.edit1,'String')) - 0.5;
            set(H.edit1,'String',num2str(in1));
      
            GUIINPUT.UpdateInput(H.edit1,H.edit2,H.edit3);
         case 'DWN2'
            in1 = str2double(get(H.edit2,'String')) - 1;
            set(H.edit2,'String',num2str(in1));
      
            GUIINPUT.UpdateInput(H.edit1,H.edit2,H.edit3);
      end
   end
  
   %Intermediate callbacks:
   %(necessary due to definition error using direct function handle callback; seems to be ignored using an intermediate callback)
   function editcall(src,evt)
      GUIINPUT.UpdateInput(H.edit1,H.edit2,H.edit3);
   end

   %temporary callbacks:
   function tempcall(src,evt)
      set(H.main,'CurrentAxes',H.disp1);
      vplot2 = readadc();
      H.plotdata2 = plot(vplot2,'Parent',gca);
      set(gca,'XLim',[0,40000],'YLim',[-5,5]);
   end

%--power1401 STARTUP
power1401startup();

%--Initialize necessary cmds; INSTRUCTIONS ARE APPLIED BY SENDING STRINGS TO 1401; COMMANDS SEE LANGUAGE SUPPORT
MATCED32('cedLdX','C:\power1401Lang\','MEMDAC','ADCMEM'); %Why load these cmds? Aren't they built-in?

%--CREATE GUI
   %Constructor methods of GFX-objects (instances of the uicontrol and figure classes) return handles for reference; all GFX-handles are stored in the "h"-structure
   %Create and hide the GUI as it is being constructed; refer to close request by function handle:
%   H.main = figure('Visible','off','Position',[0,0,625,325]);
   H.main = figure('Visible','off','Position',[0,0,625,325],'CloseRequestFcn',@closereq);
   
      %Generate icons:
      upicon = gen_upicon();
      dwnicon = gen_dwnicon();
      
   %Invoke uicontrol % axes objects & set application data:
   H.disp1 = axes('Units','Pixels','Position',[25,75,450,100],'Parent',H.main,'XLim',[0,40000],'YLim',[-5,5]);
   H.disp2 = axes('Units','Pixels','Position',[25,210,450,100],'Parent',H.main,'XLim',[0,40000],'YLim',[-5,5]);
   H.lbl1 = uicontrol('Style','text','String','Sampled signal:','Position',[50,175,100,15],'BackgroundColor',[0.8,0.8,0.8]);
   H.lbl2 = uicontrol('Style','text','String','Signal design:','Position',[50,310,100,15],'BackgroundColor',[0.8,0.8,0.8]);
   H.edit1 = uicontrol('Style','edit','String','3.0','Position',[525,210,25,25],'BackgroundColor',[1,1,1],'Callback',@editcall); %User input 1; default value
   H.edit2 = uicontrol('Style','edit','String','1','Position',[525,240,25,25],'BackgroundColor',[1,1,1],'Callback',@editcall); %User input 2; default value
   H.edit3 = uicontrol('Style','edit','String','0','Position',[525,180,75,25],'BackgroundColor',[1,1,1],'Callback',@editcall); %User input 3; default value
   H.lbl3 = uicontrol('Style','text','String','AMP:','Position',[500,210,25,15],'FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
   H.lbl4 = uicontrol('Style','text','String','FRQ:','Position',[500,240,25,15],'FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
   H.lbl5 = uicontrol('Style','text','String','V','Position',[550,210,20,15],'FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
   H.lbl6 = uicontrol('Style','text','String','Hz','Position',[550,240,20,15],'FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
   H.lbl7 = uicontrol('Style','text','String','OFF:','Position',[500,180,25,15],'FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
   H.dwnarr1 = uicontrol('Style','pushbutton','CData',dwnicon,'Position',[575,210,25,12],'Tag','DWN1','BackgroundColor',[0.8,0.8,0.8],'Callback',@BUTTON_arrows);
   H.uparr1 = uicontrol('Style','pushbutton','CData',upicon,'Position',[575,223,25,12],'Tag','UP1','BackgroundColor',[0.8,0.8,0.8],'Callback',@BUTTON_arrows);
   H.dwnarr2 = uicontrol('Style','pushbutton','CData',dwnicon,'Position',[575,240,25,12],'Tag','DWN2','BackgroundColor',[0.8,0.8,0.8],'Callback',@BUTTON_arrows);
   H.uparr2 = uicontrol('Style','pushbutton','CData',upicon,'Position',[575,253,25,12],'Tag','UP2','BackgroundColor',[0.8,0.8,0.8],'Callback',@BUTTON_arrows);
   %TEMP BUTTON:
   %H.analyze = uicontrol('Style','pushbutton','String','ANALYZE!','Position',[300,15,75,25],'Callback',@tempcall);
   
   setappdata(H.main,'uihandles',H);
   
   %Invoke GUI class objects:
   TOGGLEBTTN = togglebutton(H.main,[225,15,50,25],'SAMPLE');
   RADIOGRP = radiobuttongrp(H.main,[0.8,0.85,0.16,0.1],'SIN','SIN');
   
   %Rearrange components:
   align([H.lbl3,H.lbl5,H.edit1],'VerticalAlignment','Middle');
   align([H.lbl4,H.lbl6,H.edit2],'VerticalAlignment','Middle');
   align([H.lbl7,H.edit3],'VerticalAlignment','Middle');
   
%--INITIALIZE PROGRAM & GUI
   %set(H.main,'Units','normalized'); %Wichtig f�r Skalierungen; zun�chst weiterhin Pixel (standard) w�nschenswert
   set(H.main,'Name','1401 CONTROLCENTER');
   movegui(H.main,'center');
   %Make the GUI visible:
   set(H.main,'Visible','on')
   
   %Update global data structures:
   H = getappdata(H.main,'uihandles');
   
   %Invoke instances of control classes:
   GUIINPUT = userinput(H.edit1,H.edit2,H.edit3);
   SIGNAL = gen_signal(RADIOGRP,GUIINPUT);
   CALLINOUT = guiout(GUIINPUT,SIGNAL,H.main,H.disp2);
   CALLTOGGLE = togglecallback(TOGGLEBTTN,SIGNAL);
   
%--program run control: return 1 since all done:
r = 1;

end