%Class loads the user specified program design to 1401 on GUI request
classdef setup4 < setup.load1401
   properties
      Parent
      SignalObj
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
         
         MATCED32('cedLdX',PREFS.langpath,'RUNCMD','VAR','MEMDAC','DIGTIM'); %//Make depend on user input or prog design!
      end
      function RunSetup(obj,src,evt)
         %For this first draft pacemaking will be performed on the local machine (by cogent); consider later 1401 as external, more accurate clock source
         %// Use of cogent graphic probably not necessary!
         %// Überlebensfkt. mit Cumul EW. als Hauptparam.?
         %// Find optimal machine refresh rate automatically; s. DOC. p.34; Use for automatic calculation of time scale/ time unit in frames! //RELEVANT?
         %// Fixation cross as sprite? Faster handling?
         %// Use OFFHAZARD with 100ticks, 50 tickres & 2% prob!
         APPDAT = getappdata(obj.Parent,'appdata');
         hwait = waitbar(0,'Preprocessing stimulus intervals...');
         
         expstr = [APPDAT.subject,'_',datestr(clock(),'yyyymmddTHHMMSS')];
         RES.(expstr).RAW.defkey = [0,0];
         
         ntrial = APPDAT.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry4; %PER HEMISPHERE!
         RES.(expstr).RAW.trials = zeros(1,2*ntrial); %Array for calculated ITIs
         RES.(expstr).RAW.onset = zeros(1,2*ntrial); %Array for achieved onset times up from start_cogent
         RES.(expstr).RAW.actiti = zeros(1,2*ntrial); %Array for achieved ITIs
         ticks = APPDAT.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry3;
         ticklength = APPDAT.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry2;
         startprob = APPDAT.CURRENTOBJ.MODAL.maininput_1.UserInput.Entry1;
         
%          prob1 = startprob*sin([pi/2:pi/(ticks*2-1):pi]);
%          prob2 = abs(startprob*sin([pi:pi/(ticks*2-1):(3/2)*pi]));
         
         prob1 = (-startprob*[0:1/(ticks-1):1])+startprob;
         prob2 = startprob*[0:1/(ticks-1):1];
         
         flags = -1*ones(1,length(RES.(expstr).RAW.trials)/2);
         flags = [flags,ones(1,length(RES.(expstr).RAW.trials)/2)];
         z = randperm(length(flags));
         flags = flags(z); %Random order of trial flags: 1 will be RIGHT, -1 will be LEFT
         RES.(expstr).RAW.flags = flags;
         
         %Precalculate stimulus offsets using offhazard:
         for i=1:length(RES.(expstr).RAW.trials)
            RES.(expstr).RAW.trials(i) = cdat.offhazard(prob1,ticklength);
            
            if RES.(expstr).RAW.trials(i)/((ticklength*ticks)-ticklength) == 1 %//HAZARDFKT ÜBERDENKEN?! (Abschluss mit 5000 im konkreten Fall?)
               RES.(expstr).RAW.trials(i) = RES.(expstr).RAW.trials(i) + cdat.offhazard(prob2,ticklength);
            end
            
            waitbar(i/length(RES.(expstr).RAW.trials),hwait);
         end
         
         delete(hwait);
         
         %LOAD DIGTIM BUFFER HERE! Loading without delay, pulse itself is fired with a small lag of 2ms (minimal prepulse time of first digtim slice)
         MATCED32('cedSendString','CLEAR;');
         MATCED32('cedSendString',['DIGTIM,SI,',num2str(2^22),',',num2str(2*16*1),';']);
         MATCED32('cedSendString','DIGTIM,A,1,1,2;');
         MATCED32('cedSendString','DIGTIM,A,1,0,2;');
         
         %NOTE: Keyboard logging seems to be corrupt with synchronous use of cogent2000 & cogent graphics! Try cogent2000 only!         
         config_display(1,2,[0,0,0],[1,1,1],'Arial',50,16,0,0);
         %config_display(0);
         % cgloadlib;
         config_log([APPDAT.subject,'_',datestr(clock(),'yyyymmddTHHMMSS'),'.log']);
         config_results([APPDAT.subject,'_',datestr(clock(),'yyyymmddTHHMMSS'),'.res']);
         config_keyboard(100,5,'nonexclusive');
         % cgopen(1,0,0,1);
         % cgscale; %//Implement view angles?
         
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
            RES.(expstr).RAW.defkey(i) = lastkeydown;
         end
         
