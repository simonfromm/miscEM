#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of Berkeley 2017
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
# Modified: "Simon Fromm"
# University of California, Berkeley 
#
############################################################################

echo "*************************************************************************"
echo "Class occupancy script for Relion, Kyle Morris University of California Berkeley 2016"
echo ""
echo "This will plot the class occupancy from *_model.star files from Relion 2.0"
echo "Note: This script uses Eye Of Gnome to display the class_occupancy.png"
echo ""
echo "Note: Modified by Simon Fromm, University of California, Berkeley 2018"
echo "*************************************************************************"


##Test if input variables are empty (if or statement)

echo ""
echo "Usage is relion_class_occupancy (1) (2) (3)"
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
LASTITER=`ls -l *model.star | tail -1 | awk '{print $9}'`

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
mkdir -p class_occupancy/model_star_backup
cp -r *model.star class_occupancy/model_star_backup

#generate data file for gnuplot
for f in `ls *model.star`
do
 relion_star_printtable $f data_model_classes _rlnClassDistribution > ${f%.*}_occup.dat
done

paste *_occup.dat > class_occupancy_raw.dat

#Transpose (http://stackoverflow.com/questions/25062169/using-bash-to-sort-data-horizontally)
transpose () {
  gawk '{for (i=1; i<=NF; i++) a[i,NR]=$i; max=(max<NF?NF:max)}
        END {for (i=1; i<=max; i++)
              {for (j=1; j<=NR; j++)
                  printf "%s%s", a[i,j], (j<NR?OFS:ORS)
              }
        }'
}

cat class_occupancy_raw.dat | transpose > class_occupancy.dat
cat class_occupancy.dat

rm -rf class_occupancy_raw.dat
rm -rf *_occup.dat

##Gnu plot
smoothlines=$(wc -l class_occupancy.dat | gawk '{print $1}')

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
set ylabel "Class % ptcl occupancy"
set key outside
set term png size 900,400
set size ratio 0.6
set output "class_occupancy.png"
plot for [i=$FIRSTCL:$LASTCL] "class_occupancy.dat" using i title 'class' .i $lines
EOF

mv class_occupancy.dat class_occupancy
mv class_occupancy.png class_occupancy

eog class_occupancy/class_occupancy.png &

# Change back to original working directory
cd $CWD

exit
