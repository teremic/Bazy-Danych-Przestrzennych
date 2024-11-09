CREATE EXTENSION postgis;

-- 1
SELECT * FROM buildings_2018;
SELECT * FROM buildings_2019;

SELECT b.*
FROM buildings_2019 AS b
LEFT JOIN buildings_2018 AS a ON a.polygon_id = b.polygon_id
WHERE ST_EQUALS(a.geom, b.geom) = false OR
	a.polygon_id IS NULL OR
	a.height != b.height;

-- 2
WITH new_buildings AS (
    SELECT b.polygon_id, b.name, b.type, b.geom
    FROM buildings_2019 AS b
    LEFT JOIN buildings_2018 AS a ON a.polygon_id = b.polygon_id
    WHERE ST_Equals(a.geom, b.geom) = false OR
          a.polygon_id IS NULL OR
          a.height != b.height
),
new_poi AS (
    SELECT b.type, b.geom, b.poi_id
    FROM poi_2019 AS b
    LEFT JOIN poi_2018 AS a ON a.poi_id = b.poi_id
    WHERE a.poi_id IS NULL
)
SELECT p.type, COUNT(DISTINCT p.poi_id)
FROM new_poi AS p 
JOIN new_buildings AS b ON ST_DWithin(p.geom, b.geom, 500)
GROUP BY p.type;

-- 3
CREATE TABLE streets_19 AS
SELECT gid, link_id, st_name, ST_Transform(ST_SetSRID(geom, 4326), 31468) AS geom
FROM streets_2019;

-- 4
CREATE TABLE input_points (
    id SERIAL,
    geom GEOMETRY(Point) 
);

INSERT INTO input_points (geom)
VALUES 
    (ST_SetSRID(ST_MakePoint(8.36093, 49.03174), 4326)),
    (ST_SetSRID(ST_MakePoint(8.39876, 49.00644), 4326));

-- 5
ALTER TABLE input_points
ALTER COLUMN geom TYPE geometry(Point, 31468) USING ST_Transform(geom, 31468);

-- 6
UPDATE streets_node_2019
SET geom = ST_SetSRID(geom, 31468);

WITH input_line AS (
    SELECT ST_MakeLine(geom) AS geom
    FROM input_points
)
SELECT streets_node_2019.*
FROM streets_node_2019, input_line
WHERE ST_DWithin(streets_node_2019.geom, ST_Transform(input_line.geom,31468), 200);

--7
SELECT ST_SRID(geom)
FROM land_use_a_2019
LIMIT 1;

UPDATE poi_2019
SET geom = ST_SetSRID(geom, 31468);

UPDATE land_use_a_2019
SET geom = ST_SetSRID(geom, 31468);

SELECT
    poi_2019.poi_name AS sport_shop_name,
    land_use_a_2019.name AS park_name
FROM poi_2019 
JOIN land_use_a_2019 ON ST_Intersects(poi_2019.geom, ST_Buffer(land_use_a_2019.geom, 0.003))
WHERE poi_2019.type = 'Sporting Goods Store';