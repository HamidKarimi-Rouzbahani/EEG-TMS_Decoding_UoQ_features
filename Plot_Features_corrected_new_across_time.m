%% single features

clc;
clear all;
% close all;
Bands={'Broad','Delta','Theta','Alpha','Betta','Gamma'};
band=1;
Subject=1;
coh=1;
baseline=1;

mydataset=1;

windows=-200:999;
step_size=20;
window_span=50;
windoww=[1:53];
wind=nanmean([windows((windoww-1)*step_size+1);(windoww-1)*step_size+window_span]);

if mydataset==1
    load(['Corrected_Dec_DS_Mine_Band_',Bands{band},'_Wind_sliding_Subject_',num2str(Subject),'.mat'],'accuracy');
        Accuracy=squeeze(nanmean(accuracy,2));
else
    if coh==1
        load(['Corrected_Dec_DS_Claire_Coh_Band_',Bands{band},'_Wind_sliding_Subject_',num2str(Subject),'.mat'],'accuracy');
    else
        load(['Corrected_Dec_DS_Claire_Att_Band_',Bands{band},'_Wind_sliding_Subject_',num2str(Subject),'.mat'],'accuracy');
    end    
    if baseline==1
        Accuracy=squeeze(accuracy(:,1,:))-repmat(nanmean(accuracy(:,1,1:4),3),[1 53])+0.5;
    else
        Accuracy=squeeze(accuracy);
    end
end
    
colors={'r','g','b','c','m',['-',[0.5 0.5 0.5]],'k','-*r','-*g','-*b','-*c','-*m',['-*',[0.5 0.5 0.5]],'-*k','--r','--g','--b','--c','--m',['--',[0.5 0.5 0.5]],'--k'};
figure;
line([-75 965],[0.5 0.5],'color','k','linewidth',1)
line([0 0],[0 1],'color','k','linewidth',1)
hold on;
j=0;
for i=[2:9 11 13 18:27]
    j=j+1;
    plots(j)=plot(wind,smooth(Accuracy(i,:),5),colors{j},'lineWidth',4);
    hold on;
end

legend ([plots(1),plots(2),plots(3),plots(4),plots(5),plots(6),plots(7),plots(8),plots(9),plots(10),plots(11),...
    plots(12),plots(13),plots(14),plots(15),plots(16),plots(17),plots(18),plots(19),plots(20)],...
    {'Mean','Median','Variance','Skewness','Kurtosis','LZ','Higuchi FD',...
    'Katz FD','Hurts','SamEntropy','ApprEntrop','Autocor','HjorthComp','HjorthMob',...
    'MeanFreq','MedFreq','SEF','PowMedFrq','PhasMedFrq','Power'});

xlim([-75 965])
ylim([0.45 0.75])
xlabel('Time relative to stimulus onset (ms)')
ylabel('Decoding accuracy')
set(gca,'fontsize',30)
