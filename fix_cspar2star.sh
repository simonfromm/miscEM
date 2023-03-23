#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019, EMBL 2023                                  ###
###                                                                           ###
### Script to select particles from a relion star file based on a             ###
###     cryoSPARCv2/3 cs file which has been converted to star                ###
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
 echo '(1) original relion .star file'
 echo '(2) csparc2 .star file generated by pyEM'
 echo '(3) do you want to resort particles? it can take long! Only necessary when this script gave a WRONG star file without resorting! <YES> or <NO>'
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
RESORT=$1
shift

###test if optics table exists in star file converted from cryosparc with pyem
OPTICS=`cat $CSPARC | grep data_optics | wc -l`

#remove optics from the original star file if present
if [ $OPTICS -eq 1 ]
then
 mv $CSPARC ${CSPARC}_ori
 DATA=`cat ${CSPARC}_ori | awk '{if($1=="data_particles") print NR}'`
 cat ${CSPARC}_ori | awk -v X=$DATA '{if(NR>=X) print $0}' > $CSPARC
fi

###test if optics table exists in original star file
OPTICS=`cat $RELION | grep data_optics | wc -l`

#remove optics from the original star file if present
if [ $OPTICS -eq 1 ]
then
 mv $RELION ${RELION}_ori
 DATA=`cat ${RELION}_ori | awk '{if($1=="data_particles") print NR}'`
 cat ${RELION}_ori | awk -v X=$DATA '{if(NR>=X) print $0}' > $RELION
fi

###make list of particles from CSPARC based on _rlnImageName
#define column with _rlnImageName in CSPARC file
IMGCOL=`cat $CSPARC | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`

#define header size
PARLINES=`cat $CSPARC | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
HEADER=`cat $CSPARC | awk '{if($1=="loop_") print NR}'`
HEADERLINES=$(( PARLINES + HEADER ))


awk -v X=$HEADERLINES '{if(NR>X) print $0}' $CSPARC >> csparc2_star_noheader.tmp

###Resort if necessary
if [ $RESORT = YES ]
then
 awk -v Y=$IMGCOL '{print $Y}' csparc2_star_noheader.tmp | sed -e 's/\// /g' | awk '{print $NF}' | sed -e 's/_/ /' | awk '{print $2}' | sort -g | uniq > uniq_mics.lst
 awk -v Y=$IMGCOL '{print $Y}' csparc2_star_noheader.tmp | sed -e 's/@/ /g' | sed -e 's/_/ /' | awk '{print $1, $NF}' | sed -e 's/ //g' > tmp.tmp
 paste tmp.tmp csparc2_star_noheader.tmp > tmp2.tmp
 rm -f tmp.tmp
 for f in `cat uniq_mics.lst`
 do
  cat tmp2.tmp | grep $f | sort -g > ${f}.sorted
 done
 cat *.sorted | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}' > tmp.tmp
 mv tmp.tmp csparc2_star_noheader.tmp
 rm -f tmp2.tmp uniq_mics.lst
 awk -v Y=$IMGCOL '{print $Y}' csparc2_star_noheader.tmp > csparc2_particles.tmp
 rm -f *.sorted
else
 awk -v X=$HEADERLINES -v Y=$IMGCOL '{if(NR>X) print $Y}' $CSPARC >> csparc2_particles.tmp
fi

####prepare header for new star file from relion star file
PARLINES=`cat $RELION | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
HEADER=`cat $RELION | awk '{if($1=="loop_") print NR}'`
HEADERLINES=$(( PARLINES + HEADER ))


###sed replacement of csparc2 particle path by relion particle path
#csparc2 path
CPATH=`head -1 csparc2_particles.tmp | sed -e 's/@/ /g' -e 's/\(.*\)\//\1 /' | awk '{print $2}'`

echo $CPATH | sed -e 's/\//\\\//g' >> tmp.tmp

CPATH=`cat tmp.tmp`

rm -f tmp.tmp

#relion path
IMGCOL=`cat $RELION | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`
RPATH=`awk -v X=$HEADERLINES -v Y=$IMGCOL '{if(NR>X) print $Y}' $RELION | head -1 | sed -e 's/@/ /g' -e 's/\(.*\)\//\1 /' | awk '{print $2}'` 

echo $RPATH | sed -e 's/\//\\\//g' >> tmp.tmp

RPATH=`cat tmp.tmp`

rm -f tmp.tmp

