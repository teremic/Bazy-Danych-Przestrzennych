-- 3
CREATE EXTENSION postgis;

-- 4
CREATE TABLE IF NOT EXISTS poi(
	id SERIAL,
	geometry GEOMETRY,
	name VARCHAR(2)
);

CREATE TABLE IF NOT EXISTS roads(
	id SERIAL,
	geometry GEOMETRY,
	name VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS buildings(
	id SERIAL,
	geometry GEOMETRY,
	name VARCHAR(15)
);

-- 5
INSERT INTO roads(geometry, name) VALUES
	(ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)'), 'RoadX'),
	(ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)'), 'RoadY');

INSERT INTO poi(geometry, name) VALUES
	(ST_GeomFromText('POINT(1 3.5)'), 'G'),
	(ST_GeomFromText('POINT(5.5 1.5)'), 'H'),
	(ST_GeomFromText('POINT(9.5 6)'), 'I'),
	(ST_GeomFromText('POINT(6.5 6)'), 'J'),
	(ST_GeomFromText('POINT(6 9.5)'), 'K');

INSERT INTO buildings(geometry, name) VALUES
	(ST_GeomFromText('POLYGON((8 1.5, 10.5 1.5, 10.5 4, 8 4, 8 1.5))'), 'BuildingA'),
	(ST_GeomFromText('POLYGON((4 5, 6 5, 6 7, 4 7, 4 5))'), 'BuildingB'),
	(ST_GeomFromText('POLYGON((3 6, 5 6, 5 8, 3 8, 3 6))'), 'BuildingC'),
	(ST_GeomFromText('POLYGON((9 8, 10 8, 10 9, 9 9, 9 8))'), 'BuildingD'),
	(ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), 'BuildingF');

-- 6a
SELECT SUM(ST_Length(geometry)) AS total_length 
FROM roads;

-- 6b
SELECT ST_AsText(geometry), ST_Area(geometry) AS area, ST_Perimeter(geometry) AS perimeter 
FROM buildings
WHERE name = 'BuildingA';

-- 6c
SELECT name, ST_Area(geometry) AS area
FROM buildings
ORDER BY name;

-- 6d
SELECT name, ST_Perimeter(geometry) AS perimeter
FROM buildings
ORDER BY ST_Area(geometry) DESC;

-- 6e
SELECT ST_Distance(a.geometry, b.geometry) AS distance
FROM poi AS a
CROSS JOIN buildings AS b
WHERE a.name = 'K' AND b.name = 'BuildingC';

-- 6f
SELECT ST_Area(ST_Difference(c.geometry, ST_Buffer(b.geometry, 0.5))) AS area
FROM buildings AS c, buildings AS b
WHERE b.name = 'BuildingB' AND c.name = 'BuildingC';

-- 6g
SELECT a.name AS build, ST_Y(ST_Centroid(a.geometry)) AS centroid
FROM buildings AS a
CROSS JOIN roads AS b
WHERE b.name = 'RoadX' AND ST_Y(ST_Centroid(a.geometry)) > ST_Y(ST_Centroid(b.geometry));

-- 6h
SELECT ST_Area(ST_SymDifference(geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')))
FROM buildings
WHERE name = 'BuildingC';
 