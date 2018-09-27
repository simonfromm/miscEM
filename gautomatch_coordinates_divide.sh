#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to divide coordinates picked by gautomatch by a specified factor   ###
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
 echo 'Script to devide gauotmatch coordinates by a defined factor'
 echo 'ATTENTION: needs to be executed outside the directory with the original _automatch.star files'
 echo
 echo "Usage ${0##*/} (1) (2)"
 echo '(1) division factor'
 echo '(2) _automatch.star files to be divided'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#set variables
FACTOR=$1
shift
FILES=$*
shift

#do division
for f in $FILES
do
 cat $f | head -9 >> tmp1.star
 cat $f | awk '{if(NR>9) print $1/2, $2/2, $3, $4, $5}' >> tmp2.star
 cat tmp1.star tmp2.star >> ${f##*/}
 rm -f tmp1.star
 rm -f tmp2.star
done

exit
