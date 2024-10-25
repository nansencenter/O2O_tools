#!/bin/bash

module load NCO/5.1.9-iomkl-2022a

DIRHST=/nird/projects/NS9481K/O2O_tools/data/MIROC-ES2L/historical
DIRSSP=/nird/projects/NS9481K/O2O_tools/data/MIROC-ES2L/ssp585
DIRDAT=/nird/projects/NS9481K/O2O_tools/data/MIROC-ES2L

mkdir -p $DIRDAT

#-- historical

rm slice_list.sh

for var in thetao so o2 no3
do
   file_in=$DIRHST/${var}_Omon_MIROC-ES2L_historical_r1i1p1f2_gn_185001-201412_WOA.nc
   for range in "195001-196912" "197001-198912" "199001-200912" "201001-201412"
   do
      file_out=$DIRHST/${var}_Omon_MIROC-ES2L_historical_r1i1p1f2_gn_${range}_WOA.nc
      date_ini="${range:0:4}-${range:4:2}-01"     
      date_end="${range:7:4}-${range:11:2}-31"
      if [ -f $file_in ]; then
	  if [ ! -f $file_out ]; then
              echo "ncks -d time,'$date_ini','$date_end' $file_in $file_out ;" >> slice_list.sh
	      echo "wait" >> slice_list.sh
	      ncks -d time,${date_ini},${date_end} $file_in $file_out
	  fi
      fi
   done       
done

#-- SSP585

for var in thetao so o2 no3
do
   file_in=$DIRSSP/${var}_Omon_MIROC-ES2L_ssp585_r1i1p1f2_gn_201501-210012_WOA.nc
   for range in "201501-203412" "203501-205412" "205501-207412" "207501-209412" "209501-210012"
   do
      file_out=$DIRSSP/${var}_Omon_MIROC-ES2L_ssp585_r1i1p1f2_gn_${range}_WOA.nc
      date_ini="${range:0:4}-${range:4:2}-01"     
      date_end="${range:7:4}-${range:11:2}-31"
      if [ -f $file_in ]; then
	  if [ ! -f $file_out ]; then
              echo "ncks -d time,'$date_ini','$date_end' $file_in $file_out ;" >> slice_list.sh
	      echo "wait" >> slice_list.sh
              ncks -d time,${date_ini},${date_end} $file_in $file_out
	  fi
      fi
   done
done
