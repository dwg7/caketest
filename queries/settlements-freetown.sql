-- Settlementsレイヤー: フリータウン(シエラレオネ)周辺のbboxで集落を抽出
-- bbox: Western Area(フリータウン半島)周辺 (-13.35, 8.25, -12.95, 8.55)
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

SELECT
    place,
    name,
    population,
    cardinality(names) AS n_names,
    wikidata,
    bbox.xmin AS lon,
    bbox.ymin AS lat
FROM read_parquet('https://data.openstreetmap.us/layercake/settlements.parquet')
WHERE bbox.xmin BETWEEN -13.35 AND -12.95
  AND bbox.ymin BETWEEN 8.25 AND 8.55
ORDER BY population DESC NULLS LAST
LIMIT 100;
