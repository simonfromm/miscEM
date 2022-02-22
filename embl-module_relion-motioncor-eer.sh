#!/bin/bash
#
#
############################################################################
#
# Author: "Simon Fromm"
# EMBL Heidelberg 2022
#
# This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
############################################################################

if [ -z $1 ] ; then
  echo ""
  echo "Variables empty, usage is ${0##*/} (1) (2) (3) (4) (5) (6) (7) (8) (9) (10)"
  echo ""
  echo "(1)  = list with input eer movies"
  echo "(2)  = voltage"
  echo "(3)  = apix (A/pix)"
  echo "(4)  = eer grouping (NOTE: this has an impact on the resulting dose per frame!)"
  echo "(5)  = dose (e/A^2/frame)"
  echo "(6)  = gain ref with .gain extension"
  echo "(7)  = Number of patches (x and y) for local alignment (e.g '4 4' for Falcon4)"
  echo "(8)  = dose weighting? <'true' or 'false'>"
  echo "(9)  = MPI"
  echo "(10) = Threads per MPI"
  echo ""
  exit
fi



input=$1
shift
voltage=$1
shift
apix=$1
shift
eergroup=$1
shift
dose=$1
shift
gain=$1
shift
patchx=$1
shift
patchy=$1
shift
dw=$1
shift
mpi=$1
shift
thread=$1
shift

############################################################################
############################################################################
# get and print total number of files in directory
num=`cat $input | wc -l`
echo $num 'eer movies to be motion corrected'
echo ''

echo ''
echo 'Motion correcting with pixel size: '$apix' A/px and dose: '$dose' (e/A^2/frame) by the Relion motion correction implemenation'
echo 'using '$gain' as the gain ref'
echo "corrected movies will be save in ./corrected"
echo ''
read -p "press [Enter] key to confirm and run script..."

############################################################################
############################################################################

#load module
module purge
module load RELION/b4.0.0-beta-1-EMBLv.0003_20211110_02_e3afcf9_a-fosscuda-2020b

#generate input star file
cat /g/icem/fromm/software/templates/rln_optics_header.star > in.star
echo opticsGroup1 1 $apix $voltage 2.7 0.1 >> in.star
echo "" >> in.star
cat /g/icem/fromm/software/templates/rln_movie_data_header.star >> in.star
cat $input | awk '{print $1, 1}' >> in.star
echo "" >> in.star

#generate output directory
mkdir corrected

#do motion correction:
mpirun -n $mpi `which relion_run_motioncorr_mpi` --i in.star --o corrected/ --first_frame_sum 1 --last_frame_sum -1 --use_own  --j $thread --bin_factor 1 --bfactor 150 --dose_per_frame $dose --preexposure 0 --patch_x $patchx --patch_y $patchy --eer_grouping $eergroup --gainref $gain --gain_rot 0 --gain_flip 0 --only_do_unfinished true --dose_weighting $dw

rm in.star

echo "//////////////////////"
echo "motion correction completed"
echo "//////////////////////"