#sed replacement
cat csparc2_particles.tmp | sed -e "s/$CPATH/$RPATH/g" >> tmp.tmp
cat csparc2_star_noheader.tmp | cut -d " " -f2-  >> csparc2_no-image-names.tmp

#different particle numbering in relion star file if it came from a polishing job
if [ $RELION = shiny.star ]
then
 cat tmp.tmp | sed -e 's/@/ /g' | awk '{printf "%i %s\n", $1, $2 }' | sed -e 's/ /@/g' | awk '{print "",$0}' > tmp2.tmp
 rm -f tmp.tmp
else
 mv tmp.tmp tmp2.tmp 
fi

#remove extra number string cryosparc attaches to each image name
cat tmp2.tmp | sed -e 's/\(.*\)\//\1 /' | awk '{print $2, $1}' | cut -c 23- | awk '{print $2, $1}' | sed -e 's/ /\//' > csparc2_particles_relion-path.tmp

rm -f tmp2.tmp

paste -d " " csparc2_particles_relion-path.tmp csparc2_no-image-names.tmp >> csparc2_star_noheader_relion-path.tmp
rm -f csparc2_no-image-names.tmp



###resort the original relion particles star file in the exact same way, to ensure to have the same sorting! This involves removing headers first and then resorting the plain data file after putting the image info from the particle names into the first column (temporarily)
#optis has alredy been removed from the relion star file above

