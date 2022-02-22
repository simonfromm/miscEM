#!/bin/bash

#################################################################################
### Simon Fromm, EMBL 2021                                                    ###
###                                                                           ###
### Script to start on-the-fly syncing of data from TFS OffloadData to EMBL   ###
###	storage			                                              ###
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
 echo 'Script to start live-syncing of TEM data to EMBL storage'
 echo 'Execute this script in the folder you want to copy the data to!'
 echo
 echo "Usage: ${0##*/} (1) (2) (3)"
 echo "(1) (Planned) duration of data acquisition in days"
 echo "(2) Wait time in seconds before next rsync job starts (use short time, e.g. 15s for multi-shot single-particle, and longer, e.g. 120s for Tomo sessions)"
 echo "(3) Path of source folder on IC-Krios1 offload-data storage which has been mounted via 'gio mount'"
 echo
 echo 'exiting now...'
 echo
 exit
fi


DAYS=$1
shift
WAIT=$1
shift
IN=$1
shift
TARGET=`pwd`


TIME=$((DAYS*86400))

ID=`echo $RANDOM`

echo $IN | sed -e 's/:/\\:/g' -e 's/,/\\,/g' -e 's/=/\\=/g' > source.tmp

SOURCE=`cat source.tmp`

rm -rf source.tmp

echo \#\!/bin/bash > rsync_${ID}.sh
echo >> rsync_${ID}.sh
echo /g/icem/fromm/software/bin/msrsync -p 2 -P --rsync \"-rltpDuvh --chmod=775\" $SOURCE \. >> rsync_${ID}.sh
echo >> rsync_${ID}.sh
echo exit >> rsync_${ID}.sh

chmod +x rsync_${ID}.sh

echo
echo '#############################################################'
echo "Starting rsync in a loop with breaks of $WAIT seconds in between"
echo '#############################################################'
echo
./rsync_${ID}.sh
echo
echo '##########################################################' 
echo "rsync is done; starting new rsync after a $WAIT seconds delay"
echo '##########################################################' 
echo
sleep $WAIT

while [ $SECONDS -lt $TIME ]
do
 echo
 echo '################################'
 echo 'Starting new rsync now'
 echo
 ./rsync_${ID}.sh
 echo
 echo '##########################################################' 
 echo "rsync is done; starting new rsync after a $WAIT seconds delay"
 echo '##########################################################' 
 echo
 sleep $WAIT
done

rm -rf rsync_${ID}.sh

echo 
echo '#############################################################'
echo 'Data acquisition should be done by now; ending rsync loop now'
echo '#############################################################'
echo

exit
