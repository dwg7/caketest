-- Boundariesレイヤー: JICA研修対象9カ国すべての首都について、
-- その座標を実際に含む行政境界を求める
--
-- 注記(方法論・重要): 当初、Highwaysと同じ「bbox左下座標が検索範囲内か」
-- という判定をBoundariesにも使っていたが、これは面データには不適切
-- だった。行政境界(特に県・州レベル)のbboxは都市規模の検索窓より
-- 大きいことが多く(例: ラオス・ビエンチャン県のbboxは1.5°x1.6°)、
-- 「bboxの左下座標が窓内にあるか」は実質的に運任せの判定になる。
-- 矩形の重なり判定(overlap)に直しても、島嶼・分散国土の国
-- (パプアニューギニア等)では、遠く離れた領土を含む巨大なbboxを持つ
-- 行政区分(例: オーストラリアやツバルの行政区分)が誤って「重なる」
-- と判定される問題が起きた。
-- → 最終的に、各首都の実座標に対して`ST_Contains(geometry, ST_Point(...))`
-- で「その点を実際に含む境界」を求める方式に修正した。これは
-- bboxではなく実ジオメトリを使うため正確。事前にbbox絞り込みで
-- 候補を減らしてから正確な判定をする、という2段構えにしている。
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

WITH capitals(region, lon, lat) AS (
  VALUES
    ('フィジー(スバ)', 178.4419, -18.1416),
    ('ガボン(リーブルビル)', 9.4673, 0.4162),
    ('ラオス(ビエンチャン)', 102.6134, 17.9641),
    ('ナイジェリア(アブジャ)', 7.3986, 9.0765),
    ('パプアニューギニア(ポートモレスビー)', 147.1803, -9.4438),
    ('ルワンダ(キガリ)', 30.0619, -1.9441),
    ('シエラレオネ(フリータウン)', -13.2317, 8.4657),
    ('東ティモール(ディリ)', 125.5736, -8.5586),
    ('トーゴ(ロメ)', 1.2228, 6.1319)
)
SELECT c.region, b.admin_level, b.name[1] AS name, b."ISO3166-2"
FROM read_parquet('https://data.openstreetmap.us/layercake/boundaries.parquet') b
JOIN capitals c
  ON b.bbox.xmin <= c.lon AND c.lon <= b.bbox.xmax
 AND b.bbox.ymin <= c.lat AND c.lat <= b.bbox.ymax
WHERE b.boundary = 'administrative'
  AND ST_Contains(b.geometry, ST_Point(c.lon, c.lat))
ORDER BY c.region, b.admin_level;
