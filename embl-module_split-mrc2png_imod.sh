#!/bin/bash

#################################################################################
### Simon Fromm, EMBL 2022                                                    ###
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
 echo "(1) = binning factor for conversion into pngs ('1' for no binning)"
 echo "(2) = input stack"
 echo ""
 exit
fi

###load eman environment
module purge
module load IMOD/4.11.12-foss-2021a

###set variables
bin=$1
shift
stack=$*

###ask if all inputs are correct
echo "#################################################################################################"
echo "${stack} will be split into single files and those then converted to png files with ${bin}x binning (png files only)."
echo "#################################################################################################"
read -p "press [Enter] key to confirm and run script..."

###split the stack
newstack -split 1 -append mrc ${stack} ${stack%%.*}_

###generate list for conversion to png
ls ${stack%%.*}_*.mrc > mics_new.list

###conversion
if [[ $bin -gt 1 ]]
then
 while read p ; do
  newstack -shrink ${bin} ${p%%.*}.mrc ${p%%.*}_bin${bin}.mrc
  mrc2tif -p ${p%%.*}_bin${bin}.mrc ${p%%.*}_bin${bin}.png
 done < mics_new.list
else
 while read p ; do
  mrc2tif -p ${p} ${p%%.*}.png
 done < mics_new.list
fi

###check if all png files where generated

rm -f *.list

echo
echo "$stack has been splint and into png files with binning ${bin}"
echo

exit
