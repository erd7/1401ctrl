%Implementation of main GUI input class as userinput subclass
%Code reusable due to initialization arguments
%Also include IniData struct into redraw?
%//Event for input locking here!
classdef maininput < input.userinput
   properties
      ListeningTo
      InputState
   end
   methods
      %Constructor:
      function obj = maininput(hmain,pedit,plbl,pevt)
         %As superclass constructor requires arguments, call explicitly:
         obj = obj@input.userinput(hmain);
         
         obj.InputState = pevt(1);
         obj.IniData = struct('pedit',{pedit},'plbl',{plbl},'pevt',{pevt});
         H = getappdata(obj.Parent,'uihandles');
         
%          for i=1:length(pinput{1}(:,1))
%             posedit(i,1:4) = [ppanel(3)-pinput{1}(i,1)-5,ppanel(4)-sum(pinput{1}(1,2):pinput{1}(i,2))-5,pinput{1}(i,1),pinput{1}(i,2)];
%             poslbl(i,1:4) = [5,ppanel(4)-sum(pinput{1}(1,2):pinput{1}(i,2))-5,ppanel(3)-pinput{1}(i,1),15];
%          end

         posdata = [min(min([pedit{1}(:,1),plbl{1}(:,1)]))-10,min(min([pedit{1}(:,2),plbl{1}(:,2)]))-10,max([sum([pedit{1}(:,1),pedit{1}(:,3)]'),sum([plbl{1}(:,1),plbl{1}(:,3)]')])+10,max([sum([pedit{1}(:,2),pedit{1}(:,4)]'),sum([plbl{1}(:,2),plbl{1}(:,4)]')])+10];
         posdata(3:4) = [posdata(3)-posdata(1),posdata(4)-posdata(2)];
         
         %Group GUI components in panel:
         strpan = cdat.uistr(hmain,obj,'panel');
         H.(strpan) = uipanel('BorderType','etchedin','BackgroundColor',[.8,.8,.8],'Units','pixels','Position',posdata,'Parent',obj.Parent);
         setappdata(obj.Parent,'uihandles',H);
         
         %Invoke graphical interface objects:
         for i=1:length(pedit{1}(:,1))
            stredit = cdat.uistr(hmain,obj,'edit');
            strEntry = ['Entry',num2str(i)];
         
            H.(stredit) = uicontrol('Style','edit','String',pedit{2}(i,:),'Position',[pedit{1}(i,1)-posdata(1),pedit{1}(i,2)-posdata(2),pedit{1}(i,3:4)],'BackgroundColor',[1,1,1],'Parent',H.(strpan),'Callback',@(src,evt)UpdateInput(obj,src,evt));
            setappdata(obj.Parent,'uihandles',H);
            
            obj.UserInput.(strEntry) = str2double(get(H.(stredit),'String'));
         end
         
         for i=1:length(plbl{1}(:,1))
            strlbl = cdat.uistr(hmain,obj,'lbl');
            
            H.(strlbl) = uicontrol('Style','text','String',plbl{2}(i,:),'Position',[plbl{1}(i,1)-posdata(1),plbl{1}(i,2)-posdata(2),plbl{1}(i,3:4)],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8],'Parent',H.(strpan));
            setappdata(obj.Parent,'uihandles',H);
         end
         
         %Rearrange GUI components:
%          H = getappdata(obj.Parent,'uihandles');
%          for i=1:length(pedit{1}(:,1))
%             stredit = [cdat.classname(obj),'_','edit',num2str(i)];
%             strlbl = [cdat.classname(obj),'_','lbl',num2str(i)];
%             
%             align([H.(strlbl),H.(stredit)],'VerticalAlignment','Middle');
%          end
         
         notify(obj,'NewInputAlert');
      end
      function UpdateInput(obj,src,evt)
         H = getappdata(obj.Parent,'uihandles');
         
         m = 0;
         fn = fieldnames(H);
         
         %Get number of input fields:
         for i=1:length(fn)         
            if isempty(strfind(fn{i},cdat.classname(obj))) == 0 && isempty(strfind(fn{i},'edit')) == 0 %//Currently constrained to once and only the very first
               m = m+1;
            end
         end
         
         %Update all input fields:
         for i=1:m
            stredit = [cdat.classname(obj),'_','edit',num2str(i)];
            strEntry = ['Entry',num2str(i)];
            
            obj.UserInput.(strEntry) = str2double(get(H.(stredit),'String'));
         end
         
         notify(obj,'NewInputAlert');
      end
   end
end