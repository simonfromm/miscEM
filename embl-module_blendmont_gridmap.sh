#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to generate gridmap montage from SerialEM stack. Stack must have   ###
###     .st extension and accompanying .st.mdoc file.                         ###
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

#check if input is correct
if [ -z $2 ] ; then
 echo
 echo 'Script to generate stiched gridmap from SerialEM stack'
 echo "Usage: ${0##*/} (1) ..."
 echo 
 echo '         (1) mode: <default> or <sloppy>'
 echo '         (2) gridmap(s) with .st or .map extension; wild cards allowed'
 echo
 echo 'exiting...'
 exit
fi

MODE=$1
shift

#load modules
module purge
module load IMOD

#do stitching with blendmont from IMOD package
for f in $*
do
 extractpieces -mdoc $f ${f%%.*}.pl
 if [ $MODE = default ] ; then
  blendmont -imin $f -plin ${f%%.*}.pl -imout ${f%%.*}_stiched.mrc -plout ${f%%.*}_out.pl -xcorr -rootname $PWD
 else
  blendmont -imin $f -plin ${f%%.*}.pl -imout ${f%%.*}_stiched.mrc -plout ${f%%.*}_out.pl -very -xcorr -rootname $PWD
 fi

####check if the resulting stiched image contains multiple maps, i.e. is an image stack, if so, split it up in individual images
 SEC=`header ${f%%.*}_stiched.mrc | grep columns | awk '{print $NF}'`
 if [ $SEC -gt 1 ] ; then
  newstack -split 1 -append mrc ${f%%.*}_stiched.mrc ${f%%.*}_stiched_
  rm -f ${f%%.*}_stiched.mrc
  for i in ${f%%.*}_stiched_*.mrc
  do
   newstack -shrink 8 $i ${i%%.*}_bin8.mrc
   mrc2tif -p ${i%%.*}_bin8.mrc ${i%%.*}_bin8.png
  done
  #e2proc2d.py *.mrc @.png --meanshrink 8 --outmode uint8
 else
  newstack -shrink 8 ${f%%.*}_stiched.mrc ${f%%.*}_stiched_bin8.mrc
  mrc2tif -p ${f%%.*}_stiched_bin8.mrc ${f%%.*}_stiched_bin8.png
  #e2proc2d.py ${f%%.*}.mrc ${f%%.*}.png --meanshrink 8 --outmode uint8
 fi
done

#clean up
rm -f ../*.yef* ../*.ecd* ../*.xef* *.pl

exit
