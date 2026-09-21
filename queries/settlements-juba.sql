-- Settlementsレイヤー: ジュバ(南スーダン)周辺のbboxで集落を抽出
-- bbox: ジュバ市周辺 (31.4, 4.6, 32.0, 5.1)
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
WHERE bbox.xmin BETWEEN 31.4 AND 32.0
  AND bbox.ymin BETWEEN 4.6 AND 5.1
ORDER BY population DESC NULLS LAST
LIMIT 100;
