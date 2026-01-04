# Review

CodeRabbit CLI を使った自動レビュー＆修正サイクル

## Usage

```
/review                      # 全変更をレビュー (デフォルト)
/review uncommitted          # 未コミット変更のみ
/review committed            # コミット済み変更のみ
/review --base develop       # ベースブランチ指定
```

## Description

CodeRabbit CLI (`coderabbit --prompt-only`) を使用して、作業ディレクトリの変更をレビューし、指摘事項を自動修正するサイクルを実行する。

## Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  1. coderabbit --prompt-only でレビュー実行                  │
│     ↓                                                       │
│  2. レビュー結果を解析・表示                                 │
│     ↓                                                       │
│  3. 各指摘について：                                        │
│     - 安全な修正 → 自動実行                                 │
│     - 危険/異論あり → ユーザー確認                          │
│     ↓                                                       │
│  4. 再度 coderabbit --prompt-only でレビュー                │
│     ↓                                                       │
│  5. 指摘ゼロ or 最大3回まで 2-4 を繰り返す                  │
│     ↓                                                       │
│  6. 完了報告                                                │
└─────────────────────────────────────────────────────────────┘
```

## Execution Steps

### Step 1: 初期レビュー実行

```bash
# 引数に応じてコマンドを構築
coderabbit --prompt-only [--type <type>] [--base <branch>]
```

- 引数なし: `coderabbit --prompt-only`
- `uncommitted`: `coderabbit --prompt-only --type uncommitted`
- `committed`: `coderabbit --prompt-only --type committed`
- `--base <branch>`: `coderabbit --prompt-only --base <branch>`

### Step 2: レビュー結果の解析

CodeRabbit の出力を解析し、以下を抽出：
- ファイルパスと行番号
- 問題の説明
- 推奨される修正内容
- 重大度（Critical, Warning, Info など）

### Step 3: 修正の分類と実行

各指摘を以下のカテゴリに分類：

#### 自動修正（確認不要）
- タイポ修正
- インポート順序の整理
- 未使用変数の削除
- フォーマット修正
- 単純なリファクタリング提案

#### 確認必要（ユーザー承認を求める）
- ロジックの変更を伴う修正
- セキュリティに関わる変更
- API や公開インターフェースの変更
- 破壊的変更の可能性がある修正
- 複数ファイルにまたがる大規模な変更
- AIのレビューが妥当でないと判断した場合

#### 確認時の報告内容
1. 指摘内容の説明（日本語）
2. 該当コードの確認結果
3. AIレビューの妥当性評価
4. 推奨する修正方法
5. 修正による影響範囲

### Step 4: 再レビュー

修正後、再度 CodeRabbit を実行：
```bash
coderabbit --prompt-only [同じオプション]
```

### Step 5: サイクル管理

- **終了条件**: 指摘がゼロになる
- **最大回数**: 3回（CodeRabbit の推奨制限）
- **回数超過時**: 残りの指摘を報告して終了

### Step 6: 完了報告

最終レポートを出力：
- 実行回数
- 修正した項目のサマリー
- スキップした項目（ユーザーが拒否/保留）
- 残存する指摘（あれば）

## Safety Rules

1. **テスト実行**: 修正後、関連するテストを実行して破壊がないことを確認
2. **段階的修正**: 一度に大量の変更を行わず、段階的に修正
3. **ロールバック可能**: git の差分で変更を確認可能な状態を維持
4. **異論表明**: AIレビューが不適切と判断した場合は理由を説明して確認を求める

## Example Session

```
> /review uncommitted

[Iteration 1/3]
Running: coderabbit --prompt-only --type uncommitted

Found 5 issues:
  1. [Auto-fix] src/utils.ts:42 - Unused import 'lodash'
  2. [Auto-fix] src/api.ts:15 - Missing return type annotation
  3. [Confirm] src/auth.ts:88 - SQL injection vulnerability
  4. [Auto-fix] src/config.ts:3 - Import order
  5. [Info] src/types.ts:20 - Consider using discriminated union

Applying auto-fixes...
  ✓ Fixed: src/utils.ts:42
  ✓ Fixed: src/api.ts:15
  ✓ Fixed: src/config.ts:3

Confirmation required for src/auth.ts:88:
  Issue: SQL injection vulnerability in query builder
  Current: `db.query("SELECT * FROM users WHERE id = " + userId)`
  Suggested: Use parameterized query
  Impact: Changes query execution, test coverage recommended

  Apply fix? [y/n/s(skip)]:

[Iteration 2/3]
Running: coderabbit --prompt-only --type uncommitted

Found 0 issues.

Review complete!
  Iterations: 2
  Fixed: 4 issues
  Skipped: 1 issue (info-level, no action needed)
```

## Prerequisites

- CodeRabbit CLI がインストールされていること
- Git リポジトリ内で実行すること
- 適切な認証設定がされていること

## Notes

- CodeRabbit の出力形式が変更された場合は解析ロジックの更新が必要
- ネットワークエラー時は適切にリトライまたはエラー報告を行う
- 大規模な変更がある場合は先に手動レビューを推奨
