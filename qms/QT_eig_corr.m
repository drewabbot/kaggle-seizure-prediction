function [lambda,Cup] = QT_eig_corr(eeg_data,type_corr)
% QT_eig_corr: Calculate the eigenvalues of the correlation matrix of
% multi-channel eeg data
%
% Usage: lambda = QT_eig_corr(eeg_data,type_corr)
%
%   eeg_data: multi-channel eeg data (each column for each channel)
%   type_corr: type of correlations: 'Pearson', 'Kendall' or 'Spearman'
%   'Pearson' is default.
%
%   lambda: the eigenvalues (number of eigenvalues is the same as number of
%   channels)
%   Cup: upper matrix of the correlation matrix.
%
% Example:
%
%   load /home/tieng/progs/matlab/eeg/competition/competition_data/clips/Dog_4/Dog_4_interictal_segment_20.mat
%   [lambda,Cup] = eig(data.');
%   Cup = sort(Cup);    % sort Cup
%

% Quang Tieng (21/7/2014)

if nargin==1
    type_corr = 'Pearson';
end

% remove mean
%eeg_data = bsxfun(@minus,eeg_data,mean(eeg_data));

% normalize by standard deviation
%eeg_data = bsxfun(@times,eeg_data,1./std(eeg_data));

% calculate correlation and its eigenvalues
% Note: the method already includes normalization step thus we don't need
% to normalize data before calculating correlation.
C = corr(eeg_data,'type',type_corr);
C(isnan(C)) = 0;    % make NaN become 0
C(isinf(C)) = 0;    % make Inf become 0
lambda = sort(eig(C));

% extract upper matrix of the correlation matrix
tmp = ones(size(C));
tmp = triu(tmp,1);  % upper matrix of tmp
Cup = C(tmp==1);
%Cup = sort(Cup);