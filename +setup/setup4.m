%Class loads the user specified program design to 1401 on GUI request
classdef setup4 < setup.load1401
   properties
      Parent
      SignalObj
      FileObj
      DeviceObj
   end
   methods
      %Constructor:
      function obj = setup4(hmain,src1)
         obj.Parent = hmain;
         PREFS = getappdata(obj.Parent,'preferences');
         obj.SignalObj = src1;
         
         cdat.setobj(hmain,obj,'MODAL');
         
         Hloc = getappdata(obj.Parent,'uihandles');
         Hloc.push = uicontrol('Style','Pushbutton','String','RUN SQ.','Position',[225,25,100,115],'Callback',@(src,evt)RunSetup(obj,src,evt));
         setappdata(obj.Parent,'uihandles',Hloc);
         
         Hloc = getappdata(obj.Parent,'uihandles');
         Hloc.text = uicontrol('Style','text','String','Specify search path for data file:','Position',[350,55,180,15],'HorizontalAlignment','left','BackgroundColor',[.8,.8,.8],'Callback',@(src,evt)RunSetup(obj,src,evt));
         setappdata(obj.Parent,'uihandles',Hloc);
         
         obj.FileObj = cfile(hmain);
         obj.DeviceObj = drive1401.access1401(obj.Parent,obj.SignalObj);
         
         MATCED32('cedLdX',PREFS.langpath,'RUNCMD','VAR','MEMDAC','DIGTIM'); %//Make depend on user input or prog design!
      end
      function RunSetup(obj,src,evt)
         %For this first draft pacemaking will be performed on the local machine (by cogent); consider later 1401 as external, more accurate clock source
         %// Use of cogent graphic probably not necessary!
         %// Überlebensfkt. mit Cumul EW. als Hauptparam.?
         %// Fixation cross as sprite? Faster handling?
         APPDAT = getappdata(obj.Parent,'appdata');
         
%          err = obj.FileObj.setfilepath();
%          
%          if err == -1
%             return;
%          end
         
         %Check for data file:
         if exist([obj.FileObj.DatDir,APPDAT.researcher,'.mat'],'file') == 2
            load([obj.FileObj.DatDir,APPDAT.researcher,'.mat']);
            waitfor(msgbox('Data file found for current researcher and loaded successfully.'));
         else
            choice = questdlg('There was no data file found in the specified directory for the current researcher. Do you want to create it?','No data file found.','Yes','Cancel','Cancel');
            if strcmp(choice,'Yes') == 1
               RES = struct;
               save([obj.FileObj.DatDir,APPDAT.researcher,'.mat'],'RES');
            elseif strcmp(choice,'Cancel') == 1
               return;
            end
         end
         
         hwait = waitbar(0,'Preprocessing stimulus intervals...');
         
         expstr = APPDAT.sesstag;
         subjstr = [APPDAT.subject,'_',datestr(clock(),'yyyymmddTHHMMSS')];
         
         try
            RES.(expstr).(subjstr).RAW.defkey = [0,0]; %Definition of defkey var and creation of structure
         catch
            errordlg('There is at least one session tag invalid; may not contain space characters!');
         end
         
         ntrial = APPDAT.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry4; %PER HEMISPHERE!
         RES.(expstr).(subjstr).RAW.trials = zeros(1,2*ntrial); %Array for calculated ITIs
         RES.(expstr).(subjstr).RAW.onset = zeros(1,2*ntrial); %Array for achieved onset times up from start_cogent
         RES.(expstr).(subjstr).RAW.actiti = zeros(1,2*ntrial); %Array for achieved ITIs
         ticks = APPDAT.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry3;
         ticklength = APPDAT.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry2;
         startprob = APPDAT.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry1;
         
