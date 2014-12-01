
from load_features import load_features
from utils import *

from numpy import vstack
from sklearn.decomposition import KernelPCA 

import gc
import cPickle

def gogo_kpca( fxpath, mpath ):
    
    kpca_params = {'n_components':256,
                   'kernel':'rbf',
                   'gamma':None,
                   'degree':3,
                   'coef0':1,
                   'kernel_params':None,
                   'alpha':1.0,
                   'fit_inverse_transform':False,
                   'eigen_solver':'auto',
                   'tol':0,
                   'max_iter':None,
                   'remove_zero_eig':True}

    kpca_fname = '%s/kpca_rbf_{0}_{1}.pkl' % mpath

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

        X = vstack((X_inter, X_ictal))
        del X_inter, X_ictal; gc.collect()

        X_test = load_features( fxpath, nbreed, nsubject, 3 )
    
        X = vstack((X, X_test))
        del X_test; gc.collect()
    
        kpca = KernelPCA(**kpca_params)
        skip_interval = get_skip_interval(X)
        X = kpca_preprocess_features(X)
        kpca.fit(X[::skip_interval])
        with open(kpca_fname.format(sbreed,nsubject),'wb') as f:
            cPickle.dump(kpca,f)

        del X, kpca; gc.collect()


if __name__ == '__main__':
    import sys
    narg = len(sys.argv)
    if narg != 3:
        print 'usage: %s <fpath> <mpath>' % sys.argv[0]
        exit(1)

    fpath = sys.argv[1]
    mpath = sys.argv[2]

    #print 'fpath[%s] mpath[%s]' % ( fpath, mpath )

    gogo_kpca( fpath, mpath )


    

    


