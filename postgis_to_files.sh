#!/bin/bash

DATABASE='PG:host=xx dbname=xx user=xx password=xx'
FORMAT="${FORMAT} geojson"
FORMAT="${FORMAT} csv"
FORMAT="${FORMAT} xlsx"

echo " *** Números de Polícia *** "
for type in ${FORMAT}; do
	echo ${type}
	ogr2ogr -f ${type} numeros_policia.${type} \
	"$DATABASE" \
	-sql "select numero_policia, toponimo, id_toponimo, freguesia_lugar, geom from cartografia.numeros_policia where numero_policia is not null" 
done

echo " *** Topónimos *** "
for type in ${FORMAT}; do
	echo ${type}
	ogr2ogr -f ${type} toponimia.${type} \
	"$DATABASE" \
	-sql "select toponimo, toponimo_complementar,id_toponimo,lugar, cod_freguesia, geom from cartografia.toponimos"
done

echo " *** Limites de Freguesia *** "
for type in ${FORMAT}; do
	echo ${type}
	ogr2ogr -f ${type} limites_freguesia.${type} \
	"$DATABASE" \
	-sql "select distrito, concelho, freguesia, designacao_simplificada, dicofre, area_t_ha as area_hectares, geom from limites_administrativos.limites_freguesia"
done

echo " *** Lugares *** "
for type in ${FORMAT}; do
	echo ${type}
	ogr2ogr -f ${type} lugares.${type} \
	"$DATABASE" \
	-sql "select freguesia, lug11desig, lug11, geom from limites_administrativos.lugares_bgri2011_cgpr"
done

echo " *** Equipamentos Desportivos *** "
for type in ${FORMAT}; do
	echo ${type}
	ogr2ogr -f ${type} equipamentos_desportivos.${type} \
	"$DATABASE" \
	-sql "select designacao, situacao, tipologia, classificacao, funcionamento, horario_diario, descanso_semanal, freguesia, localidade, toponimo, numero_policia, codigo_postal, url, geom from equipamentos.equipamentos_desportivos"
done

echo " *** Yay! All Done! *** "
