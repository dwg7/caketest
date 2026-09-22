# 0004: ブラウザ表現層の検討

* ステータス: **承認(Accepted)** — アーキテクチャ方針を確定。実装は
  プロトタイプ段階
* 日付: 2026-09-22
* 前提: [`0003-exploratory-pivot.md`](0003-exploratory-pivot.md)の
  「将来的な方向性」で示された、Unix上のCLI研究とブラウザ上の
  ライブクエリ発表という二層構成の構想を、実際に検証した記録

## 結論(先に要点)

**「ブラウザでLayercakeへライブクエリ」という構想は技術的に実現可能。
ただし、claude.aiの**Artifact機能としてではなく、リポジトリ内の
**スタンドアロンHTMLファイル**(利用者自身のブラウザで、簡易HTTP
サーバー経由で開く)として実装する必要がある**。実際に動くプロトタイプを
作成し、DuckDBのCLIで得た結果と完全に一致するライブクエリ結果を
ブラウザから得られることを確認した。

## 調査の経緯

### 1. Claude Artifactとしての実現は困難と判明

`artifact-design`スキルのCDN allowlist説明を確認したところ、
Artifactのページは以下の制約を受けることが分かった:

> 外部スクリプトは cdnjs.cloudflare.com / cdn.jsdelivr.net/npm/ 等の
> 限られたホストからの`<script>`タグ読み込みのみ許可され、**それ以外
> ——スタイルシート、画像、メディア、fetch/XHR/WebSocket、ライブラリの
> ランタイムfetch——は、許可されたCDNホスト上であっても、エラー表示
> なしにブロックされる**。

DuckDB-WASMは、初期化時にWorker用JSファイルと`.wasm`バイナリを
ランタイムでfetchし、さらにhttpfs拡張がLayercakeのparquetファイルへ
HTTP範囲リクエストを投げる、という構造になっている。これらはいずれも
「`<script>`タグ以外のfetch」に該当するため、**Artifactとして公開した
場合、サイレントに(エラーも見えないまま)動作しない可能性が高い**と
判断した。この時点で、Artifactでの実装は見送ることにした。

### 2. スタンドアロンHTMLファイルとして実装・検証

代わりに、リポジトリ内に通常のHTMLファイル
([`web/index.html`](../../web/index.html))を作成した。これは
claude.aiのArtifact機構を経由せず、利用者が自分のマシン上で
(簡易HTTPサーバー経由、または将来的には静的ホスティングで)開く
前提のファイルであり、上記のCSP制約を受けない。

構成:

* DuckDB-WASM(`@duckdb/duckdb-wasm`)をjsDelivrのESMビルドから
  動的importで読み込む(標準的な「バンドラーなし」利用パターン)
* `httpfs`拡張のみを使用(`spatial`拡張やジオメトリ列は使わず、
  `bbox`構造体列でのフィルタリングのみで完結させた——WASM版での
  spatial拡張対応状況を確認する手間を避けつつ、段階1〜5で行って
  きたのと同種の集計クエリを再現できる)
* 地域をプルダウンで選び、Settlementsレイヤーの`place`種別ごとの
  件数を、その場でLayercakeへ直接クエリして表示する

### 3. 実機での動作検証(Chrome拡張が使えなかったため、Playwright経由で検証)

このセッションではClaude in Chrome拡張が接続できなかったため、
代わりにPlaywright(システムにインストール済みのChromeを使用)で
ヘッドレスブラウザから直接検証した。

* ローカルで`python3 -m http.server`を立て、`web/index.html`を配信
* 実際のChromeブラウザで開き、DuckDB-WASMの初期化・`httpfs`の
  ロード・Layercake settlements.parquetへのライブクエリが成功する
  ことを確認
* **北海道**のクエリ結果(quarter 5,762、town 132、city 35、
  suburb 35、village 27、farm 21、hamlet 19、city_block 6、
  isolated_dwelling 6、合計6,043件)が、[`notes/findings.md`](../../notes/findings.md)
  の段階1でDuckDB CLIから得た結果と**完全に一致**
* **フィジー(スバ)**のクエリ結果(suburb 23、village 14、town 3、
  farm 2、hamlet 1、city 1、合計44件)も、段階4でCLIから得た結果と
  **完全に一致**
* コンソールに出た唯一のエラー(404)は`favicon.ico`の不在によるもので、
  実質的な問題ではないことを確認済み
* クエリ時間は北海道(6,043件、settlements.parquet全体を範囲
  リクエストで読む)で約9秒、フィジー(44件)で約5.6秒。ブラウザから
  直接、惑星規模のparquetファイルへHTTP範囲リクエストを投げている
  ことを考えれば妥当な速度感だが、CLIでの応答性と比べると体感的に
  遅く、プレゼンテーション用途では読み込み中の表示が重要になる
  (プロトタイプには実装済み)

## 分かったこと・注意点

* **file://で直接開くのではなく、http(s)経由で配信する必要がある**
  (ESモジュールのimportとWorker生成が、file://オリジンでは
  ブロックされることが多いため)。将来的に配布する場合は、
  GitHub Pages等の静的ホスティングに載せることを想定する。
* Settlements/POIsのような点データのみを扱う分には、`spatial`拡張
  なしで(`httpfs`だけで)十分実用になる。Boundariesのような
  `ST_Contains`が必要な検証をブラウザ側で再現する場合は、WASM版の
  `spatial`拡張対応状況を別途確認する必要がある(今回は未検証)。
* Artifactの制約(fetch/XHRブロック)は今回の調査で初めて明確になった
  重要な既知の制約であり、今後Claude Artifactで同種の「外部データへの
  ライブクエリ」を試みる際は、最初からこの制約を前提に設計する必要が
  ある。

## 決定事項

1. ブラウザ表現層は、**claude.ai Artifactではなく、リポジトリ内の
   スタンドアロンHTMLファイル**(`web/`ディレクトリ)として開発を
   継続する。
2. `web/index.html`をプロトタイプの第一版として採用。Settlements
   レイヤー・`place`種別集計のみをサポートする最小構成。
3. データはこれまで通りLayercakeからオンラインで直接取得し、
   ローカル複製・再配布は行わない(ODbL対応方針・案Aと整合)。
4. ページ自体のコード(`web/*.html`等)はcaketestの成果物として
   CC0で扱う(ADR 0003で確定した混在ライセンス方針どおり)。

## 未決事項(人の判断が必要)

* この先、他のレイヤー(Highways、POIs、Boundaries)や複数レイヤーの
  横断的な可視化(地図表示等)へどこまで拡張するか
* 静的ホスティング先(GitHub Pages等)への配置をいつ・どう行うか
  (現時点ではローカルで簡易サーバーを立てて確認する運用にとどめている)
* Boundariesレイヤーの`ST_Contains`のようなspatial拡張が必要な
  機能を、WASM版で再現できるかどうかの検証
* 実際の研修・プレゼンテーションの場でこのプロトタイプを使うかどうか
