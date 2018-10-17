#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to add missing information to star file generated by pyEM from     ###
###     csparc2 2D selection                                                  ###
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
 echo 'Script to add _rlnCoordinateX , _rlnCoordinateY and _rlnMicrographName to star file generated from csparc 2D select by pyEM'
 echo
 echo "Usage ${0##*/} (1) (2)"
 echo '(1) .star file from pyEM; your target'
 echo '(2) particles.star file from Relion with the missing field'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#check if files to created are already present from previous runs
if [ -e img_mic_target.tmp ] ; then
 echo
 echo 'img_mic_target.tmp already exists: please delete the file and rerun the script'
 echo
 echo 'exiting now...'
 echo
 exit
fi

if [ -e particles_new.tmp ] ; then
 echo
 echo 'particles_new.tmp already exists: please delete the file and rerun the script'
 echo
 echo 'exiting now...'
 echo
 exit
fi

if [ -e header.tmp ] ; then
 echo
 echo 'header.tmp already exists: please delete the file and rerun the script'
 echo
 echo 'exiting now...'
 echo
 exit
fi

if [ -e particles_from_csparc2.star ] ; then
 echo
 echo 'particles_from_csparc2.star already exists: please delete the file and rerun the script'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#set variables
TARGET=$1
shift
SOURCE=$1
shift

###make list of _rlnImageName from TARGET star file with correct Relion path from SOURCE file
#define column with _rlnImageName in TARGET file
IMGCOL=`cat $TARGET | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`

#define path of _rlnImageName from SOURCE file
IMGCOLSOURCE=`cat $SOURCE | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`
IMGPATH=`cat $SOURCE | grep @ | head -1 | awk -v X=$IMGCOLSOURCE '{print $X}' | sed -e 's/@/ /g' | awk '{print $2}'`
IMGPATH=`dirname $IMGPATH`



MICCOL=`cat $TARGET | grep @ | awk -v X=$IMGCOL '{print $X}' | sed -e 's/@/ /g' -e 's/\// /g' | awk '{print NF}' | head -1`
cat $TARGET | grep @ | awk -v X=$IMGCOL '{print $X}' | sed -e 's/@/@ /g' -e 's/\// /g' | awk -v X=$MICCOL -v Y=$IMGPATH '{print $1 Y "/" $X}' >> img_mic_target.tmp

###find particles defined in img_mic_target.tmp in SOURCE file
grep -Ff img_mic_target.tmp $SOURCE >> particles_new.tmp

####prepare header for new starfile
PARLINES=`cat $SOURCE | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
HEADER=`cat $SOURCE | awk '{if($1=="loop_") print NR}'`
HEADERLINES=$(( PARLINES + HEADER ))

awk -v X=$HEADERLINES '{if(NR<=X) print $0}' $SOURCE >> header.tmp

###combine header and data
cat header.tmp particles_new.tmp >> particles_from_csparc2.star

###tidy up
rm -f img_mic_target.tmp header.tmp particles_new.tmp

exit
