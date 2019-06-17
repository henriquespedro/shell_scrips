#!/bin/bash

FORMAT="${FORMAT} shp_outras_cond"

for filename  in ${FORMAT}/*.shp; do
        base=${filename##*/}
        echo "Load - " ${base%.*}
        shp2pgsql -s 3763 -W "latin1" "$filename" revisao_igt."$base" | psql -p 5432 -h localhost -U postgres -d xxxx
done

echo " *** Yay! All Done! *** "
