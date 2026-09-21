-- Settlementsレイヤー: 北海道周辺のbboxで集落を抽出
-- bbox: 概ね北海道全域 (139.3, 41.3, 148.9, 45.6)
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

SELECT
    place,
    name,
    population,
    bbox.xmin AS lon,
    bbox.ymin AS lat
FROM read_parquet('https://data.openstreetmap.us/layercake/settlements.parquet')
WHERE bbox.xmin BETWEEN 139.3 AND 148.9
  AND bbox.ymin BETWEEN 41.3 AND 45.6
ORDER BY population DESC NULLS LAST
LIMIT 50;
