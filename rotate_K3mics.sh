#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to rotate micrographs by 90 degrees using newstack from imod       ###
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
if [ -z $1 ] ; then
 echo
 echo 'Script to rotate micrographs by 90 degrees. Uses newstack from imod'
 echo
 echo "Usage ${0##*/} (1)"
 echo ''
 echo '(1) micrographs (use wildcards)'
 echo
 echo 'exiting now...'
 echo
 exit
fi

for f in $*
do
 newstack -rotate 90 $f ${f%%.mrc}_rotated.mrc
done

exit
