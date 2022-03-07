clc;
clear all;
% close all;

%% Settings
Subjects={'04','14'};
conditions={'attendL','attendR'};
% conditions={'cohHigh','cohLow'};

time_window=[1:1000]; % 1:1000 = pre-stimulus; 1000:2000 = post-stimulus



for Subject=1:2
    
    %% reading the data
    for condition=1:length(conditions)
        clearvars EEG
        EEG=pop_loadset('filename',['sub-',Subjects{Subject},'_GA_crit_',conditions{condition},'.set'],'filepath','C:\\Users\\mq20185770\\Documents\\MATLAB\\Claire\\');
        for trial=1:size(EEG.data,3)
            for channel=1:size(EEG.data,1)
                signal(channel,condition,trial,1:length(time_window))=EEG.data(channel,time_window,trial);
            end
        end
    end
    clearvars -except accuracy_null_distribution significance winds accuracy signal Subject conditions Subjects
    
    %% Extracting the autocorrelation values at different lags
    number_of_lags_for_autocor=1;
    
    for condition = 1:size(signal,2)
        for channel = 1:size(signal,1)
            for trial = 1:size(signal,3)
                [acf,lags,~] =autocorr(signal(channel,condition,trial,:),number_of_lags_for_autocor);
                feature_extracted(channel,condition,trial,:)= acf(2:end);
            end
        end
    end
           
    clearvars -except accuracy_null_distribution significance data labels feature_extracted down_sampling winds accuracy Xready conditions Subjects windows window wind Dataset  accuracy Subject signal feature net
    %% Classification
    data=reshape(feature_extracted(:,1,:,:),[size(feature_extracted,1) size(feature_extracted,3)*size(feature_extracted,4)]);
    data=horzcat(data,reshape(feature_extracted(:,2,:,:),[size(feature_extracted,1) size(feature_extracted,3)*size(feature_extracted,4)]))';
    labels=[ones(1,size(feature_extracted,3)*size(feature_extracted,4)) zeros(1,size(feature_extracted,3)*size(feature_extracted,4))]';
    
    Classifier_Model = fitcdiscr(data,labels,'DiscrimType','Linear');
    CVSVMModel = crossval(Classifier_Model);
    classLoss = kfoldLoss(CVSVMModel);
    accuracy(Subject)=1-classLoss;
    
    
    %% Classification of randomly-labeled data for significance testing (random permutation)
    
    %         iterations=100;
    %         for iteration=1:iterations
    %             labels_t=zeros(1,size(feature_extracted,3)*size(feature_extracted,4)*2);
    %             labels_t(randsample([1:length(labels)],sum(labels==1)))=1;
    %
    %             Classifier_Model = fitcdiscr(data,labels_t,'DiscrimType','Linear');
    %             CVSVMModel = crossval(Classifier_Model);
    %             classLoss = kfoldLoss(CVSVMModel);
    %             accuracy_null_distribution(Subject,iteration)=1-classLoss;
    %         end
    %
    %         significance_threshold=0.05;
    %         if sum(accuracy(Subject)>accuracy_null_distribution(Subject,:))>(1-significance_threshold)*iterations
    %             significance(Subject)=1;
    %         else
    %             significance(Subject)=nan;
    %         end
    %
    %% Plotting of Autocorrelations
    
    subplot(1,length(Subjects),Subject)
    imagesc(data,[0.9 1])
    xlabel('Channel #');
    ylabel('Trial # (1:450 = condition #1 & 451:900 = condition #2)');
    title (['Subject #',Subjects{Subject}]);
    set(gca,'fontsize', 10);
    [Subject]
end
%% Plotting decoding values
figure;
plot([1:length(Subjects)],accuracy,'linewidth',2)
% hold on;
% plot([1:length(Subjects)],significance*0.85,'*')
xticks([1:length(Subjects)])
xticklabels(Subjects)
xlabel('Subject #');
ylabel('Decoding accuracy');
xlim([0.75 length(Subjects)+0.25])
ylim([0.45 0.85])
set(gca,'fontsize', 18);
