#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to convert mrc micrographs to 8bit png iwht optional binning       ###
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
 echo "(1) = binning factor ('1' for no binning)"
 echo "(2) = input micrographs"
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
bin=$1
shift
mics=$*

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
 for f in $mics ; do
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

###conversion
while read p ; do
 e2proc2d.py $p ${p##*/}.png --meanshrink $bin --outmode uint8
done < mics_new.list

###rename png files
rename 's/.mrc//' *.mrc.png

###check if all png files where generated
PNG=`ls -l *.png | wc -l`
TOT=`cat mics${i}.list | wc -l`

rm -f mics_new.list

if [ $PNG -eq $TOT ] ; then
 echo
 echo "$NEW micrographs have been newley converted into png files with binning ${bin}"
 echo "A total of $TOT micrographs are converted into png files"
 echo
else
 echo
 echo "Number of input mrc files ($TOT) and number png files in folder ($PNG) are not equal"
 echo "Either the conversion failed, or png files where already present."
 echo 
fi

exit
