#!/bin/bash

###script to transform tif files into mrc files; unsinged integer 8 bit output

for f in $*
do
	e2proc2d.py $f ${f:0:-4}.mrc --outmode uint8
done

exit
