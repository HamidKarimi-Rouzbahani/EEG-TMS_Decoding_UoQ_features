clc;
clear all;
% close all;
%% Comments
% Different subbands,
% feature/channel selection,
% features across time
% rankfeatures
%% Things to report
% contribution of different brain areas by doing single-channel decoding,
% per subject
% Decoding of each category, DIfferent frequ bands, number of features in
% features with more than one, combining them and their contribution,
% overlap of features calculated using some measeare, selecting features, categorizing features based on type, COnfusion matrices,
% discriminability of features on channels, average feature values
% (distribution) for each category, plotting erps of best features,
% Features across time, comparison of the three datasets,

%% These features provide 1 number for each trial and each channel
Subjects={'04','14'};
% categories={'attendL','attendR'};
categories={'cohHigh','cohLow'};
accuracy = nan*ones(length(Subjects),36,10);
down_sampling=100;
for Subject=1:2
    Fs=1000;
    %     signal = DatasetLoading(Dataset,Subject); % channel, time, cat, trial
    winds=[1:1000];
    signal=zeros(61,length(winds),2,450); % channel, time, cat, trial
    %     for category=1:2
    %         EEG=pop_loadset('filename',['sub-',Subjects{Subject},'_GA_crit_',categories{category},'.set'],'filepath','C:\\Users\\mq20185770\\Documents\\MATLAB\\Claire\\');
    %         signal(:,:,category,1:size(EEG.data,3))=EEG.data(:,winds,:);
    %     end
    for category=1:2
        EEG=pop_loadset('filename',['sub-',Subjects{Subject},'_GA_crit_',categories{category},'.set'],'filepath','C:\\Users\\mq20185770\\Documents\\MATLAB\\Claire\\');
        for trial=1:size(EEG.data,3)
            for ch=1:size(EEG.data,1)
                signal(ch,:,category,trial)=EEG.data(ch,winds,trial)-nanmean(EEG.data(ch,1:1000,trial),2);
            end
        end
    end
    
    clearvars -except feature_chosen_temp winds accuracy down_sampling signal Subject categories Subjects Fs
    
    for window=1:1
        for feature=[34]
            %         for feature=[35]
            if feature==33
                net= load ('imagenet-caffe-alex.mat');
            end
%             cate=ones(size(signal,4),1);
%             half_indices=randsample([1:size(signal,4)],floor(size(signal,4)./2));
%             cate(half_indices)=2;
            
            for channel = 1:size(signal,1)
                for category = 1:size(signal,3)
                    for trial = 1:size(signal,4)
                        trial_data=signal(channel,:,category,trial);
                        if feature<28 && channel==1 && category==1 && trial==1
                            feature_chosen=nan.*ones(size(signal,1),size(signal,3),size(signal,4));
                        elseif feature==28 && channel==1 && category==1 && trial==1
                            feature_chosen=nan.*ones(size(signal,1),size(signal,3),size(signal,4),114);
                        elseif (feature==29 || feature==30) && channel==1 && category==1 && trial==1
                            feature_chosen=nan.*ones(size(signal,1),size(signal,3),size(signal,4),length(winds));
                        elseif feature==31 && channel==1 && category==1 && trial==1
                            feature_chosen=nan.*ones(size(signal,1),size(signal,3),size(signal,4),30);
                        elseif feature==32 && channel==1 && category==1 && trial==1
                            feature_chosen=nan.*ones(size(signal,1),size(signal,3),size(signal,4),size(signal,1));
                        elseif feature==33 && channel==1 && category==1 && trial==1
                            feature_chosen=nan.*ones(size(signal,1),size(signal,3),size(signal,4),length(winds));
                        elseif feature==34 && channel==1 && category==1 && trial==1
                            feature_chosen=nan.*ones(size(signal,1),size(signal,3),size(signal,4),length(winds));
