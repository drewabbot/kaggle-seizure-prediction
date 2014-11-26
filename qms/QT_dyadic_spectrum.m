function [dspect, spentropy, cdspect] = QT_dyadic_spectrum(data)
% QT_dyadic_spectrum: Calculate spectrum and Shannon's entropy at different dyadic frequency bands
%
% Usage: [dspect, spentropy, cdspect] = QT_dyadic_spectrum(data)
%
%   data: multi-channel eeg data (each column for each channel)
%   dspect: spectrum of each channel at dyadic band (2,4,8,16,...)
%   spentropy: spectral entropy used Shannon's entropy measure. 
%   cdspect: correlation between dspect
%
% Example: 
%   load /home/tieng/progs/matlab/eeg/competition/competition_data/clips/Dog_4/Dog_4_interictal_segment_20.mat
%   [dspect, spentropy, cdspect] = QT_dyadic_spectrum(data.');
%

% Quang Tieng (21/7/2014)

D = abs(fft(data));             % take FFT of each channel
D(1,:) = 0;                     % set DC component to 0
D = bsxfun(@rdivide,D,sum(D));  % normalize each channel

% find number of dyadic levels
ldat = floor(size(data,1)/2);
no_levels = floor(log2(ldat));
seg = floor(ldat/2^(no_levels-1));

% find the power spectrum at each dyadic level
dspect = zeros(no_levels,size(data,2));
for n=no_levels:-1:1
    dspect(n,:) = 2*sum(D(floor(ldat/2)+1:ldat,:));
    ldat = floor(ldat/2);
end

% find the Shannon's entropy
spentropy = -sum(dspect.*log(dspect));

% find correlation between channels
[~,cdspect] = QT_eig_corr(dspect);
