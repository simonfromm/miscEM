#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to find select particles from a relion star file based on a        ###
###     selection from cryoSPARCv2                                            ###
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
 echo 'Script to add _rlnBeamTiltClass as a file to a relion star file'
 echo '     Tilt class is taken from last digits of rlnImageName (e.g. data recorded using SerialEM ImageShift)' 
 echo
 echo "Usage ${0##*/} (1)"
 echo '(1) relion .star file which should be modified'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#check if files to created are already present from previous runs
if [ -e ${1%.star}_rlnBeamTiltClass.star ] ; then
 echo
 echo " ${1%.star}_rlnBeamTiltClass.star already exists: please delete the file and rerun the script"
 echo
 echo 'exiting now...'
 echo
 exit
fi

#set variables
STAR_IN=$1

##define header size and create new header
PARLINES=`cat $STAR_IN | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
HEADER=`cat $STAR_IN | awk '{if($1=="loop_") print NR}'`
HEADERLINES=$(( PARLINES + HEADER ))

awk -v X=$HEADERLINES '{if(NR>X) print $0}' $STAR_IN > old_star_noheader.tmp
awk -v X=$HEADERLINES '{if(NR<=X) print $0}' $STAR_IN > new_header.tmp

i=$(( PARLINES + 1 ))
echo "_rlnBeamTiltClass #${i}" > new_header.tmp

###generate file with rlnBeamTiltClass
#define column with _rlnImageName in CSPARC file
IMGCOL=`cat $STAR_IN | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`
awk -v X=${IMGCOL} '{print $X}' old_star_noheader.tmp | sed -e 's/.mrcs//g' -e 's/_/ /g' | awk '{printf "%i\n", $NF}' | sed -e 's/0//g' > rlnBeamTiltClass.tmp

###add rlnBeamTiltClass to old star file
paste -d " " old_star_noheader.tmp rlnBeamTiltClass.tmp > new_star_noheader.tmp

###combine header and data
cat new_header.tmp new_star_noheader.tmp > ${STAR_IN%.star}_rlnBeamTiltClass.star

###tidy up
rm -f old_star_noheader.tmp new_header.tmp rlnBeamTiltClass.tmp new_star_noheader.tmp

###good bye message
echo ''
echo '######################################'
echo "rlnBeamTiltClass has been added to $STAR_IN"
echo ''
echo "New star file: ${STAR_IN%.star}_rlnBeamTiltClass.star"
echo '######################################'
echo ''

exit
