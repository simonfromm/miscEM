#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
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
if [ -z $2 ] ; then
 echo
 echo "Script to invert hand using relion_image_handler"
 echo "Usage: ${0##*/} (1) (2)"
 echo "		(1) map"
 echo "		(2) pixelsize in A"
 echo
 echo "exiting..."
 exit
fi

#set variable
MAPIN=$1
shift
PIX=$1

#source relion3 (Hurley lab specific)
export PATH=${APP_HOME}/relion-3.0_beta/build/bin:$PATH && export LD_LIBRARY_PATH=${APP_HOME}/relion-3.0_beta/build/lib:$LD_LIBRARY_PATH

#invert hand
relion_image_handler --i $MAPIN --o ${MAPIN%%.*}_inv.mrc --angpix $PIX --invert_hand

exit
