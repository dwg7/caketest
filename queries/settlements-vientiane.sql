-- Settlementsレイヤー: ビエンチャン(ラオス)周辺のbboxで集落を抽出
-- bbox: ビエンチャン都・県周辺 (102.0, 17.6, 103.2, 18.4)
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

SELECT
    place,
    name,
    names,
    population,
    bbox.xmin AS lon,
    bbox.ymin AS lat
FROM read_parquet('https://data.openstreetmap.us/layercake/settlements.parquet')
WHERE bbox.xmin BETWEEN 102.0 AND 103.2
  AND bbox.ymin BETWEEN 17.6 AND 18.4
ORDER BY population DESC NULLS LAST
LIMIT 100;
