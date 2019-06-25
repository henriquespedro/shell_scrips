/** Converter Polygon to Point */
CREATE OR REPLACE VIEW epanet.ee AS
	SELECT "UNIQUEID", ST_X(shape), st_y(shape) FROM aa.ee;


/** Calcular Rede **/
CREATE OR REPLACE VIEW epanet.vw_rede AS 
	SELECT row_number() over() as ID, "UNIQUEID", shape, epanet_type FROM (
		 SELECT a."UNIQUEID",
		    st_force2d(a.shape)::geometry('LINESTRING',3763) AS shape,
		    'co'::text AS epanet_type
		   FROM aa.co a,
		    ( SELECT st_union(vs.shape) AS shape
		           FROM aa.vs) b,
		    ( SELECT st_union(eb.shape) AS shape
		           FROM aa.eb) c,
		    ( SELECT st_union(vc.shape) AS shape
		           FROM aa.vc) d
		  WHERE st_disjoint(st_startpoint(a.shape), b.shape) AND st_disjoint(st_startpoint(a.shape), d.shape)
		UNION ALL
		 SELECT b."UNIQUEID", ST_LineSubstring(st_force2d(a.shape), 0, 0.5)::geometry('LINESTRING',3763) AS shape,
		    'vs'::text AS epanet_type
		   FROM aa.co a,
		    aa.vs b
		  WHERE st_intersects(st_startpoint(a.shape), b.shape)
		UNION ALL
		SELECT a."UNIQUEID", ST_LineSubstring(st_force2d(a.shape), 0.5, 1)::geometry('LINESTRING',3763) AS shape,
		    'co'::text AS epanet_type
		   FROM aa.co a,
		    aa.vs b
		  WHERE st_intersects(st_startpoint(a.shape), b.shape)
		UNION ALL
		 SELECT b."UNIQUEID", ST_LineSubstring(st_force2d(a.shape), 0, 0.5)::geometry('LINESTRING',3763) AS shape,
		    'vc'::text AS epanet_type
		   FROM aa.co a,
		    aa.vc b
		  WHERE st_intersects(st_startpoint(a.shape), b.shape)
		UNION ALL
		SELECT a."UNIQUEID", ST_LineSubstring(st_force2d(a.shape), 0.5, 1)::geometry('LINESTRING',3763) AS shape,
		    'co'::text AS epanet_type
		   FROM aa.co a,
		    aa.vc b
		  WHERE st_intersects(st_startpoint(a.shape), b.shape)
	) rede;


/** Criar tabela para o pgrouting **/
CREATE TABLE epanet.co_epanet as
SELECT * FROM epanet.vw_rede;

ALTER TABLE epanet.co_epanet ADD source INT4;
ALTER TABLE epanet.co_epanet ADD target INT4;
select pgr_createTopology('epanet.co_epanet', 0.0001, 'shape', 'id');


/** Relacionar tabela do pgrouting com os dado do coletor **/
CREATE OR REPLACE VIEW epanet.vw_co_epanet AS 
	SELECT DISTINCT b."UNIQUEID", b."TIPOCONDUT", b."COMPRIMENT", b."DIAINT", b."RUGOSIDADE", b."COEFPERDAS", a.source, a.target, a.epanet_type, a.shape
	FROM epanet.co_epanet a
	INNER JOIN aa.co b ON b."UNIQUEID" = a."UNIQUEID"


/** Criar Vertices dos troços de conduta **/
CREATE OR REPLACE VIEW epanet.vertices AS
	SELECT "UNIQUEID" , ST_X((ST_DumpPoints(shape)).geom), ST_Y((ST_DumpPoints(shape)).geom) FROM epanet.co_epanet


/* Calcular consumos */
CREATE OR REPLACE VIEW epanet.vw_ramal_consumo AS 
 SELECT a."UNIQUEID",
    sum(pc."CONSUMO") AS sum,
    st_union(a.shape) AS geom
   FROM aa.ra a
     JOIN aa.pc ON st_intersects(pc.shape, a.shape)
  GROUP BY a."UNIQUEID";

 CREATE OR REPLACE VIEW epanet.vw_condutas_consumo_montante_jusante AS
	SELECT row_number() over() as ID, "UNIQUEID", consumo, cota, shape FROM (
		SELECT a."UNIQUEID", sum(pc.sum) AS consumo, max(a."COTASOLMON") as cota, st_multi(st_union(ST_LineSubstring(st_force2d(a.shape), 0, 0.5)))::geometry('MULTILINESTRING',3763) AS shape
		   FROM aa.co a
			 LEFT JOIN epanet.vw_ramal_consumo pc ON st_intersects(st_startpoint(pc.geom), ST_LineSubstring(st_force2d(a.shape), 0, 0.5))
		  GROUP BY a."UNIQUEID"
		UNION ALL
				SELECT a."UNIQUEID", sum(pc.sum) AS consumo, max(a."COTASOLJUS") as cota, st_multi(st_union(ST_LineSubstring(st_force2d(a.shape), 0.5, 1)))::geometry('MULTILINESTRING',3763) AS shape
		   FROM aa.co a
			 LEFT JOIN epanet.vw_ramal_consumo pc ON st_intersects(st_startpoint(pc.geom), ST_LineSubstring(st_force2d(a.shape), 0.5, 1))
		  GROUP BY a."UNIQUEID"
		  
	) consumos;

CREATE OR REPLACE VIEW epanet.vw_condutas_consumo AS 
	SELECT a.id,
		sum(pc.consumo) AS consumo,
		max(pc.cota) as cota,
		st_union(a.the_geom)::geometry('POINT',3763) AS shape
	FROM epanet.co_epanet_vertices_pgr a
		JOIN epanet.vw_condutas_consumo_montante_jusante pc ON st_intersects(pc.shape, a.the_geom)
	GROUP BY a.id;



CREATE TRIGGER cadastro_trigger_pgrouting
  AFTER INSERT OR UPDATE OR DELETE
  ON aa.co
  FOR EACH ROW
  EXECUTE PROCEDURE public.cadastro_trigger_routing();

CREATE TRIGGER cadastro_trigger_pgrouting
  AFTER INSERT OR UPDATE OR DELETE
  ON aa.vc
  FOR EACH ROW
  EXECUTE PROCEDURE public.cadastro_trigger_routing();

CREATE TRIGGER cadastro_trigger_pgrouting
  AFTER INSERT OR UPDATE OR DELETE
  ON aa.vs
  FOR EACH ROW
  EXECUTE PROCEDURE public.cadastro_trigger_routing();

CREATE TRIGGER cadastro_trigger_pgrouting
  AFTER INSERT OR UPDATE OR DELETE
  ON aa.eb
  FOR EACH ROW
  EXECUTE PROCEDURE public.cadastro_trigger_routing();

CREATE OR REPLACE FUNCTION public.cadastro_trigger_routing()
RETURNS trigger AS
$BODY$
	DECLARE
		max_serial text = null;
  	BEGIN
		DELETE FROM epanet.co_epanet;
		INSERT INTO epanet.co_epanet (id, "UNIQUEID", shape, epanet_type) SELECT * FROM epanet.vw_rede;
		max_serial = 'DROP TABLE epanet.co_epanet_vertices_pgr CASCADE;';

		select pgr_createTopology('epanet.co_epanet', 0.0001, 'shape', 'id');                                                 
    	RETURN NEW;
  	END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
