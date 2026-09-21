-- POIsレイヤー: ネパール全域(bbox)の保健関連施設
-- rpi-geoserver0のベンチマークデータ(Nepal Health Facilities)との
-- 比較を意識した簡易評価
-- bbox: ネパール全域 (80.0, 26.3, 88.3, 30.5)
INSTALL spatial; LOAD spatial;
INSTALL httpfs; LOAD httpfs;

-- 内訳(amenity x healthcare)
SELECT amenity, healthcare, count(*) AS n
FROM read_parquet('https://data.openstreetmap.us/layercake/pois.parquet')
WHERE bbox.xmin BETWEEN 80.0 AND 88.3 AND bbox.ymin BETWEEN 26.3 AND 30.5
  AND (amenity IN ('hospital','clinic','doctors','pharmacy','health_post') OR healthcare IS NOT NULL)
GROUP BY amenity, healthcare
ORDER BY n DESC;

-- 属性充実度
SELECT
    count(*) AS total,
    count(*) FILTER (WHERE len(name) > 0) AS has_name,
    count(*) FILTER (WHERE phone IS NOT NULL) AS has_phone,
    count(*) FILTER (WHERE opening_hours IS NOT NULL) AS has_hours,
    count(*) FILTER (WHERE website IS NOT NULL) AS has_website,
    count(*) FILTER (WHERE "healthcare:speciality" IS NOT NULL) AS has_speciality
FROM read_parquet('https://data.openstreetmap.us/layercake/pois.parquet')
WHERE bbox.xmin BETWEEN 80.0 AND 88.3 AND bbox.ymin BETWEEN 26.3 AND 30.5
  AND (amenity IN ('hospital','clinic','doctors','pharmacy','health_post') OR healthcare IS NOT NULL);
