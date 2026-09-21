# caketest

Early exploration of [Layercake](https://layercake.openstreetmap.us/) (OSM US's
planet-wide GeoParquet layers) — can it serve as a ready-made settlement
gazetteer for dwg7?

Layercakeは、OpenStreetMap USが全世界のOSMデータをテーマ別に単一の
GeoParquetファイルへ蒸留したもの(Addresses、Boundaries、Buildings、
Highways、Parks、POIs、Settlements、Waterwaysの8テーマ)。DuckDBの
spatial拡張等でダウンロードせずに直接クエリできる規模感(多くのテーマが
数百MiB程度)であることから、dwg7のデータ需要——特に集落名辞書の
欠落という課題——に使えるかを検証する。

詳細な背景・進め方は [CLAUDE.md](CLAUDE.md) を参照。

## 構成

* `docs/decisions/` — ODbLライセンス対応方針、評価結果の判断等のADR
* `queries/` — レイヤー・地域ごとの検証用SQL
* `notes/findings.md` — 各レイヤーの評価結果、既存プロジェクトへの
  転用可能性の一覧

## ライセンス

このリポジトリ自体のコードは [LICENSE](LICENSE) を参照。Layercakeの
データはODbL(Open Database License)で提供されており、本リポジトリでの
取り扱い方針は `docs/decisions/` に記録する。
