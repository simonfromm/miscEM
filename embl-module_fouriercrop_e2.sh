#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to convert mrc micrographs to 8bit png with optional binning       ###
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
 echo "Script to fouriercrop micrographs"
 echo "ATTENTION: if executed in the directory with the original micrographs, they are overwritten by the fouriercropped ones!!!"
 echo "Variables empty, usage is ${0##*/} (1) (2) ..."
 echo ""
 echo "(1) = binning factor ('1' for no binning)"
 echo "(2) = input micrographs"
 echo ""
 exit
fi

###load eman environment
module purge
module load EMAN2

###set variables
bin=$1
shift
mics=$*

###check if mics.list already exists potenially existing file list
if [[ -e mics1.list  ]]
then
 echo "embl-module_fouriercrop_e2.sh has been executed at least once in that folder; list with uniq mrc files to be converted"
 x=`ls -l *.list | tail -1 | awk '{print $9}' | sed -e 's/mics//g' -e 's/.list//g'`
 i=$(( x + 1))
 for f in $mics ; do
   echo $f >> mics${i}.list
 done
 comm -3 mics${x}.list mics${i}.list >> mics_new.list
else
 i=1
 for f in $mics ; do
  echo $f >> mics${i}.list
 done
 cp mics${i}.list mics_new.list
fi

###ask if the number of new mrc files to bin is reasonable
NEW=`cat mics_new.list | wc -l`
echo "#############################################"
echo "A total of ${NEW} mrc files will fouriercropped (binned) by a factor of $bin"
echo "#############################################"
read -p "press [Enter] key to confirm and run script..."

###conversion
while read p ; do
 e2proc2d.py $p ${p##*/} --fouriershrink $bin
done < mics_new.list

###check if all binned files where generated
CROP=`ls -l *.mrc | wc -l`
TOT=`cat mics${i}.list | wc -l`

rm -f mics_new.list

if [ $CROP -eq $TOT ] ; then
 echo
 echo "$NEW micrographs have been newly fouriercropped by a factor of ${bin}"
 echo "A total of $TOT micrographs are fouriercropped"
 echo
else
 echo
 echo "Number of input mrc files ($TOT) and number mrc files in folder ($CROP) are not equal"
 echo "Either the conversion failed, or mrc files where already present."
 echo 
fi

exit
