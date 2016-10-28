WITH important_place_point AS (
    SELECT osm.geometry, osm.osm_id, osm.name, osm.name_en, osm.place, ne.scalerank, COALESCE(osm.population, ne.pop_min) AS population
    FROM ne_10m_populated_places AS ne, osm_place_point AS osm
    WHERE
    (
        ne.name ILIKE osm.name OR
        ne.name ILIKE osm.name_en OR
        ne.namealt ILIKE osm.name OR
        ne.namealt ILIKE osm.name_en OR
        ne.meganame ILIKE osm.name OR
        ne.meganame ILIKE osm.name_en OR
        ne.gn_ascii ILIKE osm.name OR
        ne.gn_ascii ILIKE osm.name_en OR
        ne.nameascii ILIKE osm.name OR
        ne.nameascii ILIKE osm.name_en
    )
    AND (osm.place = 'city' OR osm.place= 'town' OR osm.place = 'village')
    AND ST_DWithin(ne.geom, osm.geometry, 50000)
)
UPDATE osm_place_point
SET scalerank = important_place_point.scalerank
FROM important_place_point
WHERE osm_place_point.osm_id = important_place_point.osm_id;

CREATE INDEX IF NOT EXISTS osm_place_point_scalerank_idx ON osm_place_point (scalerank);
