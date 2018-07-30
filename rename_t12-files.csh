#!/bin/tcsh -f

###script to rename T12 files recorded with EMMENU
###Jul 13, 2018
###no input required! simply run the script in the folder with the micrographs to be renamed
###does only work with numbers below 1000

@ i = 1

while ( $i < 10)
	rename "s/_$i.tif/_00$i.tif/" *.tif
	@ i++
end

@ i = 10

while ( $i < 100)
	rename "s/_$i.tif/_0$i.tif/" *.tif
	@ i++
end
exit