%          prob1 = startprob*sin([pi/2:pi/(ticks*2-1):pi]);
%          prob2 = abs(startprob*sin([pi:pi/(ticks*2-1):(3/2)*pi]));
         
         prob1 = (-startprob*[0:1/(ticks-1):1])+startprob;
         prob2 = startprob*[0:1/(ticks-1):1];
         
         %Balanced and randomized flags to determine whether hazard rate begins from left or right:
         cueflags = -1*ones(1,length(RES.(expstr).(subjstr).RAW.trials)/2);
         cueflags = [cueflags,ones(1,length(RES.(expstr).(subjstr).RAW.trials)/2)];
         z = randperm(length(cueflags));
         cueflags = cueflags(z); %Random order of trial flags: 1 will be RIGHT, -1 will be LEFT
         RES.(expstr).(subjstr).RAW.cueflags = cueflags;
         
         RES.(expstr).(subjstr).RAW.altflags = zeros(1,2*ntrial);
         
         %Precalculate stimulus offsets: %//BETR.: Calculating hazard results in "derivation" within subject's perception? Therefore present just dicing, which would be perceived as hazard rate!
         for i=1:length(RES.(expstr).(subjstr).RAW.trials)
            dice = [0,0];
            
            while isequal(dice,[1,1]) == 1 || isequal(dice,[0,0]) == 1
               pick = randi(ticks);
               
               dice(1) = cdat.chance(prob1(pick),100);
               dice(2) = cdat.chance(prob2(pick),100);
            end
            
            RES.(expstr).(subjstr).RAW.trials(i) = ticklength*pick;
            
            if dice == [1,0]
               RES.(expstr).(subjstr).RAW.altflags(i) = 1; %TRUE AT THE FLAGGED SIDE
            elseif dice == [0,1]
               RES.(expstr).(subjstr).RAW.altflags(i) = -1; %FALSE AT THE FLAGGED SIDE
            end
            
            %NOTA: Bedingungen (s.a.u.) können auch in eine zweigeteilte if-else-Bedingung zusammengeführt werden, die intuitive Lesbarkeit des Programms wird dadurch jedoch entscheidend erschwert
            
            waitbar(i/length(RES.(expstr).(subjstr).RAW.trials),hwait);
         end
         
         delete(hwait);
         
         %LOAD DIGTIM BUFFER HERE! Loading without delay (single pulse), pulse itself is fired with a small lag of 2ms (minimal prepulse time of first digtim slice)
         obj.DeviceObj.loadtrig1401([],5);
         
         %NOTE: Keyboard logging seems to be corrupt with synchronous use of cogent2000 & cogent graphics! Try cogent2000 only!         
         config_display(1,2,[0,0,0],[1,1,1],'Arial',50,16,0,0);
         % cgloadlib;
         %config_log([APPDAT.sesstag,'_',APPDAT.subject,'_',datestr(clock(),'yyyymmddTHHMMSS'),'.log']);
         %config_results([APPDAT.sesstag,'_',APPDAT.subject,'_',datestr(clock(),'yyyymmddTHHMMSS'),'.res']);
         config_keyboard(100,5,'nonexclusive');
         % cgopen(1,0,0,1);
         
         start_cogent; %//Escape routine is not save yet!
         %Launch experiment with synchronisation click for a common time scale; start_cogent defines t0!
         MATCED32('cedSendString','DIGTIM,C,10,100;');
         
         preparestring('+',1,0,0);
         preparestring('+',2,0,0);
         preparestring('+',3,0,0);
         settextstyle('Arial',300);
         setforecolour(1,0,0);
         preparestring('•',2,-220,0);
         preparestring('•',3,220,0);
         settextstyle('Arial',30);
         setforecolour(1,1,1);
         preparestring('SEQUENCE STARTS IN',4,0,50);
         preparestring('SEQUENCE STARTS IN',5,0,50);
         preparestring('SEQUENCE STARTS IN',6,0,50);
         settextstyle('Arial',80);
         preparestring('3',4,0,-50);
         preparestring('2',5,0,-50);
         preparestring('1',6,0,-50);
         settextstyle('Arial',30);
         preparestring('PREPARE PREACTIVATION!',7,0,50);
         preparestring('PREPARE PREACTIVATION!',8,0,50);
         preparestring('PREPARE PREACTIVATION!',9,0,50);
         preparestring('PREPARE PREACTIVATION!',10,0,50);
         preparestring('PREPARE PREACTIVATION!',11,0,50);
         settextstyle('Arial',80);
         preparestring('5',7,0,-50);
         preparestring('4',8,0,-50);
         preparestring('3',9,0,-50);
         preparestring('2',10,0,-50);
         preparestring('1',11,0,-50);
         settextstyle('Arial',300);
         setforecolour(1,0,0);
         preparestring('<<',12,0,0);
         preparestring('>>',13,0,0);
         settextstyle('Arial',30);
         setforecolour(1,1,1);
         preparestring('Define key for LEFT response.',14,0,0);
         preparestring('Define key for RIGHT response.',15,0,0);
         preparestring('Waiting for both keys to be pressed...',16,0,0);
         
         %Define keys:
         for i=1:2
            drawpict(13+i);
            waitkeydown(inf);
            RES.(expstr).(subjstr).RAW.defkey(i) = lastkeydown;
         end
         
         %Preparative countdown
         drawpict(4);
         wait(1000);
         drawpict(5);
         wait(1000);
         drawpict(6);
         wait(1000);
         
         anykey = [0,0];
         
         clearkeys;
         
         for i=1:length(RES.(expstr).(subjstr).RAW.trials) %Trial loop
            %Preactivation guiding routine:
            while isequal(ismember(anykey,RES.(expstr).(subjstr).RAW.defkey),[1,1]) ~= 1
               drawpict(16);
               
               while isequal(ismember(anykey,RES.(expstr).(subjstr).RAW.defkey),[1,1]) ~= 1
                  readkeys;
                  key = getkeyup;
                  if any(ismember(key,anykey)) == 1
                     anykey(find(ismember(anykey,key))) = 0;
                  end
                  
                  try
                     if ismember(anykey(1),RES.(expstr).(subjstr).RAW.defkey) ~= 1
                        anykey(1) = lastkeydown;
                     elseif ismember(anykey(2),RES.(expstr).(subjstr).RAW.defkey) ~= 1
                        anykey(2) = lastkeydown;
                     end
                  catch
                     continue;
                  end
               end
               
               clear key;
               tprep = time;
               
               for j=1:5
                  drawpict(6+j);
                  waituntil(tprep+j*1000);
                  readkeys;
                  key = getkeyup;
                  if any(ismember(key,anykey)) == 1
                     anykey(find(ismember(anykey,key))) = 0;
                     break;
                  end
               end
               clear key;
            end
            
