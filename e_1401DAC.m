function r = e_1401DAC()
%power1401 ANALOGUE OUTPUT
%ERDCONTROL main program & GUI file
%(Construction routines & initialization)
%RBP (e), Bln2010

%TODO: entry (amp) max. 5volts/ min -5volts; mit offset vereinbaren! Graphen X-Achse von 0-1s skalieren (bei weiterhin 40k^-1 schrittweite)!
%FRQ: Nach unten gegen 0, nach oben gegen unendlich (Max value?)
%stets: Redundanzen verringern --> kommunizierende Objekte abkapseln!
%PARADIGMA: output stets erst am Ende einer Verarbeitungskette benachrichtigen, sobald intern alles berechnet ist!
%globale Datenstruktur für experimentelles Datenmaterial; Steuerdaten weiterhin objektorientiert handhaben
%DAC output als eigene klasse von togglecallback trennen? bisher nicht sinnvoll!
%grundsätzlich die gesamte headerklasse/struktur übergeben?
%Updateroutinen für alle Klassen (nicht allein abh. vom Construktor)?
%Argumente in der initialisierungsfunktion grundsätzlich als erweiterbare strukturen, die im ganzen übergeben werden? (z.B. für weitere bedienelemente)
%Implementieren (im zu implementierenden Optionsmenü mit pre sample data): um hostabhängige fehler abzufangen: increase datapacksize/ decrease sampling rate
%--> neue appdata struktur: preferences!
%Erzeugerklasse für arrowbuttons! Super- und subklasse? s.a. Slidermöglichkeit!
%Alle uihandles als appdata oder nur interaktionsobjekte?
%zentrale verarbeitungsroutinen (interface classes); trennen von output classes?
%Interaktionsdiagramm für Objekte auf allen ebenen entwickeln --> Programmlogik!

%--GLOBAL DATA STRUCTURES; via appdata accessible from every data encapsulation!
%--> H: uicontrol class object handles (to be handled as application data)
%--> APPDAT: Application data
%--> PREFS: Preferences; default values
PREFS = struct(...
   'langpath','C:\power1401Lang\',...
   'chout',0);

%--USED CUSTOM CLASSES (in the order of invocation)
%--> togglebutton
%--> radiobuttongrp
%--> userinput
%--> gen_signal
%--> guiout
%--> togglecallback

%--DEFINITION OF CALLBACK FUNCTIONS
%Übergabe der handles d. Quellobjekts?
   %Redefine std. closereq for 1401 shutdown:
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
      H = getappdata(H.main,'uihandles');
      switch get(src,'Tag')
         case 'UP1'
            in1 = str2double(get(H.edit1,'String')) + 0.5;
            set(H.edit1,'String',num2str(in1));
      
            MAININPUT.UpdateInput();
         case 'UP2'
            in1 = str2double(get(H.edit2,'String')) + 1;
            set(H.edit2,'String',num2str(in1));
      
            MAININPUT.UpdateInput();
         case 'DWN1'
            in1 = str2double(get(H.edit1,'String')) - 0.5;
            set(H.edit1,'String',num2str(in1));
      
            MAININPUT.UpdateInput();
         case 'DWN2'
            in1 = str2double(get(H.edit2,'String')) - 1;
            set(H.edit2,'String',num2str(in1));
      
            MAININPUT.UpdateInput();
      end
   end
  
   %Intermediate callbacks:
   %(necessary due to definition error using direct function handle callback; seems to be ignored using an intermediate callback)
   function editcall(src,evt)
      MAININPUT.UpdateInput(H.edit1,H.edit2,H.edit3);
   end

   function prefcall(src,evt)
      PREFGUI = prefgui(H.main);
   end

%--INITIALIZATION PROCEDURE
   %Constructor methods of GFX-objects (instances of the uicontrol and figure classes) return handles for reference; all GFX-handles are stored in the "H"-structure   
   %Create main GUI:
   H.main = figure('Visible','off','Position',[0,0,675,325],'MenuBar','none');
   %H.main = figure('Visible','off','Position',[0,0,625,325],'MenuBar','none','CloseRequestFcn',@closereq);
   H.medit = uimenu(H.main,'Label','Edit');
   H.mprefs = uimenu(H.medit,'Label','Preferences','Callback',@prefcall);
   
      %Generate icons:
      upicon = gen_upicon();
      dwnicon = gen_dwnicon();
      
   %Invoke uicontrol % axes objects & set application data:
   H.disp1 = axes('Units','Pixels','Position',[25,75,450,100],'Parent',H.main,'XLim',[0,40000],'YLim',[-5,5]);
   H.disp2 = axes('Units','Pixels','Position',[25,210,450,100],'Parent',H.main,'XLim',[0,40000],'YLim',[-5,5]);
   H.lbl1 = uicontrol('Style','text','String','Sampled signal:','Position',[50,175,100,15],'BackgroundColor',[0.8,0.8,0.8]);
   H.lbl2 = uicontrol('Style','text','String','Signal design:','Position',[50,310,100,15],'BackgroundColor',[0.8,0.8,0.8]);
   %H.dwnarr1 = uicontrol('Style','pushbutton','CData',dwnicon,'Position',[575,210,25,12],'Tag','DWN1','BackgroundColor',[0.8,0.8,0.8],'Callback',@BUTTON_arrows);
   %H.uparr1 = uicontrol('Style','pushbutton','CData',upicon,'Position',[575,222,25,12],'Tag','UP1','BackgroundColor',[0.8,0.8,0.8],'Callback',@BUTTON_arrows);
   %H.dwnarr2 = uicontrol('Style','pushbutton','CData',dwnicon,'Position',[575,240,25,12],'Tag','DWN2','BackgroundColor',[0.8,0.8,0.8],'Callback',@BUTTON_arrows);
   %H.uparr2 = uicontrol('Style','pushbutton','CData',upicon,'Position',[575,252,25,12],'Tag','UP2','BackgroundColor',[0.8,0.8,0.8],'Callback',@BUTTON_arrows);
   
   %Set application data:
   setappdata(H.main,'uihandles',H);
   setappdata(H.main,'preferences',PREFS);
   
   %Invoke GUI class objects:
   TOGGLEBTTN = togglebutton(H,[225,15,50,25],'SAMPLE');
   RADIOGRP = radiobuttongrp(H,[0.738,0.85,0.16,0.1],'SIN','CC');
   MAININPUT = input.maininput(H,RADIOGRP);
   
   %Update from application data:
   H = getappdata(H.main,'uihandles');
   
   %Rearrange components: //local
   
%--power1401 STARTUP
power1401startup();
   
   %--INITIALIZE PROGRAM & GUI
   %set(H.main,'Units','normalized'); %Wichtig für Skalierungen; zunächst weiterhin Pixel (standard) wünschenswert
   set(H.main,'Name','1401 CONTROLCENTER');
   movegui(H.main,'center');
   %Make the GUI visible:
   set(H.main,'Visible','on');
   
   %Update global data structures:
   H = getappdata(H.main,'uihandles');
   
   %Invoke instances of control classes:
   %GUIINPUT = userinput(H.edit1,H.edit2,H.edit3);
   SIGNAL = gen_signal(MAININPUT);
   CALLINOUT = guiout(SIGNAL,H.main,H.disp2);
   CALLTOGGLE = togglecallback(H.main,TOGGLEBTTN,SIGNAL);
   
%--program run control: return 1 since all done:
r = 1;

end