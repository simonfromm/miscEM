#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
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
if [ -z $1 ] ; then
 echo
 echo 'Script to generate _rlnOpticsGroup per gridsquare and image shift hole when a 5x3 pattern was used during acquisition. Inupt should be a movies.star file from a Relion3.1 Import job'
 echo '     Image shift position is taken from last digits of rlnImageName, gridsquare by preceding navigator item number (data recorded using SerialEM ImageShift, e.g. *_117-xx_000x.tif)' 
 echo '     Written for acquisition of a diamond hole matrix (5 holes) with 3 shots per hole; each hole will be the same rlnOpticsGroup instead of each shot; results in 5 times the number of grid squares date has been acquired from' 
 echo
 echo "Usage ${0##*/} (1)"
 echo '(1) relion movies.star file which should be modified'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#check if files to created are already present from previous runs
if [ -e ${1}_original ] ; then
 echo
 echo " ${1}_original already exists: please delete the file and rerun the script"
 echo
 echo 'exiting now...'
 echo
 exit
fi

#set variables
STAR_IN=$1

#make backup of the input star file
cp $STAR_IN ${STAR_IN}_original

##define header size and split star file in header and data lines
OPTICSLINE=`cat $STAR_IN | awk '{if($1=="data_movies") print NR}'`
awk -v X=$OPTICSLINE '{if(NR<X) print $0}' $STAR_IN > header_optics.tmp
DATALINE=`cat $STAR_IN | awk '{if($1=="_rlnOpticsGroup") print NR}' | tail -1`
awk -v X=$OPTICSLINE '{if(NR<X) print $0}' $STAR_IN > header_optics.tmp
awk -v X=$OPTICSLINE -v Y=$DATALINE '{if(NR>=X&&NR<=Y) print $0}' $STAR_IN > header_data.tmp
awk -v X=$DATALINE '{if(NR>X) print $0}' $STAR_IN > bla.tmp
DATALINES=`cat bla.tmp | wc -l`
DATALINES=$(( DATALINES - 1 ))
cat bla.tmp | head -${DATALINES} > data.tmp
rm -f bla.tmp

#generate list with grid square and image shift position
FIELDS=`head -1 data.tmp | sed -e 's/_/ /g' -e 's/-/ /g' -e 's/.tif//g' | awk '{print NF}'`
GRIDSQ=$(( FIELDS - 3 ))
SHIFTPOS=$(( FIELDS - 1 ))

sed -e 's/_/ /g' -e 's/-/ /g' -e 's/.tif//g' data.tmp | awk -v X=$GRIDSQ -v Y=$SHIFTPOS '{printf "%i %i\n", $X, $Y}' > gridsq-shiftpos.tmp

#find uniq grid squares
awk '{print $1}' gridsq-shiftpos.tmp | uniq > gridsq_uniq.tmp


#assign optics group base for each uniq grid square

i=0
j=1
k=2
awk '{print $1}' gridsq-shiftpos.tmp > optics_base_${j}.tmp

for f in `cat gridsq_uniq.tmp`
do
 sed -e "s/\<$f\>/$i/g" optics_base_${j}.tmp > optics_base_${k}.tmp
 rm -f optics_base_${j}.tmp
 i=$(( i + 5 ))
 j=$(( j + 1 ))
 k=$(( k + 1 ))
done

#generate list of optics groups based on image shift position
awk '{print $2}' gridsq-shiftpos.tmp > shiftpos.tmp
sed -e 's/\<2\>/1/g' -e 's/\<3\>/1/g' -e 's/\<5\>/4/g' -e 's/\<6\>/4/g' -e 's/\<8\>/7/g' -e 's/\<9\>/7/g' -e 's/\<11\>/10/g' -e 's/\<12\>/10/g' -e 's/\<14\>/13/g' -e 's/\<15\>/13/g' shiftpos.tmp | sed -e 's/\<4\>/2/g' | sed -e 's/\<7\>/3/g' | sed -e 's/\<10\>/4/g' | sed -e 's/\<13\>/5/g' > shiftpos_opticsgroup.tmp

#add optics_base to shiftpos_opticsgroup
paste shiftpos_opticsgroup.tmp optics_base_${j}.tmp | awk '{print $1 + $2}' > optics_group.tmp

#substitute optics group in original star file
paste data.tmp optics_group.tmp | awk '{print $1, $3}' > data_new-optics.tmp

#generate new optics header
NUMOPTICS=`cat optics_group.tmp | sort -g | uniq | wc -l`
OPTICS_LINE=`awk '{if($1=="loop_") print NR}' header_optics.tmp`
NUMOPTICSARG=`cat header_optics.tmp | grep _rln | grep "#" | tail -1 | sed -e 's/#//g' | awk '{print $2}'`
OPTICS_LINE=$(( OPTICS_LINE + NUMOPTICSARG + 1 ))

awk -v X=$OPTICS_LINE '{if(NR<X) print $0}' header_optics.tmp > header_optics_args.tmp
awk -v X=$OPTICS_LINE '{if(NR>X) print $0}' header_optics.tmp > header_optics_intermed.tmp
awk -v X=$OPTICS_LINE '{if(NR==X) print $0}' header_optics.tmp > header_optics_data.tmp


awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}' header_optics_data.tmp > header_optics_nogroupname.tmp

i=1

while [ $i -le $NUMOPTICS ]
do
 echo "opticsGroup${i}" >> header_optics_data-name.tmp
 echo ${i} >> header_optics_data-groupnum.tmp
 cat header_optics_nogroupname.tmp >> header_optics_data-data.tmp
 i=$(( i + 1 ))
done

paste header_optics_data-name.tmp header_optics_data-groupnum.tmp header_optics_data-data.tmp > header_optics_data.tmp

#assemble final star file
cat header_optics_args.tmp header_optics_data.tmp header_optics_intermed.tmp header_data.tmp data_new-optics.tmp > movies.star

rm -f *.tmp

exit
