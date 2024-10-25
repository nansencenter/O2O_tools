#!/bin/bash

input=$1
output=$2
var=$3

rm tmp*.nc

ncks -C -O -x -v area                        $input  tmp0.nc
ncks -C -O -x -v olevel_bounds               tmp0.nc tmp1.nc
ncks -C -O -x -v bounds_nav_lat              tmp1.nc tmp2.nc
ncks -C -O -x -v bounds_nav_lon              tmp2.nc tmp3.nc
ncatted -a bounds,,d,,                       tmp3.nc
ncrename -v nav_lat,lat -v nav_lon,lon       tmp3.nc tmp4.nc
ncatted -O -a coordinates,$var,m,c,"lat lon" tmp4.nc

cdo remapbil,r360x180 -selindexbox,2,361,2,331 tmp5.nc $output >/dev/null 2>&1
ncrename -d olevel,lev -v olevel,lev         $output

rm tmp0.nc tmp1.nc tmp2.nc tmp3.nc tmp4.nc
