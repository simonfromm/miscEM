#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to remove duplicate particles based on X-Y coordinates from        ###
###     Relion star file                                                      ###
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
 echo 'Script to remove (potential) duplicate particles from relion star file based on X-Y coordinates'
 echo
 echo "Usage ${0##*/} (1) (2)"
 echo '(1) relion .star file from which duplicate particles should be removed'
 echo '(2) distance threshold in pixel (integer value)'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#set variables
RELION=$1
shift
THRESHOLD=$1
shift

#check if files to created are already present from previous runs
if [ -e ${RELION%*.star}_duplicate_particles.dat ] ; then
 echo
 echo "${RELION}_duplicates-removed.star already exists: please delete the file and rerun the script"
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

if [ -e particles.tmp ] ; then
 echo
 echo 'particles.tmp already exists: please delete the file and rerun the script'
 echo
 echo 'exiting now...'
 echo
 exit
fi

###define header size and split header from data
PARLINES=`cat $RELION | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
HEADER=`cat $RELION | awk '{if($1=="loop_") print NR}'`
HEADERLINES=$(( PARLINES + HEADER ))
head -${HEADERLINES} $RELION > header.tmp
cat $RELION | awk -v HEADER=${HEADERLINES} '{if(NR>HEADER) print $0}' > particles.tmp

###make micrograph list
##define column with _rlnMicrographName in CSPARC file
MICCOL=`cat $RELION | grep _rlnMicrographName | awk '{print $2}' | sed -e 's/#//g'`
#generate list
awk -v X=${MICCOL} '{print $X}' particles.tmp | uniq > mics.tmp

###
##define column with _rlnCoordinateX and _rlnCoordinateY _rlnImageName
XCOL=`cat $RELION | grep _rlnCoordinateX | awk '{print $2}' | sed -e 's/#//g'`
YCOL=`cat $RELION | grep _rlnCoordinateY | awk '{print $2}' | sed -e 's/#//g'`
IMGCOL=`cat $RELION | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`

###loop over all micrographs and remove duplicate particles
for f in `cat mics.tmp`
do
##create temporary particle list for given micrograph
 grep $f particles.tmp | awk -v X=${XCOL} -v Y=${YCOL} -v IMG=${IMGCOL} '{print $X, $Y, $IMG}' | sort -g > mic_particles.tmp
 awk -v Y=$THRESHOLD '
	$1 == p1 || $1 <= (p1 + Y) {
	print p0 $0
	p0=""
	next
	}
	{p0=$0 ORS
	p1=$1}
 ' mic_particles.tmp > mic_particles_x-double.tmp

 awk -v Y=$THRESHOLD '
	$2 >= (p2 - Y) && $2 <= (p2 + Y) {
	print $3
	}
	{p2=$2}
 ' mic_particles_x-double.tmp >> ${RELION%*.star}_duplicate_particles.dat
done

###remove duplicate particles from input starfile
##create backup
mv $RELION ${RELION}_original

grep -Fv -f ${RELION%*.star}_duplicate_particles.dat ${RELION}_original > $RELION

###calculate statistics
BEFORE=`cat particles.tmp | wc -l`
DUPLICATES=`cat ${RELION%*.star}_duplicate_particles.dat | wc -l`
AFTERSTAR=`cat $RELION | wc -l`
AFTER=$(( $AFTERSTAR - $HEADERLINES ))
PERCENT=`echo $DUPLICATES $BEFORE | awk '{printf "%i", ($1/$2) * 100}'`
SUM=$(( $DUPLICATES + $AFTER ))

###tidy up
rm -f header.tmp particles.tmp mics.tmp mic_particles.tmp mic_particles_x-double.tmp

###good bye message
echo ''
echo '######################################'
echo "$DUPLICATES particles were detected to be duplicated in ${RELION}. This corresponds to $PERCENT % of all original particles. The star file has been updated accordingly and contains now $AFTER particles. The old star file is now saved as ${RELION}_original ."
echo '######################################'
echo ''

exit
