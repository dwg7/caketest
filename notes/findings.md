# findings

Layercakeの各レイヤーを実際にクエリした結果をまとめる。日付は検証を
行った日(JST)。

出典: Layercake (OpenStreetMap US) / © OpenStreetMap contributors, ODbL 1.0
(ライセンス対応方針は [`docs/decisions/0001-odbl-license-handling.md`](../docs/decisions/0001-odbl-license-handling.md) 参照)

## Settlementsレイヤー(検証日: 2026-09-22)

### 接続・スキーマ

DuckDB(`INSTALL spatial; INSTALL httpfs;` の上で `LOAD` するだけ)から、
ダウンロードなしで `https://data.openstreetmap.us/layercake/settlements.parquet`
に直接クエリできることを確認。追加の認証は不要。

スキーマ(抜粋):

| 列 | 型 | 備考 |
|---|---|---|
| `place` | varchar | OSMの`place=*`タグ値(city/town/village/hamlet/quarter等) |
| `name` | varchar | 現地表記の主名称 |
| `names` | map(varchar, varchar) | 言語コード→名称。`name:xx=*`タグ由来と見られる |
| `alt_name` / `alt_names` | varchar / map | 別名 |
| `official_name` / `official_names` | varchar / map | 正式名称 |
| `wikidata` / `wikipedia` | varchar | 外部リンク |
| `population` | ubigint | 人口(`population=*`タグ由来、多くはNULL) |
| `bbox` | struct(xmin,ymin,xmax,ymax) | float。範囲検索に使える |
| `geometry` | geometry | OGC:CRS84 |

### 全体統計

全世界で **4,601,035行**。うち:

* `population`あり: 628,024行(13.6%)
* `wikidata`リンクあり: 825,020行(17.9%)
* `names`マップに何らかの言語エントリあり: 1,262,401行(27.4%)

→ 多言語名称・人口・Wikidataリンクは、いずれも**少数派の集落にしか
付いていない**。都市規模が大きいほど充実し、末端の集落(hamlet等)は
名前だけ、あるいは名前すらないケースが多いと推測される
(地域別の内訳は下記)。

### 北海道(bbox: 139.3–148.9E, 41.3–45.6N)

* 該当: 6,043行(quarter 5762、town 132、city 35、suburb 35、
  village 27、farm 21、hamlet 19、city_block 6、isolated_dwelling 6)
* `city`/`town`上位はすべて実在の市町村と一致し、人口値も概ね妥当
  (札幌市1,973,395等)。→ **精度は高い**。
* `quarter`(=大字・町丁目相当)が圧倒的多数を占める。日本の場合、
  OSMの`place=quarter`は住所レベルの細分に近く、「集落」というより
  「住所ノード」に近い性質を持つ点に注意。
* クエリ: [`queries/settlements-hokkaido.sql`](../queries/settlements-hokkaido.sql)

### ビエンチャン周辺(bbox: 102.0–103.2E, 17.6–18.4N)

* 該当: 717行(village 663、hamlet 28、town 17、quarter 8、city 1)
* bboxがメコン川を挟んでタイ側(ノーンカーイ県)にも掛かるため、
  ラオス語表記の村とタイ語表記の町が混在する。地名の言語推定には
  国境をまたぐ注意が必要。
* `city`(ວຽງຈັນ=ビエンチャン)は`wikidata`リンクを持ち、`names`
  マップに100以上の言語の表記が入っている(Wikidataラベル由来と
  見られる)。
* 特筆すべき点: **village(村)レベルでも`names`マップにen(英語
  ローマ字表記)が入っているケースが多い**(663件中623件が
  `names`ありで、多くは`en=Ban ...`のような`name:en`タグ由来の
  ローマ字表記)。ただし`wikidata`・`population`は村レベルでは
  ほぼゼロ(0件)。
