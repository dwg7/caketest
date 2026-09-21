caketest — Claude Code 引き継ぎドキュメント

このファイルは `dwg7/caketest` リポジトリのルートに置く、Claude Code向けの
プロジェクト文脈。新しいセッションを開始する際は、まずこのファイルを
読んでください。

GitHub description: `Early exploration of Layercake (OSM US's planet-wide GeoParquet layers) — can it serve as a ready-made settlement gazetteer for dwg7?`
(2026-09-22時点でテーマは進化している。7節「方針転換」参照——
「実用可否の判定」から「Layercakeを窓にした各国・各地域のOSM
多様性・課題多様性の探索的理解」へ重心が移っている)

姉妹プロジェクト: [dwg7/kaga0](https://claude.ai/kaga0/CLAUDE.md)、
[dwg7/zukaku](https://claude.ai/zukaku/CLAUDE.md)、[dwg7/rpi-geoserver0](https://claude.ai/rpi-geoserver0/CLAUDE.md)
(同じ「実装より先に調査」という作法を踏襲)

## 1. プロジェクト概要・背景

[Layercake](https://layercake.openstreetmap.us/)は、OpenStreetMap USによる、
全世界のOSMデータをテーマ別に単一のGeoParquetファイルへ蒸留したもの。
Addresses、Boundaries、Buildings、Highways、Parks、POIs、Settlements、
Waterwaysの8テーマがあり、それぞれ惑星規模でありながら単一ファイル
(Settlementsは188MiB、Parksは671MiBと、多くのテーマが現実的に持ち運べる
サイズ)。DuckDBのspatial拡張等で、ダウンロードせずに直接クエリできる。

このリポジトリの狙いは、Layercakeがdwg7のデータ需要に使えるかを、
実際に試してみること。特に第一の検証対象はSettlementsレイヤー——
HOTの「Open Mapping x Climate Health」文書が最初に挙げていた課題
「集落名辞書の欠落が、高解像度の気候・保健インテリジェンスを制約している」
に対する、既製の解答候補になり得るかを検証する。

### なぜ今、これを試す価値があるか

* Antigravityパターンの実例: `fao-ferspas`(FAOのSTACカタログを
  GeoParquetインデックス化したもの)と同じ発想だが、こちらはメタデータ
  だけでなく、実データそのものがこの形で提供されている
* 既存プロジェクトとの接続点が多い:
  * Settlements → 集落名辞書として、okapi-map/kikimimi系列の
    地名grounding需要(kikimimiでは規模の都合で省略した機能)
  * POIs(6180万件、65列) → rpi-geoserver0のベンチマークデータ
    (Nepal Health Facilities)を、より広い地理範囲・属性で補完できるか
  * Highways(36列) → HOT文書が挙げる「道路の通行可能性」課題、
    zukakuの背景データとしての活用可能性
  * Boundaries → 国家測量研修、ラオス案件のような行政区分を伴う文脈

## 2. ライセンスについて(重要)

LayercakeのデータはODbL(Open Database License、OSMの標準ライセンス)。
これまでdwg7で検討してきたCC0/let-go principleとは性質が異なる——
シェアアライク条項(派生データベースを作成した場合、同じライセンスで
公開する義務)を持つ、コピーレフト型のライセンス。

このリポジトリでLayercakeのデータを加工・抽出・再配布する場合は、
ODbLの要件(帰属表示、派生データベースのシェアアライク)を満たす必要が
ある。`docs/decisions/`に、具体的にどう対応するかを記録すること。

**方針(2026-09-22確定)**: 「私たちのものはCC0、ODbLのものはODbL」と
明示して整理する。caketest自身の成果物(このファイル、`notes/`、
`docs/decisions/`、`queries/*.sql`等)はリポジトリの`LICENSE`
(CC0)のまま扱い、Layercake/OSM由来のデータ・そこから引用する数値・
名称は都度ODbL出典を明記する。両ライセンスの混在を許容し、
CC0への無理な統一(純化)は行わない。詳細は
[`docs/decisions/0001-odbl-license-handling.md`](docs/decisions/0001-odbl-license-handling.md)参照。

## 3. 検証の進め方

### 段階1: Settlementsレイヤーの評価(最優先)

* DuckDBのspatial拡張で、`https://data.openstreetmap.us/layercake/settlements.parquet`
  に対し、ダウンロードなしで直接クエリを試す
* 北海道、あるいはラオス(ビエンチャン)、南スーダン(ジュバ)など、
  dwg7の既存プロジェクトに関連する地域で、実際にどれだけの粒度・
  精度で集落が拾えるかを確認する
* HOT文書が課題として挙げていた「名称の欠落・重複・不整合な綴り・
  座標や行政階層との不整合」が、Layercakeのデータでどの程度
  解消されているか(あるいは同じ課題を引き継いでいるか)を評価する

### 段階2: 他レイヤーの簡易評価

* POIs、Highways、Boundariesについても、同様に簡易クエリを試し、
  既存プロジェクトへの転用可能性を一覧化する

### 段階3: 判断(当面見送り、7節参照)

* 実用に足ると判断すれば、`docs/decisions/`にADRとして記録し、
  どのプロジェクト(kikimimi、rpi-geoserver0、zukaku等)への統合を
  提案するかをまとめる
* 実用に足らないと判断した場合も、その理由を正直に記録する
  (「動かなかった」も立派な検証結果、というrpi-geoserver0以来の姿勢)
* 2026-09-22時点で、既存プロジェクトへの実統合は当面考えないという
  判断が下された。段階3自体は取り下げないが優先度は下げ、7節の
  探索的調査を優先する。

## 4. 作業分担

* Claude Codeが担当してよい範囲: DuckDBでのクエリ試行、結果の
  記録・要約、`docs/decisions/`へのADR記録、他プロジェクトへの
  転用可能性の整理
* 人の手を残す範囲: 「実用に足るかどうか」の最終判断、
  ODbLライセンスへの対応方針の決定、他プロジェクトへの実際の統合可否、
  国家測量研修の対象国リストの提供、探索の取りまとめ形式・区切りの決定

## 5. リポジトリ構成方針

```
dwg7/caketest/
├── README.md
├── CLAUDE.md                   # このファイル
├── docs/
│   └── decisions/                # ODbL対応方針、評価結果の判断等のADR
├── queries/
│   ├── settlements-*.sql         # 地域ごとの検証クエリ
│   ├── pois-*.sql
│   └── highways-*.sql
└── notes/
    └── findings.md                # 各レイヤーの評価結果、既存プロジェクト
                                     # への転用可能性の一覧
```

## 6. 現時点でのステータス

* [x] Layercakeの内容確認、dwg7への価値の見立て
* [x] プロジェクト立ち上げの決定(`dwg7/caketest`)
* [x] `dwg7/caketest` リポジトリ作成
* [x] Settlementsレイヤーの検証(段階1) — 北海道/ビエンチャン/ジュバ/
      フリータウンの4地域で検証済み、詳細は[`notes/findings.md`](notes/findings.md)
* [x] POIs/Highways/Boundariesの簡易評価(段階2) — ネパール保健施設
      /道路通行可能性(北海道・ビエンチャン・ジュバ・フリータウン)
      /ラオス・フリータウンの行政境界で検証済み、詳細は
      [`notes/findings.md`](notes/findings.md)
* [x] ODbLライセンス対応方針の決定(段階1・2分) — 案A(クエリのみ・
      再配布なし)を[`docs/decisions/0001-odbl-license-handling.md`](docs/decisions/0001-odbl-license-handling.md)
      で承認済み。段階3(他プロジェクトへの統合)の扱いは引き続き未決
* [~] 実用可否の判断、既存プロジェクトへの統合提案(段階3) — 判断材料を
      [`docs/decisions/0002-stage3-judgment-materials.md`](docs/decisions/0002-stage3-judgment-materials.md)
      に整理済み。**当面、実統合は見送りと決定**(詳細は7節・
      [`docs/decisions/0003-exploratory-pivot.md`](docs/decisions/0003-exploratory-pivot.md))
* [x] 方針転換の決定・記録 — 探索的アプローチへの転換を
      [`docs/decisions/0003-exploratory-pivot.md`](docs/decisions/0003-exploratory-pivot.md)
      に記録済み
* [ ] 国家測量研修の対象国リストの確認(人からの提供待ち)
* [ ] 対象国の特徴的な都市への調査範囲拡張(段階4、7節参照)
* [ ] ブラウザでの対話的プレゼンテーション構想の具体化(未着手、メモのみ)

## 7. 方針転換(2026-09-22): 探索的アプローチへ

段階1・2の結果([`notes/findings.md`](notes/findings.md))と判断材料
([`docs/decisions/0002-stage3-judgment-materials.md`](docs/decisions/0002-stage3-judgment-materials.md))
を踏まえ、人から以下の方針転換が示された。詳細は
[`docs/decisions/0003-exploratory-pivot.md`](docs/decisions/0003-exploratory-pivot.md)
に記録済み。新しいセッションはこのADRも合わせて読むこと。

* **軸B(Layercakeという技術)は採用可、確定**。以後は再議論しない。
* **低密度地域(ジュバ・フリータウン等)も対象から外さない**。
  「データが疎であること」自体を「その地域でのマッピングの必要性の
  シグナル」として積極的に記録する、**反転の発想=探索的アプローチ**
  へ転換した。
* **ライセンスは「私たちのものはCC0、ODbLのものはODbL」と明示区分**。
  CC0への無理な統一は行わない(2節参照)。
* **調査対象を国家測量研修の対象国全体の特徴的な都市へ拡張してよい**
  という許可が出た。対象国リストは人からの提供待ち。
* **既存プロジェクトへの実統合は当面考えない**。段階3はロードマップ
  上に残すが優先度を下げる。
* **新しい全体テーマ**: 「我々が採用したLayercakeという技術を使って、
  各国・各地域のOSMの多様性を理解し、各国・各地域の課題の多様性を
  理解する」——実用可否の判定プロジェクトから、探索的な理解・
  可視化プロジェクトへ。うまくいけば国家測量研修の教材になりうる、
  という位置づけ。
* **将来構想(未着手のメモ)**: Unix上のDuckDB CLIでの対話的研究と、
  ブラウザ上(DuckDB-WASM等)でのライブクエリによるプレゼンテーション
  という二層構成。どちらもLayercake(OSM US)からオンラインでデータを
  取得し、ローカル複製を作らないという一貫した世界観。ODbL対応
  (クエリのみ・再配布なし)とも相性が良い。
