#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to remove optics table from Relion star file for import into       ###
###     cryoSPARCv2                                                           ###
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
 echo 'Script to remove optics table from Relion star file for import into cryosSPARCv2'
 echo
 echo "Usage ${0##*/} (1)"
 echo '(1) relion.star file with optics'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#set variables
IN=$1
shift
OUT=${IN%*.star}_noOptics.star

#check if files to created are already present from previous runs
if [ -e $OUT ] ; then
 echo
 echo "$OUT already exists: please delete the file and rerun the script"
 echo
 echo 'exiting now...'
 echo
 exit
fi

###find line number where particle data starts
DATA=`cat $IN | awk '{if($1=="data_particles") print NR}'`

###make new header
echo data_ > tmp1.dat

###generate new star file without optics
cat $IN | awk -v X=$DATA '{if(NR>X) print $0}' > tmp2.dat

###combine
cat tmp1.dat tmp2.dat > $OUT

###tidy up
rm -f tmp1.dat tmp2.dat

###good bye message
echo ''
echo '######################################'
echo "Optics table has been removed from $IN and new star file is saved in $OUT"
echo '######################################'
echo ''

exit
