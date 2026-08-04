---
name: github-repo-setup
description: |
  GitHub リポジトリの新規作成と、セキュリティ初期設定6項目（SECURITY.md、Private Vulnerability Reporting、Secret Scanning + Push Protection、Dependabot + Dependency Review、CodeQL、ブランチ保護 ruleset）を gh CLI で適用する。既存リポジトリへの後付けや設定点検にも使う。
  トリガー: "リポジトリ作成", "新規リポジトリ", "repo create", "ブランチ保護", "Dependabot", "CodeQL", "secret scanning", "SECURITY.md"
---

# GitHub Repo Setup

GitHub リポジトリを新規作成し、[GitHub 公式ブログ推奨の6つのセキュリティ設定](https://github.blog/security/6-security-settings-every-github-maintainer-should-enable-this-week/)を初期装備として適用する。

1. SECURITY.md の追加
2. Private Vulnerability Reporting の有効化
3. Secret Scanning + Push Protection の有効化
4. Dependabot + Dependency Review の有効化
5. Code Scanning（CodeQL default setup）の有効化
6. デフォルトブランチの保護（ruleset）

## 重要ルール

- **リポジトリ作成と設定変更は GitHub 上の外部変更**。実行前にオーナー、リポジトリ名、公開範囲、適用する項目をユーザーへ提示し、明示的な承認を得る。
- 公開範囲とプランで適用可否が変わる。適用できない項目は黙って飛ばさず、理由と代替手段（UI 操作、プラン変更）を報告する。
- API がエラーを返したら推測のまま再実行しない。`gh api` のエラーメッセージと [GitHub REST API ドキュメント](https://docs.github.com/en/rest)で現行仕様を確認する。
- トークンなどの秘密情報をコマンド引数やファイルに残さない。認証は `gh auth` の状態をそのまま使う。

## 適用可否（公開範囲とプラン）

| 設定 | Public | Private（Free プラン） |
|---|---|---|
| 1. SECURITY.md / dependabot.yml | ○ | ○ |
| 2. Private Vulnerability Reporting | ○ | ×（機能自体が public 限定） |
| 3. Secret Scanning + Push Protection | ○ | ×（GitHub Secret Protection の購入が必要） |
| 4. Dependabot alerts / security updates | ○ | ○ |
| 4'. Dependency Review action | ○ | ×（GitHub Code Security が必要） |
| 5. CodeQL code scanning | ○ | ×（GitHub Code Security が必要） |
| 6. Ruleset（ブランチ保護） | ○ | ×（Team プラン以上） |

private リポジトリでは 1 と 4 のみ適用し、残りはスキップ理由を報告する。

## Phase 0: 前提確認

```bash
pwd             # 作業ディレクトリの確認
gh --version
gh auth status  # 認証済みアカウントと対象ホストの確認
```

ユーザーと確定させること:

- オーナー（個人 or Organization）とリポジトリ名
- 公開範囲（public / private）
- 説明、ライセンス、既存ローカルリポジトリの有無
- ブランチ保護の承認者数（下記「一人開発の注意」参照）

既存リポジトリへの後付け適用なら Phase 1 を飛ばす。

## Phase 1: リポジトリ作成

```bash
# 新規作成してクローンする場合
gh repo create <owner>/<repo> --public --description "<説明>" --add-readme --clone

# 既存ローカルリポジトリを push する場合
gh repo create <owner>/<repo> --public --source . --push
```

`--add-readme` または `--push` で初期コミットを必ず作る。空リポジトリのままでは Phase 3 の CodeQL とデフォルトブランチ保護が適用できない。

## Phase 2: セキュリティファイルの追加

このスキルの `references/` からテンプレートをコピーし、プレースホルダを置換してからコミット・push する。

| テンプレート | 配置先 | 調整箇所 |
|---|---|---|
| `references/SECURITY.md` | `SECURITY.md` | `<owner>/<repo>`、応答目安日数 |
| `references/dependabot.yml` | `.github/dependabot.yml` | プロジェクトの言語に合わせて `package-ecosystem` を追加（npm / pip / uv / cargo / gomod / docker など） |
| `references/dependency-review.yml` | `.github/workflows/dependency-review.yml` | 原則そのまま（public のみ） |

コミットは `commit-changes` スキルの規律に従う。

## Phase 3: リポジトリ設定の有効化

```bash
repo="<owner>/<repo>"

# 2. Private Vulnerability Reporting（public のみ）
gh api -X PUT "repos/$repo/private-vulnerability-reporting"

# 3. Secret Scanning + Push Protection
gh api -X PATCH "repos/$repo" \
  -f 'security_and_analysis[secret_scanning][status]=enabled' \
  -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'

# 4. Dependabot alerts + security updates（この順で実行する）
gh api -X PUT "repos/$repo/vulnerability-alerts"
gh api -X PUT "repos/$repo/automated-security-fixes"

# 5. CodeQL default setup（対応言語のコードを push した後に実行）
gh api -X PATCH "repos/$repo/code-scanning/default-setup" -f state=configured

# 6. デフォルトブランチ保護（references/ruleset.json を調整してから）
gh api -X POST "repos/$repo/rulesets" --input ruleset.json
```

### 一人開発の注意（項目6）

GitHub では自分の PR を自分で承認できない。レビュアーがいないリポジトリで `required_approving_review_count: 1` にすると PR をマージできなくなる。

- コラボレータやチームがいる → `1`（記事の推奨値）
- 一人開発 → `0` にして「直 push 禁止 + PR 経由」だけを強制する

どちらにするかは Phase 0 でユーザーに確認する。

## Phase 4: 検証と報告

```bash
gh repo view "$repo" --json name,visibility,defaultBranchRef
gh api "repos/$repo" --jq '.security_and_analysis'
gh api "repos/$repo/private-vulnerability-reporting" --jq '.enabled'
gh api "repos/$repo/vulnerability-alerts"                # 204 なら有効
gh api "repos/$repo/code-scanning/default-setup" --jq '{state, languages}'
gh api "repos/$repo/rulesets" --jq '.[] | {name, enforcement}'
```

6項目それぞれについて「有効化した / スキップした（理由）」をチェックリスト形式で報告する。スキップした項目には UI での有効化手順（Settings → Advanced Security など）を添える。

## Troubleshooting

| 症状 | 対処 |
|---|---|
| PVR で 404 / 422 | private リポジトリでは利用不可。スキップして報告する |
| secret_scanning の PATCH で 422 | private + プラン不足。Settings → Advanced Security の購入状況をユーザーへ確認 |
| CodeQL で「no supported languages」等の 422 | 対応言語のコードがまだ無い。コード push 後に再実行する |
| ruleset の POST で 403 | private リポジトリの Free プランでは利用不可。public 化か Team プランが必要 |
| `automated-security-fixes` が失敗 | 先に `vulnerability-alerts` を有効化してから再実行する |
| `gh api` が認証エラー | `gh auth status` を確認し、ユーザーに `gh auth login` / `gh auth refresh` を依頼する（admin 権限が必要） |
