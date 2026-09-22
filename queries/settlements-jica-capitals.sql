-- Settlementsレイヤー: JICA「国家測量事業計画・管理」研修対象9カ国のうち、
-- 未検証だった7カ国の首都圏をまとめて検証する
-- (ラオス/ビエンチャン、シエラレオネ/フリータウンは別途 settlements-vientiane.sql /
--  settlements-freetown.sql で検証済み)
-- 対象国リストの出典: https://github.com/UNopenGIS/7/issues/976#issuecomment-5709724004
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
-- place種別ごとの件数
SELECT r.region, s.place, count(*) AS n
FROM read_parquet('https://data.openstreetmap.us/layercake/settlements.parquet') s
JOIN regions r
  ON s.bbox.xmin BETWEEN r.xmin AND r.xmax AND s.bbox.ymin BETWEEN r.ymin AND r.ymax
GROUP BY r.region, s.place
ORDER BY r.region, n DESC;

-- 属性充実度(population/wikidata/names)
-- WITH regions(...) を再掲した上で:
-- SELECT r.region, count(*) AS total,
--        count(*) FILTER (WHERE s.population IS NOT NULL) AS has_population,
--        count(*) FILTER (WHERE s.wikidata IS NOT NULL) AS has_wikidata,
--        count(*) FILTER (WHERE s.names IS NOT NULL AND cardinality(s.names) > 0) AS has_names_map
-- FROM read_parquet('https://data.openstreetmap.us/layercake/settlements.parquet') s
-- JOIN regions r ON s.bbox.xmin BETWEEN r.xmin AND r.xmax AND s.bbox.ymin BETWEEN r.ymin AND r.ymax
-- GROUP BY r.region ORDER BY r.region;

-- 首都(place=city)の行のみ
-- SELECT r.region, s.place, s.name, s.population, s.wikidata
-- FROM read_parquet('https://data.openstreetmap.us/layercake/settlements.parquet') s
-- JOIN regions r ON s.bbox.xmin BETWEEN r.xmin AND r.xmax AND s.bbox.ymin BETWEEN r.ymin AND r.ymax
-- WHERE s.place = 'city'
-- ORDER BY r.region;
