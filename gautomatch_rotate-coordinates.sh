#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to rotate coordinates by 90 degrees. Written for gautomatch        ###
###     usage with rotated (by newstack) K3 micrographs                       ###
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
 echo 'Script to rotate coordinates by 90 degrees. Used when gautomatch was used on rotated (newstack) K3 micrographs'
 echo
 echo "Usage ${0##*/} (1)"
 echo ''
 echo '(1) gautomatch _automatch.star files (use wildcards)'
 echo
 echo 'exiting now...'
 echo
 exit
fi

for f in $*
do
 echo "" > ${f%%.star}_rotated.star
 echo "data_" >> ${f%%.star}_rotated.star
 echo "" >> ${f%%.star}_rotated.star
 echo "loop_" >> ${f%%.star}_rotated.star
 echo "_rlnCoordinateX #1" >> ${f%%.star}_rotated.star
 echo "_rlnCoordinateY #2" >>${f%%.star}_rotated.star
 echo "_rlnAnglePsi #3" >> ${f%%.star}_rotated.star
 echo "_rlnClassNumber #4" >> ${f%%.star}_rotated.star
 echo "_rlnAutopickFigureOfMerit #5" >> ${f%%.star}_rotated.star
 cat $f | awk '{if(NR>9) print ($1-2046), (-$2+2880), $3, $4, $5}' | awk '{print -$2, $1, $3, $4, $5}' | awk '{print ($1+2880), (-$2+2046), $3, $4, $5}' >> ${f%%.star}_rotated.star
done

exit
