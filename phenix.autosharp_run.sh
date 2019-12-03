#!/bin/bash

#################################################################################
### Simon Fromm, UC Berkeley 2019                                             ###
###                                                                           ###
### Script to run phenix density modification from the command line           ###
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

if [[ -z $1 ]] ; then
  echo ""
  echo "Variables empty, usage is $0 (1) (2) (3)"
  echo ""
  echo "(1)  = full unsharpened map"
  echo "(2)  = resolution"
  echo "(3)  = pdb"
  echo ""
  exit
fi

FULL=$1
shift
RES=$1
shift
PDB=$1
shift

OUTBASE=${FULL##*/}
OUTBASE=${OUTBASE%*.mrc}
OUTBASE=${OUTBASE%*.ccp4}

phenix.auto_sharpen input_files.map_file=${FULL} input_files.pdb_file=${PDB} crystal_info.resolution=${RES} output_files.sharpened_map_file=${OUTBASE}_autosharpened.ccp4 

exit
