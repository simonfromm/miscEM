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
 echo '         (2) gridmap(s) with .st extension; wild cards allowed'
 echo
 echo 'exiting...'
 exit
fi

MODE=$1
shift

#load EMAN2 environment
source ~/.initialize_eman2-sphire.sh && conda activate

#do stitching with blendmont from IMOD package
for f in $*
do
 extractpieces -mdoc $f ${f%%.*}.pl
 if [ $MODE = default ] ; then
  blendmont -imin $f -plin ${f%%.*}.pl -imout ${f%%.*}.mrc -plout ${f%%.*}_out.pl -xcorr -rootname $PWD
 else
  blendmont -imin $f -plin ${f%%.*}.pl -imout ${f%%.*}.mrc -plout ${f%%.*}_out.pl -very -xcorr -rootname $PWD
 fi
 e2proc2d.py ${f%%.*}.mrc ${f%%.*}.png --meanshrink 8 --outmode uint8
done

#clean up
rm -f ../*.yef* ../*.ecd* ../*.xef*

exit
