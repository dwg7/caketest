caketest — Claude Code 引き継ぎドキュメント

このファイルは `dwg7/caketest` リポジトリのルートに置く、Claude Code向けの
プロジェクト文脈。新しいセッションを開始する際は、まずこのファイルを
読んでください。

姉妹プロジェクト: [dwg7/kaga0](https://claude.ai/kaga0/CLAUDE.md)、
[dwg7/zukaku](https://claude.ai/zukaku/CLAUDE.md)、[dwg7/rpi-geoserver0](https://claude.ai/rpi-geoserver0/CLAUDE.md)
(同じ「実装より先に調査」という作法を踏襲)

## 今、これは何のプロジェクトか

**[Layercake](https://layercake.openstreetmap.us/)という技術を使って、
各国・各地域のOSMデータの多様性、そこにある課題の多様性を理解する
探索的調査プロジェクト。**

Layercakeは、OpenStreetMap USが全世界のOSMデータをテーマ別に単一の
GeoParquetファイルへ蒸留したもの(Addresses、Boundaries、Buildings、
Highways、Parks、POIs、Settlements、Waterwaysの8テーマ、それぞれ
惑星規模でありながら単一ファイル)。DuckDBの`httpfs`/`spatial`拡張で、
ダウンロードせずに直接クエリできる。

GitHub description(当初の立ち上げ時の問い、今も出発点として有効):
`Early exploration of Layercake (OSM US's planet-wide GeoParquet layers) — can it serve as a ready-made settlement gazetteer for dwg7?`

**経緯**: 当初は「Layercakeが集落名辞書として実用に足るか」を判定する
プロジェクトとして始まった(段階1・2)。北海道・ラオス・南スーダン・
シエラレオネの4地域で検証したところ、「地域のOSMマッピング密度がそのまま
データの充実度に反映される」ことが分かり、この結果を踏まえて
2026-09-22に方針転換した——実用可否の判定ではなく、**低密度地域も
含めて対象を広げ続け、データの疎密そのものを「その地域でのマッピングの
必要性のシグナル」として記録する探索的アプローチ**へ移行した
([`docs/decisions/0003-exploratory-pivot.md`](docs/decisions/0003-exploratory-pivot.md))。
以後、JICA課題別研修「国家測量事業計画・管理」の参加9カ国
(フィジー/ガボン/ラオス/ナイジェリア/パプアニューギニア/ルワンダ/
シエラレオネ/東ティモール/トーゴ)の首都+特徴的な都市へ調査対象を
拡張し、さらにブラウザからLayercakeへライブクエリするプロトタイプの
検証にも着手した。詳しい経緯は下記「現時点でのステータス」と
`docs/decisions/`の各ADRを参照。

### 既存プロジェクトとの接続点(当初の着想、今も背景として有効)

* Settlements → 集落名辞書として、okapi-map/kikimimi系列の
  地名grounding需要(kikimimiでは規模の都合で省略した機能)
* POIs(6180万件、65列) → rpi-geoserver0のベンチマークデータ
  (Nepal Health Facilities)を、より広い地理範囲・属性で補完できるか
* Highways(36列) → HOT文書「Open Mapping x Climate Health」が挙げる
  「道路の通行可能性」課題、zukakuの背景データとしての活用可能性
* Boundaries → 国家測量研修、ラオス案件のような行政区分を伴う文脈

ただし2026-09-22の方針転換以降、**これらへの実統合は当面考えない**
(下記参照)。今は探索そのものが目的。

## ライセンス方針

LayercakeのデータはODbL(Open Database License、OSMの標準ライセンス)
——シェアアライク条項を持つコピーレフト型で、dwg7の他プロジェクトが
軸にしてきたCC0/let-go principleとは性質が異なる。

**方針(確定)**: 「私たちのものはCC0、ODbLのものはODbL」と明示して
整理する。caketest自身の成果物(このファイル、`notes/`、
`docs/decisions/`、`queries/*.sql`、`web/`等)はリポジトリの`LICENSE`
(CC0)のまま扱い、Layercake/OSM由来のデータ・そこから引用する数値・
名称は都度ODbL出典を明記する。両ライセンスの混在を許容し、CC0への
無理な統一(純化)は行わない。詳細は
[`docs/decisions/0001-odbl-license-handling.md`](docs/decisions/0001-odbl-license-handling.md)。

データは常にLayercakeからオンラインで直接取得し、ローカル複製・
再配布は行わない(クエリのみ・再配布なし方針)。

## 作業分担

* Claude Codeが担当してよい範囲: DuckDBでのクエリ試行、結果の
  記録・要約、`docs/decisions/`へのADR記録、ブラウザプロトタイプの
  実装・検証
* 人の手を残す範囲: 「実用に足るかどうか」の最終判断、ODbLライセンス
  対応方針の決定、他プロジェクトへの実際の統合可否、探索の取りまとめ
  形式・区切りの決定

## リポジトリ構成

```
dwg7/caketest/
├── README.md
├── CLAUDE.md                     # このファイル
├── docs/
│   └── decisions/                  # ADR(ライセンス方針・判断材料・方針転換の記録)
├── queries/
│   ├── settlements-*.sql           # 地域ごとの検証クエリ
│   ├── pois-*.sql
│   ├── highways-*.sql
│   └── boundaries-*.sql
├── notes/
│   └── findings.md                  # 各段階の検証結果(本体)
└── web/
    └── index.html                    # ブラウザからLayercakeへ直接
                                        # ライブクエリするプロトタイプ
```

## 現時点でのステータス(2026-09-22時点)

調査の本体は[`notes/findings.md`](notes/findings.md)に段階ごとに
記録されている。以下は各段階の要約と、対応するADR:

* **段階1** — Settlementsレイヤーを北海道/ビエンチャン(ラオス)/
  ジュバ(南スーダン)/フリータウン(シエラレオネ)の4地域で検証。
  「地域のOSMマッピング密度がそのままデータ充実度に反映される」
  という基本傾向を確認。
* **段階2** — POIs/Highways/Boundariesを同4地域で簡易評価。
  ネパール全域の保健施設(rpi-geoserver0との比較)、道路の通行可能性
  属性、ラオス/フリータウンの行政境界を検証。
* **ADR [0001](docs/decisions/0001-odbl-license-handling.md)** —
  ODbL対応方針(クエリのみ・再配布なし)を承認。混在ライセンス方針も
  確定。
* **ADR [0002](docs/decisions/0002-stage3-judgment-materials.md)** —
  段階3(統合可否)の判断材料を、軸A(OSMデータそのもの)/軸B
  (Layercakeという技術)に分けて整理。
* **ADR [0003](docs/decisions/0003-exploratory-pivot.md)** —
  **方針転換**。実用可否の判定から探索的アプローチへ。低密度地域も
  対象に残す、ライセンス混在方針の確定、既存プロジェクトへの統合は
  当面見送り、というここでの決定を記録。
* **段階4** — 方針転換を受け、JICA研修参加9カ国のうち未検証だった
  7カ国の首都圏を4レイヤーで検証。Boundariesのbbox判定に方法論上の
  誤りを発見し、`ST_Contains`による正確な判定に修正(過去の結果も
  再検証済み)。
* **段階5** — 各国について首都と対照的な「特徴的な都市」を1つずつ
  選び(ラゴス、ギセニ、オエクシ等)、同4レイヤーで検証。**「国」より
  「都市・地域のマッパーコミュニティ」がデータ充実度を左右する**
  という、この調査の中心的な知見を得た(国内で3〜10倍以上の差)。
  9都市で十分と判断し、地域拡張はここで一区切り。
* **ADR [0004](docs/decisions/0004-browser-presentation-layer.md)** —
  ブラウザ表現層の検討。**claude.ai Artifactでは外部への
  fetch/XHRがCSPでブロックされるため実現不可**と判明し、代わりに
  リポジトリ内のスタンドアロンHTML([`web/index.html`](web/index.html))
  として実装。DuckDB-WASM + httpfsでLayercakeへのライブクエリを
  実機検証済み(CLIの結果と完全一致)。動かし方は[README.md](README.md)参照。

### 次にありうる展開(未着手・人の判断待ち)

* `web/`プロトタイプの拡張(他レイヤー対応、地図表示。静的ホスティングは
  2026-10-27にGitHub Pagesへ配置済み)、およびBoundariesの`ST_Contains`をWASM版`spatial`拡張で
  再現できるかの検証
* 探索の成果をどう取りまとめるか(国別レポート、レイヤー横断分析等)
* 探索を「いつまで」続けるかの区切り
* (優先度低・当面見送り)既存プロジェクト(kikimimi、rpi-geoserver0、
  zukaku)への実際の統合可否
