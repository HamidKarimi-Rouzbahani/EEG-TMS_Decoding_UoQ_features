clc;
clear all;
% close all;
decoding=2; % 1=attention size; 2= coherence level
baseline=0; %baselined or not (1/0)

Maximum_or_Mean=0; % max=1; mean=0



Dataset=1;
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


array=1:25;
features=[2:8 9 11 13 18 19 20 27 21:26 32 28:30 34];
chosen_features=features(array); %
Feat_names={'Mean','Median','Variance','Skewness','Kurtosis','LZ Cmplx','Higuchi FD',...
    'Katz FD','Hurst Exp','Apprx Ent','Autocorr','Hjorth Cmp','Hjorth Mob',...
    'Signal Pw','Mean Freq','Med Freq','Avg Freq','SEF 95%','Pw MedFrq','Phs MdFrq',...
    'Cros Cor','Wavelet','Hilb Amp','Hilb Phs','Samples'};

%% Significance
colors={[0 0.8 0.8],[0 0 0],[0.8 0 0],[0 0.8 0],[0.8 0 0.8],[0.8 0.8 0],[0 0 0.8],[0.5 0.5 0.5]};
gca = axes('Position',[0.13 0.131 0.775 0.2]);
xtic=[1:5 7:14 16:22 24:28];

    accuracies=nan*ones(35,53,length(Subjects));
    for Subject=[1:length(Subjects)]
        load(['New_Dec_DS_Claire_',main_conditions{1,1}(1:3),'_Wind_sliding_Subject_',num2str(Subject),'Cmplt_Feats.mat'],'accuracy');
        accuracies(:,:,Subject)=nanmean(accuracy,2);
        if baseline==1
            for feat=chosen_features
                accuracies(feat,:,Subject)=accuracies(feat,:,Subject)-nanmean(accuracies(feat,1:8,Subject),2)+0.5;
            end
        end
    end
    
    f=0;
    for feat=features
        f=f+1;
        if Maximum_or_Mean==1
            significance(1,f)=bf.ttest(nanmax(squeeze(accuracies(feat,9:end,:)))',nanmean(squeeze(accuracies(feat,1:8,:)))');
        else
            significance(Dataset,f)=bf.ttest(nanmean(squeeze(accuracies(feat,9:end,:)))',nanmean(squeeze(accuracies(feat,1:8,:)))');
        end
    end

% Bayes stats againts chance
for Dataset=1:length(features)
    Effects=significance';
    for e=1:size(Effects,2)
        if Effects(Dataset,e)>10
            Bayes(Dataset,e)=2.5;
        elseif Effects(Dataset,e)>3 && Effects(Dataset,e)<=10
            Bayes(Dataset,e)=1.5;
        elseif Effects(Dataset,e)>1 && Effects(Dataset,e)<=3
            Bayes(Dataset,e)=0.5;
        elseif Effects(Dataset,e)<1 && Effects(Dataset,e)>=1/3
            Bayes(Dataset,e)=-0.5;
        elseif Effects(Dataset,e)<1/3 && Effects(Dataset,e)>=1/10
            Bayes(Dataset,e)=-1.5;
        elseif Effects(Dataset,e)<1/10
            Bayes(Dataset,e)=-2.5;
        end
    end
end
for Dataset=1:length(xtic)
    line([xtic(Dataset) xtic(Dataset)],[0.39 0.43],'Color','k','linestyle',':','linewidth',1);
    hold on;
end

Baseline=0.45;
steps=0.005;
distans=1.5; % times step
for Dataset=1:size(Bayes,2)
    for f=1:size(Bayes,1)
        hold on;
        if Bayes(f,Dataset)==-0.5 || Bayes(f,Dataset)==0.5
            plots(Dataset)=plot(xtic(f),Bayes(f,Dataset).*steps+Baseline-(3*2+distans)*steps,'LineStyle','none','marker','o','Color',colors{9-Dataset},'linewidth',2,'markersize',7);
        elseif Bayes(Dataset,Dataset)~=0
            plots(Dataset)=plot(xtic(f),Bayes(f,Dataset).*steps+Baseline-(3*2+distans)*steps,'LineStyle','none','marker','o','MarkerFaceColor',colors{9-Dataset},'Color',colors{9-Dataset},'linewidth',2,'markersize',7);
        end
    end
    baseline_temp=Baseline-(3*2+distans)*steps;
    line([-5 max(xtic)+5],[baseline_temp baseline_temp],'linestyle','--','Color','k','linewidth',1);
    line([-5 max(xtic)+5],[baseline_temp baseline_temp]-steps,'Color','k','linewidth',1);
    line([-5 max(xtic)+5],[baseline_temp baseline_temp]-2*steps,'Color','k','linewidth',1);
    line([-5 max(xtic)+5],[baseline_temp baseline_temp]-3*steps,'Color','k','linewidth',1);
    line([-5 max(xtic)+5],[baseline_temp baseline_temp]+steps,'Color','k','linewidth',1);
    line([-5 max(xtic)+5],[baseline_temp baseline_temp]+2*steps,'Color','k','linewidth',1);
    line([-5 max(xtic)+5],[baseline_temp baseline_temp]+3*steps,'Color','k','linewidth',1);
end

set(gca,'FontSize',20,'FontName','Calibri','XTick',...
    [xtic],'XTickLabel',Feat_names,'YTick',...
    [1],'YTickLabel',{''});
ylabel({'Bayes';'Factors'})
xtickangle(45);
xlim([0 29])
ylim([0.39 0.43])
box off;

