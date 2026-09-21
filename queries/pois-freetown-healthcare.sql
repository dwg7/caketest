-- POIsレイヤー: フリータウン(シエラレオネ)周辺の保健関連施設
-- ネパール(queries/pois-nepal-healthcare.sql)との比較用
-- bbox: Western Area周辺 (-13.35, 8.25, -12.95, 8.55)
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

SELECT
    count(*) AS total,
    count(*) FILTER (WHERE len(name) > 0) AS has_name,
    count(*) FILTER (WHERE phone IS NOT NULL) AS has_phone,
    count(*) FILTER (WHERE opening_hours IS NOT NULL) AS has_hours
FROM read_parquet('https://data.openstreetmap.us/layercake/pois.parquet')
WHERE bbox.xmin BETWEEN -13.35 AND -12.95 AND bbox.ymin BETWEEN 8.25 AND 8.55
  AND (amenity IN ('hospital','clinic','doctors','pharmacy','health_post') OR healthcare IS NOT NULL);
