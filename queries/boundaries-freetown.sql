-- Boundariesレイヤー: フリータウン(シエラレオネ)周辺の行政境界
-- bbox: Western Area周辺 (-13.35, 8.25, -12.95, 8.55)
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

SELECT boundary, admin_level, name, "ISO3166-2"
FROM read_parquet('https://data.openstreetmap.us/layercake/boundaries.parquet')
WHERE bbox.xmin BETWEEN -13.35 AND -12.95 AND bbox.ymin BETWEEN 8.25 AND 8.55
  AND boundary = 'administrative'
ORDER BY admin_level;
