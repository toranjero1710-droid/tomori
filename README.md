# Project TOMORI / ともり ホームページ Sprint1.5

Blue Hip の新規ブランド「ともり」のホームページ初版です。GitHub Pagesで公開する前提の静的サイトとして構成しています。

## 公開想定

- リポジトリ名: `tomori`
- GitHub Pages公開URL: `https://toranjero1710-droid.github.io/tomori/`
- 公開対象ディレクトリ: `homepage/`

この作業環境では `.git` が無く、`git` コマンドもPATH上に無いため、ローカルからのcommit / pushは未実施です。

## Pages公開可否

現在のサイトは、HTML/CSS/JavaScript/画像だけで構成された静的サイトです。GitHub Pagesの公開元をリポジトリのルートにした場合、以下のURLでそのまま表示できます。

```text
https://toranjero1710-droid.github.io/tomori/
```

`homepage/index.html` があるため、`/homepage/` で404にならない構成です。

## 構成

```text
/
├── index.html
├── styles.css
├── script.js
├── robots.txt
├── sitemap.xml
├── assets/
│   └── tomori-hero.png
├── homepage/
│   ├── index.html
│   ├── styles.css
│   ├── script.js
│   ├── robots.txt
│   ├── sitemap.xml
│   └── assets/
│       └── tomori-hero.png
└── README.md
```

## GitHub Webアップロード手順

1. GitHubで新規リポジトリ `tomori` を作成する。
2. リポジトリ画面で `uploading an existing file` を選ぶ。
3. この作業フォルダ内の `index.html`、`styles.css`、`script.js`、`robots.txt`、`sitemap.xml`、`assets`、`homepage`、`README.md` をアップロードする。
4. コミットメッセージに `Add TOMORI Sprint1 homepage` などを入力してコミットする。
5. リポジトリの `Settings` を開く。
6. 左メニューの `Pages` を開く。
7. `Build and deployment` の `Source` を `Deploy from a branch` にする。
8. `Branch` を `main`、フォルダを `/ (root)` にして保存する。
9. 数分後に `https://toranjero1710-droid.github.io/tomori/` を開いて表示確認する。

## URL統一

以下は公開URL `https://toranjero1710-droid.github.io/tomori/` に統一済みです。

- `homepage/index.html` の canonical / OGP URL
- `index.html` の canonical / OGP URL
- `homepage/robots.txt` の Sitemap URL
- `robots.txt` の Sitemap URL
- `homepage/sitemap.xml` の loc
- `sitemap.xml` の loc
- このREADME

GitHubユーザー名またはOrganization名が `bluehip` ではない場合、公開前にURLを差し替えてください。

## 未確定項目

- 電話番号: `homepage/index.html` 内にTODOコメントを残しています。
- LINE公式アカウントID: `homepage/index.html` 内にTODOコメントを残しています。

## Sprint1 / Sprint1.5 の範囲

- トップページ1枚構成
- スマホ優先のレスポンシブ表示
- サービス詳細の開閉UI
- 基本プラン 月額9,800円（税込）の掲載
- 電話・LINE相談導線
- title / description / OGP
- robots.txt / sitemap.xml
- GitHub Webアップロード手順の整理

## 今回あえて作らないもの

- AI機能
- LINE自動連携
- 顧客ログイン
- お客様ページ
- 一年の便り生成機能
- 相談フォーム
- ダミー口コミ・お客様の声

## ローカル確認

`homepage/index.html` をブラウザで開いて確認できます。

この環境では `python` が Windows Store エイリアスのみで、簡易サーバーには使えませんでした。確認時は Node.js の一時静的サーバーで `http://127.0.0.1:4174/` を開いて検証しています。

Git push test: 2026-07-16 Sprint2.1 environment check.
