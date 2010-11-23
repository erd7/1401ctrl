%ANALYSIS- SCRIPT FOR EXPERIMENT: "tRNS: U-shaped"
clear all;

xlsfile = 'D:\PROGWORKS\MATLAB\1401ctrl\analyze\DATA_MRRBP_tRNSUshape.xls';
lvls = 10;
subjs = {'Maria','Rouven','Robert'};

for i=1:length(subjs)   
   DAT.emgraw = xlsread(xlsfile,i,'b6:d125');
   DAT.lvlraw = xlsread(xlsfile,i,'j6:j125');
     
   %Zunächst nur FDI!
   for j=1:lvls
      m = 1;
      lvlstr = ['lvl',num2str(j)];
      for k=1:length(DAT.emgraw(:,2))
         if DAT.lvlraw(k) == j
         DAT.(subjs{i}).(lvlstr)(m) = DAT.emgraw(k,2);
         m = m+1;
         end
      end
   end
end
DAT = rmfield(DAT,'emgraw');
DAT = rmfield(DAT,'lvlraw');

%Gruppendaten: //s. "grouped" prop für bar für kontrollfinger!
fn = fieldnames(DAT);

for i=1:lvls
   lvlstr = ['lvl',num2str(i)];
   
   for j=1:length(subjs)
      DAT.GROUP.dataset((j-1)*length(DAT.(fn{j}).(lvlstr))+1:j*length(DAT.(fn{j}).(lvlstr)),i) = DAT.(fn{j}).(lvlstr);
   end
   
   DAT.GROUP.(lvlstr).mean = mean(DAT.GROUP.dataset(:,i));
   DAT.GROUP.(lvlstr).std = std(DAT.GROUP.dataset(:,i));
   DAT.GROUP.(lvlstr).err = std(DAT.GROUP.dataset(:,i))/sqrt(length(DAT.GROUP.dataset(:,i)));
end

figure('Name','SR mit tRNS in M1','Position',[0,0,800,600],'Color',[1,1,1]);

bar(mean(DAT.GROUP.dataset),'FaceColor',[1,0.5,0.5],'LineWidth',3); hold on;
errorbar(mean(DAT.GROUP.dataset),std(DAT.GROUP.dataset)/sqrt(length(DAT.GROUP.dataset)),['x','k']); %s. Konfidenzintervall

for i=1:(lvls-1) %//IMPLEMENT: BAR COLOR TO DEPEND ON H-VALUE
   [h,p] = ttest(DAT.GROUP.dataset(:,i),DAT.GROUP.dataset(:,i+1));
   text(i+1,mean(DAT.GROUP.dataset(:,i+1))+std(DAT.GROUP.dataset(:,i+1))/sqrt(length(DAT.GROUP.dataset(:,i+1))),['*p = ' num2str(p)]); %y test position at the upper end of the error bar
end
%set(gca,'XTickLabel',{'...'});
%title(['FDI vs cFDI; t = ' num2str(h)]); ylabel('mean MEPs');
title('tRNS: GROUP'); ylabel('mean MEPs/µV');