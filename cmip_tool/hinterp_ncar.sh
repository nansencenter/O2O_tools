#!/bin/bash

input=$1
output=$2

rm tmp*.nc

ncap2 -s 'lev=lev*0.01' $input tmp0.nc
cdo remapbil,r360x180 tmp0.nc $output >/dev/null 2>&1

rm tmp0.nc
