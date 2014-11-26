
from numpy import power
from sklearn.preprocessing import MinMaxScaler as MMS
def kpca_preprocess_features(X):
    mms = MMS(feature_range=(-0.5, 0.5))
    n_rows, n_cols = X.shape
    for j in range(n_cols):
        col_max = max(X[:,j])
        col_min = min(X[:,j])
        if col_max <= 1.0 and col_min >= -1.0:
            pass
        else:
            X[:,j] = power(X[:,j],0.125)
    X = mms.fit_transform(X)    
    return X

def get_skip_interval(X):
    D1_len = 1135680 + 56784 + 1187732
    acceptable_num_samples = D1_len / 100
    skip_interval = len(X)/acceptable_num_samples
    return skip_interval

from numpy import zeros
import gc
def kpca_incremental_transform(kpca, X):
    increment = 10000
    X_out = zeros((len(X),kpca.n_components))
    n_increments = len(X)/increment + 1
    for i in range(n_increments):
        inc_slice = slice(increment*i,increment*(i+1))
        if len(X[inc_slice]) > 0:
            X_out[inc_slice,:] = kpca.transform(X[inc_slice]) 
    del X; gc.collect()
    return X_out


from numpy import linspace
def tr(lo,hi,n):
    return 10.**linspace(lo,hi,n)

def scorer(estimator, X, Y):
    preds = estimator.predict_proba(X)[:,1]
    return roc_auc_score(Y, preds)
