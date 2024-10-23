#!/bin/bash

input=$1
output=$2

rm tmp*.nc

ncks -C -O -x -v depth   $input  tmp0.nc
ncks -C -O -x -v depth_c tmp0.nc tmp1.nc
ncks -C -O -x -v eta     tmp1.nc tmp2.nc

cdo remapbil,r360x180 tmp2.nc $output >/dev/null 2>&1

rm tmp0.nc tmp1.nc tmp2.nc
