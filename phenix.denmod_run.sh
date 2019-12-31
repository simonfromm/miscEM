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
  echo "Variables empty, usage is $0 (1) (2) (3) (4) (5) (6) (7)"
  echo ""
  echo "(1)  = half map 1"
  echo "(2)  = half map 2"
  echo "(3)  = full map ('None' if not applicable)"
  echo "(4)  = mask ('None' if not applicable)"
  echo "(5)  = resolution"
  echo "(6)  = sequence file or molecular weight in Dalton"
  echo "(7)  = restore full box size ('true' or 'false')"
  echo ""
  exit
fi

HALF1=$1
shift
HALF2=$1
shift
FULL=$1
shift
MASK=$1
shift
RES=$1
shift
MW=$1
shift
BOXSIZE=$1

OUTBASE=${HALF1##*/}
OUTBASE=${OUTBASE%*_half_1.mrc}

if [ -e $MW ]
then
 echo "phenix.resolve_cryo_em input_files.half_map_file_name_1=${HALF1} input_files.half_map_file_name_2=${HALF2} input_files.map_file_name=${FULL} input_files.mask_file_name=${MASK} input_files.seq_file=${MW} crystal_info.resolution=${RES} output_files.denmod_blur_50_map_file_name=${OUTBASE}_denmod_blur50.ccp4 output_files.denmod_map_file_name=${OUTBASE}_denmod.ccp4 output_files.denmod_half_map_1_file_name=${OUTBASE}_denmod_half_1.ccp4 output_files.denmod_half_map_2_file_name=${OUTBASE}_denmod_half_2.ccp4 output_files.restore_full_size=${BOXSIZE}" > phenix.denmod_command.txt
 phenix.resolve_cryo_em input_files.half_map_file_name_1=${HALF1} input_files.half_map_file_name_2=${HALF2} input_files.map_file_name=${FULL} input_files.mask_file_name=${MASK} input_files.seq_file=${MW} crystal_info.resolution=${RES} output_files.denmod_blur_50_map_file_name=${OUTBASE}_denmod_blur50.ccp4 output_files.denmod_map_file_name=${OUTBASE}_denmod.ccp4 output_files.denmod_half_map_1_file_name=${OUTBASE}_denmod_half_1.ccp4 output_files.denmod_half_map_2_file_name=${OUTBASE}_denmod_half_2.ccp4 output_files.restore_full_size=${BOXSIZE}
else
 echo "phenix.resolve_cryo_em input_files.half_map_file_name_1=${HALF1} input_files.half_map_file_name_2=${HALF2} input_files.map_file_name=${FULL} input_files.mask_file_name=${MASK} crystal_info.molecular_mass=${MW} crystal_info.resolution=${RES} output_files.denmod_blur_50_map_file_name=${OUTBASE}_denmod_blur50.ccp4 output_files.denmod_map_file_name=${OUTBASE}_denmod.ccp4 output_files.denmod_half_map_1_file_name=${OUTBASE}_denmod_half_1.ccp4 output_files.denmod_half_map_2_file_name=${OUTBASE}_denmod_half_2.ccp4 output_files.restore_full_size=${BOXSIZE}" > phenix.denmod_command.txt
 phenix.resolve_cryo_em input_files.half_map_file_name_1=${HALF1} input_files.half_map_file_name_2=${HALF2} input_files.map_file_name=${FULL} input_files.mask_file_name=${MASK} crystal_info.molecular_mass=${MW} crystal_info.resolution=${RES} output_files.denmod_blur_50_map_file_name=${OUTBASE}_denmod_blur50.ccp4 output_files.denmod_map_file_name=${OUTBASE}_denmod.ccp4 output_files.denmod_half_map_1_file_name=${OUTBASE}_denmod_half_1.ccp4 output_files.denmod_half_map_2_file_name=${OUTBASE}_denmod_half_2.ccp4 output_files.restore_full_size=${BOXSIZE}
fi

exit
