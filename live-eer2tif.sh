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
 echo 'Script to start live eer 2 tiff conversion'
 echo 'Execute the folder where your eer movies from the microscope are coming in'
 echo
 echo "Usage: ${0##*/} (1) (2)"
 echo "(1) (Planned) duration of data acquisition in days"
 echo "(2) Wait time in seconds before next rsync job starts (use short time, e.g. 15s for multi-shot single-particle, and longer, e.g. 120s for Tomo sessions)"
 echo "(3) Number of eer fractions to group (use the IMOD header command to check how many total fractions your movies have)"
 echo "(4) optional: gain reference in .gain format"
 echo
 echo 'exiting now...'
 echo
 exit
fi


DAYS=$1
shift
WAIT=$1
shift
EERFRACTIONS=$1
shift
GAIN=$1

TIME=$((DAYS*86400))

mkdir converted_to_tif

module purge
module load RELION/b4.0.0-beta-2-EMBLv.0004_20220110_01_a26bd45_a-fosscuda-2020b

ls *.eer > eer-files.lst


echo
echo '############################################################################'
echo "Starting eer to tif conversion in a loop with breaks of $WAIT seconds in between"
echo '############################################################################'
echo
mpirun -n 6 `which relion_convert_to_tiff_mpi` --i eer-files.lst --o converted_to_tif/ --eer_grouping ${EERFRACTIONS} --only_do_unfinished true --gain $GAIN
echo
echo '#################################################################################'
echo "eer files are converted to tif; starting new conversion round after a $WAIT second delay"
echo '#################################################################################'
echo
sleep $WAIT

while [ $SECONDS -lt $TIME ]
do
 echo
 echo '######################################'
 echo 'Starting new eer to tif conversion now'
 echo '######################################'
 echo
 ls *.eer > eer-files.lst
 mpirun -n 6 `which relion_convert_to_tiff_mpi` --i eer-files.lst --o converted_to_tif/ --eer_grouping ${EERFRACTIONS} --only_do_unfinished true --gain $GAIN
 echo
 echo '#################################################################################'
 echo "eer files are converted to tif; starting new conversion round after a $WAIT second delay"
 echo '#################################################################################'
 echo
 sleep $WAIT
done

echo 
echo '#############################################################################'
echo 'Data acquisition should be done by now; ending eer to tif conversion loop now'
echo '#############################################################################'
echo

exit
