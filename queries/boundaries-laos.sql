-- Boundariesレイヤー: ラオス・タイ・ベトナム国境付近の行政境界
-- admin_levelとISO3166コードの対応関係を確認する
-- bbox: ラオス北部〜ビエンチャン周辺 (100.0, 17.0, 104.0, 19.5)
--
-- 注記: このクエリはbbox左下座標での判定を使っており、面データに対する
-- 近似としては不正確(詳細はqueries/boundaries-jica-capitals.sqlの
-- 注記を参照)。ビエンチャンについてはST_Containsを使った正確な結果が
-- 同ファイルにあるので、そちらを正とする。このファイルは初期の
-- 素朴な調査記録として残す。
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

SELECT boundary, admin_level, name, "ISO3166-2", "ISO3166-1:alpha2"
FROM read_parquet('https://data.openstreetmap.us/layercake/boundaries.parquet')
WHERE bbox.xmin BETWEEN 100.0 AND 104.0 AND bbox.ymin BETWEEN 17.0 AND 19.5
  AND boundary = 'administrative'
ORDER BY admin_level;
