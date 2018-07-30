#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to rename files with numbering to include leading zeros            ###
###     e.g. when recorded with EMMENU; does only work up to 4 digit numbers  ###
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
 echo "Script to set micrograph numbering to 4 digits with leading zeros (_000X)"
 echo "Usage: ${0##*/} (1)"
 echo "		(1) file extension (without the dot)"
 echo
 echo "exiting..."
 exit
fi

#set variable
EXT=$1

#rename mics 0-9
i=1

while  [ $i -lt 10 ] ; do
 rename -e "s/_$i.$EXT/_000$i.$EXT/" *.$EXT
 i=$((i+1))
done

while [ $i -lt 100 ] ; do
 rename -e "s/_$i.$EXT/_00$i.$EXT/" *.$EXT
 i=$((i+1))
done

while [ $i -lt 1000 ] ; do
 rename -e "s/_$i.$EXT/_0$i.$EXT/" *.$EXT
 i=$((i+1))
done

exit
