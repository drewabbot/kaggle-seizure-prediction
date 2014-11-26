
# 11/25/14: a simple script to "flip" all probabilities

import sys
from numpy import *

narg = len(sys.argv)

if narg != 2:
  print "usage: %s <file>" % sys.argv[0]
  exit(1)

path = sys.argv[1]

f = open(path)
X = f.readlines()
f.close()

N = len(X)

for n in range(N):
  xcsv = X[n].split(',')
  assert( len(xcsv) == 1 )

  x = 1 - float(xcsv[0])
  assert( x >= 0 and x <= 1 )

  print '%.17f' % ( x )