%          for i=1:2 %//Was wollte ich hiermit an dieser Stelle bezwecken?
%             checkkey = [];
%             drawpict(13+i);
%             while RES.(expstr).RAW.defkey(i) == 0
%                %clearkeys;
%                %readkeys;
%                
%                if isempty(checkkey) == 1
%                   checkkey = lastkeydown;
%                else
%                   RES.(expstr).RAW.defkey(i) = checkkey;
%                end
%             end
%          end
         
         %Preparative countdown
         drawpict(4);
         wait(1000);
         drawpict(5);
         wait(1000);
         drawpict(6);
         wait(1000);
         
         for i=1:length(RES.(expstr).RAW.trials)
            %Draw fixation cross:
%             cgpenwid(6);
%             cgpencol([.8,.8,.8]);
%             cgdraw(0,40,0,-40);
%             cgdraw(-40,0,40,0);
%             cgflip([0,0,0]);

            readkeys;
            esc = getkeydown;
            if ismember(52,esc) == 1
               stop_cogent;
               break;
            end

            anykey = [0,0];
            
            drawpict(16);
            
            while isequal(ismember(anykey,RES.(expstr).RAW.defkey),[1,1]) ~= 1
               if ismember(anykey(1),RES.(expstr).RAW.defkey) ~= 1
                  anykey(1) = waitkeydown(inf);
               elseif ismember(anykey(2),RES.(expstr).RAW.defkey) ~= 1
                  anykey(2) = waitkeydown(inf);
               end
            end
            
            tprep = time;
            drawpict(7);
            waituntil(tprep+1000);
            drawpict(8);
            waituntil(tprep+2000);
            drawpict(9);
            waituntil(tprep+3000);
            drawpict(10);
            waituntil(tprep+4000);
            drawpict(11);
            waituntil(tprep+5000);
            
%             drawpict(1);
            
               %//Probed hemisphere indicator:
               if flags(i) == -1
                  drawpict(12);
               elseif flags(i) == 1
                  drawpict(13);
               end
               
               tind = time;
               waituntil(tind+1000);
               
               drawpict(1);
            
            if RES.(expstr).RAW.trials(i)/((ticklength*ticks)-ticklength) <= 1
               
%                %//Probed hemisphere indicator:
%                if flags(i) == -1
%                   drawpict(12);
%                elseif flags(i) == 1
%                   drawpict(13);
%                end
%                
%                tind = time;
%                waituntil(tind+1000);
%                
%                drawpict(1);
               
               t0 = time;
               waituntil(t0+RES.(expstr).RAW.trials(i));
               %cgpencol([1,.4,.4]);
               %cgellipse(-200,0,100,100,'f');
               %cgflip([0,0,0]);
               
               if flags(i) == -1
                  drawpict(2);
               elseif flags(i) == 1
                  drawpict(3);
               end

               RES.(expstr).RAW.onset(i) = time; 
               logstring(RES.(expstr).RAW.onset(i));
               RES.(expstr).RAW.actiti(i) = RES.(expstr).RAW.onset(i) - t0;
               
               clearkeys;
               waituntil(RES.(expstr).RAW.onset(i)+1000);
               readkeys; %Read all key events
               
               esc = getkeydown;
               if ismember(52,esc) == 1
                  stop_cogent;
                  break;
               end
               
               if flags(i) == -1
                  [key,t,n] = getkeyup;
                  if n == 0 || isequal(key,RES.(expstr).RAW.defkey(1)) ~= 1 %no key press
                     response = nan;
                     rt = nan;
                  elseif n == 1 && isequal(key,RES.(expstr).RAW.defkey(1)) == 1 %single key press
                     response = key(1);
                     rt = t(1) - RES.(expstr).RAW.onset(i);
                     logkeys;
                  else
                     response = nan; %multiple or false key press
                     rt = nan;
                  end
               elseif flags(i) == 1
                  [key,t,n] = getkeyup;
                  if n == 0 || isequal(key,RES.(expstr).RAW.defkey(2)) ~= 1 %no key press
                     response = nan;
                     rt = nan;
                  elseif n == 1 && isequal(key,RES.(expstr).RAW.defkey(2)) == 1 %single key press
                     response = key(1);
                     rt = t(1) - RES.(expstr).RAW.onset(i);
                     logkeys;
                  else
                     response = nan; %multiple or false key press
                     rt = nan;
                  end
               end
            elseif RES.(expstr).RAW.trials(i)/((ticklength*ticks)-ticklength) > 1
               
