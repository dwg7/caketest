-- POIsレイヤー: 9カ国の「特徴的な都市」(段階5)における
-- 保健関連施設の名称・実務属性の付与率を比較する
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

WITH regions(region, xmin, xmax, ymin, ymax) AS (
  VALUES
    ('フィジー(ラバサ、バヌアレブ島)', 179.25, 179.45, -16.55, -16.30),
    ('ガボン(ポールジェンティル)', 8.65, 8.90, -0.85, -0.60),
    ('ラオス(ルアンパバーン)', 102.05, 102.25, 19.80, 19.95),
    ('ナイジェリア(ラゴス)', 3.10, 3.60, 6.35, 6.70),
    ('パプアニューギニア(ココポ、東ニューブリテン州)', 152.15, 152.40, -4.45, -4.20),
    ('ルワンダ(ルバブ/ギセニ)', 29.15, 29.35, -1.80, -1.60),
    ('シエラレオネ(ボー)', -11.85, -11.60, 7.85, 8.05),
    ('東ティモール(オエクシ、飛び地)', 124.20, 124.55, -9.30, -9.10),
    ('トーゴ(ソコデ)', 1.02, 1.25, 8.88, 9.10)
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
