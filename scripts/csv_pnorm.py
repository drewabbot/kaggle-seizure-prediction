
import sys

narg = len(sys.argv)

if narg!=3 and narg!=4:
  print "usage: %s <fpath> <p> [nsubject]" % sys.argv[0]
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

# optional extra argument: the single subject contained in input file
#  ( defaults to all subjects )
if narg == 4:
  nsubject = int(sys.argv[3])
  assert( 1 <= nsubject and nsubject <= 7 )

  nsegs = T[nsubject-1]
  assert( N % nsegs == 0 )

  nsampsPerSeg = N / nsegs
  assert( N == nsampsPerSeg*nsegs )

  #print 'subject%d: nsampsPerSeg[%d] ' % ( nsubject, nsampsPerSeg )

  L = [ nsampsPerSeg ] * 7
  irange = [ nsubject-1 ]

  # for this case, assume only one csv token per line
  ntok = 1

else:
  # the default number of samples for each subject
  #  ( assuming 8-sec, 63/64 overlap, upsampled by 8 )
  L = [ 37849, 37849, 37849, 37849, 37849, 37889, 37889 ]

  assert( N == sum( [ (i*j) for (i,j) in zip(T,L) ] ) )

  # default to all subjects
  irange = range(7)

  # for this case, assume two csv tokens per line
  ntok = 2

assert( len(T) == 7 )
assert( len(L) == 7 )


n=0 # line number

for i in irange:
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
      assert( len(xtok) == ntok )
      xsum += pow( float(xtok[ntok-1]), p )

    xavg = pow( xsum / L[i], 1.0/p )

    print '%s_%d_test_segment_%04d.mat,%.16f' % \
      ( sbreed, nsubject, nseg, xavg )

    n += L[i]
    nseg += 1

