-- Highwaysレイヤー: JICA研修対象7カ国(ラオス/シエラレオネ以外)の首都圏で
-- 道路の通行可能性属性(surface等)の付与率を比較する
--
-- 注記(方法論): ここでは道路セグメントの`bbox`の左下座標
-- (xmin,ymin)が検索範囲内かどうかで判定している。都市圏規模の
-- bboxに対して道路セグメントは十分小さいため、この近似は
-- 実務上問題ない(ナイジェリア/アブジャで矩形重なり判定と
-- 比較検証済み: 44,584件 vs 44,723件、surface付与率はどちらも4.0%
-- で一致)。Boundariesレイヤーのような大きな面データでは同じ近似が
-- 通用しない点に注意(queries/boundaries-jica-capitals.sqlの注記参照)。
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
       round(100.0 * count(*) FILTER (WHERE h.surface IS NOT NULL) / count(*), 1) AS surface_pct,
       round(100.0 * count(*) FILTER (WHERE h.tracktype IS NOT NULL) / count(*), 1) AS tracktype_pct,
       round(100.0 * count(*) FILTER (WHERE h.access IS NOT NULL) / count(*), 1) AS access_pct,
       round(100.0 * count(*) FILTER (WHERE h.bridge IS NOT NULL) / count(*), 1) AS bridge_pct
FROM read_parquet('https://data.openstreetmap.us/layercake/highways.parquet') h
JOIN regions r
  ON h.bbox.xmin BETWEEN r.xmin AND r.xmax AND h.bbox.ymin BETWEEN r.ymin AND r.ymax
GROUP BY r.region
ORDER BY r.region;
