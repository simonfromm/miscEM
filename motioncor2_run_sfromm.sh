#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of California Berkeley 2016
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
#
# Edited by Simon Fromm
# University of California Berkeley 2018
#
###########################################################################

if [[ -z $1 ]] ; then
  echo ""
  echo "Variables empty, usage is $0 (1) (2) (3) (4) (5) (6) (7) (8) (9) (10) (11) (12) (13) (14)"
  echo ""
  echo "(1)  = apix (A/pix); superresolution pixel size if frames where recorded in superresolution!"
  echo "(2)  = acceleration voltage (kV)"
  echo "(3)  = dose (e/A^2/frame); 'none' if movies have eer format"
  echo "(4)  = binning factor"
  echo "(5)  = frames directory"
  echo "(6)  = gain ref (converted to mrc using 'dm2mrc' for Gatan cameras, 'none' if already applied)"
  echo "(7)  = Rotate gain reference counter-clockwise: 0 - no rotation, 1 - rotate 90 degree, 2 - rotate 180 degree, 3 - rotate 270 degree"
  echo "(8)  = Flip gain reference after gain rotation: 0 - no flipping, 1 - flip upside down, 2 - flip left right."
  echo "(9)  = input extension (e.g. tif, mrc, eer)"
  echo "(10)  = output extension (e.g. mrc)"
  echo "(11)  = Number of patches (x and y) for local alignment (e.g '5 5' for K2/FalconX and '7 5' for K3)"
  echo "(12)  = Number of subsequent frames to group to increase S/N"
  echo "(13)  = Should aligned stack be written out? (0=NO; 1=YES)"
  echo "(14) = gpu id (i.e. 0 1 ...)"
  echo ""

  exit
fi

apix=$1
shift
volt=$1
shift
dose=$1
shift
bin=$1
shift
dir=$1
shift
gain=$1
shift
rotation=$1
shift
flip=$1
shift
ext=$1
shift
ext2=$1
shift
patchx=$1
shift
patchy=$1
shift
group=$1
shift
stack=$1
shift
gpu=$1
shift
suffix="cor2"

motioncor2exe="/usr/local/software/bin/motioncor2"

############################################################################
############################################################################

# get and print total number of files in directory
num=$(ls $dir/*.$ext | wc -l)
echo $num 'files to extract sub-frames from'
echo ''

echo ''
echo 'Motion correcting subframes with apix: '$apix' and dose (e/A^2/frame): '$dose' by motioncor2'
echo "Using input files with extension: ${dir}/*.${ext}"
echo "Using output file extension:      ${ext2}"
echo ''
read -p "press [Enter] key to confirm and run script..."

############################################################################
############################################################################

#Remove existing converted micrographs from filelist.dat, excluding those with the set suffix i.e. already processed
ls -n $dir/*.$ext | grep -v $suffix | awk {'print $9'} | cat -n > filelist.dat

#Loop through filelist.dat for all the files
i=1
while read p; do
   file=$(sed -n $i"p" filelist.dat | awk {'print $2'})
   name=$(basename $file .$ext)

   orig=$dir/"$name".$ext
   new="$name"_"$suffix".$ext2

   if [ -e $new ]; then
    echo ""
    echo $new "- File exists, skipping"
    echo ""
   else
    echo ""
    echo "File_in:" $orig
    echo "File_out:" $new
    echo ""
    #For simple fast whole frame alignment
    #$motioncor2exe -InMrc $orig -OutMrc $new -Iter 10 -Tol 0.5 -Throw 2 -PixSize $apix

    #For patch alignment, dose weighting, fourier binning of superres, and grouping for higher S/N
    if [ $ext = tif ]; then
     ${motioncor2exe} -InTiff ${orig} -OutMrc ${new} -Gain ${gain} -RotGain $rotation -FlipGain $flip -Patch ${patchx} ${patchy} -Iter 10 -Tol 0.5 -Throw 0 -kV $volt -PixSize $apix -FmDose $dose -FtBin $bin -Group ${group} -SumRange 0 0 -Gpu $gpu 
     elif [ $ext = mrc ]; then
     ${motioncor2exe} -InMrc ${orig} -OutMrc ${new} -Gain ${gain} -RotGain $rotation -FlipGain $flip -Patch ${patchx} ${patchy} -Iter 10 -Tol 0.5 -Throw 0 -kV $volt -PixSize $apix -FmDose $dose -FtBin $bin -Group ${group} -SumRange 0 0 -Gpu $gpu 
     elif [ $ext = eer ]; then
     ${motioncor2exe} -InEer ${orig} -OutMrc ${new} -Gain ${gain} -RotGain $rotation -FlipGain $flip -Iter 10 -Tol 0.5 -Throw 0 -kV $volt -PixSize $apix -FtBin $bin -Group ${group} -SumRange 0 0 -Gpu $gpu 
    fi
   fi

   i=$((i+1))
done < filelist.dat

rm filelist.dat

echo "//////////////////////"
echo "Motioncorr2 complete"
echo "Corrected $((i-1)) files"
echo "//////////////////////"
