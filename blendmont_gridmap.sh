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
if [ -z $1 ] ; then
 echo
 echo 'Script to generate stiched gridmap from SerialEM stack'
 echo "Usage: ${0##*/} (1) ..."
 echo 
 echo '		(1) gridmap(s) with .st extension; wild cards allowed'
 echo
 echo 'exiting...'
 exit
fi

#load EMAN2 environment
if [ -e /usr/local/software/EMAN2/bin/e2proc2d.py ]
then
 export PATH=/usr/local/software/EMAN2/bin:$PATH
 export LD_PRELOAD=/usr/local/software/EMAN2/lib/libmpi.so
else
 export PATH=/usr/local/software/eman2/bin:$PATH
 export LD_PRELOAD=/usr/local/software/eman2/lib/libmpi.so
fi

#do stitching with blendmont from IMOD package
for f in $*
do
 extractpieces -mdoc $f ${f%%.*}.pl
 #blendmont -imin $f -plin ${f%%.*}.pl -imout ${f%%.*}.mrc -plout ${f%%.*}_out.pl -very -xcorr -rootname $PWD
 blendmont -imin $f -plin ${f%%.*}.pl -imout ${f%%.*}.mrc -plout ${f%%.*}_out.pl -xcorr -rootname $PWD
 e2proc2d.py ${f%%.*}.mrc ${f%%.*}.png --meanshrink 8 --outmode uint8
done

#clean up
rm -f ../*.yef* ../*.ecd* ../*.xef*
exit
