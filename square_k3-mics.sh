#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to make K3 images square in order to work with gautomatch          ###
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
if [ -z $3 ] ; then
 echo ""
 echo "Script to pad K3 images to be squared in order to be compatible with gautomatch v0.56"
 echo ""
 echo "Usage is ${0##*/} (1) (2) (3) ..."
 echo ""
 echo "(1) = x dimension of input micrographs"
 echo "(2) = y dimension of input micrographs"
 echo "(3) = input micrographs"
 echo ""
 exit
fi

###load eman environment
if [ -e /usr/local/software/EMAN2/bin/e2proc2d.py ]
then
 export PATH=/usr/local/software/EMAN2/bin:$PATH
 export LD_PRELOAD=/usr/local/software/EMAN2/lib/libmpi.so
else
 export PATH=/usr/local/software/eman2/bin:$PATH
 export LD_PRELOAD=/usr/local/software/eman2/lib/libmpi.so
fi

###set variables
XDIM=$1
shift
YDIM=$1
shift
MICS=$*

###check if mics.list already exists potenially existing file list
if [[ -e mics1.list  ]]
then
 echo "mrc2png_e2.sh has been executed at least once in that folder; list with uniq mrc files to be converted"
 x=`ls -l *.list | tail -1 | awk '{print $9}' | sed -e 's/mics//g' -e 's/.list//g'`
 i=$(( x + 1))
 for f in $mics ; do
   echo $f >> mics${i}.list
 done
 FOLDER=`cat mics${i}.list | head -1`
 FOLDER=${FOLDER%/*}
 ls -l *.png | awk '{print $9}' | sed -e 's/.png/.mrc/g' >> mics_present.tmp
 for f in `cat mics_present.tmp` ; do
  echo ${FOLDER}/${f} >> mics_present.list
 done
 comm -3 mics_present.list mics${i}.list >> mics_new.list
 rm -f mics_present.tmp
 rm -f mics_present.list
else
 i=1
 for f in $MICS ; do
  echo $f >> mics${i}.list
 done
 cp mics${i}.list mics_new.list
fi

###ask if the number of new png files to convert is reasonable
NEW=`cat mics_new.list | wc -l`
echo "#############################################"
echo A total of ${NEW} mrc files will be converted into png files.
echo "#############################################"
read -p "press [Enter] key to confirm and run script..."

#ceck if x or y are higher (if the micrograph is vertical or horizontally orientated)
if [[ $XDIM -gt $YDIM ]]
then
 PAD=`echo $XDIM | awk -v Y=$YDIM '{print $1-Y}'` 
 CENTER=`echo $XDIM | awk '{print ($1/2)}'`

###conversion
 while read p ; do
  e2proc2d.py $p ${p##*/}_pad.mrc --clip=$XDIM,$PAD
  e2proc2d.py ${p##*/}_pad.mrc ${p##*/}_pad-square.mrc --clip=$XDIM,$XDIM,$CENTER,$CENTER
  newstack --rotate 180 ${p##*/}_pad-square.mrc ${p##*/}_pad-square_rot.mrc
  e2proc2d.py $p ${p##*/}_square.mrc --clip=$XDIM,$XDIM,$CENTER,$CENTER
  e2proc2d.py ${p##*/}_square.mrc ${p##*/}_square-pad.mrc --addfile ${p##*/}_pad-square_rot.mrc
  rm -f ${p##*/}_pad.mrc ${p##*/}_pad-square.mrc ${p##*/}_square.mrc ${p##*/}_pad-square_rot.mrc
  rename 's/.mrc_square-pad.mrc/_squared.mrc/' ${p##*/}_square-pad.mrc
 done < mics_new.list
else
 PAD=`echo $YDIM | awk -v X=$XDIM '{print $1-X}'` 
 CENTER=`echo $YDIM | awk '{print ($1/2)}'`

###conversion
 while read p ; do
  e2proc2d.py $p ${p##*/}_pad.mrc --clip=$PAD,$YDIM
  e2proc2d.py ${p##*/}_pad.mrc ${p##*/}_pad-square.mrc --clip=$YDIM,$YDIM,$CENTER,$CENTER
  newstack --rotate 180 ${p##*/}_pad-square.mrc ${p##*/}_pad-square_rot.mrc
  e2proc2d.py $p ${p##*/}_square.mrc --clip=$YDIM,$YDIM,$CENTER,$CENTER
  e2proc2d.py ${p##*/}_square.mrc ${p##*/}_square-pad.mrc --addfile ${p##*/}_pad-square_rot.mrc
  #rm -f ${p##*/}_pad.mrc ${p##*/}_pad-square.mrc ${p##*/}_square.mrc ${p##*/}_pad-square_rot.mrc
  rename 's/.mrc_square-pad.mrc/_squared.mrc/' ${p##*/}_square-pad.mrc
 done < mics_new.list
fi


###check if all png files where generated
SQUARED=`ls -l *_squared.mrc | wc -l`
TOT=`cat mics${i}.list | wc -l`

rm -f mics_new.list

if [ $SQUARED -eq $TOT ] ; then
 echo
 echo "$NEW micrographs have been newley converted into png files with binning ${bin}"
 echo "A total of $TOT micrographs are converted into png files"
 echo
 echo
 echo "ATTENTION: Use these micrographs ONLY for gautomatch, not for any image processing."
 echo "Don't forget to remove particle coordinates with ${X}-values greater than $COORD from the gautomatch.star files."
 echo "You can do that by running the remove_gautomatch-coordinates.sh script."
 echo 
else
 echo
 echo "Number of input mrc files ($TOT) and number png files in folder ($SQUARED) are not equal"
 echo "Either the conversion failed, or png files where already present."
 echo 
fi

exit
