

function [test_results,train_results,test_results1,train_results1,trainStore,testStore,isPreIctal] = QT_preictal_lassoglm_misc_rm2_11_select(prefix,no_segs,rmfeature)

% QT_PREICTAL_LASSOGLM_MISC_RM2_11_SELECT:  Predicting preictal with features based on
% the correlation matrix, its eigenvalues, statistical moments and spectrum
% at dyadic levels, Hjorth parameters, spectrum and entropy of 6 frequency bands,
% spectral edge power and fractional dimensions using Lassoglm with alpha
% of 0.1
%
% Usage:    [test_results,train_results,test_results1,train_results1,trainStore,testStore,isPreIctal] = QT_preictal_lassoglm_misc_rm2_11_select(prefix,no_segs,rmfeature)
%
%   test_results and train_results: results using mean value of segments
%   test_results1 and train_results1: results using median value of segments
%   trainStore: features for traning with labels at isPreIctal
%   testStore: features for testing
%   prefix: location of eeg data
%   no_segs: data is dividing into no_segs segments
%   rmfeature: feature is removed (1 to 11)
%
% Example:
%   [test_results,train_results,test_results1,train_results1,trainStore,testStore,isPreIctal] = QT_preictal_lassoglm_misc_rm2_11_select('/home/tieng/progs/matlab/eeg/competition/data/Dog_1/',1,1);
%

% Quang Tieng (7/11/2014)

preIctalClips = dir([prefix '*_preictal_*.mat']);
interIctalClips = dir([prefix '*_interictal_*.mat']);
testClips = dir([prefix '*_test_*.mat']);
    
mat = matfile([prefix preIctalClips(1).name]);
varlist = who(mat);
data_struct = mat.(varlist{1});
ldat = floor(size(data_struct.data,2)/no_segs);

