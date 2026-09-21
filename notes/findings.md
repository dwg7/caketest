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

## POIs / Highways / Boundaries(段階2)

未着手。
