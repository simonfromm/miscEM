#!/bin/bash

#################################################################################
### Simon Fromm, EMBL 2021                                                    ###
###                                                                           ###
### Script to concatenate particle coordinates in the Relion star format      ###
###     in order to import them into cryoSPARC                                ###
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
 echo 'Script to concatenate coordinates in the Relion star format into one single file for import to cryoSPARC'
 echo '     Script assumes that each input file contains coordinate information (_rlnCoordinateX and _rlnCoordinateY) of one micrograph and that the file has the same name as the micrograph; the extension _manualpick is acceptable.'
 echo
 echo "Usage ${0##*/} (*) ..."
 echo '(*) all coordinate files you want to concatenate; use of wildcards is encouraged'
 echo
 echo 'exiting now...'
 echo
 exit
fi

FIRST=$1

ALL=$*

#get column number of _rlnCoordinateX and _rlnCoordinateY
XCOL=`grep _rlnCoordinateX $FIRST | awk '{print $2}' | sed -e 's/#//'`
YCOL=`grep _rlnCoordinateY $FIRST | awk '{print $2}' | sed -e 's/#//'`

#get line number where data entries start
LASTHEAD=`grep "#" $FIRST | awk '{print $2}' | tail -1`
START=`cat $FIRST | awk -v X=$LASTHEAD '{if($2==X) print NR}'`

#generate header
echo "" >> header.tmp
echo "data_" >> header.tmp
echo "" >> header.tmp
echo "loop_" >> header.tmp
echo "_rlnCoordinateX #1" >> header.tmp
echo "_rlnCoordinateY #2" >> header.tmp
echo "_rlnMicrographName #3" >> header.tmp

#loop over all input files and collect coordinate and micrograph information
for f in $ALL
do
	NAME=`echo $f | sed -e 's/_manualpick//g'`
	cat $f | awk -v L=$START -v X=$XCOL -v Y=$YCOL -v N=$NAME '{if(NR>L) print $X, $Y, N}' >> particles_all.tmp
done

#remove empty lines form the particle_all.tmp file
awk 'NF' particles_all.tmp > particles.tmp

#count the total number of particles
TOTAL=`cat particles.tmp | wc -l`

#count number of input micrographs
MICS=`ls $ALL | wc -l`

#calculate number of particles per micrograph
PERMIC=`cat header.tmp | awk -v T=$TOTAL -v M=$MICS '{if(NR==1) printf "%.0f\n", T/M }'`

#add header to particles
cat header.tmp particles.tmp > concatenated_particles.star

#remove intermediate files
rm -f particles_all.tmp particles.tmp header.tmp

#generate exit statement
echo ""
echo "######################################"
echo "A total of $TOTAL particles from $MICS micrographs have been concatenated into concatenated_particles.star. That corresponds to $PERMIC particles per micrograph on average."
echo "######################################"
echo ""

exit
