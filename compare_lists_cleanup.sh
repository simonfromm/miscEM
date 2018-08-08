#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to compare two file lists and remove any files which are not       ###
###     present in both                                                       ###
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
 echo "Script to compare two file lists with the same file type  and remove any files which are not present in both"
 echo "ATTENTION: Script needs to be executed in the folder where the files which should be deleted are present"
 echo "Usage: ${0##*/} (1) (2)"
 echo "		(1) Reference folder"
 echo "		(2) file extension"
 echo "exiting..."
 echo
 exit
fi

#set variables
REFFOLDER=$1
shift
TYPE=$1
shift

#generate lists
ls -l $REFFOLDER*.$TYPE | awk '{print $9}' >> ref.list
while read p ; do
 echo ${p##*/} >> ref_pure.list
done < ref.list

ls -l *.$TYPE | awk '{print $9}' >> clean.list

#check each item from the clean.list for existence in the ref_pure.list; if not remove the file
while read p; do
 TMP=`cat ref_pure.list | grep $p`
 if [[ $p != $TMP ]] ; then
  rm -f $p
 fi
done < clean.list

#generate numbers for output
BEFORE=`cat clean.list | wc -l`
CHECK=`cat ref.list | wc -l`
AFTER=`ls -l *.$TYPE | wc -l`

#clean up
rm -f *.list

#write output
echo
echo "$BEFORE files were given as input and compared to $CHECK files. $AFTER files remained. "
echo

exit
