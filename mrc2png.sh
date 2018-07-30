#!/bin/bash
######################################
###script to convert mrc micrographs to 8bit png with optional binning
###uses e2proc2d.py

###check input
if [ -z $2 ] ; then
	echo ""
	echo "Variables empty, usage is $0 (1) (2) ..."
	echo ""
	echo "(1) = binning factor"
	echo "(2) = input micrographs"
	echo ""

	exit
fi

###load eman environment
export PATH=/usr/local/software/EMAN2/bin:$PATH
export LD_PRELOAD=/usr/local/software/EMAN2/lib/libmpi.so

###set variables
bin=$1
shift
mics=$*

###conversion
for f in $mics ; do
	e2proc2d.py $f ${f:0:-4}.png --meanshrink $bin --outmode uint8
done
exit
