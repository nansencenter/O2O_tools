#!/bin/bash

input=$1
output=$2

cdo remapbil,r360x180 -selindexbox,1,360,1,290 $input $output >/dev/null 2>&1
