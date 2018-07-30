#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to run Ctffind4 in batch mode.                                     ###
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

#check input parameters
if [ -z $9 ] ; then
 echo
 echo 'Program to run Ctffind4 in batch mode'
 echo
 echo 'Wrong input parameters'
 echo "Usage ${0##*/} (1) (2) (3) (4) (5) (6) (7) (8) (9) (10)"
 echo '(1) Acceleration Voltage [kV]'
 echo '(2) Spherical aberration Cs [mm]'
 echo '(3) Amplitude contrast [0.07-0.15]'
 echo '(4) Pixel size [Angstrom]'
 echo '(5) Tile size [px]'
 echo '(6) Min resolution search range [A]'
 echo '(7) Max resolution search range [A]'
 echo '(8) Exhaustive search? [yes/no] slows down the computation, but highly recommended!'
 echo '(9) Number of parallel processes (i.e. CPUs; ATTENTION: NO MPI but rather dirty background organization!)'
 echo '(10) Micrographs (with wild cards)'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#set variable
VOLT=$1
shift
CS=$1
shift
AMP=$1
shift
PX=$1
shift
TILE=$1
shift
MINRES=$1
shift
MAXRES=$1
shift
EXHAUST=$1
shift
CPU=$1
shift
MICS=$*

#set 'yes' string for comparison
YES=yes

#generate file list
rm -f filelist_ctf.dat
for f in $MICS ; do
 echo $f >> filelist_ctf.dat
done

#count number of micrographs in list
MICS_NUM=`cat filelist_ctf.dat | wc -l`

#summarize parameters and wait for approval
echo
echo
echo "Running Ctffind4 on $MICS_NUM micrographs using parameters:"
echo
echo "Acceleration voltage [kV]:     $VOLT"
echo "Spherical averration Cs [mm]:  $CS"
echo "Amplitude conrast:             $AMP"
echo "Pixel size [A]:                $PX"
echo "Tile size [px]:                $TILE"
echo "Frequency search range [A]:    $MINRES-$MAXRES"
echo "Defocus search range [um]:     0.5-5.0    (change possible only in base script)"
echo "Defocus search step size [um]: 0.05       (change possible only in base script)"
if [ $YES = $EXHAUST ] ; then
 echo 
 echo "Exhaustive search turned on, might take a while! (~30 s per 4k micrograph)"
fi
echo
echo "Micrographs will be distributed over $CPU CPU(s)"
echo
read -p "press [Enter] key to confirm and run script..."

#define how many micrographs per cpu are needed to be processed
MIC_CPU=$(((MICS_NUM/CPU)+1))

#generate file lists for each parallel process
rm -f tmp_*
split -a 1 -d -l $MIC_CPU filelist_ctf.dat tmp_

#generate one separate ctffind script for each list
rm -f script_tmp_*
PROC=`ls -l tmp_* | wc -l`

i=0

while [ $i -lt $((PROC-1)) ] ; do
echo \#\!'/bin/bash' >> script_tmp_$i.sh
echo "MICS0$i=\`cat tmp_$i\`" >> script_tmp_$i.sh
echo 'for f in $MICS0'"$i"' ; do' >> script_tmp_$i.sh
echo 'ctffind4 <<EOF' >> script_tmp_$i.sh
echo '$f' >> script_tmp_$i.sh
echo '${f%.*}_ctf.mrc' >> script_tmp_$i.sh
echo "$PX" >> script_tmp_$i.sh
echo "$VOLT" >> script_tmp_$i.sh
echo "$CS" >> script_tmp_$i.sh
echo "$AMP" >> script_tmp_$i.sh
echo "$TILE" >> script_tmp_$i.sh
echo "$MINRES" >> script_tmp_$i.sh
echo "$MAXRES" >> script_tmp_$i.sh
echo '5000' >> script_tmp_$i.sh
echo '50000' >> script_tmp_$i.sh
echo '500' >> script_tmp_$i.sh
echo 'no' >> script_tmp_$i.sh
echo "$EXHAUST" >> script_tmp_$i.sh
echo 'no' >> script_tmp_$i.sh
echo 'no' >> script_tmp_$i.sh
echo 'no' >> script_tmp_$i.sh
echo 'EOF' >> script_tmp_$i.sh
echo 'done' >> script_tmp_$i.sh
echo 'exit' >> script_tmp_$i.sh

chmod +x script_tmp_$i.sh
./script_tmp_$i.sh &
sleep 2
 i=$((i+1))
done

echo \#\!'/bin/bash' >> script_tmp_$i.sh
echo "MICS0$i=\`cat tmp_$i\`" >> script_tmp_$i.sh
echo 'for f in $MICS0'"$i"' ; do' >> script_tmp_$i.sh
echo 'ctffind4 <<EOF' >> script_tmp_$i.sh
echo '$f' >> script_tmp_$i.sh
echo '${f%.*}_ctf.mrc' >> script_tmp_$i.sh
echo "$PX" >> script_tmp_$i.sh
echo "$VOLT" >> script_tmp_$i.sh
echo "$CS" >> script_tmp_$i.sh
echo "$AMP" >> script_tmp_$i.sh
echo "$TILE" >> script_tmp_$i.sh
echo "$MINRES" >> script_tmp_$i.sh
echo "$MAXRES" >> script_tmp_$i.sh
echo '5000' >> script_tmp_$i.sh
echo '50000' >> script_tmp_$i.sh
echo '500' >> script_tmp_$i.sh
echo 'no' >> script_tmp_$i.sh
echo "$EXHAUST" >> script_tmp_$i.sh
echo 'no' >> script_tmp_$i.sh
echo 'no' >> script_tmp_$i.sh
echo 'no' >> script_tmp_$i.sh
echo 'EOF' >> script_tmp_$i.sh
echo 'done' >> script_tmp_$i.sh
echo 'exit' >> script_tmp_$i.sh

chmod +x script_tmp_$i.sh
./script_tmp_$i.sh

exit
