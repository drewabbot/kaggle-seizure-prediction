
from numpy import *

def describe(nbreed,nclass):
    B = [ 'dog', 'human' ]
    C = [ 'ictal', 'inter', 'test' ]
    sbreed = B[nbreed-1]
    sclass = C[nclass-1]
    return sbreed,sclass


# load pre-calculated features from files in directory D

def load_features( D, nbreed,nsubject,nclass ):

    sbreed,sclass = describe(nbreed,nclass)
    s = '%s/%s%d.%s.dat' % ( D, sbreed,nsubject,sclass )

    f = open( s, 'rb' )

    # [ M x N ] features
    M = fromfile( f, uint64, 1 )
    N = fromfile( f, uint64, 1 )
    
    # force at least one sample and at least one feature 
    assert( M >= 1 and N >= 1 )

    # two extra columns are stored
    X = zeros( (M,N+2) )

    # manual read loop
    for i in range(M):
        X[i] = fromfile( f, double, N+2 )

    f.close()

    assert( size(X,axis=0) == M )
    assert( size(X,axis=1) == N+2 )

    return X[:,2:]

