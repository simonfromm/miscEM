#!/bin/bash

#check input
if [ -z $4 ] ; then
 echo
 echo 'Script to plot ms peptide spectra'
 echo
 echo "Usage ${0##*/} (1) (2) (3) (4) ..."
 echo ''
 echo '(1) peptide name/label (no spaces)'
 echo '(2) min m/z value'
 echo '(3) max m/z value'
 echo '(4) data file(s) ending with .dat'
 echo
 echo 'exiting now...'
 echo
 exit
fi

PEPTIDE=$1
shift
RANGE_LOW=$1
shift
RANGE_HIGH=$1
shift
DATA=$*

#determine max y-value
#YMAX=`cat $DATA | awk '{print $i3}' | sort -g | tail -1 | awk '{print $1*1.1}'`


DATE=`date +%F | sed -e 's/-//g'`
SCRIPT=${DATE}_hdx-peptide_gnuplot.sh

for f in $DATA
do
 echo \#\!'/bin/bash' > $SCRIPT
 echo '' >> $SCRIPT
 echo '' >> $SCRIPT
 echo 'gnuplot -persist <<EOF' >> $SCRIPT
 	echo '	set term post color landscape' >> $SCRIPT
	echo "	set output" \""${DATE}_${f%*.dat}_${PEPTIDE}.eps"\" >> $SCRIPT
	echo "	unset key" >> $SCRIPT
	echo "  set title" \""${f%*.dat} ${PEPTIDE}"\" >> $SCRIPT
	echo "	set xrange[$RANGE_LOW:$RANGE_HIGH]" >> $SCRIPT
	echo "	set xtics nomirror out" >> $SCRIPT
	echo "	unset ytics" >> $SCRIPT
	echo "	set border 1 " >> $SCRIPT
	echo "	set yrange[0:*]" >> $SCRIPT
	echo "	set xlabel" \""m/z"\" >> $SCRIPT
	echo "  plot '$f' u 1:2 w l lc rgb " \""#000000"\" >> $SCRIPT
	echo '	exit' >> $SCRIPT
	echo 'EOF' >> $SCRIPT
	echo 'exit' >> $SCRIPT

 chmod +x $SCRIPT

 ./$SCRIPT
done

rm -f $SCRIPT

exit

