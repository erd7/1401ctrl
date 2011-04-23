%Class erzeugt eine Buttongroup aus zwei Radiobuttons; zu implementieren: dynamische Anpassung der Buttonzahl
%ALT: KONZEPT: Klasse als allg REDRAW klasse (selbst superklasse, untergeordnete implementierungsklassen erstellen!)- beerbt maininput
%+Subklasse: Konkrete implementierung erst in der Refreshfunktion in Subklasse!
%Neues Konzept: cmode-subklasse!
classdef redraw_1 < input.mainredraw
   properties
      ContainerPosition
      ButtonString1
      ButtonString2
   end
   methods
      %Constructor: //Use position: [0.8,0.85,0.16,0.1] (testing)
      function obj = redraw_1(hmain,pos,lbl1,lbl2)
         %As superclass constructor requires arguments, call explicitly:
         obj = obj@input.mainredraw(hmain,pos,lbl1,lbl2);
      end
      function redraw(obj,mod)         
         %//Hier variabilität der cases im Argument berücksichtigen und mit schleife cases durchiterieren!
         if mod == 1            
            if isobject(obj.InputObj) == 1
               delete(obj.InputObj);
            end
            
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
            
            obj.InputObj = input.maininput(obj.Parent,iniedit,inilbl,inievt);
            
            obj.InputState = 1;
            notify(obj,'Redraw');
               
%             obj.UpdateInput();
%             notify(obj,'NewInputAlert');
         elseif mod == 2
            if isobject(obj.InputObj) == 1
               delete(obj.InputObj);
            end
            
               iniedit =...
                  {[550,150,25,25;...
                  550,180,25,25;...
                  550,210,25,25],...
                  [2;1.5;10;30]};
               inilbl =...
                  {[500,150,50,15;...
                  500,180,50,15;...
                  500,210,50,15],...
                  {'OFF (V):';'LVL:';'SWEEPS:'}};
               inievt = [1];
            
            obj.InputObj = input.maininput(obj.Parent,iniedit,inilbl,inievt);
               
            obj.InputState = 4;
            notify(obj,'Redraw');
%             obj.UpdateInput();
%             notify(obj,'NewInputAlert');
         end
      end
      %Destructor:
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.radio1);
         delete(Hloc.radio2);
         delete(Hloc.radiogrp);
         Hloc = rmfield(Hloc,'radiogrp');
         Hloc = rmfield(Hloc,'radio1');
         Hloc = rmfield(Hloc,'radio2');
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end