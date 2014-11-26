
import sys

narg = len(sys.argv)

if narg != 3:
  print "usage: %s <f1> <f2>" % sys.argv[0]
  exit(1)

path1 = sys.argv[1]
path2 = sys.argv[2]

f1 = open(path1)
X1 = f1.readlines()
f1.close()
f2 = open(path2)
X2 = f2.readlines()
f2.close()

N = len(X1)
assert( len(X2) == N )

# power mean parameter
p=1.0

n=0 # line number

for i in range(N):
  x1 = X1[i].split(',')
  x2 = X2[i].split(',')
  assert( len(x1) == 2 )
  assert( len(x2) == 2 )

  if i==0:
    print '%s,%s' % ( x1[0], x1[1].strip() )
    continue

  ######################
  # p-norm
  xsum = 0
  for x in [ x1, x2 ]:
    xsum += pow( float(x[1]), p )
  xavg = pow( xsum / 2.0, 1.0/p )

  ######################
  # weighted mean
  #xavg = 0.6*float(x1[1]) + 0.4*float(x2[1])

  ######################
  # geometric mean
  #xavg = pow( float(x1[1])*float(x2[1]), 0.5 );

  # clip
  if xavg < 0:
    xavg = 0
  if xavg > 1:
    xavg = 1
  assert( xavg >= 0 and xavg <= 1 )

  n += 1
  print '%s,%.17f' % ( x1[0], xavg )

