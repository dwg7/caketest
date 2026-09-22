-- Boundariesレイヤー: 9カ国の「特徴的な都市」について、実際に
-- その座標を含む行政境界をST_Containsで求める(段階5)
--
-- 教訓: 東ティモール/オエクシでは、当初手作業で見積もった座標
-- (124.3818, -9.1903)ではST_Containsがfalseになった
-- (実際の境界からの距離約0.0033度=370m、海岸線付近での見積誤差)。
-- Settlementsレイヤーから実際のOSMノード座標(Pante-Macassar:
-- 124.36968, -9.203337)を取り直したところ正しくTL-OEを検出できた。
-- → 海岸沿いの地点では、手動推定座標ではなくOSM自体の座標を
-- 使うべき、という教訓(下のクエリはこの教訓を反映済み)。
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

WITH points(region, lon, lat) AS (
  VALUES
    ('フィジー(ラバサ)', 179.3667, -16.4333),
    ('ガボン(ポールジェンティル)', 8.7815, -0.7193),
    ('ラオス(ルアンパバーン)', 102.1348, 19.8845),
    ('ナイジェリア(ラゴス)', 3.3792, 6.5244),
    ('パプアニューギニア(ココポ)', 152.2617, -4.3486),
    ('ルワンダ(ルバブ/ギセニ)', 29.2564, -1.7025),
    ('シエラレオネ(ボー)', -11.7381, 7.9558),
    ('東ティモール(オエクシ、Pante-Macassarの実座標)', 124.36968, -9.203337),
    ('トーゴ(ソコデ)', 1.1333, 8.9833)
)
SELECT p.region, b.admin_level, b.name[1] AS name, b."ISO3166-2"
FROM read_parquet('https://data.openstreetmap.us/layercake/boundaries.parquet') b
JOIN points p
  ON b.bbox.xmin <= p.lon AND p.lon <= b.bbox.xmax
 AND b.bbox.ymin <= p.lat AND p.lat <= b.bbox.ymax
WHERE b.boundary = 'administrative'
  AND ST_Contains(b.geometry, ST_Point(p.lon, p.lat))
ORDER BY p.region, b.admin_level;
