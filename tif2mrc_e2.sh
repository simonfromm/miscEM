#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to transform tif files into mrc files                              ###
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

#check input
if [ -z $2 ] ; then
 echo
 echo "Script to transform tif into mrc files using e2proc2d.py"
 echo "Usage: ${0##*/} (1) (2)..."
 echo 
 echo "		(1) outmode: float, int8, int16, int32, uint8, uint16 or uint32"
 echo "		(2) files to be converted; wild cards accepted"
 echo 
 echo "exiting..."
 echo
 exit
fi

#set variable
OUTMODE=$1
shift
MICS=$*

#generate micrograph list
rm -f mics.list

for f in $MICS ; do
 echo $f >> mics.list
done

NUM=`cat mics.list | wc -l`

#load eman environment
export PATH=/usr/local/software/EMAN2/bin:$PATH
export LD_PRELOAD=/usr/local/software/EMAN2/lib/libmpi.so


while read p ; do
 e2proc2d.py $p ${p%.*}.mrc --outmode $OUTMODE
done < mics.list

rm -f mics.list

echo
echo "$NUM micrographs have been converted from tif to $OUTMODE mrc files"
echo

exit
