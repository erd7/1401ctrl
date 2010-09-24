function r = e_1401DAC()
%power1401 ANALOGUE OUTPUT
%ERDCONTROL main program:
%Construction routines & initialization
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
%Erzeugerklasse f�r arrowbuttons! Super- und subklasse? s.a. Sliderm�glichkeit!
%Alle uihandles als appdata oder nur interaktionsobjekte?
%zentrale verarbeitungsroutinen (interface classes); trennen von output classes?
%Interaktionsdiagramm f�r Objekte auf allen ebenen entwickeln --> Programmlogik!
%PRINZIP: Handle struct stets vollst�ndig �bergeben- aus entwicklungstechnischen gr�nden (z.B. f�r debugging) zus�tzlich handle appdate mitf�hren!
%PRINZIP: APPDATA NIEMALS INNERHALB EINER �BERGEORDNETEN ROUTINE UPDATEN, NACHDEM IN SUBROUTINEN GEUPDATET WURDE!
%nota: nicht unkritisch variablen globalisieren, indem sie als object property deklariert werden!

%--GLOBAL DATA STRUCTURES; via appdata accessible from every data encapsulation!
%--> H: Stores uicontrol class object handles (to be handled as application data)
%--> APPDAT: Application data; default values
%--> PREFS: Preferences; default values
APPDAT = struct(...
   'Researcher','Default Researcher',...
   'Subject','Unnamed');

PREFS = struct(...
   'langpath','C:\power1401Lang\',...
   'chout',0);

%--power1401 STARTUP
power1401startup();

%--DEFINITION OF CALLBACK FUNCTIONS
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

   %Common callback for the arrowbuttons: //Implement within inputclass! //Implement as slider?
   %function BUTTON_arrows(src,evt)
   %   H = getappdata(H.main,'uihandles');
   %   switch get(src,'Tag')
   %      case 'UP1'
   %         in1 = str2double(get(H.edit1,'String')) + 0.5;
   %         set(H.edit1,'String',num2str(in1));
   %   
   %         MAININPUT.UpdateInput();
   %      case 'UP2'
   %         in1 = str2double(get(H.edit2,'String')) + 1;
   %         set(H.edit2,'String',num2str(in1));
   %   
   %         MAININPUT.UpdateInput();
   %      case 'DWN1'
   %         in1 = str2double(get(H.edit1,'String')) - 0.5;
   %         set(H.edit1,'String',num2str(in1));
   %   
   %         MAININPUT.UpdateInput();
   %      case 'DWN2'
   %         in1 = str2double(get(H.edit2,'String')) - 1;
   %         set(H.edit2,'String',num2str(in1));
   %   
   %         MAININPUT.UpdateInput();
   %   end
   %end
  
   %Intermediate callbacks:
   %(necessary due to definition error using direct function handle callback; seems to be ignored using an intermediate callback)
   function prefcall(src,evt)
      PREFGUI = prefgui(H.main);
   end

%--INITIALIZATION PROCEDURE
   %Constructor methods of GFX-objects (instances of the uicontrol/ -menu and figure classes) return handles for reference; all GFX-handles are stored in the "H"-structure   
   %Create main GUI:
   H.main = figure('Visible','off','Position',[0,0,675,325],'MenuBar','none');
   %H.main = figure('Visible','off','Position',[0,0,625,325],'MenuBar','none','CloseRequestFcn',@closereq);
   H.medit = uimenu(H.main,'Label','Edit');
   H.mprefs = uimenu(H.medit,'Label','Preferences','Callback',@prefcall);
   
   %Set application data:
   setappdata(H.main,'uihandles',H);
   setappdata(H.main,'appdata',APPDAT);
   setappdata(H.main,'preferences',PREFS);
   
   %Invoke main working mode switch class object:
   PRGMODE = mode(H);
   
   %Update global data structures from application data:
   H = getappdata(H.main,'uihandles');
   
   %Rearrange components & properties: //local
   %set(H.main,'Units','normalized'); %Wichtig f�r Skalierungen; zun�chst weiterhin Pixel (standard) w�nschenswert
   set(H.main,'Name','1401 CONTROLCENTER');
   movegui(H.main,'center');
   set(H.main,'Visible','on');
   
%--program run control: return 1 since all done:
r = 1;

end