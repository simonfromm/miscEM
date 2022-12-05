#!/bin/bash

#################################################################################
### Simon Fromm, EMBL 2022                                                    ###
###                                                                           ###
### Script to invert the hand of a map using relion_image_handler             ###
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
 echo "Script to invert hand using relion_image_handler"
 echo "Usage: ${0##*/} (1)"
 echo "		(1) Falcon 4i eer gain reference in the .gain format; can be found on OffloadData in ImagesForProcessing/EF-Falcon/<2/3>00kV"
 echo
 echo "exiting..."
 exit
fi

EER=$1
shift

module purge
module load IMOD/4.11.12-foss-2021a
module load RELION/4.0.0-beta-2-EMBLv.0007_20220703_01_44c8b38_a-foss-2021a-CUDA-11.3.1

newstack $EER ${EER%%.*}.mrc

echo data_movies > tmp.star
echo "" >> tmp.star
echo loop_ >> tmp.star
echo "_rlnMicrographMovieName #1" >> tmp.star
echo ${EER%%.*}.mrc >> tmp.star

relion_estimate_gain --i tmp.star --o ${EER%%.*}_WARP.mrc

rm -f tmp.star ${EER%%.*}.mrc

exit
