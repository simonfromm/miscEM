#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to transform tif files into mrc files using tif2mrc from imod      ###
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
if [ -z $1 ] ; then
 echo
 echo "Script to transform tif into mrc files using tif2mrc from imod"
 echo "Usage: ${0##*/} (1)..."
 echo 
 echo "		(1) files to be converted; wild cards accepted"
 echo 
 echo "exiting..."
 echo
 exit
fi

#set variable
MICS=$*

#generate micrograph list
rm -f mics.list

for f in $MICS ; do
 echo $f >> mics.list
done

NUM=`cat mics.list | wc -l`

while read p ; do
 tif2mrc $p ${p%.*}.mrc
done < mics.list

rm -f mics.list

echo
echo "$NUM micrographs have been converted from tif to mrc files"
echo

exit
