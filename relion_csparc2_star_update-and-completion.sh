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
if [ -z $3 ] ; then
 echo
 echo 'Script to correct the particles path from a csparc2 star file (converted using pyEM) based on _rlnImageName from the original relion star file'
 echo '     Script will also add fields present in the original relion star file but missing in the csparc2 star file to the newly generated star file' 
 echo
 echo "Usage ${0##*/} (1) (2) (3)"
 echo '(1) relion .star file from which the partices should be selected'
 echo '(2) csparc2 .star file with the selected particles'
 echo '(3) start of common micrograph name string (e.g. 18Sep10 )'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#check if files to created are already present from previous runs
if [ -e csparc2_particles.tmp ] ; then
 echo
 echo 'csparc2_particles.tmp already exists: please delete the file and rerun the script'
 echo
 echo 'exiting now...'
 echo
 exit
fi

if [ -e csparc2_particles_relion-path.tmp ] ; then
 echo
 echo 'csparc2_particles_relion-path.tmp already exists: please delete the file and rerun the script'
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

if [ -e csparc2_particles_relion-parameters.tmp ] ; then
 echo
 echo 'csparc2_particles_relion-path.tmp already exists: please delete the file and rerun the script'
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
RELION=$1
shift
CSPARC=$1
shift
MICSTRING=$1
shift

###make list of particles from CSPARC based on _rlnImageName
#define column with _rlnImageName in CSPARC file
IMGCOL=`cat $CSPARC | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`

#define header size
PARLINES=`cat $CSPARC | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
HEADER=`cat $CSPARC | awk '{if($1=="loop_") print NR}'`
HEADERLINES=$(( PARLINES + HEADER ))

awk -v X=$HEADERLINES -v Y=$IMGCOL '{if(NR>X) print $Y}' $CSPARC >> csparc2_particles.tmp
awk -v X=$HEADERLINES '{if(NR>X) print $0}' $CSPARC >> csparc2_star_noheader.tmp

####prepare header for new star file from relion star file
PARLINES=`cat $RELION | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
HEADER=`cat $RELION | awk '{if($1=="loop_") print NR}'`
HEADERLINES=$(( PARLINES + HEADER ))

awk -v X=$HEADERLINES '{if(NR<=X) print $0}' $RELION >> header.tmp

###sed replacement of csparc2 particle path by relion particle path
#csparc2 path
CPATH=`head -1 csparc2_particles.tmp | sed -e 's/@/ /g' | awk '{print $2}' | sed -e "s/$MICSTRING/ /g" | awk '{print $1}'`

echo $CPATH | sed -e 's/\//\\\//g' >> tmp.tmp

CPATH=`cat tmp.tmp`

rm -f tmp.tmp

#relion path
IMGCOL=`cat $RELION | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`
RPATH=`awk -v X=$HEADERLINES -v Y=$IMGCOL '{if(NR>X) print $Y}' $RELION | head -1 | sed -e 's/@/ /g' | awk '{print $2}' | sed -e "s/$MICSTRING/ /g" | awk '{print $1}'`

echo $RPATH | sed -e 's/\//\\\//g' >> tmp.tmp

RPATH=`cat tmp.tmp`

rm -f tmp.tmp

#sed replacement
cat csparc2_particles.tmp | sed -e "s/$CPATH/$RPATH/g" >> csparc2_particles_relion-path.tmp
cat csparc2_star_noheader.tmp | sed -e "s/$CPATH/$RPATH/g" >> csparc2_star_noheader_relion-path.tmp
###find particles defined in csparc2_particles_relion-path.tmp in Relion star file
grep -Ff csparc2_particles_relion-path.tmp $RELION >> csparc2_particles_relion-parameters.tmp

###compare headers and identify fields missing in the csparc star file
cat $RELION | grep _rln | awk '{print $1}' >> relion_parameters.tmp
cat $CSPARC | grep _rln | awk '{print $1}' >> csparc_parameters.tmp

MISSING=`grep -Fvf csparc_parameters.tmp relion_parameters.tmp`

#make one file for each missing column
i=1
for f in $MISSING
do
 X=`cat $RELION | grep $f | awk '{print $2}' | sed -e 's/#//g'`
 cat csparc2_particles_relion-parameters.tmp | awk -v X=$X '{print $X}' >> FIELD${i}.tmp
 i=$(( i + 1))
done

###combine data
paste -d " " csparc2_star_noheader_relion-path.tmp FIELD*.tmp >> particles_from_csparc2_full-parameters.tmp

####prepare header for new star
PARLINES=`cat $CSPARC | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
HEADER=`cat $CSPARC | awk '{if($1=="loop_") print NR}'`
HEADERLINES=$(( PARLINES + HEADER ))

awk -v X=$HEADERLINES '{if(NR<=X) print $0}' $CSPARC >> csparc_header.tmp

i=$(( PARLINES + 1 ))
for f in $MISSING
do
 echo $f \#${i}>> missing_relion_fields.tmp
 i=$(( i + 1 ))
done

cat csparc_header.tmp missing_relion_fields.tmp >> new_header.tmp 

###combine header and data
cat new_header.tmp particles_from_csparc2_full-parameters.tmp >> particles_from_csparc2.star

###prepare nice summary
PARTIN=`cat csparc2_particles.tmp | wc -l`
PARTOUT=`cat csparc2_particles_relion-parameters.tmp | wc -l`

###tidy up
rm -f header.tmp csparc2_particles_relion-parameters.tmp csparc2_particles_relion-path.tmp csparc2_particles.tmp csparc2_star_noheader.tmp csparc2_star_noheader_relion-path.tmp new_header.tmp particles_from_csparc2_full-parameters.tmp missing_relion_fields.tmp relion_parameters.tmp csparc_parameters.tmp FIELD*.tmp csparc_header.tmp

###good bye message
echo ''
echo '######################################'
echo "$PARTIN particles from $CSPARC have been searched for in $RELION and $PARTOUT have been found and written to particles_from_csparc2.star with all parameters from $RELION maintained"
echo '######################################'
echo ''

exit
