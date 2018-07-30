#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to convert mrc micrographs to 8bit png iwht optional binning       ###
###                                                                           ###
### This program is free software: you can redistribute it and/or modify      ###
###     it under the terms of the GNU General Public License as published by  ###
###     the Free Software Foundation, either version 3 of the License, or     ###
###     (at your option) any later version.                                   ###
###                                                                           ###
###     This program is distributed in the hope that it will be useful,       ###
###     but WITHOUT ANY WARRANTY; without even the implied warranty of        ###
###     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         ###
###     GNU General Public License for more details.                          ### 
###                                                                           ###
###     You should have received a copy of the GNU General Public License     ###
###     along with this program.  If not, see <http://www.gnu.org/licenses/>. ###
###                                                                           ###
#################################################################################

###check input
if [ -z $2 ] ; then
 echo ""
 echo "Variables empty, usage is ${0##*/} (1) (2) ..."
 echo ""
 echo "(1) = binning factor ('1' for no binning)"
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

###remove potenially existing file list
rm -f mics.list

###generate file list
for f in $mics ; do
 echo $f >> mics.list
done

###conversion
while read p ; do
 e2proc2d.py $p ${p:0:-4}.png --meanshrink $bin --outmode uint8
done < mics.list

###check if all png files where generated
PNG=`ls -l *.png | wc -l`
MRC=`cat mics.list | wc -l`

if [ $PNG -eq $MRC ] ; then
 echo
 echo "$MRC micrographs have been converted into png files with binning $bin"
 echo
else
 echo
 echo "Number of input mrc files ($MRC) and number png files in folder ($PNG) are not equal"
 echo "Either the conversion failed, or png files where already present."
 echo 
fi

rm -f mics.list

exit
