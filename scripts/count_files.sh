#!/bin/sh

for D in * ; do
  if [ ! -d $D ] ; then continue; fi

  nseiz=`find $D -type f -name '*_preictal_*.mat' | wc -l`
  nnorm=`find $D -type f -name '*_interictal_*.mat' | wc -l`
  ntest=`find $D -type f -name '*_test_*.mat' | wc -l`

  #echo "$D: $nseiz $nnorm $ntest "
  echo "$nseiz $nnorm $ntest ; ... "
  
  ntot=`find $D -type f  | wc -l`

  if [ $ntot -ne $(($nseiz + $nnorm + $ntest)) ] ; then
      echo "extra files found in $D!"
  fi

  #echo "------------------------------------ "

done