%% Bar plots
gca = axes('Position',[0.13 0.05 0.775 0.794]);
for Dataset=1:size(Bayes,2)
    accuracies=nan*ones(35,53,length(Subjects));
    for Subject=[1:length(Subjects)]
        load(['New_Dec_DS_Claire_',main_conditions{1,1}(1:3),'_Wind_sliding_Subject_',num2str(Subject),'Cmplt_Feats.mat'],'accuracy');
        accuracies(:,:,Subject)=nanmean(accuracy,2);
        if baseline==1
            for feat=chosen_features
                accuracies(feat,:,Subject)=accuracies(feat,:,Subject)-nanmean(accuracies(feat,1:8,Subject),2)+0.5;
            end
        end
    end
    f=0;
    for feat=features
        f=f+1;
        if Maximum_or_Mean==1
            [data(f,Dataset,:),data_max(f,Dataset,:)]=nanmax(squeeze(accuracies(feat,9:end,:)));
%             if nanmean(nanmean(squeeze(accuracies(feat,9:15,:))))<0.5
%                 [data(f,Dataset,:),data_max(f,Dataset,:)]=nanmin(squeeze(accuracies(feat,9:15,:)));
%             end
        else
            data(f,Dataset,:)=nanmean(squeeze(accuracies(feat,31:end,:)));
        end
        Bars(Dataset)=bar(xtic(f),nanmean(data(f,Dataset,:)),'facecolor',colors{9-Dataset},'edgecolor','none','LineWidth',0.1);
        hold on;
        errorbar(xtic(f),nanmean(data(f,Dataset,:)),nanstd(data(f,Dataset,:))./sqrt(length(Subjects)),'linewidth',2,'color','k','CapSize',0,'LineStyle','none')
        significance(Dataset,f)=bf.ttest(squeeze(data(f,Dataset,:)),nanmean(squeeze(accuracies(feat,1:30,:)))');
    end
end

line([-5 max(xtic)+5],[0.5 0.5],'color','k','linestyle','--')
set(gca,'FontSize',20,'FontName','Calibri','XTick',xtic,'XTickLabel',{''},...
    'YTick',[0.5 0.55 0.6 0.65],'YTickLabel',{'50','55','60','65'});
xtickangle(45)
box off;
if Maximum_or_Mean==1    
    ylabel('Maximum Decoding Accuracy (%)')
    save('Max_decoding_accuracy.mat','data')
else
    ylabel('Average Decoding Accuracy (%)')
    save('Mean_decoding_accuracy.mat','data')
end
ylim([0.45 0.68]);
xlim([0 29])


%% Cross-condition Significance Matrix
% clc;
% clear all;
% close all;
figure;
if Maximum_or_Mean==1
    load('Max_decoding_accuracy.mat','data')
else
    load('Mean_decoding_accuracy.mat','data')
end
Dataset=1;
Feat_names={'Mean','Median','Variance','Skewness','Kurtosis','LZ Cmplx','Higuchi FD',...
    'Katz FD','Hurst Exp','Apprx Ent','Autocorr','Hjorth Cmp','Hjorth Mob',...
    'Signal Pw','Mean Freq','Med Freq','Avg Freq','SEF 95%','Pw MedFrq','Phs MdFrq',...
    'Cros Cor','Wavelet','Hilb Amp','Hilb Phs','Samples'};

    for feat1=1:25
        for feat2=1:25
            Significanc_mat(feat1,feat2)=bf.ttest(squeeze(data(feat1,1,:)),squeeze(data(feat2,1,:)));
            %         if feat1==feat2
            %             Significanc_mat(feat1,feat2)=1;
            %         end
            if feat1==feat2
                Significanc_mat(feat1,feat2)=0.01;
            end
            if feat1<feat2
                Significanc_mat(feat1,feat2)=0;
            end
            
        end
    end
    for feat1=1:25
        for feat2=1:25
            if Significanc_mat(feat1,feat2)>10
                Bayes_mat(feat1,feat2,Dataset)=6;
            elseif Significanc_mat(feat1,feat2)>3 && Significanc_mat(feat1,feat2)<=10
                Bayes_mat(feat1,feat2,Dataset)=5;
            elseif Significanc_mat(feat1,feat2)>1 && Significanc_mat(feat1,feat2)<=3
                Bayes_mat(feat1,feat2,Dataset)=4;
            elseif Significanc_mat(feat1,feat2)<1 && Significanc_mat(feat1,feat2)>=1/3
                Bayes_mat(feat1,feat2,Dataset)=3;
            elseif Significanc_mat(feat1,feat2)<1/3 && Significanc_mat(feat1,feat2)>=1/10
                Bayes_mat(feat1,feat2,Dataset)=2;
            elseif Significanc_mat(feat1,feat2)<1/10 && Significanc_mat(feat1,feat2)~=0
                Bayes_mat(feat1,feat2,Dataset)=1;
            elseif Significanc_mat(feat1,feat2)==0
                Bayes_mat(feat1,feat2,Dataset)=0;
            end
        end
    end
    subplot_tmp=subplot(1,1,Dataset);
    hold(subplot_tmp,'on');
    image(Bayes_mat(:,:,Dataset),'Parent',subplot_tmp,'CDataMapping','scaled');
    axis(subplot_tmp,'tight');
    axis(subplot_tmp,'ij');
    set(subplot_tmp,'CLim',[0 6],'DataAspectRatio',[1 1 1],'FontSize',10,'FontName','Calibri');
    
    xticks(1:25)
    yticks(1:25)
    xticklabels(Feat_names)
    yticklabels(Feat_names)
    ytickangle(45)
    xtickangle(45)
    colormap_mine=parula(6);
    colormap_mine=vertcat([1 1 1],colormap_mine);
    colormap(colormap_mine);
%     title(['Dataset ',num2str(Dataset)],'FontSize',16)
