#!/bin/bash

module load NCO/5.1.9-iomkl-2022a

DIRHST=/nird/datalake/NS9560K/ESGF/CMIP6/CMIP/IPSL/IPSL-CM6A-LR/historical/r1i1p1f1/Omon
DIRSSP=/nird/datalake/NS9560K/ESGF/CMIP6/ScenarioMIP/IPSL/IPSL-CM6A-LR/ssp585/r1i1p1f1/Omon
DIRDAT=/nird/projects/NS9481K/O2O_tools/data/IPSL-CM6A-LR/

mkdir -p $DIRDAT

#-- historical

rm slice_list.sh

for var in thetao so o2 no3
do
   file_in=$DIRHST/$var/gn/latest/${var}_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_195001-201412.nc
   for range in "195001-196912" "197001-198912" "199001-200912" "201001-201412"
   do
      file_out=$DIRDAT/historical/sliced/${var}_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_${range}.nc
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

for file in $DIRDAT/historical/sliced/*.nc
do
   ncrename -d olevel,lev -v olevel,lev $file
done

#-- SSP585

for var in thetao so o2 no3
do
   file_in=$DIRSSP/$var/gn/latest/${var}_Omon_IPSL-CM6A-LR_ssp585_r1i1p1f1_gn_201501-210012.nc
   for range in "201501-203412" "203501-205412" "205501-207412" "207501-209412" "209501-210012"
   do
      file_out=$DIRDAT/ssp585/sliced/${var}_Omon_IPSL-CM6A-LR_ssp585_r1i1p1f1_gn_${range}.nc
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

for file in $DIRDAT/ssp585/sliced/*.nc
do
   ncrename -d olevel,lev -v olevel,lev $file
done
