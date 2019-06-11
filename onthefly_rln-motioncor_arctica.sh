#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to start on-the-fly copying and motioncorrection (within Relion)   ###
###     of Arctica data                                                       ###
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
if [ -z $8 ] ; then
 echo
 echo 'Script to start on-the-fly arctica copying and motion correction within Relion'
 echo '   Relion directory/project has to exist already, movie import job and motioncor job has to be executed once already'
 echo
 echo "Usage ${0##*/} (1) (2) (3) (4) (5) (6) (7) (8)"
 echo '(1) arctica username' 
 echo '(2) data folder on arctica ftp (starts with /username/)'
 echo '(3) absolute path to target directory for raw data storage'
 echo '(4) absolute path to directory where raw tif movies will be stored'
 echo '(5) absolute path to relion directory'
 echo '(6) Movie import job directory, NOT absolute, relative from relion directory (e.g. Import/job001)'
 echo '(7) Motioncor job directory, NOT absolute, relative from relion directory (e.g. MotionCorr/job002)'
 echo '(8) Number of MPIs to use from motioncor2'
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
MOVIE_DIR=$1
shift
RELION_DIR=$1
shift
RELION_IMPORT_JOBDIR=$1
shift
RELION_MOTIONCOR_DIR=$1
shift
MPI=$1

#copy data
rsync -auvh ${USER}@arctica-nas.qb3.berkeley.edu:${DATA_SOURCE_DIR} ${DATA_TARGET_DIR}

##swith to relion
cd ${RELION_DIR}

#link new movies
cd Micrographs
ln -fs ${MOVIE_DIR}/*.tif .
cd ..

#exexute relion import command
relion_star_loopheader rlnMicrographMovieName > ${RELION_IMPORT_JOBDIR}/movies.star 
ls Micrographs/*.tif >> ${RELION_IMPORT_JOBDIR}/movies.star

#execute relion motioncor command
echo \#\!'/bin/bash' > motioncor_tmp.sh
echo mpirun -n $MPI `cat ${RELION_MOTIONCOR_DIR}/note.txt | grep relion_ | tail -1` --only_do_unfinished >> motioncor_tmp.sh
chmod +x motioncor_tmp.sh
./motioncor_tmp.sh

rm -f motioncor_tmp.sh

exit