%                %//Probed hemisphere indicator:
%                if flags(i) == -1
%                   drawpict(12);
%                elseif flags(i) == 1
%                   drawpict(13);
%                end
%                
%                tind = time;
%                waituntil(tind+1000);
%                
%                drawpict(1);
               
               t0 = time;
               waituntil(t0+RES.(expstr).RAW.trials(i));
               %cgpencol([1,.4,.4]);
               %cgellipse(200,0,100,100,'f');
               %cgflip([0,0,0]);
               
               if flags(i) == -1
                  drawpict(3);
               elseif flags(i) == 1
                  drawpict(2);
               end
               
               RES.(expstr).RAW.onset(i) = time; 
               logstring(RES.(expstr).RAW.onset(i));
               RES.(expstr).RAW.actiti(i) = RES.(expstr).RAW.onset(i) - t0;
               
               clearkeys;
               waituntil(RES.(expstr).RAW.onset(i)+1000);
               readkeys;
               
               esc = getkeydown;
               if ismember(52,esc) == 1
                  stop_cogent;
                  break;
               end
               
               if flags(i) == -1
                  [key,t,n] = getkeyup;
                  if n == 0 || isequal(key,RES.(expstr).RAW.defkey(2)) ~= 1 %no key press
                     response = nan;
                     rt = nan;
                  elseif n == 1 && isequal(key,RES.(expstr).RAW.defkey(2)) == 1 %single key press
                     response = key(1);
                     rt = t(1) - RES.(expstr).RAW.onset(i);
                     logkeys;
                  else
                     response = nan; %multiple or false key press
                     rt = nan;
                  end
               elseif flags(i) == 1
                  [key,t,n] = getkeyup;
                  if n == 0 || isequal(key,RES.(expstr).RAW.defkey(1)) ~= 1 %no key press
                     response = nan;
                     rt = nan;
                  elseif n == 1 && isequal(key,RES.(expstr).RAW.defkey(1)) == 1 %single key press
                     response = key(1);
                     rt = t(1) - RES.(expstr).RAW.onset(i);
                     logkeys;
                  else
                     response = nan; %multiple or false key press
                     rt = nan;
                  end
               end
            end
            
            %Add the stimulus, reaction time and key press to the results file.
            addresults(response,rt);
            RES.(expstr).RAW.key(i) = response;
            RES.(expstr).RAW.rt(i) = rt;
            
            drawpict(1);
            tpause = time;
            waituntil(tpause+2000);
         end
         
         %cgshut;
         stop_cogent;
         
         try
            %//Simple processing of reaction times:
            RES.(expstr).PROC.trueleft = [];
            RES.(expstr).PROC.falseleft = [];
            RES.(expstr).PROC.trueright = [];
            RES.(expstr).PROC.falseright = [];
            
            for i=1:length(RES.(expstr).RAW.trials)
               if isequal(RES.(expstr).RAW.flags(i),-1) == 1 && le(RES.(expstr).RAW.trials(i)/((ticklength*ticks)-ticklength),1) == 1 %TRUE LEFT
                  RES.(expstr).PROC.trueleft = [RES.(expstr).PROC.trueleft,RES.(expstr).RAW.rt(i)];
               elseif isequal(RES.(expstr).RAW.flags(i),-1) == 1 && gt(RES.(expstr).RAW.trials(i)/((ticklength*ticks)-ticklength),1) == 1 %FALSE LEFT
                  RES.(expstr).PROC.falseleft = [RES.(expstr).PROC.falseleft,RES.(expstr).RAW.rt(i)];
               elseif isequal(RES.(expstr).RAW.flags(i),1) == 1 && le(RES.(expstr).RAW.trials(i)/((ticklength*ticks)-ticklength),1) == 1 %TRUE RIGHT
                  RES.(expstr).PROC.trueright = [RES.(expstr).PROC.trueright,RES.(expstr).RAW.rt(i)];
               elseif isequal(RES.(expstr).RAW.flags(i),1) == 1 && gt(RES.(expstr).RAW.trials(i)/((ticklength*ticks)-ticklength),1) == 1 %FALSE RIGHT
                  RES.(expstr).PROC.falseright = [RES.(expstr).PROC.falseright,RES.(expstr).RAW.rt(i)];
               end
            end
            
            RES.(expstr).PROC.trueleftratio = length(RES.(expstr).PROC.trueleft) / length(RES.(expstr).RAW.trials);
            RES.(expstr).PROC.falseleftratio = length(RES.(expstr).PROC.falseleft) / length(RES.(expstr).RAW.trials);
            RES.(expstr).PROC.truerightratio = length(RES.(expstr).PROC.trueright) / length(RES.(expstr).RAW.trials);
            RES.(expstr).PROC.falserightratio = length(RES.(expstr).PROC.falseright) / length(RES.(expstr).RAW.trials);
            
            RES.(expstr).PROC.mrt_trueleft = nanmean(RES.(expstr).PROC.trueleft);
            RES.(expstr).PROC.mrt_falseleft = nanmean(RES.(expstr).PROC.falseleft);
            RES.(expstr).PROC.mrt_trueright = nanmean(RES.(expstr).PROC.trueright);
            RES.(expstr).PROC.mrt_falseright = nanmean(RES.(expstr).PROC.falseright);
            
            save([APPDAT.researcher,'.mat'],'RES');
         catch
            errordlg('No postprocessing possible: Sequence terminated on user request.');
         end
         
