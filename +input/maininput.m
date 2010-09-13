classdef maininput < input.userinput
   properties
      Parent
   end
   methods
      %Constructor:
      function obj = maininput(fig)
         obj.Parent = fig;
         Hloc = getappdata(obj.Parent,'uihandles');
         
         Hloc.edit1 = uicontrol('Style','edit','String','3.0','Position',[525,210,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 1; default value
         Hloc.edit2 = uicontrol('Style','edit','String','1','Position',[525,240,25,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 2; default value
         Hloc.edit3 = uicontrol('Style','edit','String','0','Position',[525,180,75,25],'BackgroundColor',[1,1,1],'Callback',@(src,evt)UpdateInput(obj,src,evt)); %User input 3; default value
         setappdata(obj.Parent,'uihandles',Hloc);
         
         obj.UserInput.Entry1 = str2double(get(Hloc.edit1,'String'));
         obj.UserInput.Entry2 = str2double(get(Hloc.edit2,'String'));
         obj.UserInput.Entry3 = str2double(get(Hloc.edit3,'String'));
         
         notify(obj,'NewInputAlert'); %probably redundant
      end
      function UpdateInput(obj,src,evt)
         Hloc = getappdata(obj.Parent,'uihandles');
         
         obj.UserInput.Entry1 = str2double(get(Hloc.edit1,'String'));
         obj.UserInput.Entry2 = str2double(get(Hloc.edit2,'String'));
         obj.UserInput.Entry3 = str2double(get(Hloc.edit3,'String'));
         
         notify(obj,'NewInputAlert');
      end
   end
end