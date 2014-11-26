function [dspect, spentropy, spedge, lxchannels, lxfreqbands] = QT_6_freq_bands(data,sfreq,tfreq,ppow)
% QT_6_freq_bands: Calculate spectrum and Shannon's entropy at six frequency bands
% delta (0.1-4Hz), theta (4-8Hz), alpha (8-12Hz), beta (12-30Hz),
% low-gamma (30-70Hz) and high gamma (70-180Hz).
%
% Usage: [dspect, spentropy, spedge, lxchannels, lxfreqbands] = QT_6_freq_bands(data,sfreq,tfreq,ppow)
%
%   data: multi-channel eeg data (each column for each channel)
%   sfreq: sampling frequency
%   tfreq: the cut-off frequency to calculate spectral edge power (default = 40Hz)
%   tfreq must be less than sfreq/2.
%   ppow: percentage of power up to tfreq used to calculate spectral edge power ([0,1], default = 0.5)
%   dspect: spectrum of each frequency band
%   spentropy: spectral entropy used Shannon's entropy measure.
%   spedge: spectral edge power of 50% power up to 40Hz
%
% Example: 
%   load /home/tieng/progs/matlab/eeg/competition/competition_data/clips/Dog_4/Dog_4_interictal_segment_20.mat
%   [dspect, spentropy, spedge, lxchannels, lxfreqbands] = QT_6_freq_bands(data.',freq);
%

% Quang Tieng (1/9/2014)
% 5/9/2014: add lxchannels and lxfreqbands

% deal with the various inputs
if nargin < 3
    tfreq = 40;
    ppow = 0.5;
end

if nargin < 4
    ppow = 0.5;
end

D = abs(fft(data));             % take FFT of each channel
D(1,:) = 0;                     % set DC component to 0
D = bsxfun(@rdivide,D,sum(D));  % normalize each channel

% find number data points corresponding to 6 frequency bands
l = [0.1 4 8 12 30 70 180]; % frequency levels in Hz
lseg = round(size(data,1)/sfreq*l)+1;   % segments corresponding to frequency bands

% find the power spectrum at each frequency bands
dspect = zeros(length(l)-1,size(data,2));
for n=1:length(l)-1
    dspect(n,:) = 2*sum(D(lseg(n):lseg(n+1),:));
end

% find the Shannon's entropy
spentropy = -sum(dspect.*log(dspect));

% find the spectral edge frequency (not finish this part yet)
topfreq = round(size(data,1)/sfreq*tfreq)+1;
A = cumsum(D(1:topfreq,:));
B = bsxfun(@minus,A,max(A)*ppow);
[~,spedge] = min(abs(B));
spedge = (spedge-1)/(topfreq-1)*tfreq;

% find eigenvalues of the spectral correlation matrix
lxchannels = abs(QT_eig_corr(dspect));  % correlating between channels
lxfreqbands = abs(QT_eig_corr(dspect.'));   % correlating between frequency bands



