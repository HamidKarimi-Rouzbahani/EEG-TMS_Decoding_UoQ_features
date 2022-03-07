%% Features combined
clc;
clear all;
% close all;
Datasets={'Mine','Vhab','Stfd'};
Bands={'Broad','Delta','Theta','Alpha','Betta','Gamma'};
band=1;
accuracies=nan*ones(53,10);
Feat_Select_all=nan*ones(53,21,10);
listFS = {'ILFS','InfFS','ECFS','mrmr','relieff','mutinffs','fsv','laplacian','mcfs','rfe','L0','fisher','UDFS','llcfs','cfs','fsasl','dgufs','ufsol','lasso'};
selection_method=listFS{3};

for Subject=[1:2]
    %% all channels, 4-class, variance explained: above chance (50.5) decoding: 52.7
    load(['Corrected_Dec_DS_Claire_Att_Band_',Bands{band},'_Wind_sliding_Subject_',num2str(Subject),'_CombFeat_',selection_method,'_PCA.mat'],'accuracy','Sel_feat');
%     load(['Corrected_Dec_DS_Claire_Coh_Band_',Bands{band},'_Wind_sliding_Subject_',num2str(Subject),'_CombFeat_',selection_method,'_PCA.mat'],'accuracy','Sel_feat');
    
    accuracies(:,Subject)=nanmean(accuracy,2);
    try
        Feat_Select_all(:,:,Subject)=squeeze(nanmean(Sel_feat,2));
    catch
        Feat_Select_all(:,:,Subject)=squeeze((Sel_feat));
    end
end

% subplot(3,1,1)
figure;
plot(smooth(nanmean(accuracies(:,:),2),4),'linewidth',3)

figure;
try
    imagesc(squeeze(nanmean(Feat_Select_all,3)))
catch
    imagesc(squeeze(nanmean(Feat_Select_all,3)))
end

