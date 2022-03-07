clc;
clear all;
% close all;
Dataset=1;

decoding=2; % 1=attention size; 2= coherence level
series=4;  % 1:4
baseline=1; %baselined or not (1/0)



if decoding==1
    main_conditions={'attendL','attendR'};
    titles='Attention side';
elseif decoding==2
    main_conditions={'cohHigh','cohLow'};
    titles='Coherence level';
end

Subjects={'01','02','03','04','05','06','07','08','09','10',...
    '11','12','13','14','15','17','18','19',...
    '20','21','22','23','24','26','27','28','29','30',...
    '31','32','34','35','36','37','38','39','40',...
    '41','43','44','45','46','47','48','98','99'};

Windows=[1:53];

if series==1
    array=1:5;
    miny=0.28;
elseif series==2
    array=6:13;
    miny=0.16;
elseif series==3
    array=14:20;
    miny=0.2;
elseif series==4
    array=21:25;
    miny=0.28;
end
    
features=[2:8 9 11 13 18 19 20 27 21:26 32 28:30 34];    
chosen_features=features(array); %


Feat_names={'Mean','Median','Variance','Skewness','Kurtosis','LZ Cmplx','Higuchi FD',...
'Katz FD','Hurst Exp','Apprx Ent','Autocorr','Hjorth Cmp','Hjorth Mob',...
'Signal Pw','Mean Freq','Med Freq','Avg Freq','SEF 95%','Pw MedFrq','Phs MdFrq',...
'Cros Cor','Wavelet','Hilb Amp','Hilb Phs','Samples'};
minx=-175;
maxx=900;
maxy=0.66;

accuracies=nan*ones(35,53,46);
for Subject=1:length(Subjects)
    load(['New_Dec_DS_Claire_',main_conditions{1,1}(1:3),'_Wind_sliding_Subject_',num2str(Subject),'Cmplt_Feats.mat'],'accuracy');
    accuracies(:,:,Subject)=nanmean(accuracy,2);
    if baseline==1
        for feat=chosen_features
            accuracies(feat,:,Subject)=accuracies(feat,:,Subject)-nanmean(accuracies(feat,1:8,Subject),2)+0.5;
        end
    end
end
%% Plotting

figure;
colors={[0 0.8 0.8],[0 0 0],[0.8 0 0],[0 0.8 0],[0.8 0 0.8],[0.8 0.8 0],[0 0 0.8],[0.5 0.5 0.5],[0.6 0.1 0.1]};
times=[-175:20:865]+25;
% times=[-200:5:950]+50;

