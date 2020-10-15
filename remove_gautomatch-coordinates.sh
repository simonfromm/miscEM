#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to remove particles from a gautomatch star files abova a definded  ###
###      coordinate value                                                     ###
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
if [ -z $3 ] ; then
 echo
 echo 'Script to remove particle coordinates above or below a chosen coordinate'
 echo
 echo "Usage ${0##*/} (1) (2) (3)"
 echo '(1) 'x' or 'y' coordinate'
 echo '(2) coordinate value'
 echo '(3) remove coordinates <above> or <below> that value'
 echo '(4) input star files'
 echo
 echo 'exiting now...'
 echo
 exit
fi

X=$1
shift
COORD=$1
shift
DIREC=$1
shift
STAR_IN=$*

for f in $STAR_IN
do
 PARLINES=`cat $f | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g'`
 HEADER=`cat $f | awk '{if($1=="loop_") print NR}'`
 HEADERLINES=$(( PARLINES + HEADER ))
 awk -v X=$HEADERLINES '{if(NR>X) print $0}' $f > old_star_noheader.tmp
 awk -v X=$HEADERLINES '{if(NR<=X) print $0}' $f > header.tmp
 if [ $X = x ]
 then
  if [ $DIREC = above ]
  then
   cat old_star_noheader.tmp | awk -v Z=$COORD '{if($1<=Z) print $0}' > new_star_noheader.tmp
   cat header.tmp new_star_noheader.tmp > ${f%.star}_new.star
   rm -f old_star_noheader.tmp header.tmp
  else
   cat old_star_noheader.tmp | awk -v Z=$COORD '{if($1>=Z) print $0}' > new_star_noheader.tmp
   cat header.tmp new_star_noheader.tmp > ${f%.star}_new.star
   rm -f old_star_noheader.tmp header.tmp
  fi
 else
  if [ $DIREC = above ]
  then 
   cat old_star_noheader.tmp | awk -v Z=$COORD '{if($2<=Z) print $0}' > new_star_noheader.tmp
   cat header.tmp new_star_noheader.tmp > ${f%.star}_new.star
   rm -f old_star_noheader.tmp header.tmp new_star_noheader.tmp
  else
   cat old_star_noheader.tmp | awk -v Z=$COORD '{if($2>=Z) print $0}' > new_star_noheader.tmp
   cat header.tmp new_star_noheader.tmp > ${f%.star}_new.star
   rm -f old_star_noheader.tmp header.tmp new_star_noheader.tmp
  fi
 fi 
done

###good bye message
echo ''
echo '######################################'
echo "gautomatch star files have been modified and are saved as _new.star"
echo ''
echo "all particle coordinates with a ${X}-value $DIREC than $COORD have been removed"
echo '######################################'
echo ''

exit
