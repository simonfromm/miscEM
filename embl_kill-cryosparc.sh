#!/bin/bash

#################################################################################
### Simon Fromm, EMBL 2024                                                    ###
###                                                                           ###
### Script to generate gridmap montage from SerialEM stack. Stack must have   ###
###     .st extension and accompanying .st.mdoc file.                         ###
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


USR=`echo $USER`

JOBS=`ps -ef | grep cryosparc | awk -v X=$USR '{if($1=="X") print $2}'`

echo "#################################################################################################"
echo "ATTENTION: This will kill all cryosparc processes run under the user $USR on $HOSTNAME as listed below"
echo "#################################################################################################"
echo
ps -ef | grep cryosparc | awk -v X=$USR '{if($1=="X") print $0}'
echo
echo "#################################################################################################"
read -p "press [Enter] key to confirm and run script or Ctrl+C to abort..."

for f in $JOBS
do
 sudo kill -9 $f
done

echo
echo "######################################################################################################################"
echo "All jobs listed above have been attempted to be killed; if none are listed below anymore the operation was successful."
echo "If some jobs are still listed, you may not have permissions to kill the above listed jobs. Sorry about that."
echo "######################################################################################################################"
echo
ps -ef | grep cryosparc | awk -v X=$USR '{if($1=="X") print $0}'

exit