p=0;
for Feature=chosen_features
    p=p+1;
    plot_line{p}=shadedErrorBar(times,nanmean(squeeze((accuracies(Feature,:,:))),2),nanstd(squeeze((accuracies(Feature,:,:)))')./sqrt(46),{'color',colors{p},'LineWidth',3},1);
%     plot_line(p)=plot(times,smooth(nanmean(accuracies(Feature,:,:),3),5),'Color',colors{p},'linewidth',3);
    hold on;
end

line([minx maxx],[0.5 0.5],'LineWidth',1.5,'Color','k','LineStyle','--');
line([0 0],[miny maxy],'LineWidth',1.5,'Color','k','LineStyle','--');

%% sigfnificance
for feature=1:size(accuracies,1)
    for time=1:size(accuracies,2)
        significance(feature,time)=bf.ttest(squeeze(accuracies(feature,time,:)),squeeze(nanmean(accuracies(feature,1:8,:),2)));
    end
end

% Bayes stats againts chance
for feature=1:size(significance,1)
    Effects=significance;
    for time=1:size(significance,2)
        if Effects(feature,time)>10
            Bayes(feature,time)=2.5;
        elseif Effects(feature,time)>3 && Effects(feature,time)<=10
            Bayes(feature,time)=1.5;
        elseif Effects(feature,time)>1 && Effects(feature,time)<=3
            Bayes(feature,time)=0.5;
        elseif Effects(feature,time)<1 && Effects(feature,time)>=1/3
            Bayes(feature,time)=-0.5;
        elseif Effects(feature,time)<1/3 && Effects(feature,time)>=1/10
            Bayes(feature,time)=-1.5;
        elseif Effects(feature,time)<1/10
            Bayes(feature,time)=-2.5;
        end
    end
end


Baseline=0.47;
steps=0.005;
distans=2; % times step
f=0;
for feature=chosen_features
    f=f+1;
    hold on;
    for windoww=1:size(Bayes,2)
        if Bayes(feature,windoww)==-0.5 || Bayes(feature,windoww)==0.5
            plots(f)=plot(times(windoww),Bayes(feature,windoww).*steps+Baseline-(f-1)*(3*2+distans)*steps,'LineStyle','none','marker','o','Color',colors{f},'linewidth',2,'markersize',4);
        elseif Bayes(feature,windoww)~=0
            plots(f)=plot(times(windoww),Bayes(feature,windoww).*steps+Baseline-(f-1)*(3*2+distans)*steps,'LineStyle','none','marker','o','MarkerFaceColor',colors{f},'Color',colors{f},'linewidth',2,'markersize',4);
        end
    end
    baseline_temp=Baseline-(f-1)*(3*2+distans)*steps;
    line([minx maxx],[baseline_temp baseline_temp],'linestyle','--','Color','k','linewidth',1);
    line([minx maxx],[baseline_temp baseline_temp]-steps,'Color','k','linewidth',1);
    line([minx maxx],[baseline_temp baseline_temp]-2*steps,'Color','k','linewidth',1);
    line([minx maxx],[baseline_temp baseline_temp]-3*steps,'Color','k','linewidth',1);
    line([minx maxx],[baseline_temp baseline_temp]+steps,'Color','k','linewidth',1);
    line([minx maxx],[baseline_temp baseline_temp]+2*steps,'Color','k','linewidth',1);
    line([minx maxx],[baseline_temp baseline_temp]+3*steps,'Color','k','linewidth',1);
end

if series==1
    
    legend([plot_line{1,1}.mainLine,plot_line{1,2}.mainLine,plot_line{1,3}.mainLine,plot_line{1,4}.mainLine,plot_line{1,5}.mainLine],...
        {Feat_names{array(1)},Feat_names{array(2)},Feat_names{array(3)},Feat_names{array(4)},Feat_names{array(5)}},'EdgeColor','w','FontSize',16);

elseif series==2
    legend([plot_line{1,1}.mainLine,plot_line{1,2}.mainLine,plot_line{1,3}.mainLine,plot_line{1,4}.mainLine,plot_line{1,5}.mainLine,plot_line{1,6}.mainLine,plot_line{1,7}.mainLine,plot_line{1,8}.mainLine],...
        {Feat_names{array(1)},Feat_names{array(2)},Feat_names{array(3)},Feat_names{array(4)},Feat_names{array(5)},Feat_names{array(6)},Feat_names{array(7)},Feat_names{array(8)}},'EdgeColor','w','FontSize',12);

elseif series==3
     legend([plot_line{1,1}.mainLine,plot_line{1,2}.mainLine,plot_line{1,3}.mainLine,plot_line{1,4}.mainLine,plot_line{1,5}.mainLine,plot_line{1,6}.mainLine,plot_line{1,7}.mainLine],...
        {Feat_names{array(1)},Feat_names{array(2)},Feat_names{array(3)},Feat_names{array(4)},Feat_names{array(5)},Feat_names{array(6)},Feat_names{array(7)}},'EdgeColor','w','FontSize',14);   

elseif series==4
     legend([plot_line{1,1}.mainLine,plot_line{1,2}.mainLine,plot_line{1,3}.mainLine,plot_line{1,4}.mainLine,plot_line{1,5}.mainLine],...
        {Feat_names{array(1)},Feat_names{array(2)},Feat_names{array(3)},Feat_names{array(4)},Feat_names{array(5)}},'EdgeColor','w','FontSize',16);   
end

ylim([miny maxy])

ylabel('Decoding Accuracy (%)')
box off;

xlabel('Time Relative to Stimulus Onset (ms)')
box off;
set(gca,'FontSize',24,'LineWidth',4,'XTick',...
    [-100 0 100:100:900],'XTickLabel',...
    {'-100','0','100','200','300','400','500','600','700','800','900'},'YTick',...
    [0.5 0.55 0.6 0.65],'YTickLabel',{'50','55','60','65'},'XMinorTick','on');
xtickangle(45);
xlim([minx maxx])
% title(titles)
