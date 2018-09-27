#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2018                                             ###
###                                                                           ###
### Script to generate random selection from an input star file               ###
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
if [ -z $2 ] ; then
 echo
 echo 'Script to generate a starfile with a random selection from the input starfile; usefule for optimizing parameters for e.g. ctf determination or particle picking'
 echo
 echo "Usage ${0##*/} (1) (2)"
 echo '(1) starfile'
 echo '(2) desired number of random entries'
 echo
 echo 'exiting now...'
 echo
 exit
fi

#set variable
STARIN=$1
shift
ENTRIES=$1
shift

#make starfile backup
cp $STARIN ${STARIN%%.*}_bkp.star

#get length of header and print it in new file
HEAD=`cat $STARIN | grep "#" | tail -1 | awk '{print $2}' | sed -e 's/#//g' | awk '{print $1+6}'`
cat $STARIN | awk -v X=$HEAD '{if(NR<X) print $0}' >> ${STARIN%%.*}_random${ENTRIES}.tmp

#get total number of all entries
TOTAL=`cat $STARIN | awk -v X=$HEAD '{if(NR>=X) print $0}' | wc -l`

#generate starfile without header
cat $STARIN | awk -v X=$HEAD '{if(NR>=X) print $0}' > ${STARIN%%.*}_nohead.star

#generate random selection
i=1

while [[ $i -le $ENTRIES ]]
do
 RAND=`echo $(( RANDOM % $TOTAL ))`
 cat ${STARIN%%.*}_nohead.star | awk -v X=$RAND '{if(NR==X) print $0}' >> ${STARIN%%.*}_random${ENTRIES}.tmp2
 i=$(( i+1 ))
done

cat ${STARIN%%.*}_random${ENTRIES}.tmp2 | sort | uniq -u >> ${STARIN%%.*}_random${ENTRIES}.tmp3

cat ${STARIN%%.*}_random${ENTRIES}.tmp ${STARIN%%.*}_random${ENTRIES}.tmp3 >> ${STARIN%%.*}_random${ENTRIES}.star

rm -f ${STARIN%%.*}_random${ENTRIES}.tmp*
rm -f ${STARIN%%.*}_nohead.star

echo "Starfile with random selection based on ${STARIN} was generated with ${ENTRIES} randomly selected entries and stored as ${STARIN%%.*}_random${ENTRIES}.star"
echo "In case two entries where selected twice during the randomization the new star file does contain this number less of entries"

exit
