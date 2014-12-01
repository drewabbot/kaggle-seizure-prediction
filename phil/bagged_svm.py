
from load_features import load_features
from utils import *

from numpy import array
from numpy import vstack

import pandas as pd
import sys
import cPickle


# try adaboost too on LR and SVM
#from sklearn.linear_model import LogisticRegression as LR
from sklearn.svm import LinearSVC
from sklearn.ensemble import BaggingClassifier as BC
from sklearn.metrics import roc_auc_score #(y_true, y_score, average='macro', sample_weight=None)

def gogo_bagged_svm( fxpath, mpath, spath ):

    transform = True

    svc_params = {'penalty':'l2',
                  'loss':'l2', 
                  'dual':False,
                  'C':33.0, 
                  'intercept_scaling':1e4, 
                  'class_weight':'auto',
                  'random_state':42}

    bc_params = {'base_estimator':LinearSVC(**svc_params),
                 'n_estimators':96, 
                 'max_samples':0.1, 
                 'max_features':0.8,  
                 'oob_score':False,
                 
                 # if you have tons of memory (i.e. 32gb ram + 32gb swap)
                 #  incresaing this parameter may help performance.  else,
                 #  increasing it may cause "out of memory" errors.
                 'n_jobs':1,
                 #'n_jobs':8,

                 'verbose':1,
                 'random_state':42}

    '''
    lr_params = {'C':1e6,#tr(-3,3,7),
                 'penalty':'l2',
                 'class_weight':'auto',
                 'intercept_scaling':1e6}#tr(-1,6,7)}
    '''

    preds = []

    kpca_fname = '%s/kpca_rbf_{0}_{1}.pkl' % mpath
    s_fname = '%s/kpca_linear_svm{0}_{1}_preds.csv' % spath

    for i in range(7):
        if i < 5:
            nbreed = 1
            sbreed = 'dog'
            nsubject = i+1
        else:
            nbreed = 2
            sbreed = 'human'
            nsubject = 1 + abs(5-i)

        print 'breed%d.subject%d..' % ( nbreed, nsubject )

        X_ictal = load_features( fxpath, nbreed, nsubject, 1 )
        X_inter = load_features( fxpath, nbreed, nsubject, 2 )
    
        X_train = vstack((X_inter, X_ictal))
        Y = [0 for x in X_inter] + [1 for x in X_ictal]
        wi = 1.0/len(X_inter) * 1000
        wp = 1.0/len(X_ictal) * 1000
        W = array([wp if y else wi for y in Y])
    
        del X_inter, X_ictal; gc.collect()
    
        with open(kpca_fname.format(sbreed,nsubject),'rb') as f:
            kpca = cPickle.load(f)
    
        if transform:   
            X_train = kpca_preprocess_features(X_train)
            X_train = kpca_incremental_transform(kpca,X_train)
            gc.collect()
    
        X_test = load_features( fxpath, nbreed, nsubject, 3 )
        if transform:
            X_test = kpca_preprocess_features(X_test)
            X_test = kpca_incremental_transform(kpca,X_test)
            gc.collect()
            
        bc = BC(**bc_params)
        bc.fit(X_train,Y)

        #print 'oob_score: ', bc.oob_score_
        subject_preds = bc.predict_proba(X_test)[:,1]

        preds.append(subject_preds)
        subject_preds = pd.DataFrame(subject_preds)

        subject_preds.to_csv(s_fname.format(sbreed,nsubject),index=False,header=None)    

        del X_train, X_test; gc.collect()
        sys.stdout.flush()


if __name__ == '__main__':

    narg = len(sys.argv)
    if narg != 4:
        print 'usage: %s <fpath> <mpath> <spath>' % sys.argv[0]
        exit(1)

    fpath = sys.argv[1]
    mpath = sys.argv[2]
    spath = sys.argv[3]

    #print 'fpath[%s] mpath[%s] spath[%s]' % ( fpath, mpath, spath )

    gogo_bagged_svm( fpath, mpath, spath )

