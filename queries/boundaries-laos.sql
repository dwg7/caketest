-- Boundariesレイヤー: ラオス・タイ・ベトナム国境付近の行政境界
-- admin_levelとISO3166コードの対応関係を確認する
-- bbox: ラオス北部〜ビエンチャン周辺 (100.0, 17.0, 104.0, 19.5)
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

SELECT boundary, admin_level, name, "ISO3166-2", "ISO3166-1:alpha2"
FROM read_parquet('https://data.openstreetmap.us/layercake/boundaries.parquet')
WHERE bbox.xmin BETWEEN 100.0 AND 104.0 AND bbox.ymin BETWEEN 17.0 AND 19.5
  AND boundary = 'administrative'
ORDER BY admin_level;
