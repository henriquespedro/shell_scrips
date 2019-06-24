/** Sistema de Abastecimento de Água **/

CREATE OR REPLACE FUNCTION aa.malhada_close(integer)
RETURNS geometry
LANGUAGE sql
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "aa"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "aa"."co" n, walk_network w
    WHERE ST_intersects(w.shape,n.shape) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM aa.vs WHERE "ABERTURA" = 'Fechada'),n.shape)) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;

CREATE OR REPLACE FUNCTION aa.malhada_all(integer)
RETURNS geometry
LANGUAGE sql
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "aa"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "aa"."co" n, walk_network w
    WHERE ST_intersects(w.shape,n.shape) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM aa.cr),n.shape) OR ST_Intersects((SELECT ST_UNION(shape) FROM aa.ee),n.shape) OR ST_Intersects((SELECT ST_UNION(shape) FROM aa.eb),n.shape) OR ST_Intersects((SELECT ST_UNION(shape) FROM aa.rv),n.shape)) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;

CREATE OR REPLACE FUNCTION aa.malhada(integer)
RETURNS geometry
LANGUAGE sql
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "aa"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "aa"."co" n, walk_network w
    WHERE ST_intersects(w.shape,n.shape) AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;



CREATE OR REPLACE FUNCTION aa.downstream_close(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "aa"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "aa"."co" n, walk_network w
    WHERE ST_intersects(ST_EndPoint(w.shape),ST_StartPoint(n.shape)) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM aa.vs WHERE "ABERTURA" = 'Fechada'),ST_StartPoint(n.shape))) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;

CREATE OR REPLACE FUNCTION aa.downstream_all(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "aa"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "aa"."co" n, walk_network w
    WHERE ST_intersects(ST_EndPoint(w.shape),ST_StartPoint(n.shape)) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM aa.cr),ST_StartPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM aa.ee),ST_StartPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM aa.eb),ST_StartPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM aa.rv),ST_StartPoint(n.shape))) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;

CREATE OR REPLACE FUNCTION aa.downstream(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "aa"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "aa"."co" n, walk_network w
    WHERE ST_intersects(ST_EndPoint(w.shape),ST_StartPoint(n.shape)) AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;


CREATE OR REPLACE FUNCTION aa.upstream_close(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "aa"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "aa"."co" n, walk_network w
    WHERE ST_intersects(ST_StartPoint(w.shape),ST_EndPoint(n.shape)) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM aa.vs WHERE "ABERTURA" = 'Fechada'),ST_EndPoint(n.shape))) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;

CREATE OR REPLACE FUNCTION aa.upstream_all(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "aa"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "aa"."co" n, walk_network w
    WHERE ST_intersects(ST_StartPoint(w.shape),ST_EndPoint(n.shape)) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM aa.cr),ST_EndPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM aa.ee),ST_EndPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM aa.eb),ST_EndPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM aa.rv),ST_EndPoint(n.shape))) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;

CREATE OR REPLACE FUNCTION aa.upstream(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "aa"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "aa"."co" n, walk_network w
    WHERE ST_intersects(ST_StartPoint(w.shape),ST_EndPoint(n.shape)) AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;




/** Sistema de Águas Residuais **/

CREATE OR REPLACE FUNCTION ar.downstream_close(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "ar"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "ar"."co" n, walk_network w
    WHERE ST_intersects(ST_EndPoint(w.shape),ST_StartPoint(n.shape)) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM ar.vs WHERE "ABERTURA" = 'Fechada'),ST_StartPoint(n.shape))) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;

CREATE OR REPLACE FUNCTION ar.downstream_all(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "ar"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "ar"."co" n, walk_network w
    WHERE ST_intersects(ST_EndPoint(w.shape),ST_StartPoint(n.shape)) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM ar.vs),ST_StartPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM ar.vr),ST_StartPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM ar.vd),ST_StartPoint(n.shape))) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;

CREATE OR REPLACE FUNCTION ar.downstream(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "ar"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "ar"."co" n, walk_network w
    WHERE ST_intersects(ST_EndPoint(w.shape),ST_StartPoint(n.shape)) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM ar.ee),ST_StartPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM ar.et),ST_StartPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM ar.vs),ST_StartPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM ar.vd),ST_StartPoint(n.shape))) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;


CREATE OR REPLACE FUNCTION ar.upstream_close(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "ar"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "ar"."co" n, walk_network w
    WHERE ST_intersects(ST_StartPoint(w.shape),ST_EndPoint(n.shape)) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM ar.vs WHERE "ABERTURA" = 'Fechada'),ST_EndPoint(n.shape))) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;

CREATE OR REPLACE FUNCTION ar.upstream_all(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "ar"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "ar"."co" n, walk_network w
    WHERE ST_intersects(ST_StartPoint(w.shape),ST_EndPoint(n.shape)) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM ar.vs),ST_EndPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM ar.vr),ST_EndPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM ar.vd),ST_EndPoint(n.shape))) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;

CREATE OR REPLACE FUNCTION aa.upstream(integer)
RETURNS geometry
AS $BODY$
WITH RECURSIVE walk_network(id, shape) AS (
    SELECT "SERIALID" as id, shape, array["SERIALID"] as all_parents FROM "aa"."co" WHERE "SERIALID" = $1
  UNION ALL
    SELECT n."SERIALID", n.shape, w.all_parents||n."SERIALID"
    FROM "aa"."co" n, walk_network w
    WHERE ST_intersects(ST_StartPoint(w.shape),ST_EndPoint(n.shape)) AND ((ST_Intersects((SELECT ST_UNION(shape) FROM ar.ee),ST_EndPoint(n.shape)) OR ST_Intersects((SELECT ST_UNION(shape) FROM ar.eb),ST_EndPoint(n.shape))) ='f') AND n."SERIALID" <> ALL (w.all_parents)
  )
SELECT ST_Union(shape)
FROM walk_network
$BODY$
LANGUAGE sql IMMUTABLE
  COST 100;
