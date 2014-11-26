

import sys
from numpy import *

narg = len(sys.argv)

if narg != 2:
  print "usage: %s <file>" % sys.argv[0]
  exit(1)

fpath = sys.argv[1]

f = open(fpath)
X = f.readlines()
f.close()

N = len(X)

# the number of test segments for each subject
T = [ 502, 1000, 907, 990, 191, 195, 150 ]

assert( N == sum(T)+1 )

# cumsum of T
C = [ sum(T[:i+1]) for i in range(len(T)) ]
assert( C[-1] == sum(T) )

assert( len(C)==7 and len(T)==7 )


# first line is the special "clip,preictal" header
print X[0].rstrip()



for i in range(7):
  if i < 5:
    sbreed = 'Dog'
    nsubject = i+1
  else:
    sbreed = 'Patient'
    nsubject = 1 + abs(5-i)
  
  # number of test segments for this subject
  n = T[i]
  x = zeros(n)

  n0 = 1 if i==0 else C[i-1]+1
  nF = C[i]

  nn = range(n0,nF+1)
  assert( nn[0]==n0 and nn[-1]==nF )
  assert( len(nn) == n )

  #print '%d: [%d,%d] => len[%d] ' % ( i, n0,nF, len(nn) )

  for j in range(n):
    xcsv = X[nn[j]].split(',')
    x[j] = xcsv[1]

  xmed = median(x)
  x -= xmed
  x /= 2
  x += 0.5

  for j in range(n):
    if x[j] > 1:
      x[j] = 1
    if x[j] < 0:
      x[j] = 0
    assert( x[j] >= 0 and x[j] <= 1 )

    print '%s_%d_test_segment_%04d.mat,%.17f' % ( sbreed,nsubject, j+1, x[j] )
