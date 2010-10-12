function r = e_1401ctrl()
%power1401 ANALOGUE AND DIG. TRIGGER OUTPUT
%CONTROL CENTER main program:
%Construction routines & initialization
%RBP (e), Bln2010

%NOTE: RND GENS ARE INITIALIZED WITH INCREMENT UP FROM MATLAB START PER DEFAULT!!1
%NEUES ANSTEUERUNGSPRINZIP: Erst Programm designen, dann als 1401interne RUNCMD sq übermitteln! --> programm endlich; endlosschleife anfragen!
%--> PROGRAMMKONZEPT AUFSTELLEN!
%Gemeinsame interface klasse für 1401 ansteuerungsklassen (toggle gemeinsam etc.)
%übergeordnete sammelklasse, die immer mitübergeben wird und die hauptdatenstrukturen updatet!
%anstelle von obj.Parent gcf oder ähnliches! .. eigene übergeordnete statische methode?
%anpassbar designen: RUNCMD vorerst unterlassen, programmschreiben via MATLAB --> Signalupdate möglich! (RUNCMD nur um die eingabe von 1401 testprogrammen zu erleichtern)
%TODO: entry (amp) max. 5volts/ min -5volts; mit offset vereinbaren! Graphen X-Achse von 0-1s skalieren (bei weiterhin 40k^-1 schrittweite)!
%FRQ: Nach unten gegen 0, nach oben gegen unendlich (Max value?)
%stets: Redundanzen verringern --> kommunizierende Objekte abkapseln!
%PARADIGMA: output stets erst am Ende einer Verarbeitungskette benachrichtigen, sobald intern alles berechnet ist!
%globale Datenstruktur für experimentelles Datenmaterial; Steuerdaten weiterhin objektorientiert handhaben
%DAC output als eigene klasse von togglecallback trennen? bisher nicht sinnvoll!
%grundsätzlich die gesamte headerklasse/struktur übergeben? JA!
%Updateroutinen für alle Klassen (nicht allein abh. vom Construktor)?
%Argumente in der initialisierungsfunktion grundsätzlich als erweiterbare strukturen, die im ganzen übergeben werden? (z.B. für weitere bedienelemente) --> s. a. variable Argumente!
%Implementieren (im zu implementierenden Optionsmenü mit pre sample data): um hostabhängige fehler abzufangen: increase datapacksize/ decrease sampling rate
%--> neue appdata struktur: preferences!
%Erzeugerklasse für arrowbuttons! Super- und subklasse? s.a. Slidermöglichkeit!
%Alle uihandles als appdata oder nur interaktionsobjekte?
%zentrale verarbeitungsroutinen (interface classes); trennen von output classes?
%Interaktionsdiagramm für Objekte auf allen ebenen entwickeln --> Programmlogik!
%PRINZIP: Handle struct stets vollständig übergeben- aus entwicklungstechnischen gründen (z.B. für debugging) zusätzlich handle appdate mitführen!
%PRINZIP: APPDATA NIEMALS INNERHALB EINER ÜBERGEORDNETEN ROUTINE UPDATEN, NACHDEM IN SUBROUTINEN GEUPDATET WURDE!
% --> stets auf individuelle gfx obj handlevars achten!
%nota: nicht unkritisch variablen globalisieren, indem sie als object property deklariert werden!
%--> noch unstimmigkeit im main closerq!
%--> ERSTELLE GRUNDSÄTZLICH WIEDERVERWENDBARE IMPLEMENTIERUNGSKLASSEN; ENTSPRECHENDE OBERKLASSEN --> VERW. IN SUBKLASSEN AUCH OBERKLASSEN KONSTRUKTOREN UND VARIABLES ARGUMENT!
%--> Toggleclasse mit internem callback konzipieren: interface klasse mit gemeinsamkeiten; sub für die jew. implementierung --> toggle als privates gui element! --> dennoch toggleevent, um andere objekte für vermutliche änderungen im betriebsmodus zu benachrichtigen!
%--> nicht togglecallbacks, sondern funktionsbezogen!

%--GLOBAL DATA STRUCTURES; via appdata accessible from every data encapsulation!
%--> H: Stores uicontrol class object handles (to be handled as application data)
%--> APPDAT: Application data; default values
%--> PREFS: Preferences; default values
APPDAT = struct(...
   'researcher','Default Researcher',...
   'subject','Unnamed');
APPDAT.CURRENTOBJ.dummy = 0;
APPDAT.CURRENTOBJ = rmfield(APPDAT.CURRENTOBJ,'dummy');

PREFS = struct(...
   'langpath','C:\1401Lang\',...
   'chout',0,...
   'mepdelay',30);

%--power1401 STARTUP
power1401startup; %//Make depend on former calls; implement at other point!

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

   %Intermediate callbacks:
   %(necessary due to definition error using direct function handle callback; seems to be ignored using an intermediate callback)
   function prefcall(src,evt)
      PREFGUI = prefgui(H);
   end

   function sesscall(src,evt)
      SESSGUI = sessgui(H);
   end

%--INITIALIZATION PROCEDURE
   %Constructor methods of GFX-objects (instances of the uicontrol/ -menu and figure classes) return handles for reference; all GFX-handles are stored in the "H"-structure   
   %Create main GUI:
   %H.main = figure('Visible','off','Position',[0,0,675,325],'Name','1401 CONTROLCENTER','MenuBar','none');
   H.main = figure('Visible','off','Position',[0,0,675,325],'Name','1401 CONTROLCENTER','MenuBar','none','CloseRequestFcn',@closereq);
   H.mfile = uimenu(H.main,'Label','File');
   H.msess = uimenu(H.mfile,'Label','Session','Callback',@sesscall);
   %H.msubj = uimenu(H.mfile,'Label','Subject');
   H.medit = uimenu(H.main,'Label','Edit');
   H.mprefs = uimenu(H.medit,'Label','Preferences','Callback',@prefcall);
   
   %Set application data (necessary after every data update invocation):
   setappdata(H.main,'uihandles',H);
   setappdata(H.main,'appdata',APPDAT);
   setappdata(H.main,'preferences',PREFS);
   
   %Invoke main working mode switch class object:
   PRGMODE = cmode(H);
   
   %Update global data structures from application data:
   H = getappdata(H.main,'uihandles');
   
   %Rearrange components & properties: //local
   %set(H.main,'Units','normalized'); %Wichtig für Skalierungen; zunächst weiterhin Pixel (standard) wünschenswert
   movegui(H.main,'center');
   set(H.main,'Visible','on');
   
%--program run control: return 1 since all done:
r = 1;

end