#!/bin/bash

model=$1
range=$2
EXP=$3

year_start=${range:0:4}
year_end=${range:5:4}

mrange=${year_start}01-${year_end}12

case $model in
    GFDL)
	INSTITUTE=NOAA-GFDL
        MODEL=GFDL-ESM4
        ENS=r1i1p1f1
	GRID=gr
        VER=latest #v20190726
	;;
    MPI-LR)
	INSTITUTE=MPI-M
        MODEL=MPI-ESM1-2-LR
        ENS=r1i1p1f1
	GRID=gn
        VER=latest #v20190726
	;;
    MPI-HR)
	INSTITUTE=MPI-M
        MODEL=MPI-ESM1-2-HR
        ENS=r1i1p1f1
	GRID=gn
        VER=latest #v20190726
	;;
    *)
	echo $"Usage: $0 {GFDL|MPI-LR|MPI-HR} {1950-1969|1970-1989|1990-2009|2010-2014} {historical|}"
        exit 1
esac    

SRCDIR=/nird/datalake/NS9560K/ESGF/CMIP6/CMIP/${INSTITUTE}/${MODEL}/${EXP}/${ENS}/Omon
DATDIR=$(dirname $PWD)/data/${MODEL}/${EXP}

mkdir -p $DATDIR

target_hgrid=def_hgrid_woa.txt
target_zgrid=def_zgrid_woa.txt

var_list=(dissic o2 no3 thetao so mlotst)

for var in ${var_list[*]}
do	    

    ncfile=${var}_Omon_${MODEL}_${EXP}_${ENS}_${GRID}_${mrange}.nc
    ncfile_in=${SRCDIR}/${var}/${GRID}/latest/${ncfile}

    if [ -f $ncfile_in ]; then
       ncfile_out=${DATDIR}/${ncfile%.*}_WOA.nc
       if [ ! -f $ncfile_out ]; then
          if [ "$var" == "mlotst" ]; then # 2D variables
             cdo -s remapbil,${target_hgrid} $ncfile_in $ncfile_out        # Horizontal interpolation 
          else                            # 3D variables
             cdo -s remapbil,${target_hgrid} $ncfile_in tmp.nc             # Horizontal interpolation
             cdo -s intlevel,$(cat def_zgrid_woa.txt) tmp.nc $ncfile_out   # Vertical interpolation
             rm tmp.nc
          fi
          echo "${ncfile_out} SAVED"
       else
          echo "${ncfile_out} EXITS, SKIPP"
       fi
    else
       echo "Can not find $ncfile_in"
    fi

done

exit