* → HOT文書が課題視した「現地語表記しかなく国際的な保健・気候
  データと突合できない」という問題に対し、**ローマ字表記の存在が
  部分的な解になり得る**ことを確認。ただし人口等の属性は乏しい。
* クエリ: [`queries/settlements-vientiane.sql`](../queries/settlements-vientiane.sql)

### ジュバ周辺(bbox: 31.4–32.0E, 4.6–5.1N)

* 該当: わずか22行(city 1、town 1、village 9、hamlet 11)。
  首都圏だけでこの粒度は、他の2地域と比べて**著しくスカスカ**。
* `city`(Juba)のみ`population`(372,410)と`wikidata`リンク・
  122言語の`names`を持つ。それ以外の21行は`population`NULL、
  `names`マップもほぼ空(1〜2件を除き0)。
* **重複エントリを確認**: `hamlet` "River Wanga" が2回出現(同じ
  名前、別レコード)。HOT文書が挙げていた「名称の重複」課題が、
  Layercake側でも解消されずそのまま残っている実例。
* → 南スーダンのような低マッピング密度地域では、Layercakeは
  **OSM自体のカバレッジ不足をそのまま反映するだけ**であり、
  「既製の集落名辞書」としての価値は乏しい。これはLayercakeの
  欠陥というより、南スーダンのOSMコミュニティ規模・地上調査量の
  問題。
* クエリ: [`queries/settlements-juba.sql`](../queries/settlements-juba.sql)

### 段階1の暫定評価

* **精度・充実度は地域のOSMマッピング密度にそのまま比例する**。
  日本(北海道)のようにマッピングが成熟した地域では、市町村単位
  までは高精度・高属性(人口あり)。ラオスのような中間的な地域では、
  村レベルの名前とローマ字表記は拾えるが人口等は乏しい。南スーダン
  のような低密度地域では、首都以外はほぼ名前だけで、重複や欠損も
  残る。
* HOT文書の課題(「名称の欠落・重複・不整合な綴り」)は、
  **Layercakeが解決するものではなく、そのまま可視化するもの**と
  いう理解が妥当。Layercakeの価値は「クエリしやすい単一ファイルに
  蒸留してくれること」であって、「OSMより高精度な集落名辞書を
  新たに作ってくれること」ではない。
* kikimimi/okapi-map系列への転用を考える場合、**マッピング密度が
  高い地域(日本、都市部)では実用に足るが、低密度地域(南スーダン
  等、まさにHOT文書が課題視していた地域)では期待するほどの改善は
  得られない**可能性が高い。これは段階3の判断材料として重要。

## POIs / Highways / Boundaries(段階2、検証日: 2026-09-22)

### POIs — ネパールの保健施設(rpi-geoserver0との比較を意識)

* スキーマ: `amenity`/`healthcare`/`shop`/`tourism`等、OSMのメインタグが
  そのまま列になっている(65列)。`name`/`names`等はvarchar配列
  ([]) になっており、Settlementsの単一varcharとは型が異なる点に注意。
* ネパール全域(bbox: 80.0–88.3E, 26.3–30.5N)で、hospital/clinic/
  doctors/pharmacy/health_post/`healthcare=*`のいずれかに該当する
  POIが**11,057件**ヒット。内訳はclinic(2,658)、healthcare=centre
  (2,129)、hospital(2,086)、pharmacy(1,453)等、amenity/healthcareの
  組み合わせが多岐にわたる(要: どちらかだけを見るとデータが漏れる)。
* 属性充実度: `name`あり 91.1%(10,075/11,057)。一方、`phone`
  10.0%、`opening_hours`5.6%、`website`1.4%、`healthcare:speciality`
  2.1%と、連絡先・診療時間などの実務的属性は乏しい。
* → rpi-geoserver0のNepal Health Facilitiesベンチマークと比べると、
  **件数・地理的網羅性では大きく上回る可能性が高い**(全国のOSM
  マッピング成果をそのまま拾える)。ただし電話番号・診療時間などの
  実務属性はOSM側でそもそもほとんど入力されておらず、rpi-geoserver0
  が持つ公式データセット固有の属性を代替できるわけではない。
  **「位置と名称の広域カバレッジ」を補完する用途に向く**。
