function h = QT_hjorth(data)
% QT_hjorth: Hjorth parameters
%
% Usage: h = QT_hjorth(data)
%
% data: multi-channel data (each column for each channel)
% h(1,:) : Hjorth activity parameter
% h(2,:) : Hjorth mobility parameter
% h(3,:) : Hjorth complexity parameter
%
% Example: 
%   load /home/tieng/progs/matlab/eeg/competition/competition_data/clips/Dog_4/Dog_4_interictal_segment_20.mat
%   h = QT_hjorth(data.');
%

% Quang Tieng (28/7/2014)

h(1,:) = var(data);
h(2,:) = std(diff(data))./std(data);
h(3,:) = std(diff(diff(data)))./std(diff(data))./h(2,:);