#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to frame bin (average) movies using relion_image_handler           ###
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
 echo "Variables empty, usage is ${0##*/} (1) (2) ..."
 echo ""
 echo "(1) = how many consecutive frames to average"
 echo "(2) = input movies (need to have mrc extension)"
 echo ""
 exit
fi

###set variables
bin=$1
shift
movies=$*

###check if mics.list already exists potenially existing file list
if [[ -e movies1.list  ]]
then
 echo "the script has been executed at least once in that folder; list with unique movie files to be converted"
 x=`ls -l *.list | tail -1 | awk '{print $9}' | sed -e 's/movies//g' -e 's/.list//g'`
 i=$(( x + 1))
 for f in $movies ; do
   echo $f >> movies${i}.list
 done
 FOLDER=`cat movies${i}.list | head -1`
 FOLDER=${FOLDER%/*}
 ls -l *.mrc | awk '{print $9}'  >> movies_present.tmp
 for f in `cat movies_present.tmp` ; do
  echo ${FOLDER}/${f} >> movies_present.list
 done
 comm -3 movies_present.list movies${i}.list >> movies_new.list
 rm -f movies_present.tmp
 rm -f movies_present.list
else
 i=1
 for f in $movies ; do
  echo $f >> movies${i}.list
 done
 cp movies${i}.list movies_new.list
fi

###ask if the number of new png files to convert is reasonable
NEW=`cat movies_new.list | wc -l`
echo "#############################################"
echo "A total of ${NEW} movies will be frame binned ($bin consecutive frames are averaged)."
echo "#############################################"
#read -p "press [Enter] key to confirm and run script..."

###make symbolic links with mrcs extension
while read p ; do
 ln -s $p ${p##*/}s
done < movies_new.list

rm -f movies_new.list

###generate new list for conversion
ls -l *.mrcs | awk '{print $9}'  >> movies_new.list

while read p ; do
 relion_image_handler --i $p --o ${p%%.*}_frame-binned.mrcs --avg_bin 2
done < movies_new.list

#rename frame binned movies
rename 's/_frame-binned.mrcs/.mrc/' *_frame-binned.mrcs

###check if all movies were frame binned
FRAME_BIN=`ls -l *.mrc | wc -l`
TOT=`cat movies${i}.list | wc -l`

rm -f movies_new.list

###remove linked movies
rm -f *.mrcs

if [ $FRAME_BIN -eq $TOT ] ; then
 echo
 echo "$NEW micrographs have been newly frame binned (${bin} consecutive frames)"
 echo "A total of $TOT movies have been frame binned"
 echo
else
 echo
 echo "Number of input movies ($TOT) and number of frame binned movies (mrc files) in folder ($FRAME_BIN) are not equal"
 echo "Either the conversion failed, or frame binned movies (mrc files) where already present."
 echo 
fi

exit
