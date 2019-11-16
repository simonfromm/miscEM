#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to make transform cryolo CBOX coordinates to relion star           ###
###     coordinates with desired threshold                                    ###
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
 echo "Script to transform cryolo CBOX coordinates to relion star coordinates with desired threshold"
 echo ""
 echo "Usage is ${0##*/} (1) (2) ..."
 echo ""
 echo "(1) = threshold"
 echo "(2) = CBOX files to convert"
 echo ""
 exit
fi

#define input variables
CUTOFF=$1
shift
COORD_FILES=$*

#generate relion star header file
echo "" > relion_coord_star_header.tmp
echo "data_" >> relion_coord_star_header.tmp
echo "" >> relion_coord_star_header.tmp
echo "loop_" >> relion_coord_star_header.tmp
echo "_rlnCoordinateX #1" >> relion_coord_star_header.tmp
echo "_rlnCoordinateY #2" >> relion_coord_star_header.tmp
echo "_rlnClassNumber #3" >> relion_coord_star_header.tmp
echo "_rlnAnglePsi #4" >> relion_coord_star_header.tmp
echo "_rlnAutopickFigureOfMerit  #5" >> relion_coord_star_header.tmp

#transform coordinate files
for f in $COORD_FILES
do
 cat $f | awk -v X=$CUTOFF '{if($5>X) print $1+($3/2), $2+($4/2), -999, -999.0, -999.0}' > tmp.star 
 cat relion_coord_star_header.tmp tmp.star > ${f%%.cbox}_manualpick.star
 rm -f tmp.star
done

rm -f relion_coord_star_header.tmp

exit