* クエリ: [`queries/pois-nepal-healthcare.sql`](../queries/pois-nepal-healthcare.sql)

### Highways — 道路の通行可能性属性(zukaku/HOT文書の課題を意識)

地域ごとに`surface`/`tracktype`/`access`/`bridge`/`smoothness`の
被覆率を比較(件数/全体道路数):

| 地域 | 総道路数 | surface | tracktype | access | bridge | smoothness |
|---|---|---|---|---|---|---|
| 北海道 | 665,306 | 9.1% | 1.0% | 1.0% | 4.9% | 0.8% |
| ビエンチャン周辺 | 61,058 | 26.5% | 0.8% | 1.0% | 1.5% | 2.8% |
| ジュバ周辺 | 18,306 | **84.7%** | 3.0% | 0.3% | 0.5% | 0.03% |

* 意外な結果: **ジュバ周辺の`surface`タグ被覆率が突出して高い
  (84.7%)**。北海道(9.1%)やビエンチャン(26.5%)よりずっと高い。
  これは南スーダンが人道支援マッピング(HOTのタスク等)の対象地域
  として重点的に道路の舗装状況がタグ付けされてきたためと推測される
  (未舗装路や増水期に通行不能になる道の把握が、人道支援上重要な
  ため)。一方`tracktype`/`access`/`bridge`等の細かい属性は
  いずれの地域でも1桁%と乏しい。
* → HOT文書が課題視する「道路の通行可能性」情報は、**まさにその
  課題意識でマッピングされてきた地域(南スーダン等)では、すでに
  相応の蓄積がある**ことを確認。zukakuの背景データとしては、
  少なくとも`surface`タグの活用は有望。ただし`tracktype`・`access`
  等のより詳細な通行可否判断に使える属性は、どの地域でもまだ薄い。
* クエリ: [`queries/highways-passability.sql`](../queries/highways-passability.sql)

### Boundaries — ラオス周辺の行政境界

* ラオス・タイ・ベトナム国境付近(bbox: 100.0–104.0E, 17.0–19.5N)で
  `boundary=administrative`を抽出すると、`admin_level=4`(県・
  จังหวัด・tỉnh相当)には`ISO3166-2`コードが付与されている
  (例: `LA-VI`=ビエンチャン県、`LA-VT`=ビエンチャン都、
  `TH-43`=ノーンカーイ県)。`admin_level=6`(郡・อำเภอ・ເມືອງ相当)
  にはISOコードがなく、名称のみ。`admin_level=10`(集落・村落境界)
  も一部存在する。
* → **国をまたいだ行政階層が同じ`admin_level`スキームで統一的に
  扱えており、ISO3166-2コードが県レベルで機械可読に取得できる**点は
  有用。国家測量研修やラオス案件のような、行政区分をまたぐ文脈での
  基礎データとして活用しやすい構造。ただし郡・村落レベルでは
  ISOコードがなく、名称の表記ゆれ(タイ語/ラオス語混在)への
  対応は別途必要。
* クエリ: [`queries/boundaries-laos.sql`](../queries/boundaries-laos.sql)

### 段階2の暫定評価

* POIs・Highways・Boundariesいずれも、**Settlementsと同じ傾向
  ——地域のOSMマッピング密度・関心の偏りがそのまま属性充実度に
  反映される——が確認できた**。特にHighwaysでは、人道支援上の
  関心が高い地域(南スーダン)ほど通行可能性に関わるタグが充実して
  いるという、直感に反するが理にかなった結果が得られた。
* 3レイヤーとも、既存プロジェクトへの「即座の代替」ではなく
  「広域カバレッジを補完する追加ソース」として位置づけるのが
  妥当と考えられる。最終的な統合可否の判断は段階3で人が行う。
