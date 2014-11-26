
def equal( x, y, eps=1e-6 ):

  global maxdiff

  d = abs( x - y )

  if d < eps: # absolute diff ( for "tiny" numbers )
    diff = d
    maxdiff = max(maxdiff,diff)
    return True

  else: # relative diff ( for "normal" numbers, which aren't "tiny" )
    x = abs(x)
    y = abs(y)
    m = max(x,y)

    diff = d/m # note: this allows divide by zero
    maxdiff = max(maxdiff,diff)

    if d <= m * eps:
      return True
    else:
      return False


def csv_cmp( X, Y ):

  nX = len(X)
  nY = len(Y)
  
  if 0: # force files to be same length
    assert( nX == nY )
    N = nX
  else: # allow different length files
    N = min(nX,nY)
    

  # cols 1-K should be exactly equal, and
  # cols K+1 and above should be approximately equal
  K = 1

  for i in range(N):
    # skip first line
    if i==0: continue
    
    x = X[i]
    y = Y[i]

    xcols = x.split(',')
    ycols = y.split(',')

    # they should of course have the same number of columns
    assert( len(xcols) == len(ycols) )

    # cols 1-K should be exactly equal
    assert( xcols[0:K] == ycols[0:K] )

    # cols K+1 and above should be approximately equal
    xfloats = [ float(x) for x in xcols[K:] ]
    yfloats = [ float(y) for y in ycols[K:] ]
  
    diffs = [ equal(x,y) for (x,y) in zip(xfloats,yfloats) ]

    if False in diffs:
      print 'error: found diff[%.16f] at line %d' % ( maxdiff, i+1 )
      exit(-1)

#############################################################

import sys

narg = len(sys.argv)
if narg != 3:
  print 'usage: %s <x.csv> <y.csv>' % sys.argv[0]
  exit(1)
  
path1 = sys.argv[1]
path2 = sys.argv[2]

f = open(path1)
X = f.readlines()
f.close()

f = open(path2)
Y = f.readlines()
f.close()

maxdiff = 0

csv_cmp( X, Y )
  
print 'success! maxdiff: %.3e' % maxdiff

exit(0)

