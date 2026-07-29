---
name: codex-security
description: |
  OpenAI Codex Security CLI（@openai/codex-security）でコードのセキュリティスキャンを実行するスキル。リポジトリ全体・差分・未コミット変更の脆弱性検出、結果レポートの解釈と修正対応、未導入環境のセットアップ支援を行う。
  トリガー: "codex-security", "セキュリティスキャン", "脆弱性スキャン", "脆弱性診断", "セキュリティ診断", "security scan", "vulnerability scan"
  使用場面: (1) リポジトリ全体の脆弱性スキャン、(2) push・PR作成前の差分セキュリティチェック（標準ゲート）、(3) スキャン結果（findings）の確認と修正対応、(4) CLI未導入環境のセットアップ
---

# Codex Security Scan

OpenAI の Codex Security CLI（[openai/codex-security](https://github.com/openai/codex-security)）でセキュリティスキャンを実行し、検出結果の解釈と修正対応まで行う。

## 重要ルール

- **スキャンは対象コードを OpenAI のモデルへ送信する**。実行前に必ず対象リポジトリとスキャン範囲をユーザーへ提示し、明示的な承認を得る。機密性の高いコードでは特に慎重に確認する。
- API キーやトークンを平文でファイル・シェル履歴・コミットに残さない。認証は `login`（対話）または環境変数 `OPENAI_API_KEY` のみ。エージェントは認証情報の入力を代行しない。
- CLI の仕様は更新されうる。コマンドやオプションが失敗したら `npx codex-security --help` で現行仕様を確認し、推測のまま再実行しない。
- スキャン結果ディレクトリ（`codex-security-results/` など）はコミットしない。リポジトリ管理下に出力する場合は `.gitignore` への追加を提案する。

## Phase 0: 環境チェック

実行環境を確認し、不足があれば Phase 1 のセットアップへ進む。

```bash
pwd                                        # 対象リポジトリにいるか確認
node --version                             # Node.js 22 以上が必要
npx --no-install codex-security --version  # CLI 導入済みか（未導入ならエラー）
```

判定:
- Node.js が未導入または 22 未満 → Phase 1-1
- CLI が未導入 → Phase 1-2
- 認証未設定はスキャン実行時の認証エラーで判明する → Phase 1-3

## Phase 1: セットアップ（不足がある場合のみ）

### 1-1. Node.js 22+ の導入

インストールは勝手に実行せず、環境に合う方法をユーザーへ提案して確認を取る。

- ランタイムマネージャ利用中ならそれを優先: `mise use node@22` / `nvm install 22` など
- macOS: `brew install node`
- Windows: `winget install OpenJS.NodeJS.LTS`

補足: リポジトリには Docker 構成（`Dockerfile` / `compose.yaml`）も含まれるため、ローカルに Node.js を入れたくない場合はコンテナ実行も選択肢として提示する。

### 1-2. CLI の導入

```bash
# プロジェクトに導入する場合（推奨: devDependencies でバージョン固定できる）
npm install --save-dev @openai/codex-security

# 導入せず都度実行する場合
npx @openai/codex-security --help
```

### 1-3. 認証

認証操作はユーザー自身が行う。エージェントは認証情報を入力・保存しない。

- 対話環境: ユーザーに `npx codex-security login` を実行してもらう（ブラウザで ChatGPT 認証）
- ブラウザを開けない環境: `npx codex-security login --device-auth`
- CI・非対話環境: `OPENAI_API_KEY` を環境変数として設定してもらう（値をファイルへ書き出さない）

Codex Security へのアクセス権がある ChatGPT アカウントまたは API キーが必要。権限エラーが出る場合は、プラン・組織設定の確認をユーザーへ依頼する。

## Phase 2: スキャン実行

実行前に必ずユーザーへ確認する: スキャン対象（全体か差分か）、コード外部送信の承認、コスト上限の要否。

```bash
# リポジトリ全体をスキャン
npx codex-security scan . --output-dir codex-security-results
```

主なオプション（詳細・最新は `npx codex-security scan --help` で確認）:

| オプション | 用途 |
|---|---|
| `--path <path>` | 特定パスに限定（複数指定可） |
| `--diff` | ベースとの差分のみスキャン |
| `--working-tree` | 未コミット変更のみスキャン |
| `--mode deep` | より広範・深い検査 |
| `--max-cost <usd>` | モデル利用コストの上限（USD） |
| `--dry-run` | 実行内容の事前確認 |

スコープ選択の目安:
- push・PR作成前の確認（`commit-changes` / `pull-request-workflow` からの標準ゲート） → `--working-tree` または `--diff`
- 初回・定期の棚卸し → リポジトリ全体（`--max-cost` の指定を推奨）

push・PR前ゲートとして呼ばれた場合、ユーザーが明示的にスキップを選ぶか、送信対象の差分にコード変更がない（ドキュメント・設定のみ）ときはスキャンを省略してよい。省略した場合はその判断を報告に含める。

## Phase 3: 結果の確認と対応

出力ディレクトリ（`--output-dir` 指定先）の構成:

```
codex-security-results/
├── scan-manifest.json     # スキャン設定・メタデータ
├── findings.json          # 検出結果（重大度・確度・位置・根拠・修正案）
├── coverage.json          # 検査カバレッジ
├── report.md              # 人間向けサマリレポート
├── artifacts/
└── exports/results.sarif  # SARIF 形式（CI・IDE 連携用）
```

対応フロー:
1. `report.md` を読み、全体像をユーザーへ要約する
2. `findings.json` を重大度・確度の高い順に整理する
3. 修正するかどうかはユーザーの判断を仰ぐ。修正時は1件ずつ、根拠（evidence）をコードと突き合わせてから直す
4. 修正後は同じスコープで再スキャンし、解消されたことを確認する

誤検知と判断した項目も黙って無視せず、判断理由をユーザーへ共有する。

## スキャン履歴の管理

```bash
npx codex-security scans list .              # 過去スキャンの一覧
npx codex-security scans show <SCAN_ID>      # スキャン詳細の表示
npx codex-security scans rerun <SCAN_ID>     # 同条件で再実行
npx codex-security scans compare <ID1> <ID2> # 2つのスキャンを比較
```

## Troubleshooting

| 症状 | 対処 |
|---|---|
| `codex-security: command not found` | Phase 1-2 で導入する。`npx --no-install` はローカル導入が前提 |
| Node.js のバージョンエラー | Phase 1-1 で Node.js 22+ を導入する |
| 認証エラー | ユーザーに `npx codex-security login` の再実行を依頼。CI では `OPENAI_API_KEY` の設定を確認 |
| アクセス権エラー | Codex Security が利用可能なプラン・組織かユーザーへ確認を依頼する |
| 不明なオプションエラー | `npx codex-security --help` / `npx codex-security scan --help` で現行仕様を確認して修正する |
