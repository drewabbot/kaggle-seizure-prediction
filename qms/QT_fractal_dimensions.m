function fd = QT_fractal_dimensions(data)
% QT_fractal_dimensions: Calculating fractal dimensions of multiple
% channels EEG data
%
% Usage: fd = QT_fractal_dimensions(data)
%
%   data: data matrix (NxM) stores data of N channels with the length of M
%   fd: 3 different fractal dimensions of each channel
%
% Example:
%   load /home/tieng/progs/matlab/eeg/competition/competition_data/clips/Dog_4/Dog_4_interictal_segment_20.mat
%   fd = QT_fractal_dimensions(data);
%

% Quang Tieng (3/9/2014)

no_channels = size(data,1);
fd = zeros(3,no_channels);

for n=1:no_channels
    fd(:,n) = wfbmesti(data(n,:));
end