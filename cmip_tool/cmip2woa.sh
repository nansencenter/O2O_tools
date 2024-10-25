#!/bin/bash
#
# References:
#   https://code.mpimet.mpg.de/boards/1/topics/8676
#   https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/754286611/Regridding+E3SM+Data+with+ncremap
#

module load CDO/2.0.6-gompi-2022a  # this will take care of HDF5 and netCDF version
module load NCO/5.1.9-iomkl-2022a

model=$1
EXP=$2
mode=$3

case $model in
    NCC)
	INSTITUTE=NCC
        MODEL=NorESM2-MM
        ENS=r1i1p1f1
        VER=(latest)
        GRID=(gr) # lev = 0, 5, 10 , ..
        dlist_hst=(1950-1959 1960-1969 1970-1979 1980-1989 1990-1999 2000-2009 2010-2014)
        dlist_ssp=(2015-2020 2021-2030 2031-2040 2041-2050 2051-2060 2061-2070 2071-2080 2081-2090 2091-2100)
	;;
    GFDL)
	INSTITUTE=NOAA-GFDL
        MODEL=GFDL-ESM4
        ENS=r1i1p1f1
        VER=(latest)
        GRID=(gr) # lev = 2.5, 10, 20, ..
        dlist_hst=(1950-1969 1970-1989 1990-2009 2010-2014)
        dlist_ssp=(2015-2034 2035-2054 2055-2074 2075-2094 2095-2100)
	;;
    MPI)
	INSTITUTE=MPI-M
        MODEL=MPI-ESM1-2-LR
        ENS=r1i1p1f1
        VER=(latest)
        GRID=(gn) # lev = 6, 17, 27, ..
        dlist_hst=(1950-1969 1970-1989 1990-2009 2010-2014)
        dlist_ssp=(2015-2034 2035-2054 2055-2074 2075-2094 2095-2100)
	;;
    IPSL)
	INSTITUTE=IPSL
        MODEL=IPSL-CM6A-LR
        ENS=r1i1p1f1
        VER=(latest)
        #VER=(v20190119 latest)
        GRID=(gn) # olevel = 0.50576, 1.555855, 2.667682, 3.85628, ..
	dlist_hst=(195001-196912 197001-198912 199001-200912 201001-201412)               # sliced files
	dlist_ssp=(201501-203412 203501-205412 205501-207412 207501-209412 209501-210012) # sliced files
        #dlist_hst=(1850-2014 1950-2014) # original file
        #dlist_ssp=(2015-2100)           # original file
	;;
    CCCma) # issue remains in horizontal interpolation
	INSTITUTE=CCCma
        MODEL=CanESM5
        ENS=r1i1p1f1
        VER=(latest)
        GRID=(gn) # lev = 3.04677271842957, 9.4540491104126, 16.3639659881592, ..
        dlist_hst=(1850-2014 1941-1950 1951-1960 1961-1970 1971-1980 1981-1990 1991-2000 2001-2010 2011-2014)
        dlist_ssp=(2015-2100 2015-2020 2021-2030 2031-2040 2041-2050 2051-2060 2061-2070 2071-2080 2081-2090 2091-2100)
	;;
    MOHC)
	INSTITUTE=MOHC
        MODEL=UKESM1-0-LL
        ENS=r1i1p1f2
        VER=(latest)
        GRID=(gn) # lev = 0.505760014057159, 1.55585527420044, 2.66768169403076, ..
        dlist_hst=(1950-1999 2000-2014 1950-2014)
        dlist_ssp=(2015-2049 2050-2099 2100-2100 2050-2100)
	;;
    CNRM)
	INSTITUTE=CNRM-CERFACS
        MODEL=CNRM-ESM2-1
        ENS=r1i1p1f2
        VER=(latest)
        GRID=(gn) # lev = 0.505760017002558, 1.55585530384678, 2.6676817536727, ..
        dlist_hst=(1850-2014 195001-197412 1950-1999 197501-199912 2000-2014 200001-201412)
        dlist_ssp=(2015-2064 2065-2100 2015-2100 2015-2039 2040-2064 2065-2089 2090-2100)
	;;
    NCAR) # o2 in historical run is missing
	INSTITUTE=NCAR
        MODEL=CESM2
        ENS=r4i1p1f1
        #ENS=r1i1p1f1
        VER=(latest)
        GRID=(gn) # 500, 1500, 2500, 3500, .. in cm!
        dlist_hst=(1850-2014)
        dlist_ssp=(2015-2064 2065-2100)
	;;
    MIROC) # BGC variables are missing
	INSTITUTE=MIROC
        MODEL=MIROC-ES2L
        ENS=r1i1p1f2
        VER=(latest)
        #VER=(v20190823 latest)
        GRID=(gn) # 1, 3.5, 7, 11, 15.5, 
        dlist_hst=(1850-2014) # original file
        dlist_ssp=(2015-2100) # original file
	;;
    *)
	echo $"Usage: $0 {NCC|GFDL|MPI|IPSL|MOHC|CNRM|CCCma|NCAR|MIROC} {historical|ssp585} {run|overwrite|(check)}"
        exit 1
esac    

#--

DATDIR=$(dirname $PWD)/data/${MODEL}/${EXP}
mkdir -p $DATDIR

#-- IPSL file is too big, so sliced to smaller files first

if [ "$model" == "IPSL" ]; then
   if [ "$mode" == "run" ]; then
       if [ ! -d $DATDIR/sliced ]; then
          bash slice_ipsl.sh
       fi
   elif [ "$mode" == "check" ]; then
       if [ ! -d $DATDIR/sliced ]; then
          echo "IPSL files are sliced to smaller chunks first."
       fi
   fi
