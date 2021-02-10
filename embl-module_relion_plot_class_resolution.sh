#!/bin/bash
#
#
############################################################################
#
# Author: "Simon Fromm"
# EMBL Heidelberg, 2021
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

echo "*************************************************************************"
echo "Class resolution script for Relion"
echo "Adapted from class occupancy script for Relion from Kyle Morris"
echo ""
echo "This will plot the class occupancy from *_model.star files from Relion"
echo ""
echo "For use in module-based EMBL IT environment, Simon Fromm, EMBL Heidelberg 2021"
echo "*************************************************************************"


##Test if input variables are empty (if or statement)

echo ""
echo "Usage embl-module_relion_plot_class_resolution.sh (1) (2) (3)"
echo ""
echo "(1) = directory containing *model.star"
echo "(2) = First class number (optional)"
echo "(3) = Last class number (optional)"
echo ""
echo "Note that if you are using this in OSX you will need to edit relion_star_printtable to use gawk"
echo ""

if [[ -z $1 ]] ; then
  echo ""
  echo "Location of *model.star needs to be specified..."
  echo ""
  exit
fi

#load module environment
module purge
module load RELION
module load gnuplot

#set variables from input  
DIR=$1
shift
FIRSTCL=$1
shift
LASTCL=$1
shift

# Change directory to where *model.star files are
CWD=`pwd`
echo "Changing directory to $DIR"
cd $DIR

#see how many iterations were done
TOTITER=`ls -l *model.star | wc -l`
TOTITER=$((TOTITER-1))

#set most current iteration
LASTITER=`ls -lrt *model.star | tail -1 | awk '{print $9}'`

#define class numbers and plotting range
if [[ -z $FIRSTCL ]] || [[ -z $LASTCL ]] ; then
 echo ""
 echo "No variables provided analysing all classes"
 echo ""
 FIRSTCL=1
 LASTCL=`cat $LASTITER | grep "_rlnNrClasses" | awk '{print $2}' | sed -e 's/#//'`
else
 echo ""
 echo "Analysing all classes, but plotting" $FIRSTCL "to" $LASTCL
 echo ""
fi

# Make a backup of the *model.star
mkdir -p class_resolution/model_star_backup
cp -r *model.star class_resolution/model_star_backup

#generate data file for gnuplot
i=0
for f in `ls -rt *model.star`
do
 if [[ $i -lt 10 ]]
 then
  relion_star_printtable $f data_model_classes _rlnEstimatedResolution > 0${i}_${f%.*}_reso.dat
  i=$((i+1))
 else
  relion_star_printtable $f data_model_classes _rlnEstimatedResolution > ${i}_${f%.*}_reso.dat
  i=$((i+1))
 fi
done

paste *_reso.dat > class_resolution_raw.dat

#Transpose (http://stackoverflow.com/questions/25062169/using-bash-to-sort-data-horizontally)
transpose () {
  gawk '{for (i=1; i<=NF; i++) a[i,NR]=$i; max=(max<NF?NF:max)}
        END {for (i=1; i<=max; i++)
              {for (j=1; j<=NR; j++)
                  printf "%s%s", a[i,j], (j<NR?OFS:ORS)
              }
        }'
}

cat class_resolution_raw.dat | transpose > class_reso.dat

#generate header including occupancy of the last iteration
relion_star_printtable $LASTITER data_model_classes _rlnClassDistribution | awk '{printf "%s-%2.1f%s\n", "class"NR, $0*100, "%"}' > columnhead.dat

cat columnhead.dat | transpose > column_title.dat

cat column_title.dat class_reso.dat > class_resolution.dat

cat class_resolution.dat

rm -rf class_resolution_raw.dat
rm -rf *_reso.dat
rm -rf column*.dat

##Gnu plot
smoothlines=$(wc -l class_resolution.dat | gawk '{print $1}')

if (($smoothlines > 3))
then
	echo ''
	echo 'More than 4 data points, using smooth lines for plot'
	echo ''
	lines='with lines lw 2 smooth bezier'
else
	echo ''
	echo 'Fewer than 4 data points, using normal lines for plot'
	lines='with lines lw 2'
	echo ''
fi

gnuplot << EOF
set xlabel "3D classification iteration"
set ylabel "Class resolution [Å]"
set key outside
set key autotitle columnhead
set term png size 900,400
set size ratio 0.6
set output "class_resolution.png"
plot for [i=$FIRSTCL:$LASTCL] "class_resolution.dat" using i $lines
EOF

mv class_resolution.dat class_resolution
mv class_resolution.png class_resolution

# Change back to original working directory
cd $CWD

exit
