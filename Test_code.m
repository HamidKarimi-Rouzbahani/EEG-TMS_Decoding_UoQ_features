clc;
clear all;
close all;
% eeglab



EEG=pop_loadset('filename','sub-04_GA_crit_attendL.set','filepath','C:\\Users\\mq20185770\\Documents\\MATLAB\\Claire\\');
EEG_data=EEG.data;
clearvars -except EEG_data

