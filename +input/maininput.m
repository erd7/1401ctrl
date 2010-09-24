%Implementation of main GUI input class as userinput subclass
classdef maininput < input.userinput
   properties
      Parent
      ListeningTo
      Hloc %am besten herausnehmen und nur �ber appdata zugreifen!
      InputState = 1;
   end
   methods
      %Constructor:
      function obj = maininput(h,src1)
         obj.Parent = h.main;
         obj.ListeningTo = src1;
         obj.Hloc = getappdata(obj.Parent,'uihandles');
         
         obj.Hloc.edit1 = uicontrol('Style','edit','String','3.0','Position',[550,210,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         obj.Hloc.edit2 = uicontrol('Style','edit','String','1','Position',[550,240,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 2; default value
         obj.Hloc.edit3 = uicontrol('Style','edit','String','0','Position',[550,180,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 3; default value
         obj.Hloc.lbl1 = uicontrol('Style','text','String','AMP (V):','Position',[500,210,50,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         obj.Hloc.lbl2 = uicontrol('Style','text','String','FRQ (Hz):','Position',[500,240,50,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         obj.Hloc.lbl3 = uicontrol('Style','text','String','OFF:','Position',[500,180,25,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
         setappdata(obj.Parent,'uihandles',obj.Hloc);
         
         %Rearrange graphic components:
         align([obj.Hloc.lbl1,obj.Hloc.edit1],'VerticalAlignment','Middle');
         align([obj.Hloc.lbl2,obj.Hloc.edit2],'VerticalAlignment','Middle');
         align([obj.Hloc.lbl3,obj.Hloc.edit3],'VerticalAlignment','Middle');
         
         obj.UserInput.Entry1 = str2double(get(obj.Hloc.edit1,'String'));
         obj.UserInput.Entry2 = str2double(get(obj.Hloc.edit2,'String'));
         obj.UserInput.Entry3 = str2double(get(obj.Hloc.edit3,'String'));
         
         notify(obj,'NewInputAlert'); %probably redundant
         
         addlistener(obj.ListeningTo,'SelRadio1',@(src,evt)RefreshGUI(obj,src,evt,1));
         addlistener(obj.ListeningTo,'SelRadio2',@(src,evt)RefreshGUI(obj,src,evt,2));
      end
      function RefreshGUI(obj,src,evt,mod)
         if mod == 1
            if isfield(obj.Hloc,{'edit','lbl'}) == 1
               obj.Hloc = getappdata(obj.Parent,'uihandles');
               tmp = [obj.Hloc.edit,obj.Hloc.lbl];
               obj.Hloc = rmfield(obj.Hloc,{'edit','lbl'});
               setappdata(obj.Parent,'uihandles',obj.Hloc);
               delete(tmp); %Handles erst hinterher bearbeiten und updaten?
               
               obj.Hloc.edit1 = uicontrol('Style','edit','String','3.0','Position',[550,210,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
               obj.Hloc.edit2 = uicontrol('Style','edit','String','1','Position',[550,240,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 2; default value
               obj.Hloc.edit3 = uicontrol('Style','edit','String','0','Position',[550,180,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 3; default value
               obj.Hloc.lbl1 = uicontrol('Style','text','String','AMP (V):','Position',[500,210,50,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
               obj.Hloc.lbl2 = uicontrol('Style','text','String','FRQ (Hz):','Position',[500,240,50,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
               obj.Hloc.lbl3 = uicontrol('Style','text','String','OFF:','Position',[500,180,25,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
               setappdata(obj.Parent,'uihandles',obj.Hloc);
         
               %Rearrange graphic components:
               align([obj.Hloc.lbl1,obj.Hloc.edit1],'VerticalAlignment','Middle');
               align([obj.Hloc.lbl2,obj.Hloc.edit2],'VerticalAlignment','Middle');
               align([obj.Hloc.lbl3,obj.Hloc.edit3],'VerticalAlignment','Middle');
               
               obj.InputState = 1;
               obj.UpdateInput();
               notify(obj,'NewInputAlert');
            end
         elseif mod == 2
            if isfield(obj.Hloc,{'edit1','edit2','edit3','lbl1','lbl2','lbl3'}) == 1
               obj.Hloc = getappdata(obj.Parent,'uihandles');
               tmp = [obj.Hloc.edit1,obj.Hloc.edit2,obj.Hloc.edit3,obj.Hloc.lbl1,obj.Hloc.lbl2,obj.Hloc.lbl3];
               obj.Hloc = rmfield(obj.Hloc,{'edit1','edit2','edit3','lbl1','lbl2','lbl3'});
               setappdata(obj.Parent,'uihandles',obj.Hloc);
               delete(tmp);
               
               obj.Hloc.edit = uicontrol('Style','edit','String','1','Position',[550,240,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt));
               obj.Hloc.lbl = uicontrol('Style','text','String','VOLT (V):','Position',[500,240,50,15],'HorizontalAlignment','left','FontName','Arial','FontSize',8,'BackgroundColor',[0.8,0.8,0.8]);
               setappdata(obj.Parent,'uihandles',obj.Hloc);
               
               %Rearrange graphic components:
               align([obj.Hloc.lbl,obj.Hloc.edit],'VerticalAlignment','Middle');
               
               obj.InputState = 2;
               obj.UpdateInput();
               notify(obj,'NewInputAlert');
            end
         end
      end
      function UpdateInput(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         if isfield(obj.Hloc,{'edit1','edit2','edit3','lbl1','lbl2','lbl3'}) == 1
            obj.UserInput.Entry1 = str2double(get(Hloc.edit1,'String'));
            obj.UserInput.Entry2 = str2double(get(Hloc.edit2,'String'));
            obj.UserInput.Entry3 = str2double(get(Hloc.edit3,'String'));
         elseif isfield(obj.Hloc,{'edit','lbl'}) == 1
            obj.UserInput.Entry1 = str2double(get(Hloc.edit,'String'));
         end
         
         notify(obj,'NewInputAlert');
      end
      %Destructor:
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.edit1);
         delete(Hloc.edit2);
         delete(Hloc.edit3);
         delete(Hloc.lbl1);
         delete(Hloc.lbl2);
         delete(Hloc.lbl3);
         Hloc = rmfield(Hloc,{'edit1','edit2','edit3'});
         Hloc = rmfield(Hloc,{'lbl1','lbl2','lbl3'});
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end