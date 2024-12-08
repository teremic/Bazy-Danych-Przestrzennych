-- Tworzenie rastrów z istniejących rastrów i interakcja z wektorami 
-- P1
CREATE TABLE rasters.intersects AS  
SELECT a.rast, b.municipality 
FROM rasters.dem AS a, vectors.porto_parishes AS b  
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto'; 

alter table rasters.intersects 
add column rid SERIAL PRIMARY KEY; 

CREATE INDEX idx_intersects_rast_gist ON rasters.intersects 
USING gist (ST_ConvexHull(rast)); 

SELECT AddRasterConstraints('rasters'::name, 
'intersects'::name,'rast'::name); 

-- P2
CREATE TABLE rasters.clip AS  
SELECT ST_Clip(a.rast, b.geom, true), b.municipality  
FROM rasters.dem AS a, vectors.porto_parishes AS b  
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO'; 

-- P3
CREATE TABLE rasters.union AS  
SELECT ST_Union(ST_Clip(a.rast, b.geom, true)) 
FROM rasters.dem AS a, vectors.porto_parishes AS b  
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);


-- Tworzenie rastrów z wektorów (rastrowanie) 
-- P1
CREATE TABLE rasters.porto_parishes AS 
WITH r AS ( 
SELECT rast FROM rasters.dem  
LIMIT 1 
) 
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast 
FROM vectors.porto_parishes AS a, r 
WHERE a.municipality ilike 'porto'; 

-- P2
DROP TABLE rasters.porto_parishes; --> drop table porto_parishes first 
CREATE TABLE rasters.porto_parishes AS 
WITH r AS ( 
SELECT rast FROM rasters.dem  
LIMIT 1 
) 
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast 
FROM vectors.porto_parishes AS a, r 
WHERE a.municipality ilike 'porto';

-- P3
DROP TABLE rasters.porto_parishes; --> drop table porto_parishes first 
CREATE TABLE rasters.porto_parishes AS 
WITH r AS ( 
SELECT rast FROM rasters.dem  
LIMIT 1 ) 
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,
32767)),128,128,true,-32767) AS rast 
FROM vectors.porto_parishes AS a, r 
WHERE a.municipality ilike 'porto'; 


-- Konwertowanie rastrów na wektory (wektoryzowanie) 
-- P1
create table rasters.intersection as  
SELECT 
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)
 ).val 
FROM rasters.dem1 AS a, vectors.porto_parishes AS b  
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast); 

-- P2
CREATE TABLE rasters.dumppolygons AS 
SELECT 
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val 
FROM rasters.dem1 AS a, vectors.porto_parishes AS b  
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast); 

-- Analiza rastrów 
-- P1
CREATE TABLE rasters.landsat_nir AS 
SELECT rid, ST_Band(rast,4) AS rast 
FROM rasters.dem1; 

-- P2
CREATE TABLE rasters.paranhos_dem AS 
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast 
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

-- P3
CREATE TABLE rasters.paranhos_slope AS 
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast 
FROM rasters.paranhos_dem AS a; 

-- P4
CREATE TABLE rasters.paranhos_slope_reclass AS 
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3', 
'32BF',0) 
FROM rasters.paranhos_slope AS a; 

-- P5
SELECT st_summarystats(a.rast) AS stats 
FROM rasters.paranhos_dem AS a; 

-- P6
SELECT st_summarystats(ST_Union(a.rast)) 
FROM rasters.paranhos_dem AS a; 

-- P7
WITH t AS ( 
SELECT st_summarystats(ST_Union(a.rast)) AS stats 
FROM rasters.paranhos_dem AS a 
) 
SELECT (stats).min,(stats).max,(stats).mean FROM t; 

-- P8
WITH t AS ( 
SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast, 
b.geom,true))) AS stats 
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast) 
group by b.parish 
) 
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t; 

-- P9
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom) 
FROM  
rasters.dem a, vectors.places AS b 
WHERE ST_Intersects(a.rast,b.geom) 
ORDER BY b.name; 

-- P10
create table rasters.tpi30 as 
select ST_TPI(a.rast,1) as rast 
from rasters.dem a; 

CREATE INDEX idx_tpi30_rast_gist ON rasters.tpi30 
USING gist (ST_ConvexHull(rast)); 

SELECT AddRasterConstraints('rasters'::name, 
'tpi30'::name,'rast'::name);


-- Algebra map 
-- P1
CREATE TABLE rasters.porto_ndvi AS  
WITH r AS ( 
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast 
FROM rasters.dem1 AS a, vectors.porto_parishes AS b 
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast) 
) 
SELECT 
r.rid,ST_MapAlgebra( 
r.rast, 1, 
r.rast, 4, 
'([rast2.val] - [rast1.val]) / ([rast2.val] + 
[rast1.val])::float','32BF' 
) AS rast 
FROM r; 

CREATE INDEX idx_porto_ndvi_rast_gist ON rasters.porto_ndvi 
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('rasters'::name, 
'porto_ndvi'::name,'rast'::name); 

-- P2
create or replace function rasters.ndvi( 
value double precision [] [] [],  
pos integer [][], 
VARIADIC userargs text [] 
) 
RETURNS double precision AS 
$$ 
BEGIN --RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes 
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value 
[1][1][1]); --> NDVI calculation! 
END; 
$$ 
LANGUAGE 'plpgsql' IMMUTABLE COST 1000; 

CREATE TABLE rasters.porto_ndvi2 AS  
WITH r AS ( 
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast 
FROM rasters.dem1 AS a, vectors.porto_parishes AS b 
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast) 
) 
SELECT 
r.rid,ST_MapAlgebra( 
r.rast, ARRAY[1,4], 
'rasters.ndvi(double precision[], 
integer[],text[])'::regprocedure, --> This is the function! 
'32BF'::text 
) AS rast 
FROM r; 

CREATE INDEX idx_porto_ndvi2_rast_gist ON rasters.porto_ndvi2 
USING gist (ST_ConvexHull(rast)); 

SELECT AddRasterConstraints('rasters'::name, 
'porto_ndvi2'::name,'rast'::name); 

-- Eksport danych
-- P1
SELECT ST_AsTiff(ST_Union(rast)) 
FROM rasters.porto_ndvi; 

-- P2
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 
'PREDICTOR=2', 'PZLEVEL=9']) 
FROM rasters.porto_ndvi; 

SELECT ST_GDALDrivers();

-- P3
CREATE TABLE tmp_out AS 
SELECT lo_from_bytea(0, 
ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 
'PREDICTOR=2', 'PZLEVEL=9']) 
) AS loid 
FROM rasters.porto_ndvi;

SELECT lo_export(loid, 'C:\Program Files\PostgreSQL\myraster.tiff')
FROM tmp_out; 

SELECT lo_unlink(loid) 
FROM tmp_out; --> Delete the large object. 


-- Publikowanie danych za pomocą MapServer 
-- P1
create table rasters.tpi30_porto as 
SELECT ST_TPI(a.rast,1) as rast 
FROM rasters.dem AS a, vectors.porto_parishes AS b  
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto'

CREATE INDEX idx_tpi30_porto_rast_gist ON rasters.tpi30_porto 
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('rasters'::name, 
'tpi30_porto'::name,'rast'::name);
