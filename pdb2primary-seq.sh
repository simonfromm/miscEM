#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to get primary seq from pdb file                                   ###
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
 echo "Script to get primary sequence from a pdb as a plain cummulative sequence or by chain in fasta format"
 echo "Usage: ${0##*/} (1) (2)"
 echo 
 echo "		(1) 'plain' or 'fasta'"
 echo "		(2) pdb file"
 echo 
 echo "exiting..."
 echo
 exit
fi

TYPE=$1
shift
IN=$1
shift

if [ $TYPE = plain ]
then
 cat $IN | awk '{if($1=="ATOM") print $4, $6}' | uniq | awk '{print $1}' | sed -e 's/ALA/A/g' -e 's/ARG/R/g' -e 's/ASN/N/g' -e 's/ASP/D/g' -e 's/CYS/C/g' -e 's/GLN/Q/g' -e 's/GLU/E/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LEU/L/g' -e 's/LYS/K/g' -e 's/MET/M/g' -e 's/PHE/F/g' -e 's/PRO/P/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/VAL/V/g' | awk '{printf "%s", $1}' > primary_seq.dat
elif [ $TYPE = fasta ]
then
 chains=`cat $IN | awk '{if($1=="ATOM") print $5}' | sort -g | uniq`
 for f in $chains
 do
  echo ">"chain_${f} >> primary_seq.fasta
  cat $IN | awk '{if($1=="ATOM") print $4, $5, $6}' | grep " $f " | awk '{print $1, $3}' | uniq | awk '{print $1}' | sed -e 's/ALA/A/g' -e 's/ARG/R/g' -e 's/ASN/N/g' -e 's/ASP/D/g' -e 's/CYS/C/g' -e 's/GLN/Q/g' -e 's/GLU/E/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LEU/L/g' -e 's/LYS/K/g' -e 's/MET/M/g' -e 's/PHE/F/g' -e 's/PRO/P/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/VAL/V/g' | awk '{printf "%s", $1}' >> primary_seq.fasta
  echo "" >> primary_seq.fasta
 done
else
 echo ""
 echo "#####################################################################"
 echo "Wrong output type specified, please specify either 'plain' or 'fasta'"
 echo "exiting now...."
 echo "#####################################################################"
 exit
fi
  
exit