[lambda,Cup] = QT_eig_corr(data_struct.data(:,1:ldat).');
[~,~,s,k] = QT_statistical_moments(data_struct.data(:,1:ldat).');
[~,spentropy,cdspect] = QT_dyadic_spectrum(data_struct.data(:,1:ldat).');
h = QT_hjorth(data_struct.data(:,1:ldat).');
[bspect, bspentropy, spedge] = QT_6_freq_bands(data_struct.data(:,1:ldat).',data_struct.sampling_frequency);
fd = QT_fractal_dimensions(data_struct.data(:,1:ldat)); fd = fd(1:2,:); % use the first two values

l1 = length(lambda); l2 = length(Cup); l3 = length(s); l4 = length(k); l5 = length(spentropy(:)); l6 = length(cdspect(:));
l7 = length(h(:)); l8 = length(bspect(:)); l9 = length(bspentropy(:)); l10 = length(spedge(:)); l11 = length(fd(:));
    
fprintf( 1, 'Calculate features with %d segments\n', no_segs );

totlen = l1+l2+l3+l4+l5+l6+l7+l8+l9+l10+l11;
trainStore = zeros(totlen,no_segs*(length(preIctalClips)+length(interIctalClips)));

train_clip = cell(length(preIctalClips)+length(interIctalClips),1);
m = 1;
for iter = 1:no_segs:no_segs*length(preIctalClips)
    train_clip{m} = preIctalClips(m).name;
    mat = matfile([prefix preIctalClips(m).name]);
    varlist = who(mat);
    data_struct = mat.(varlist{1});
    for n=0:no_segs-1
        data = data_struct.data(:,n*ldat+1:(n+1)*ldat);
        [lambda,Cup] = QT_eig_corr(data.');
        [~,~,s,k] = QT_statistical_moments(data.');
        [~,spentropy,cdspect] = QT_dyadic_spectrum(data.');
        h = QT_hjorth(data.');
        [bspect, bspentropy, spedge] = QT_6_freq_bands(data.',data_struct.sampling_frequency);
        fd = QT_fractal_dimensions(data); fd = fd(1:2,:);
        trainStore(:,iter+n) = [lambda(:)' Cup(:)' s k spentropy(:)' cdspect(:)' h(:)' bspect(:)' bspentropy(:)' spedge(:)' fd(:)']';
        isPreIctal(iter+n) = true;
    end
    m = m+1;
end

for iter = (1+ no_segs*length(preIctalClips)):no_segs:no_segs*(length(interIctalClips)+ length(preIctalClips))
    train_clip{m} = interIctalClips(m-length(preIctalClips)).name;
    mat = matfile([prefix interIctalClips(m-length(preIctalClips)).name]);
    varlist = who(mat);
    data_struct = mat.(varlist{1});
    for n=0:no_segs-1
        data = data_struct.data(:,n*ldat+1:(n+1)*ldat);
        [lambda,Cup] = QT_eig_corr(data.');
        [~,~,s,k] = QT_statistical_moments(data.');
        [~,spentropy,cdspect] = QT_dyadic_spectrum(data.');
        h = QT_hjorth(data.');
        [bspect, bspentropy, spedge] = QT_6_freq_bands(data.',data_struct.sampling_frequency);
        fd = QT_fractal_dimensions(data); fd = fd(1:2,:);
        trainStore(:,iter+n) = [lambda(:)' Cup(:)' s k spentropy(:)' cdspect(:)' h(:)' bspect(:)' bspentropy(:)' spedge(:)' fd(:)']';
        isPreIctal(iter+n) = false;
    end
    m = m+1;
end

%% test

clip = cell(length(testClips),1);
testStore = zeros(totlen,no_segs*length(testClips));
m = 1; 
for iter = 1:no_segs:no_segs*length(testClips)
    clip{m} = testClips(m).name;
    mat = matfile([prefix testClips(m).name]);
    varlist = who(mat);
    data_struct = mat.(varlist{1});
    for n=0:no_segs-1
        data = data_struct.data(:,n*ldat+1:(n+1)*ldat);
        [lambda,Cup] = QT_eig_corr(data.');
        [~,~,s,k] = QT_statistical_moments(data.');
        [~,spentropy,cdspect] = QT_dyadic_spectrum(data.');
        h = QT_hjorth(data.');
        [bspect, bspentropy, spedge] = QT_6_freq_bands(data.',data_struct.sampling_frequency);
        fd = QT_fractal_dimensions(data); fd = fd(1:2,:);
        testStore(:,iter+n) = [lambda(:)' Cup(:)' s k spentropy(:)' cdspect(:)' h(:)' bspect(:)' bspentropy(:)' spedge(:)' fd(:)']';
    end
    m = m+1;
end

%% select features for training and testing

if rmfeature>10 || rmfeature<0 || rmfeature==2
    fprintf( 1, 'All features are used\n' );
    L = 1:l1+l2+l3+l4+l5+l6+l7+l8+l9+l10+l11;
else
    fprintf( 1, 'Features 2 and 11 are removed permanently\n' );
    
    if rmfeature==1
        L = [l1+l2+1:l1+l2+l3+l4+l5+l6+l7+l8+l9+l10];
    elseif rmfeature==3
        L = [1:l1 l1+l2+l3+1:l1+l2+l3+l4+l5+l6+l7+l8+l9+l10];
    elseif rmfeature==4
        L = [1:l1 l1+l2+1:l1+l2+l3 l1+l2+l3+l4+1:l1+l2+l3+l4+l5+l6+l7+l8+l9+l10];
    elseif rmfeature==5
        L = [1:l1 l1+l2+1:l1+l2+l3+l4 l1+l2+l3+l4+l5+1:l1+l2+l3+l4+l5+l6+l7+l8+l9+l10];
    elseif rmfeature==6
        L = [1:l1 l1+l2+1:l1+l2+l3+l4+l5 l1+l2+l3+l4+l5+l6+1:l1+l2+l3+l4+l5+l6+l7+l8+l9+l10];
    elseif rmfeature==7
        L = [1:l1 l1+l2+1:l1+l2+l3+l4+l5+l6 l1+l2+l3+l4+l5+l6+l7+1:l1+l2+l3+l4+l5+l6+l7+l8+l9+l10];
    elseif rmfeature==8
        L = [1:l1 l1+l2+1:l1+l2+l3+l4+l5+l6+l7 l1+l2+l3+l4+l5+l6+l7+l8+1:l1+l2+l3+l4+l5+l6+l7+l8+l9+l10];
    elseif rmfeature==9
        L = [1:l1 l1+l2+1:l1+l2+l3+l4+l5+l6+l7+l8 l1+l2+l3+l4+l5+l6+l7+l8+l9+1:l1+l2+l3+l4+l5+l6+l7+l8+l9+l10];
    else
        L = [1:l1 l1+l2+1:l1+l2+l3+l4+l5+l6+l7+l8+l9];
    end
end

%%

rng('default');
[Bbasic,FitInfoBasic] = lassoglm(trainStore(L,:)',isPreIctal','binomial','lambda',1e-3,'CV',10,'Alpha',0.1,'Options',statset('UseParallel',true));
basicIndx = FitInfoBasic.Index1SE;
cnst = FitInfoBasic.Intercept(basicIndx);
mdlBasic = [cnst;Bbasic(:,basicIndx)];

%%
tmp = glmval(mdlBasic,testStore(L,:)','logit');
preictal = zeros(size(clip));
m = 1;
for n=1:no_segs:length(tmp)
    preictal(m) = mean(tmp(n:n+no_segs-1));
    m = m+1;
end
test_results = table(clip,preictal);

preictal = zeros(size(clip));
m = 1;
for n=1:no_segs:length(tmp)
    preictal(m) = median(tmp(n:n+no_segs-1));
    m = m+1;
end
test_results1 = table(clip,preictal);

tmp = glmval(mdlBasic,trainStore(L,:)','logit');

[~,~,~,auc] = perfcurve(double(isPreIctal.'),round(tmp),1);
fprintf( 1, 'Before averaging, AUC is %f with %d segments\n', auc, no_segs );

preictal = zeros(size(train_clip));
m = 1;
for n=1:no_segs:length(tmp)
    preictal(m) = mean(tmp(n:n+no_segs-1));
    m = m+1;
end
train_results = table(train_clip,preictal);

[~,~,~,auc] = perfcurve(double(isPreIctal(1:no_segs:end).'),round(preictal),1);
fprintf( 1, 'After averaging, AUC is %f with %d segments\n', auc, no_segs );

preictal = zeros(size(train_clip));
m = 1;
for n=1:no_segs:length(tmp)
    preictal(m) = median(tmp(n:n+no_segs-1));
    m = m+1;
end
train_results1 = table(train_clip,preictal);

[~,~,~,auc] = perfcurve(double(isPreIctal(1:no_segs:end).'),round(preictal),1);
fprintf( 1, 'After median, AUC is %f with %d segments\n', auc, no_segs );