fi
    
#--

target_hgrid=global_1 # This option is equivalent to WOA 1degx1deg grid
#target_hgrid=def_hgrid_woa.txt
target_zgrid=def_zgrid_woa.txt

version_list=("${VER[@]}")
var_list=(thetao)
#var_list=(thetao so o2 no3)
#var_list=(dissic o2 o2sat no3 po4 thetao so mlotst agessc msftmz msftyz)
grid_list=("${GRID[@]}")

if [ "$EXP" == "historical" ]; then
   dlist=("${dlist_hst[@]}")
   if [ "$model" == "NCC" ]; then
     SRCDIR=/nird/projects/NS9034K/CMIP6/CMIP/${INSTITUTE}/${MODEL}/${EXP}/${ENS}/Omon
   elif [ "$model" == "IPSL" ]; then
     SRCDIR=${DATDIR}/sliced
   else
     SRCDIR=/nird/datalake/NS9560K/ESGF/CMIP6/CMIP/${INSTITUTE}/${MODEL}/${EXP}/${ENS}/Omon
   fi
else
   dlist=("${dlist_ssp[@]}")
   if [ "$model" == "NCC" ]; then
     SRCDIR=/nird/projects/NS9034K/CMIP6/ScenarioMIP/${INSTITUTE}/${MODEL}/${EXP}/${ENS}/Omon
   elif [ "$model" == "IPSL" ]; then
     SRCDIR=${DATDIR}/sliced
   else
     SRCDIR=/nird/datalake/NS9560K/ESGF/CMIP6/ScenarioMIP/${INSTITUTE}/${MODEL}/${EXP}/${ENS}/Omon
   fi
fi

echo "------------------------------"
echo " Convert from $SRCDIR"
echo "           to $DATDIR"
echo "------------------------------"

for file in tmp*.nc; do
  [ -f $file ] && rm $file
done	    

for range in ${dlist[*]}
do
  if [ ${#range} -eq 9 ]; then
     year_start=${range:0:4}
     year_end=${range:5:4}
     mrange=${year_start}01-${year_end}12
  else
     mrange=$range
  fi

  echo "-----------------------------"
  echo "${EXP^^}: $mrange"
  echo "-----------------------------"

for var in ${var_list[*]}
do	    

for grid in ${grid_list[*]}
do

for ver in ${version_list[*]}
do

    ncfile=${var}_Omon_${MODEL}_${EXP}_${ENS}_${grid}_${mrange}.nc
    if [ "$model" == "IPSL" ]; then
	ncfile_in=${SRCDIR}/${ncfile}
    else
	ncfile_in=${SRCDIR}/${var}/${grid}/${ver}/${ncfile}
    fi

    if [ -f $ncfile_in ]; then
       echo "$ncfile_in will be regridded" 
       ncfile_out=${DATDIR}/${ncfile%.*}_WOA.nc
       if [ ! -f $ncfile_out ] || [ "$mode" == "overwrite" ]; then
          if [ "$mode" == "run" ] || [ "$mode" == "overwrite" ]; then
             if [ "$var" == "mlotst" ]; then                                         # horizontal 2D variables
                cdo -s remapbil,${target_hgrid} $ncfile_in $ncfile_out                  # Horizontal interpolation
             elif [ "$var" == "msftmz" ] ||  [ "$var" == "msftyz" ]; then            # vertical 2D variables
                ln -sf $ncfile_in $ncfile_out                                           # Just create symlinks
             else                                                                    # 3D variables
		#
		# Horizontal interpolation
		#
                if [ "$model" == "MPI" ]; then
		   bash hinterp_mpi.sh $ncfile_in tmp.nc                  
                elif [ "$model" == "IPSL" ]; then
		   bash ipsl.sh $ncfile_in tmp.nc $var
		   #bash hinterp_ipsl.sh $ncfile_in tmp.nc $var
                elif [ "$model" == "CCCma" ]; then
		   bash hinterp_cccma.sh $ncfile_in tmp.nc 
                elif [ "$model" == "CNRM" ]; then
		   bash hinterp_cnrm.sh $ncfile_in tmp.nc
                elif [ "$model" == "NCAR" ]; then
		   bash hinterp_ncar.sh $ncfile_in tmp.nc
                elif [ "$model" == "MIROC" ]; then
		   bash hinterp_miroc.sh $ncfile_in tmp.nc
		else
                   cdo -s remapbil,${target_hgrid} $ncfile_in tmp.nc >/dev/null 2>&1
		fi
		#
		# Vertical interpolation
		#
                if  [ ! -f tmp.nc ]; then
                   echo "Failed in horizontal interpolation of  $ncfile_in, SKIP"
                   break
                else
                   cdo -s intlevel,$(cat ${target_zgrid}) tmp.nc $ncfile_out
                   rm tmp.nc #commented out to check horizontal interpolation
                fi
             fi
             if [ "$mode" == "overwrite" ]; then
		 echo "${ncfile_out} is OVER-WRITTEN"
	     else
		 echo "${ncfile_out} is SAVED"
	     fi
          else
             echo "${ncfile_out} will be SAVED or OVER-WRITTEN"
          fi
       else
          if [ "$mode" == "run" ]; then
             echo "${ncfile_out} is SKIPPED"
	  else
             echo "${ncfile_out} will be SKIPPED or OVER-WRITTEN"
	  fi
       fi
    fi

done

done

done

done

exit
