# caketest

[Layercake](https://layercake.openstreetmap.us/)(OpenStreetMap USが
全世界のOSMデータをテーマ別に単一のGeoParquetファイルへ蒸留したもの)
という技術を使って、各国・各地域のOSMデータの多様性、そこにある課題の
多様性を理解する探索的調査プロジェクト。

当初は「dwg7の集落名辞書として実用に足るか」を判定する検証として
始まったが、調査の過程で「地域のOSMマッピング密度がそのままデータ
充実度に反映される」——特に**国より都市単位で大きく変動する**——
ことが分かり、実用可否の判定から探索的な理解へと重心を移した。
JICA課題別研修「国家測量事業計画・管理」の参加9カ国の首都+特徴的な
都市を対象に検証を進めている。

詳しい経緯・現状は [CLAUDE.md](CLAUDE.md) を参照。

## 構成

* `docs/decisions/` — ODbLライセンス対応方針、評価結果の判断等のADR
* `queries/` — レイヤー・地域ごとの検証用SQL
* `notes/findings.md` — 各レイヤーの評価結果、既存プロジェクトへの
  転用可能性の一覧
* `web/` — ブラウザからLayercakeへ直接ライブクエリするプロトタイプ
  ([`docs/decisions/0004-browser-presentation-layer.md`](docs/decisions/0004-browser-presentation-layer.md)参照)

## ブラウザプロトタイプの動かし方

公開版: <https://dwg7.unopengis.org/caketest/>
(`main`の`web/`が変わるたびにGitHub Actionsで自動デプロイされる。
`.github/workflows/pages.yml`)

ローカルで動かす場合:

```bash
cd web && python3 -m http.server 8743
```

上記を実行し、ブラウザで <http://localhost:8743/index.html> を開く
(`file://`で直接開くとESモジュール読み込みが失敗するため、必ず
簡易サーバー経由で開くこと)。

## ライセンス

このリポジトリ自体のコードは [LICENSE](LICENSE) を参照。Layercakeの
データはODbL(Open Database License)で提供されており、本リポジトリでの
取り扱い方針は `docs/decisions/` に記録する。