%             drawpict(1);
            
            %//Probed hemisphere indicator:
            if cueflags(i) == -1 %CUE LEFT
               drawpict(12);
            elseif cueflags(i) == 1 %CUE RIGHT
               drawpict(13);
            end
            
            tind = time;
            waituntil(tind+1000);
            
            %Set intermediate escape point:
            readkeys;          
            esc = getkeydown;
            if ismember(52,esc) == 1
               stop_cogent;
               break;
            end
            
            clear key esc;
            
            clearkeys; %Blind interval follows.
            
            %Drawing fixation cross marks begin of trial:
            MATCED32('cedSendString','DIGTIM,C,10,100;'); %//Launch before, because of 2ms lag which may be cancelled out with loading lag of new screen
            drawpict(1);
            
            t0 = time;
            waituntil(t0+RES.(expstr).(subjstr).RAW.trials(i));
            
            MATCED32('cedSendString','DIGTIM,C,10,100;');
            if cueflags(i) == -1  && RES.(expstr).(subjstr).RAW.altflags(i) == 1 %TRUE LEFT --> LEFT (cue)
               drawpict(2);
            elseif cueflags(i) == 1 && RES.(expstr).(subjstr).RAW.altflags(i) == 1 %TRUE RIGHT --> RIGHT (cue)
               drawpict(3);
            elseif cueflags(i) == -1 && RES.(expstr).(subjstr).RAW.altflags(i) == -1 %FALSE LEFT --> RIGHT (cue)
               drawpict(3);
            elseif cueflags(i) == 1 && RES.(expstr).(subjstr).RAW.altflags(i) == -1 %FALSE RIGHT --> LEFT (cue)
               drawpict(2);
            end
            
            RES.(expstr).(subjstr).RAW.onset(i) = time;
            %logstring(RES.(expstr).(subjstr).RAW.onset(i));
            RES.(expstr).(subjstr).RAW.actiti(i) = RES.(expstr).(subjstr).RAW.onset(i) - t0;
            
            waituntil(RES.(expstr).(subjstr).RAW.onset(i)+1000); %1s for reactions is granted
            readkeys;
            
            [key,t,n] = getkeyup;
            
            if cueflags(i) == -1  && RES.(expstr).(subjstr).RAW.altflags(i) == 1 %TRUE LEFT --> LEFT (cue)
               if n ~= 1 || any(ismember(key,RES.(expstr).(subjstr).RAW.defkey(1))) ~= 1 %no appropriate key press
                  response = nan;
                  rt = nan;
               elseif n == 1 && isequal(key,RES.(expstr).(subjstr).RAW.defkey(1)) == 1 %single approproate key press
                  response = key(1);
                  rt = t(1) - RES.(expstr).(subjstr).RAW.onset(i);
                  %logkeys;
               end
            elseif cueflags(i) == 1 && RES.(expstr).(subjstr).RAW.altflags(i) == 1 %TRUE RIGHT --> RIGHT (cue)
               if n ~= 1 || any(ismember(key,RES.(expstr).(subjstr).RAW.defkey(2))) ~= 1 %no appropriate key press
                  response = nan;
                  rt = nan;
               elseif n == 1 && isequal(key,RES.(expstr).(subjstr).RAW.defkey(2)) == 1 %single approproate key press
                  response = key(1);
                  rt = t(1) - RES.(expstr).(subjstr).RAW.onset(i);
                  %logkeys;
               end
            elseif cueflags(i) == -1 && RES.(expstr).(subjstr).RAW.altflags(i) == -1 %FALSE LEFT --> RIGHT (cue)
               if n ~= 1 || any(ismember(key,RES.(expstr).(subjstr).RAW.defkey(2))) ~= 1 %no appropriate key press
                  response = nan;
                  rt = nan;
               elseif n == 1 && isequal(key,RES.(expstr).(subjstr).RAW.defkey(2)) == 1 %single approproate key press
                  response = key(1);
                  rt = t(1) - RES.(expstr).(subjstr).RAW.onset(i);
                  %logkeys;
               end
            elseif cueflags(i) == 1 && RES.(expstr).(subjstr).RAW.altflags(i) == -1 %FALSE RIGHT --> LEFT (cue)
               if n ~= 1 || any(ismember(key,RES.(expstr).(subjstr).RAW.defkey(1))) ~= 1 %no appropriate key press
                  response = nan;
                  rt = nan;
               elseif n == 1 && isequal(key,RES.(expstr).(subjstr).RAW.defkey(1)) == 1 %single approproate key press
                  response = key(1);
                  rt = t(1) - RES.(expstr).(subjstr).RAW.onset(i);
                  %logkeys;
               end
            end
            
            %Refresh button press status:
            if any(ismember(key,anykey)) == 1
               anykey(find(ismember(anykey,key))) = 0;
            end
            
            %Add the stimulus, reaction time and key press to the results file.
            %addresults(response,rt);
            RES.(expstr).(subjstr).RAW.key(i) = response;
            RES.(expstr).(subjstr).RAW.rt(i) = rt;
            
            drawpict(1);
            tpause = time;
            waituntil(tpause+2000);
            
            %Perform esc at iteration end if required:
            if ismember(52,key) == 1
               stop_cogent;
               break;
            end
         end
         
         %cgshut;
         stop_cogent;
         
         try
            %//Simple processing of reaction times:
            RES.(expstr).(subjstr).PROC.trueleft = [];
            RES.(expstr).(subjstr).PROC.falseleft = [];
            RES.(expstr).(subjstr).PROC.trueright = [];
            RES.(expstr).(subjstr).PROC.falseright = [];
            
