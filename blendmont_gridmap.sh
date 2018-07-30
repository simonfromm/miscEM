#!/bin/bash
######################################
###script to prepare gridmap montage from stack
###stack must have .st ending and accompanying .st.mdoc file

export PATH=/usr/local/software/EMAN2/bin:$PATH
export LD_PRELOAD=/usr/local/software/EMAN2/lib/libmpi.so

for f in $*
do
	extractpieces -mdoc $f ${f:0:-3}.pl
	blendmont -imin $f -plin ${f:0:-3}.pl -imout ${f:0:-3}.mrc -plout ${f:0:-3}_out.pl -very -xcorr -rootname $PWD
	#blendmont -imin $f -plin ${f:r}.pl -imout ${f:r}.mrc -plout ${f:r}_out.pl -xcorr -rootname $PWD
	e2proc2d.py ${f:0:-3}.mrc ${f:0:-3}.png --meanshrink 8 --outmode uint8
done

rm -f ../*.yef* ../*.ecd* ../*.xef*
exit
