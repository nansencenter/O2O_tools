#!/bin/bash

model=$1
EXP=$2
mode=$3

case $model in
    GFDL)
	INSTITUTE=NOAA-GFDL
        MODEL=GFDL-ESM4
        ENS=r1i1p1f1
        VER=latest
        dlist_hst=(1950-1969 1970-1989 1990-2009 2010-2014)
        dlist_ssp=(2015-2034 2035-2054 2055-2074 2075-2094 2095-2100)
	;;
    MPI)
	INSTITUTE=MPI-M
        MODEL=MPI-ESM1-2-LR
        ENS=r1i1p1f1
        VER=latest
        dlist_hst=(1950-1969 1970-1989 1990-2009 2010-2014)
        dlist_ssp=(2015-2034 2035-2054 2055-2074 2075-2094 2095-2100)
	;;
    IPSL)
	INSTITUTE=IPSL
        MODEL=IPSL-CM6A-LR
        ENS=r1i1p1f1
        VER=latest
        dlist_hst=(1850-2014 1850-1949 1950-2014)
        dlist_ssp=(2015-2100)
	;;
    CCCma)
	INSTITUTE=CCCma
        MODEL=CanESM5
        ENS=r1i1p1f1
        VER=latest
        dlist_hst=(1941-1950 1951-1960 1961-1970 1971-1980 1981-1990 1991-2000 2001-2010 2011-2014 1850-2014)
        dlist_ssp=(2015-2100 2015-2020 2021-2030 2031-2040 2041-2050 2051-2060 2061-2070 2071-2080 2081-2090 2091-2100)
	;;
    MOHC)
	INSTITUTE=MOHC
        MODEL=UKESM1-0-LL
        ENS=r1i1p1f2
        VER=latest
        dlist_hst=(1950-1999 2000-2014 1950-2014)
        dlist_ssp=(2015-2049 2050-2099 2100-2100 2050-2100)
	;;
    CNRM)
	INSTITUTE=CNRM-CERFACS
        MODEL=CNRM-ESM2-1
        ENS=r1i1p1f2
        VER=latest
        dlist_hst=(1950-1999 2000-2014 1950-2014)
        dlist_ssp=(2015-2064 2065-2100 2015-2100)
	;;
    NCAR)
	INSTITUTE=NCAR
        MODEL=CESM2
        #ENS=r1i1p1f1
        ENS=r4i1p1f1
        VER=latest
        dlist_hst=(1850-2014)
        dlist_ssp=(2015-2064 2065-2100)
	;;
    MIROC)
	INSTITUTE=MIROC
        MODEL=MIROC-ES2L
        ENS=r1i1p1f2
        VER=latest
        dlist_hst=(1850-2014)
        dlist_ssp=(2015-2100)
	;;
    *)
	echo $"Usage: $0 {GFDL|MPI|IPSL|CCCma|MOHC|CNRM|NCAR|MIROC} {historical|ssp585} {run|check}"
        exit 1
esac    

DATDIR=$(dirname $PWD)/data/${MODEL}/${EXP}

mkdir -p $DATDIR

target_hgrid=def_hgrid_woa.txt
target_zgrid=def_zgrid_woa.txt

var_list=(dissic o2 no3 po4 thetao so mlotst agessc msftmz msftyz)
grid_list=(gn gr)

if [ "$EXP" == "historical" ]; then
   dlist=("${dlist_hst[@]}")
   SRCDIR=/nird/datalake/NS9560K/ESGF/CMIP6/CMIP/${INSTITUTE}/${MODEL}/${EXP}/${ENS}/Omon
else
   dlist=("${dlist_ssp[@]}")
   SRCDIR=/nird/datalake/NS9560K/ESGF/CMIP6/ScenarioMIP/${INSTITUTE}/${MODEL}/${EXP}/${ENS}/Omon
fi

echo "------------------------------"
echo " Convert from $SRCDIR"
echo "           to $DATDIR"
echo "------------------------------"

for range in ${dlist[*]}
do

  year_start=${range:0:4}
  year_end=${range:5:4}
  mrange=${year_start}01-${year_end}12

  echo "-----------------------------"
  echo "${EXP^^}: $mrange"
  echo "-----------------------------"

for var in ${var_list[*]}
do	    

for grid in ${grid_list[*]}
do

    ncfile=${var}_Omon_${MODEL}_${EXP}_${ENS}_${grid}_${mrange}.nc
    ncfile_in=${SRCDIR}/${var}/${grid}/latest/${ncfile}

    if [ -f $ncfile_in ]; then
       ncfile_out=${DATDIR}/${ncfile%.*}_WOA.nc
       if [ ! -f $ncfile_out ]; then
          if [ "$mode" == "run" ]; then
             if [ "$var" == "mlotst" ]; then                                         # horizontal 2D variables
                cdo -s remapbil,${target_hgrid} $ncfile_in $ncfile_out                  # Horizontal interpolation
             elif [ "$var" == "msftmz" ] ||  [ "$var" == "msftyz" ]; then            # vertical 2D variables
                ln -sf $ncfile_in $ncfile_out                                           # Just create symlinks
             else                                                                    # 3D variables
                cdo -s remapbil,${target_hgrid} $ncfile_in tmp.nc                       # Horizontal interpolation
                if  [ ! -f tmp.nc ]; then
                   echo "Failed in horizontal interpolation of  $ncfile_in, SKIP"
                   break
                else
                   cdo -s intlevel,$(cat ${target_zgrid}) tmp.nc $ncfile_out            # Vertical interpolation
                   rm tmp.nc
                fi
             fi
             echo "$(basename ${ncfile_out}) is SAVED"
          else
             echo "$(basename ${ncfile_out}) will be SAVED"
          fi
       else
          echo "$(basename ${ncfile_out}) exists, SKIP"
       fi
    #else
    #   echo "${var}/${grid}/latest/$(basename $ncfile_in) Can notbe found, SKIP"
    fi

done

done

done

exit
