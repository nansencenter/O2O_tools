#!/bin/bash

exp=historical

for model in GFDL
do	     

bash cmip2woa.sh $model 1950-1969 $exp
bash cmip2woa.sh $model 1970-1989 $exp
bash cmip2woa.sh $model 1990-2009 $exp
bash cmip2woa.sh $model 2010-2014 $exp

done

exit