%                             feature_chosen_temp=nan.*ones(size(signal,1),size(signal,3),size(signal,4),length(winds)./down_sampling);
                        elseif feature==35 && channel==1 && category==1 && trial==1
                            numLags=10;
                            feature_chosen=nan.*ones(size(signal,1),size(signal,3),size(signal,4),numLags);                      
                        end
                        if sum(isnan(trial_data))>0
                            feature_chosen(channel,category,trial)=nan;
                        else
                            if feature==1
                                %%            Baseline
                                feature_chosen(channel,category,trial) = mean(trial_data);
                            elseif feature==2
                                %%            Time features: Sigal mean
                                feature_chosen(channel,category,trial) = mean(trial_data);
                                
                            elseif feature==3
                                %% Signal median
                                feature_chosen(channel,category,trial) = median(trial_data);
                                
                            elseif feature==4
                                %% Signal variance
                                feature_chosen(channel,category,trial) = var(trial_data);
                                
                            elseif feature==5
                                %% Signal skewness
                                feature_chosen(channel,category,trial) = skewness(trial_data);
                                
                            elseif feature==6
                                %% Signal Kurtosis
                                feature_chosen(channel,category,trial) = kurtosis(trial_data);
                                
                            elseif feature==7
                                %%                 LZ complexity
                                threshold = median(trial_data);
                                %         threshold = mean(data);
                                trial_data(trial_data>= threshold)=1;
                                trial_data(trial_data< threshold)=0;
                                [feature_chosen(channel,category,trial),~] = calc_lz_complexity(trial_data, 'exhaustive', 1);
                                
                            elseif feature==8
                                %%                  Higuchi fractal dimension
                                maxtime = length(trial_data);
                                %                             Kmax = floor(maxtime./2);
                                Kmax = 10;
                                feature_chosen(channel,category,trial) = Higuchi_FD(trial_data,Kmax);
                                %                 % second implementation
                                %                 [HFD2(channel,category,trial),~,~,~]  = HFD_LCALC(data);
                                %                 % thrid implementation
                                %                 HFD3(channel,category,trial) = hfd(data,Kmax);
                                
                            elseif feature==9
                                %%                 Katz fractal dimensions
                                feature_chosen(channel,category,trial) = Katz_FD(trial_data);
                                
                            elseif feature==10
                                %%                  Lyapunov exponent (largest LLE)
                                [feature_chosen(channel,category,trial),~] = lyaprosen(trial_data,0,0);
                                
                            elseif feature==11
                                %%                  Hurst Exponent
                                feature_chosen(channel,category,trial) = estimate_hurst_exponent(trial_data);
                                %                 HE2(channel,category,trial) = genhurst(data);
                                %                 HE3(channel,category,trial) = hurstCC(data);
                                
                            elseif feature==12
                                %%                  Sample entropy
                                feature_chosen(channel,category,trial) = entropy (trial_data);
                                %                 Ent2(channel,category,trial) = SampEn (2,0.2.* std(data),data,1);
                                
                            elseif feature==13
                                %%                  Approximate Entropy
                                feature_chosen(channel,category,trial) = ApEn (2,0.2.* std(trial_data),trial_data,1);
                                %                 Ent4(channel,category,trial) = approx_entropy(2,0.2.* std(data),data);
                                
                            elseif feature==14
                                %%                  ERP components P1/C1/P100, N1/N170, P200/P2a and P2b, chosen by visual inspection of PO3 channel, windows of components are 40, 60, 70 and 80 ms respectively.
                                % each trial can have 1 to 4 components
                                % P1
                                feature_chosen(channel,category,trial)=nanmean(trial_data([80:120]));
                                
                            elseif feature==15
                                %% N1
                                feature_chosen(channel,category,trial)=nanmean(trial_data([120:200]));
                                
                            elseif feature==16
                                %% P2a
                                feature_chosen(channel,category,trial)=nanmean(trial_data([150:220]));
                                
                            elseif feature==17
                                %% P2b
                                feature_chosen(channel,category,trial)=nanmean(trial_data([200:275]));
                                
                            elseif feature==18
                                %%              Within-trial correlation
                                numLags=20;
                                [acf,lags,~] =autocorr(trial_data,numLags);
                                feature_chosen(channel,category,trial)= mean(acf);
                                
                            elseif feature==19
                                %%              Hjorth complexity
                                % this finds spread of the spectrum and represents the change in frequency
                                % Hcomplexity
                                step_size=1./Fs;
                                data_prime=(diff(trial_data)./step_size);
                                data_second=(diff(data_prime)./step_size);
                                feature_chosen(channel,category,trial)=(std(data_second).*std(trial_data))./(std(trial_data)).^2;
                                
                            elseif feature==20
                                %% Hmobility
                                step_size=1./Fs;
                                data_prime=(diff(trial_data)./step_size);
                                data_second=(diff(data_prime)./step_size);
                                feature_chosen(channel,category,trial)=std(data_prime)./std(trial_data);
                                
                            elseif feature==21
                                %% Mean Freq
                                feature_chosen(channel,category,trial) = meanfreq(trial_data,Fs);
                                
                            elseif feature==22
                                %% Median Freq
                                feature_chosen(channel,category,trial) = medfreq(trial_data,Fs);
                                
                            elseif feature==23
                                %% Average Freq
                                zeroscount=0;
                                for i=2:length(trial_data)
                                    if (trial_data(i)>0 && trial_data(i-1)<0) || (trial_data(i)<0 && trial_data(i-1)>0)
                                        zeroscount=zeroscount+1;
                                    end
                                end
                                feature_chosen(channel,category,trial) =zeroscount.*(length(trial_data)./Fs);
                                
                            elseif feature==24
                                %% Spectral edge frequency 95%
                                if var(trial_data)==0
                                    feature_chosen(channel,category,trial) =0;
                                else
                                    Fourier = fft(trial_data)/length(trial_data);
                                    Fouriers = (abs(Fourier));                           % Spectrum
                                    Fv = linspace(0, 1, fix(length(trial_data)/2)+1)*Fs/2;        % Frequency Vector
                                    Iv = 1:length(Fv);                                      % Index Vector
                                    IntSpectrum = cumtrapz(Fv, Fouriers(Iv));               % Numeric Integration
                                    feature_chosen(channel,category,trial) = interp1(IntSpectrum, Fv, 0.95*IntSpectrum(end), 'linear');    % Interploate To Find ?SEF?
                                end
                            elseif feature==25
                                %% Power at Median Freq
                                amp = 2*abs(fft(trial_data))/length(trial_data);
                                phs = angle(fft(trial_data));
                                Fv = linspace(0, 1, fix(length(trial_data)/2)+1)*Fs/2;  % Frequency Vector
                                Iv = 1:length(Fv);                                      % Index Vector
                                fr_des = medfreq(trial_data,Fs);                        % Desired Frequency
                                ampv = amp(Iv);                                         % Trim To Length Of ?Fv?
                                phsv = phs(Iv);                                         % Trim To Length Of ?Fv?
                                ap = [ampv(:) phsv(:)];                                 % Amplitude & Phase Matrix
                                ap_des = interp1(Fv(:), ap, fr_des, 'linear');
                                feature_chosen(channel,category,trial) =ap_des(1);
                                
                            elseif feature==26
                                %% Phase at Median Freq
                                amp = 2*abs(fft(trial_data))/length(trial_data);
                                phs = angle(fft(trial_data));
                                Fv = linspace(0, 1, fix(length(trial_data)/2)+1)*Fs/2;  % Frequency Vector
                                Iv = 1:length(Fv);                                      % Index Vector
                                fr_des = medfreq(trial_data,Fs);                        % Desired Frequency
                                ampv = amp(Iv);                                         % Trim To Length Of ?Fv?
                                phsv = phs(Iv);                                         % Trim To Length Of ?Fv?
                                ap = [ampv(:) phsv(:)];                                 % Amplitude & Phase Matrix
                                ap_des = interp1(Fv(:), ap, fr_des, 'linear');
                                feature_chosen(channel,category,trial) =ap_des(2);
                                
                            elseif feature==27
                                %% Signal power
                                feature_chosen(channel,category,trial)=bandpower(trial_data);
                                
                            elseif feature==28
                                %% Wavelet transform:
                                [c,l] = wavedec(trial_data,5,'sym2');
                                [ca5] = appcoef(c,l,'sym2',5);
                                [cd1,cd2,cd3,cd4,cd5] = detcoef(c,l,[1 2 3 4 5]);
                                feature_chosen(channel,category,trial,:)=[ca5,cd1,cd2,cd3,cd4,cd5];
                                
                            elseif feature==29
                                %% Hilbert transform amplitude: 800 features per trial
                                Hilb = hilbert(trial_data);
                                feature_chosen(channel,category,trial,:)=abs(Hilb);
                                
                            elseif feature==30
                                %% Hilbert transform phase: 800 features per trial
                                Hilb = hilbert(trial_data);
                                feature_chosen(channel,category,trial,:)=angle(Hilb);
                                
                            elseif feature==31
                                %% Phase-Amplitude Coupling
                                data.trial{1,1}= trial_data;
                                data.time{1,1}= [0.001:0.001:0.1];
                                data.trialinfo=[100]';
                                data.label{1,1}='SampleData';
                                toi=[0.001 1.0]; % time of interest
                                phase=[0.5 12];   % phase(1):0.4:phase(2)
                                ampl=[24 120];   % amp(1):2.8:amp(2)
                                diag = 'no'; %'yes' or 'no' to turn on or off diagrams during computation
                                surrogates = 'no'; %'yes' or 'no' to turn on or off surrogates during computation
                                approach = 'tort';%,'ozkort','canolty','PLV';
                                [MI_matrix_raw,~] = calc_MI(data,toi,phase,ampl,diag,surrogates,approach);
                                feature_chosen(channel,category,trial,:)=reshape(MI_matrix_raw(1:6,1:5),[30 1]);
                                
                            elseif feature==32
                                %% Inter-channel correlation 31 feature per trial
                                ICC=zeros(size(signal,1),1);
                                for ch2=1:size(signal,1)
                                    trial_data2=signal(ch2,:,category,trial);
                                    ICC(ch2,1)=corr(trial_data',trial_data2');
                                end
                                feature_chosen(channel,category,trial,:)=ICC;
                                
                            elseif feature==33
                                %% CNN
                                trial_data=(trial_data+abs(min(trial_data)));
                                trial_data=(trial_data).*(255./max(trial_data));
                                
                                im_ = single(uint8(trial_data));
                                im_ = repmat(im_,[1 ceil(227*227./length(im_))]);
                                im_=im_(1,1:227*227);
                                im_=reshape(im_,[227 227]);
                                im_ = imresize(im_,net.meta.normalization.imageSize(1:2));
                                im_ = im_ - net.meta.normalization.averageImage;
                                
                                res = vl_simplenn(net, im_);
                                feature_chosen(channel,category,trial,:)=squeeze(res.x);
                                
                            elseif feature==34
                                %% Signal samples
                                feature_chosen(channel,category,trial,:)=trial_data;
