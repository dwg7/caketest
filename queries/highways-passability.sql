-- Highwaysレイヤー: 道路の通行可能性属性(surface/tracktype/access等)の
-- カバレッジを地域ごとに比較する
-- 北海道・ビエンチャン・ジュバの3bboxで実行(下記は北海道の例)
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

SELECT
    count(*) AS total,
    count(*) FILTER (WHERE surface IS NOT NULL) AS has_surface,
    count(*) FILTER (WHERE tracktype IS NOT NULL) AS has_tracktype,
    count(*) FILTER (WHERE access IS NOT NULL) AS has_access,
    count(*) FILTER (WHERE bridge IS NOT NULL) AS has_bridge,
    count(*) FILTER (WHERE smoothness IS NOT NULL) AS has_smoothness
FROM read_parquet('https://data.openstreetmap.us/layercake/highways.parquet')
WHERE bbox.xmin BETWEEN 139.3 AND 148.9 AND bbox.ymin BETWEEN 41.3 AND 45.6; -- 北海道
-- WHERE bbox.xmin BETWEEN 102.0 AND 103.2 AND bbox.ymin BETWEEN 17.6 AND 18.4; -- ビエンチャン
-- WHERE bbox.xmin BETWEEN 31.4 AND 32.0 AND bbox.ymin BETWEEN 4.6 AND 5.1; -- ジュバ
