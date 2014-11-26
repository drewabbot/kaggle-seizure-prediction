function [m,v,s,k] = QT_statistical_moments(eeg_data)
% QT_statistical_moments: Calculate statistical moments of multi-channel
% eeg data (mean, variance, skewness and kurtosis)
%
% Usage: [m,v,s,k] = QT_statistical_moments(eeg_data)
%   
%   eeg_data: multi-channel eeg data (each column for each channel)
%   m: mean
%   v: variance
%   s: skewness
%   k: kurtosis
%   v, s and k are calculated with zero mean data
%
% Example:
%   load /home/tieng/progs/matlab/eeg/competition/competition_data/clips/Dog_4/Dog_4_interictal_segment_20.mat
%   [~,v,s,k] = QT_statistical_moments(data.');
%

% Quang Tieng (21/7/2014)

% mean of data
m = mean(eeg_data);

% remove mean
eeg_data = bsxfun(@minus,eeg_data,m);

% variance
v = var(eeg_data);

% skewness
s = skewness(eeg_data);

% kurtosis
k = kurtosis(eeg_data);