%                                 feature_chosen_temp(channel,category,trial,:)=downsample(feature_chosen(channel,category,trial,:),down_sampling);
                            elseif feature==35
                                %% Within-trial correlation
                                [acf,lags,~] =autocorr(trial_data,numLags);
                                feature_chosen(channel,category,trial,:)= acf(2:end);

%                                 feature_chosen(channel,cate(trial),trial,:)= acf(2:end);

                            end
                        end
                    end
                end
            end
            %% Classification
            clearvars Xready X Y
            Xready(:,:,:,1)=feature_chosen(:,1,:,:);
            Xready(:,:,:,2)=feature_chosen(:,2,:,:);

            clearvars -except feature_chosen_temp down_sampling winds accuracy Xready categories Subjects windows window wind Dataset Fs True_Predicted_labels accuracy Subject signal feature X Y  net           
         
            X=reshape(Xready(:,:,:,1),[size(Xready,1) size(Xready,2)*size(Xready,3)]);
            X=horzcat(X,reshape(Xready(:,:,:,2),[size(Xready,1) size(Xready,2)*size(Xready,3)]))';
            Y=[ones(1,size(Xready,2)*size(Xready,3)) 2*ones(1,size(Xready,2)*size(Xready,3))];
            
            Classifier_Model = fitcdiscr(X,Y','DiscrimType','Linear');
            CVSVMModel = crossval(Classifier_Model);
            classLoss = kfoldLoss(CVSVMModel);
            accuracy(Subject,feature,1)=1-classLoss;
            
            [Subject feature]
        end
    end
    save(['Decoding_Accuracy_DS_Claire_Window_',num2str(window),'.mat'],'accuracy');
end

%%
hold on;
plot(squeeze(nanmean(accuracy,3))')


