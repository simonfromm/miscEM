#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to convert cryosparc2 fsc curves to the emdb xml format            ###
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
 echo 'Script to convert cryosparc2 fsc files to plain txt and emdb xml files'
 echo
 echo "Usage ${0##*/} (1) (2) (3) (4)"
 echo '(1) cryosparc2 fsc txt file'
 echo '(2) which fsc curve do you want? Please type the exact wording of following options:'
 echo '           nomask'
 echo '           spherical'
 echo '           loose'
 echo '           corrected'
 echo
 echo '(3) box size in pixel'
 echo '(4) pixel size in Angstrom'
 echo
 echo 'exiting now...'
 echo
 exit
fi


IN=$1
shift
TYPE=$1
shift
BOX=$1
shift
APIX=$1
shift

###Convert type to column number in cryosparc2 fsc txt file
if [ $TYPE = corrected ]
then
 COL=7
elif [ $TYPE = loose ]
then
 COL=4
elif [ $TYPE = spherical ]
then
 COL=3
elif [ $TYPE = nomask ]
then
 COL=2
else
 echo
 echo 'Wrong option for the fsc curve type; please check the exact wording and rerun the script'
 echo
 echo 'exiting now...'
 exit
fi

TXTOUT=${IN%*.txt}_${TYPE}.txt
XMLOUT=${IN%*.txt}_${TYPE}.xml

###first convert cryosparc2 fsc to plain txt format
cat $IN | awk -v BOX=$BOX -v APIX=$APIX -v COL=$COL '{if(NR>1) print ($1/(BOX * APIX)), $COL}' > $TXTOUT

###now convert this file to xml format

i=1

j=`cat ${IN%*.txt}_${TYPE}.txt | wc -l`
j=$(( j + 1 ))

echo '<fsc title="" xaxis="Resolution (A-1)" yaxis="Correlation Coefficient">' >  $XMLOUT

while [ $i -lt $j ]
do
	x=`cat $TXTOUT | awk -v i=$i '{if(NR==i) print $1}'`
	y=`cat $TXTOUT | awk -v i=$i '{if(NR==i) print $2}'`
	echo '  <coordinate>' >> $XMLOUT
	echo "    <x>$x</x>" >> $XMLOUT
	echo "    <y>$y</y>" >> $XMLOUT
	echo '  </coordinate>' >> $XMLOUT
	i=$(( i + 1 ))
done

echo '</fsc>' >> $XMLOUT

###make nice closing statement
echo
echo '###############################################################################################################'
echo "Converted $IN into plain txt format with frequence instead of wave number as well as into EMDB-style xml format"
echo "Plain txt file with frequency in column 1 and FSC in column 2 is saved as $TXTOUT"
echo "EMDB-style xml file is saved as $XMLOUT"
echo '###############################################################################################################'
echo

exit

