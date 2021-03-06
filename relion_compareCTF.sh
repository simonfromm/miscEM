#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to compare CTF determination results of gctf and Ctffind4          ###
###     Generates a scatter plot with the difference in dU and dV determined  ###
###     by the two programs; an exclusion list based on a user-set threshold  ###
###     is also generated.                                                    ###
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
 echo 'Program to compare ctffind4 and gctf results generated by the relion3 wrapper and generate a list with micrographs to discard'
 echo
 echo "Usage ${0##*/} (1) (2) (3) (4)"
 echo '(1) ctffind4 micrographs_ctf.star'
 echo '(2) gctf micrographs_ctf.star'
 echo '(3) threshold difference in A still accepted'
 echo '(4) where non-dose-weighted (noDW) micrographs used? YES=1, NO=0'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#set variables
ctffind=$1
shift
gctf=$1
shift
threshold=$1
shift
DW=$1
shift

#get column numbers for micrograph name, dU and dV
if [[ $DW -eq 1 ]]
then
 col_MIC_ctffind=`cat $ctffind | grep _rlnMicrographNameNoDW | awk '{print $2}' | sed -e 's/#//g'`
else 
 col_MIC_ctffind=`cat $ctffind | grep '_rlnMicrographName ' | awk '{print $2}' | sed -e 's/#//g'`
fi

col_ctffindU=`cat $ctffind | grep _rlnDefocusU | awk '{print $2}' | sed -e 's/#//g'`
col_ctffindV=`cat $ctffind | grep _rlnDefocusV | awk '{print $2}' | sed -e 's/#//g'`
col_gctfU=`cat $gctf | grep _rlnDefocusU | awk '{print $2}' | sed -e 's/#//g'`
col_gctfV=`cat $gctf | grep _rlnDefocusV | awk '{print $2}' | sed -e 's/#//g'`

#generate tmp files with the extracted info
cat $ctffind | awk -v X=$col_MIC_ctffind -v Y=$col_ctffindU -v Z=$col_ctffindV '{if(NF>5) print $X, ($Y+$Z)/2 }' > ctffind_defoci.tmp
cat $gctf | awk -v Y=$col_gctfU -v Z=$col_gctfV '{if(NF>5) print ($Y+$Z)/2 }' > gctf_defoci.tmp

#paste files and calculate differences
paste ctffind_defoci.tmp gctf_defoci.tmp | awk '{print (($2-$3)^2)^0.5, $1}' | sort -n -r >  defoci_diff.txt

#plot differences
gnuplot<<EOF
set term post color
set output 'ctf_difference-plot.ps'
set xlabel '#MIC'
set ylabel 'deltaDefocusAverage'
set key off
plot 'defoci_diff.txt' u 1 w p
exit
EOF

rm -f ctffind_defoci.tmp
rm -f gctf_defoci.tmp

#generate list with micrographs to discard
cat defoci_diff.txt | awk -v X=$threshold '{if($1>X) print $2}' >> bad_ctf_mics.tmp

cat bad_ctf_mics.tmp | sort -g | uniq > bad_ctf_mics.tmpp

#remove everything except the actual filename from the list
while read p; do
 echo ${p##*/} >> bad_ctf_mics.txt
done < bad_ctf_mics.tmpp


BAD=`cat bad_ctf_mics.txt | wc -l`
TOT=`cat defoci_diff.txt | wc -l`

rm -rf bad_ctf_mics.tmp*

echo bla > perc.tmp

PERC=`cat perc.tmp | awk -v X=$BAD -v Y=$TOT '{print (X/Y)*100}'`

rm -f perc.tmp

echo
echo "A plot with the differences between ctffind4 and gctf is stored as ctf_difference-plot.ps"
echo
echo "$PERC % ($BAD) of your micrographs had a higher discrepancy than $threshold A between ctffind4 and gctf"
echo
echo "You might want to remove these micrographs from any further processing or inspect them carefully"
echo "A list of them is stored in bad_ctf_mics.txt"
echo "You can also use the script relion_ctf_remove_bad.sh to remove those from the relion star file directly"
echo
exit
