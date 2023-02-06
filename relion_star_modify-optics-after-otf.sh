#!/bin/bash

#################################################################################
### Simon Fromm, EMBL 2023                                                    ###
###                                                                           ###
### Script to generate one rlnOpticsGroup per gridsquare and image shift hole ###
###     position                                                              ###
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
 echo 'Script to correct/complete optics group table after Relion on-the-fly ran with one optics group'
 echo
 echo "Usage ${0##*/} (1) (2)"
 echo '(1) relion micrographs_ctf.star'
 echo '(2) txt file with a list of file name suffixes which should get a unique optics group'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#set variables
INPUT=$1
shift
SUFFIX=$1
shift

module load RELION

#make backup of input star file
mv $INPUT ${INPUT}_ori

#get rid of optics group from star file
relion_star_handler --i ${INPUT}_ori --o ${INPUT}_nopt --remove_column rlnOpticsGroup

###remove optics from star file and generate a new optics header
#remove optics header
DATA=`cat ${INPUT}_nopt | awk '{if($1=="data_micrographs") print NR}'`
cat ${INPUT}_nopt | awk -v X=$DATA '{if(NR>=X) print $0}' > $INPUT

##generate new optics header
#get original header
OPTICS=`cat ${INPUT}_nopt | awk '{if($1=="opticsGroup1") print NR}'`
cat ${INPUT}_nopt | awk -v X=$OPTICS '{if(NR<=X) print $0}' > optics_header_ori.tmp

#define how many optics groups we need
TOTALOPTICS=`cat $SUFFIX | wc -l`

#get defaults optics group definition from original optics header
cat optics_header_ori.tmp | tail -1 > optics_template.tmp

#generate not optics data with one group per suffix
i=1
while [ $i -le $TOTALOPTICS ]
do
	sed -e "s/opticsGroup1/opticsGroup${i}/g" -e "s/ 1 / ${i} /g" optics_template.tmp > optics-group_${i}.tmp
	i=$(( i + 1 ))
done

#remove data from original optics header
sed -i '/opticsGroup1/d' optics_header_ori.tmp

#assemble new optics header
echo > emptyline.tmp
cat optics_header_ori.tmp optics-group_*.tmp emptyline.tmp > optics_header_new.txt

rm -f *.tmp

mv optics_header_new.txt optics_header_new.tmp

###split micrograph header from data
#define header size, split header from data and generate new data header with rlnOpticsGroup
PARLINES=`cat $INPUT | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
HEADER=`cat $INPUT | awk '{if($1=="loop_") print NR}'`
HEADERLINES=$(( PARLINES + HEADER ))
OPTICSCOLNO=$(( PARLINES + 1 ))


awk -v X=$HEADERLINES '{if(NR>X) print $0}' $INPUT >> data_noheader.tmp
awk -v X=$HEADERLINES '{if(NR<=X) print $0}' $INPUT >> header.tmp

echo "_rlnOpticsGroup #${OPTICSCOLNO}" > opticscoldef.tmp


###generate new OpticsGroup column
#transfrom micrograph name into suffix only
relion_star_printtable ${INPUT} data_micrographs rlnMicrographName > rlnMicrographs.tmp
cat rlnMicrographs.tmp | sed -e 's/_/ /g' | awk '{print $NF}' | sed -e 's/\./ /g' | awk '{print $1}' > data_suffixes.tmp
rm -f rlnMicrographs.tmp

#strip suffix input in case the '_' and the file name where included
cat $SUFFIX | sed -e 's/_//g' -e 's/\./ /g' | awk '{print $1}' > suffix-lst.tmp

#replace data suffix with new optics group
i=1
for f in `cat suffix-lst.tmp`
do
	sed -i "s/$f/$i/g" data_suffixes.tmp
	i=$(( i + 1 ))
done

mv data_suffixes.tmp data_rlnOpticsGroup.tmp

###put together new star file
#add optics group column to data file
paste data_noheader.tmp data_rlnOpticsGroup.tmp > data_new.tmp

cat optics_header_new.tmp header.tmp opticscoldef.tmp data_new.tmp > ${INPUT%%.star}_newOptics.star

rm -f *.tmp
rm -f ${INPUT}_nopt
cp ${INPUT}_ori ${INPUT}


echo
echo
echo "###########"
echo "New star file with updated optics group based on the provided ${SUFFIX} file was generated. It's named ${INPUT%%.star}_newOptics.star and is maybe worth to glance at to see if it looks as expected ;-)"
echo "###########"
echo
echo

exit
