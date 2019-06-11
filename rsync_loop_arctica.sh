#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to start on-the-fly copying of Arctica data                        ###
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
if [ -z $4 ] ; then
 echo
 echo 'Script to start on-the-fly arctica copying'
 echo
 echo "Usage ${0##*/} (1) (2) (3)"
 echo '(1) arctica username' 
 echo '(2) data folder on arctica ftp (starts with /username/)'
 echo '(3) absolute path to target directory for raw data storage'
 echo '(4) folder where the raw movies will endo up on the local storage'
 echo
 echo 'exiting now...'
 echo
 exit
fi

USER=$1
shift
DATA_SOURCE_DIR=$1
shift
DATA_TARGET_DIR=$1
shift
MOVIES_RAW_DIR=$1
shift

MOVIES_DIFFERENCE=1

echo
echo '##############'
echo 'Starting rsync'
echo '##############'
echo
rsync -auvh ${USER}@arctica-nas.qb3.berkeley.edu:${DATA_SOURCE_DIR} ${DATA_TARGET_DIR}
echo
echo '#############################################################' 
echo 'rsync is done, checking if new data to be copied is available'
echo '#############################################################' 
echo

while [ $MOVIES_DIFFERENCE -gt 0 ]
do
 echo
 echo '################################'
 echo 'More data available to be copied'
 echo
 echo 'Starting rsync after a 10 min delay'
 i=10
 while [ $i != 0 ]
 do
  echo "Starting rsync in $i minutes"
  sleep 1m
  i=$(( i - 1 ))
 done
 echo 'Starting rsync now'
 MOVIES_START=`ls -l ${MOVIES_RAW_DIR}/*.tif | wc -l`
 rsync -auvh ${USER}@arctica-nas.qb3.berkeley.edu:${DATA_SOURCE_DIR} ${DATA_TARGET_DIR}
 MOVIES_CURRENT=`ls -l ${MOVIES_RAW_DIR}/*.tif | wc -l`
 MOVIES_DIFFERENCE=$(( MOVIES_CURRENT - MOVIES_START ))
 echo
 echo '#############################################################' 
 echo 'rsync is done, checking if new data to be copied is available'
 echo '#############################################################' 
 echo
done

echo 
echo '###################################################'
echo 'All movies copied to local storage using rsync'
echo "A total of ${MOVIES_CURRENT} movies has been copied"
echo '###################################################'
echo

exit