%          for i=1:RES.(expstr).RAW.trials
%             
%             %Draw fixation cross:
%             cgpenwid(10);
%             cgpencol([.8,.8,.8]);
%             cgdraw(0,40,0,-40);
%             cgdraw(-40,0,40,0);
%             cgflip([0,0,0]);
%             
%             haz1 = cdat.onhazard(prob1,ticklength); %//More elegant soluation: hazard calls listener!
%             
%             %preparestring('+',2);
%             %drawpict(2);
%             
%             if haz1 == 1
%                %Keep fixation cross by redrawing it on the offscreen area together with the 'left' stimulus:
%                cgpenwid(10);
%                cgpencol([.8,.8,.8]);
%                cgdraw(0,40,0,-40);
%                cgdraw(-40,0,40,0);
%                
%                cgpencol([1,.4,.4]);
%                cgellipse(-200,0,100,100,'f');
%                cgflip([0,0,0]);
%                
%                t0 = time;
%                logstring(t0);
%                clearkeys;
%                readkeys;
%                logkeys;
%                
%                %Check key press and calculate the reaction time
%                [ key, t, n ] = getkeydown;
%                if n == 0 % no key press
%                   response = 0;
%                   rt = 0;
%                elseif n == 1 % single key press
%                   response = key(1);
%                   rt = t(1) - t0;
%                else
%                   response = 0; % multiple key press
%                   rt = 0;
%                end
%                
%                addresults(response,rt);
%             elseif haz1 == 0
%                haz2 = cdat.onhazard(prob2,ticklength);
%                
%                %             if haz2 == 0 %//Reassingnment is redundant since waiting happens anyway
%                %                haz2 = 1;
%                %             end
%                
%                cgpenwid(10);
%                cgpencol([.8,.8,.8]);
%                cgdraw(0,40,0,-40);
%                cgdraw(-40,0,40,0);
%                
%                cgpencol([1,.4,.4]);
%                cgellipse(200,0,100,100,'f');
%                cgflip([0,0,0]);
%                
%                               t0 = time;
%                logstring(t0);
%                clearkeys;
%                readkeys;
%                logkeys;
%                
%                %Check key press and calculate the reaction time
%                [ key, t, n ] = getkeydown;
%                if n == 0 % no key press
%                   response = 0;
%                   rt = 0;
%                elseif n == 1 % single key press
%                   response = key(1);
%                   rt = t(1) - t0;
%                else
%                   response = 0; % multiple key press
%                   rt = 0;
%                end
%                
%                addresults(response,rt);
%             end
%             pause(1);
%          end
%          
%          cgshut;
%          stop_cogent;
      end
      function delete(obj)
         Hloc = getappdata(obj.Parent,'uihandles');
         delete(Hloc.push);
         Hloc = rmfield(Hloc,'push');
         setappdata(obj.Parent,'uihandles',Hloc);
      end
   end
end