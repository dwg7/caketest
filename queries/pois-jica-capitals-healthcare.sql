-- POIsレイヤー: JICA研修対象7カ国(ラオス/シエラレオネ以外)の首都圏で
-- 保健関連施設の名称・実務属性の付与率を比較する
-- (ネパール全域・フリータウンとの比較はqueries/pois-nepal-healthcare.sql、
--  queries/pois-freetown-healthcare.sqlを参照)
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

WITH regions(region, xmin, xmax, ymin, ymax) AS (
  VALUES
    ('フィジー(スバ)', 178.30, 178.58, -18.28, -18.00),
    ('ガボン(リーブルビル)', 9.30, 9.60, 0.25, 0.55),
    ('ナイジェリア(アブジャ)', 7.25, 7.55, 8.90, 9.20),
    ('パプアニューギニア(ポートモレスビー)', 147.05, 147.35, -9.60, -9.30),
    ('ルワンダ(キガリ)', 29.90, 30.20, -2.05, -1.80),
    ('東ティモール(ディリ)', 125.45, 125.75, -8.65, -8.45),
    ('トーゴ(ロメ)', 1.05, 1.35, 6.00, 6.25)
)
SELECT r.region,
       count(*) AS total,
       count(*) FILTER (WHERE len(p.name) > 0) AS has_name,
       count(*) FILTER (WHERE p.phone IS NOT NULL) AS has_phone,
       count(*) FILTER (WHERE p.opening_hours IS NOT NULL) AS has_hours
FROM read_parquet('https://data.openstreetmap.us/layercake/pois.parquet') p
JOIN regions r
  ON p.bbox.xmin BETWEEN r.xmin AND r.xmax AND p.bbox.ymin BETWEEN r.ymin AND r.ymax
WHERE (p.amenity IN ('hospital','clinic','doctors','pharmacy','health_post') OR p.healthcare IS NOT NULL)
GROUP BY r.region
ORDER BY r.region;