%             for i=1:length(RES.(expstr).(subjstr).RAW.trials)
%                if isequal(RES.(expstr).(subjstr).RAW.cueflags(i),-1) == 1 && le(RES.(expstr).(subjstr).RAW.trials(i)/((ticklength*ticks)-ticklength),1) == 1 %TRUE LEFT
%                   RES.(expstr).(subjstr).PROC.trueleft = [RES.(expstr).(subjstr).PROC.trueleft,RES.(expstr).(subjstr).RAW.rt(i)];
%                elseif isequal(RES.(expstr).(subjstr).RAW.cueflags(i),-1) == 1 && gt(RES.(expstr).(subjstr).RAW.trials(i)/((ticklength*ticks)-ticklength),1) == 1 %FALSE LEFT
%                   RES.(expstr).(subjstr).PROC.falseleft = [RES.(expstr).(subjstr).PROC.falseleft,RES.(expstr).(subjstr).RAW.rt(i)];
%                elseif isequal(RES.(expstr).(subjstr).RAW.cueflags(i),1) == 1 && le(RES.(expstr).(subjstr).RAW.trials(i)/((ticklength*ticks)-ticklength),1) == 1 %TRUE RIGHT
%                   RES.(expstr).(subjstr).PROC.trueright = [RES.(expstr).(subjstr).PROC.trueright,RES.(expstr).(subjstr).RAW.rt(i)];
%                elseif isequal(RES.(expstr).(subjstr).RAW.cueflags(i),1) == 1 && gt(RES.(expstr).(subjstr).RAW.trials(i)/((ticklength*ticks)-ticklength),1) == 1 %FALSE RIGHT
%                   RES.(expstr).(subjstr).PROC.falseright = [RES.(expstr).(subjstr).PROC.falseright,RES.(expstr).(subjstr).RAW.rt(i)];
%                end
%             end

            %Group results according to cond:
            for i=1:length(RES.(expstr).(subjstr).RAW.trials)
               if cueflags(i) == -1  && RES.(expstr).(subjstr).RAW.altflags(i) == 1 %TRUE LEFT --> LEFT (cue)
                  RES.(expstr).(subjstr).PROC.trueleft = [RES.(expstr).(subjstr).PROC.trueleft,RES.(expstr).(subjstr).RAW.rt(i)];
               elseif cueflags(i) == 1 && RES.(expstr).(subjstr).RAW.altflags(i) == 1 %TRUE RIGHT --> RIGHT (cue)
                  RES.(expstr).(subjstr).PROC.trueright = [RES.(expstr).(subjstr).PROC.trueright,RES.(expstr).(subjstr).RAW.rt(i)];
               elseif cueflags(i) == -1 && RES.(expstr).(subjstr).RAW.altflags(i) == -1 %FALSE LEFT --> RIGHT (cue)
                  RES.(expstr).(subjstr).PROC.falseleft = [RES.(expstr).(subjstr).PROC.falseleft,RES.(expstr).(subjstr).RAW.rt(i)];
               elseif cueflags(i) == 1 && RES.(expstr).(subjstr).RAW.altflags(i) == -1 %FALSE RIGHT --> LEFT (cue)
                  RES.(expstr).(subjstr).PROC.falseright = [RES.(expstr).(subjstr).PROC.falseright,RES.(expstr).(subjstr).RAW.rt(i)];
               end
            end
            
            RES.(expstr).(subjstr).PROC.trueleftratio = length(RES.(expstr).(subjstr).PROC.trueleft) / length(RES.(expstr).(subjstr).RAW.trials);
            RES.(expstr).(subjstr).PROC.falseleftratio = length(RES.(expstr).(subjstr).PROC.falseleft) / length(RES.(expstr).(subjstr).RAW.trials);
            RES.(expstr).(subjstr).PROC.truerightratio = length(RES.(expstr).(subjstr).PROC.trueright) / length(RES.(expstr).(subjstr).RAW.trials);
            RES.(expstr).(subjstr).PROC.falserightratio = length(RES.(expstr).(subjstr).PROC.falseright) / length(RES.(expstr).(subjstr).RAW.trials);
            
            RES.(expstr).(subjstr).PROC.mrt_trueleft = nanmean(RES.(expstr).(subjstr).PROC.trueleft);
            RES.(expstr).(subjstr).PROC.mrt_falseleft = nanmean(RES.(expstr).(subjstr).PROC.falseleft);
            RES.(expstr).(subjstr).PROC.mrt_trueright = nanmean(RES.(expstr).(subjstr).PROC.trueright);
            RES.(expstr).(subjstr).PROC.mrt_falseright = nanmean(RES.(expstr).(subjstr).PROC.falseright);
            
            save([obj.FileObj.DatDir,APPDAT.researcher,'.mat'],'RES');
         catch
            errordlg('No postprocessing possible: Sequence terminated on user request.');
         end
      end
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.push);
         delete(Hloc.text);
         Hloc = rmfield(Hloc,{'push','text'});
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end