IMGCOLRE=`cat $RELION | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`
PARLINES=`cat $RELION | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
HEADER=`cat $RELION | awk '{if($1=="loop_") print NR}'`
HEADERLINES=$(( PARLINES + HEADER ))

if [ $RESORT = YES ]
then
 awk -v X=$HEADERLINES '{if(NR>X) print $0}' $RELION | sed -e '/^$/d' >> relion_noheader.tmp
 awk -v Y=$IMGCOLRE '{print $Y}' relion_noheader.tmp | sed -e 's/\// /g' | awk '{print $NF}' | sort -g | uniq > uniq_mics.lst
 awk -v Y=$IMGCOLRE '{print $Y}' relion_noheader.tmp | sed -e 's/@/ /g' | sed -e 's/\// /g' | awk '{print $1, $NF}' | sed -e 's/ //g' > tmp.tmp
 paste tmp.tmp relion_noheader.tmp > tmp2.tmp
 rm -f tmp.tmp
 for f in `cat uniq_mics.lst`
 do
  cat tmp2.tmp | grep $f | sort -g > ${f}.sorted
 done
 cat *.sorted | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}' > tmp.tmp
 mv tmp.tmp relion_noheader.tmp
 rm -f tmp2.tmp uniq_mics.lst *.sorted
else
 awk -v X=$HEADERLINES '{if(NR>X) print $0}' $RELION | sed -e '/^$/d' >> relion_noheader.tmp
fi

###find particles defined in csparc2_particles_relion-path.tmp in RESORTED Relion star file
grep -Fwf csparc2_particles_relion-path.tmp relion_noheader.tmp >> csparc2_particles_relion-parameters.tmp

###compare headers and identify fields missing in the csparc star file
cat $RELION | grep _rln | awk '{print $1}' >> relion_parameters.tmp
cat $CSPARC | grep _rln | awk '{print $1}' >> csparc_parameters.tmp

MISSING=`grep -Fvxf csparc_parameters.tmp relion_parameters.tmp`

#make one file for each missing column
i=1
for f in $MISSING
do
 if [ $i -lt 10 ]
 then
  X=`cat $RELION | grep -w $f | awk '{print $2}' | sed -e 's/#//g'`
  cat csparc2_particles_relion-parameters.tmp | awk -v X=$X '{print $X}' >> FIELD0${i}.tmp
  i=$(( i + 1))
 else
  X=`cat $RELION | grep -w $f | awk '{print $2}' | sed -e 's/#//g'`
  cat csparc2_particles_relion-parameters.tmp | awk -v X=$X '{print $X}' >> FIELD${i}.tmp
  i=$(( i + 1))
 fi
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
 echo $f \#${i} >> missing_relion_fields.tmp
 i=$(( i + 1 ))
done

cat csparc_header.tmp missing_relion_fields.tmp >> new_header.tmp 

###combine header and data
cat new_header.tmp particles_from_csparc2_full-parameters.tmp >> particles_from_csparc2.star

###prepare nice summary
PARTIN=`cat csparc2_particles.tmp | wc -l`
PARTOUT=`cat particles_from_csparc2_full-parameters.tmp | wc -l`

###test if micrograph and image names fit; if not spit out error message but still give outputs for trouble shooting
IMGCOL=`cat particles_from_csparc2.star | grep _rlnImageName | awk '{print $2}' | sed -e 's/#//g'`
MICCOL=`cat particles_from_csparc2.star | grep _rlnMicrographName | awk '{print $2}' | sed -e 's/#//g'`

MICPATH=`cat particles_from_csparc2_full-parameters.tmp | awk -v X=$MICCOL '{print $X}' | head -1 | sed -e 's/\(.*\)\//\1 /' | awk '{print $1}'` 
echo $MICPATH | sed -e 's/\//\\\//g' >> tmp.tmp
MICPATH=`cat tmp.tmp`
rm -f tmp.tmp

if [ $RELION = shiny.star ]
then
 TEST=`cat particles_from_csparc2_full-parameters.tmp | awk -v X=$IMGCOL -v Y=$MICCOL '{print $X, $Y}' | sed -e "s/$RPATH/ /g" -e "s/$MICPATH//g" -e 's/mrcs/mrc/g' -e 's/_shiny//g' | awk '{print $2,$3}' | sed -e 's/\///g' | awk '{if($1==$2) print "TRUE"; else print "FALSE"}' | sort -g | uniq | head -1`
else
 TEST=`cat particles_from_csparc2_full-parameters.tmp | awk -v X=$IMGCOL -v Y=$MICCOL '{print $X, $Y}' | sed -e "s/$RPATH/ /g" -e "s/$MICPATH//g" -e 's/mrcs/mrc/g' | awk '{print $2,$3}' | uniq | sed -e 's/\///g' | awk '{if($1==$2) print "TRUE"; else print "FALSE"}' | sort -g | uniq | head -1`
fi

###tidy up
rm -f header.tmp csparc2_particles_relion-parameters.tmp csparc2_particles_relion-path.tmp csparc2_particles.tmp csparc2_star_noheader.tmp csparc2_star_noheader_relion-path.tmp new_header.tmp particles_from_csparc2_full-parameters.tmp missing_relion_fields.tmp relion_parameters.tmp csparc_parameters.tmp FIELD*.tmp csparc_header.tmp csparc2_star_noheader_relion-path.tmp relion_noheader.tmp relion_noheader.tmp csparc2_star_noheader_relion-path.tmp

###if optics table exists in original star file, add it back
if [ $OPTICS -eq 1 ]
then
 mv particles_from_csparc2.star tmp.star
 cat ${RELION}_ori | awk -v X=$DATA '{if(NR<X) print $0}' > optics.tmp
 cat optics.tmp tmp.star | sed -e 's/data_images/data_particles/' > particles_from_csparc2.star
 rm -f optics.tmp tmp.star $RELION
 mv ${RELION}_ori $RELION
fi

###regenerate original csparc star file in case it had a optics table
if [ -e ${CSPARC}_ori ]
then
 mv ${CSPARC}_ori $CSPARC
fi

###good bye message
if [ $TEST = "FALSE" ]
then
 mv particles_from_csparc2.star particles_from_csparc2_WRONG.star
 echo ''
 echo '######################################'
 echo 'ATTENTION: At least one particle has a mismatch between ImageName and MicrographName. This usually means that the particle order in the original relion star file and the star file generated by csparc2star.py are not the same. As a consequence this script will lead to an erroneous star file. This star file is still written out in case you want to trouble shoot, but it is highly recommended to NOT USE THIS STAR FILE FOR ANY FURTHER PROCESSING. It is saved as particles_from_csparc2_WRONG.star.'
 echo ''
 echo "$PARTIN particles from $CSPARC have been searched for in $RELION and $PARTOUT have been found and written to particles_from_csparc2_WRONG.star with all parameters from $CSPARC maintained and missing fields from $RELION added. As stated above, this star file is WRONG."
 echo '######################################'
 echo ''
else
 echo ''
 echo '######################################'
 echo "$PARTIN particles from $CSPARC have been searched for in $RELION and $PARTOUT have been found and written to particles_from_csparc2.star with all parameters from $CSPARC maintained and missing fields from $RELION added. Most propably cryosparc changed the rlnOpticsGroup number(s)! You have to check that manually and fix it if it's wrong. Easiest is to fix the number in the data_optics definition at the start of the star file. You might also want to remove the rlnRandomSubset column before using the star file in Relion. Easiest is using relion_star_handler with the --remove_column option."
 echo '######################################'
 echo ''
fi

exit
