#!/bin/bash

input=$1
output=$2

cdo remapbil,r360x180 -selindexbox,2,361,2,293 $input $output >/dev/null 2>&1
