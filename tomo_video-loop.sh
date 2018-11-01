#!/bin/sh

#individual slices need to start at 10000 and in the format BASE-10000.tif
#slices need to be in the same folder and noting else present
#slices need to be in .tif format and not more than 999

#check highest image number
SLICES=`ls -l *.tif | tail -1 | awk '{print $9}'`
SLICES=${SLICES##*-}
SLICES=${SLICES%.tif}

#define BASENAME
BASE=`ls -l *.tif | tail -1 | awk '{print $9}'`
BASE=${BASE%-*.tif}

i=$SLICES
j=$SLICES

while [ $i -ge 10000 ]
do
 j=$(( j+1 ))
 cp ${BASE}-${i}.tif ${BASE}-${j}.tif
 i=$(( i-1 ))
done

exit
