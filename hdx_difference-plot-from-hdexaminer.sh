#!/bin/bash
#################################################################################
### Simon Fromm, UC Berkeley 2020                                             ###
###                                                                           ###
### Script to plot HDX difference data based on data from HDExaminer          ###
###     calculated 'per-residue' difference data                              ###
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

#check inputs
if [ -z $3 ] ; then
 echo "Wrong number of arguments, exiting"
 echo ""
 echo "USAGE: ${0##*/} <file with HDX data> <length of protein> <experiment title without spaces>"
 echo "Data structure of the HDX data file: x-center:x-width:y-value:y-error"
 echo ""
 exit
fi

#set variables
DATA=$1
shift
LENGTH=$1
shift
NAME=$1
shift

#set name of gnuplot script
DATE=`date +%F | sed -e 's/-//g'`
SCRIPT=${DATE}_${NAME}_gnuplot.sh

echo \#\!'/bin/bash' > $SCRIPT
echo '' >> $SCRIPT
echo '' >> $SCRIPT
echo 'gnuplot -persist <<EOF' >> $SCRIPT
	echo '	set term post color landscape' >> $SCRIPT
	echo "	set output" \""${DATE}_${NAME}_hdx-difference.eps"\" >> $SCRIPT
	echo "	unset key" >> $SCRIPT
	echo "  set title" \""${NAME} HDX Difference"\" >> $SCRIPT
	echo "	set xrange[1:$LENGTH]" >> $SCRIPT
	echo "	set xtics out" >> $SCRIPT
	echo "	set yrange[-100:100]" >> $SCRIPT
	echo "	set xlabel" \""\#aa"\" >> $SCRIPT
	echo "	set ylabel" \""HDX difference"\" >> $SCRIPT
	echo "	set style fill solid 1.0 border 0" >> $SCRIPT
	echo "  plot 0 ls -1, -10 ls 0, 10 ls 0, '$DATA' u 1:3:4:2 w boxerrorbars lc rgb" \""#1e90ff"\" >> $SCRIPT
	echo '	exit' >> $SCRIPT
	echo 'EOF' >> $SCRIPT
	echo 'exit' >> $SCRIPT

chmod +x $SCRIPT

./$SCRIPT

#	echo "	set x2range[1:$LENGTH]" >>! tmp.csh
#	echo "	set x2tics axis mirror format" \"" "\" >>! tmp.csh

exit
