#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
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
 echo 'Script to select particles from a relion star file based on _rlnImageName from a csparc2 selection'
 echo '     csparc2 .cs file needs to be already converted to .star using pyEM'
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

echo $RPATH | sed -e 's/\//\\\//g' > tmp.tmp

RPATH=`cat tmp.tmp`

rm -f tmp.tmp

#sed replacement
cat csparc2_particles.tmp | sed -e "s/$CPATH/$RPATH/g" > tmp.tmp

#different particle numbering in relion star file if it came from a polishing job
if [ $RELION = shiny.star ]
then
 cat tmp.tmp | sed -e 's/@/ /g' | awk '{printf "%i %s\n", $1, $2 }' | sed -e 's/ /@/g' | awk '{print "",$0}' > csparc2_particles_relion-path.tmp
 rm -f tmp.tmp
else
 mv tmp.tmp csparc2_particles_relion-path.tmp
fi

#define path of _rlnImageName from SOURCE file
#IMGCOLSOURCE=`cat $SOURCE | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`
#IMGPATH=`cat $SOURCE | grep @ | head -1 | awk -v X=$IMGCOLSOURCE '{print $X}' | sed -e 's/@/ /g' | awk '{print $2}'`
#IMGPATH=`dirname $IMGPATH`



#MICCOL=`cat $TARGET | grep @ | awk -v X=$IMGCOL '{print $X}' | sed -e 's/@/ /g' -e 's/\// /g' | awk '{print NF}' | head -1`
#cat $TARGET | grep @ | awk -v X=$IMGCOL '{print $X}' | sed -e 's/@/@ /g' -e 's/\// /g' | awk -v X=$MICCOL -v Y=$IMGPATH '{print $1 Y "/" $X}' >> img_mic_target.tmp

###find particles defined in csparc2_particles_relion-path.tmp in Relion star file
grep -Ff csparc2_particles_relion-path.tmp $RELION >> csparc2_particles_relion-parameters.tmp

###combine header and data
cat header.tmp csparc2_particles_relion-parameters.tmp > particles_from_csparc2.star

###prepare nice summary
PARTIN=`cat csparc2_particles.tmp | wc -l`
PARTOUT=`cat csparc2_particles_relion-parameters.tmp | wc -l`

###tidy up
rm -f header.tmp csparc2_particles_relion-parameters.tmp csparc2_particles_relion-path.tmp csparc2_particles.tmp

###good bye message
echo ''
echo '######################################'
echo "$PARTIN particles from $CSPARC have been searched for in $RELION and $PARTOUT have been found and written to particles_from_csparc2.star with all parameters from $RELION maintained"
echo '######################################'
echo ''

exit
