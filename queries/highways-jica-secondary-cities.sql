-- Highwaysレイヤー: 9カ国の「特徴的な都市」(段階5、対象都市は
-- settlements-jica-secondary-cities.sqlの選定理由コメント参照)で
-- 道路の通行可能性属性を比較する
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
       round(100.0 * count(*) FILTER (WHERE h.surface IS NOT NULL) / count(*), 1) AS surface_pct,
       round(100.0 * count(*) FILTER (WHERE h.tracktype IS NOT NULL) / count(*), 1) AS tracktype_pct,
       round(100.0 * count(*) FILTER (WHERE h.access IS NOT NULL) / count(*), 1) AS access_pct,
       round(100.0 * count(*) FILTER (WHERE h.bridge IS NOT NULL) / count(*), 1) AS bridge_pct
FROM read_parquet('https://data.openstreetmap.us/layercake/highways.parquet') h
JOIN regions r
  ON h.bbox.xmin BETWEEN r.xmin AND r.xmax AND h.bbox.ymin BETWEEN r.ymin AND r.ymax
GROUP BY r.region
ORDER BY r.region;
