
# 11/24/14:
#   about to add two extra optional params to this script,
#    so it support other overlap amounts, etc., but backing
#    up current state first..
#

import sys

narg = len(sys.argv)

if narg != 3:
  print "usage: %s <fpath> <p>" % sys.argv[0]
  exit(1)

fpath = sys.argv[1]

# pnorm parameter
p = float(sys.argv[2])

# read input file
f = open(fpath)
X = f.readlines()
f.close()

N = len(X)

# the number of test segments for each subject
T = [ 502, 1000, 907, 990, 191, 195, 150 ]

# the number of samples for each subject
#  ( assuming 8-sec, 63/64 overlap, upsampled by 8 )
L = [ 37849, 37849, 37849, 37849, 37849, 37889, 37889 ]

assert( N == sum( [ (i*j) for (i,j) in zip(T,L) ] ) )

assert( len(T) == 7 )
assert( len(L) == 7 )

n=0 # line number

for i in range(7):
  if i<5:
    sbreed='Dog'
    nsubject = i+1
  else:
    sbreed='Patient'
    nsubject = i-4
  
  nseg=1

  for nT in range(T[i]):
    #print "[%d,%d]" % ( n, n+L[i]-1 )

    xblk = X[n:n+L[i]]
    assert( len(xblk) == L[i] )

    xsum = 0
    for x in xblk:
      xtok = x.split(',')
      assert( len(xtok) == 2 )
      xsum += pow( float(xtok[1]), p )

    xavg = pow( xsum / L[i], 1.0/p )

    print '%s_%d_test_segment_%04d.mat,%.16f' % \
      ( sbreed, nsubject, nseg, xavg )

    n += L[i]
    nseg += 1

