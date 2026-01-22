---
allowed-tools: Bash(gh:*), Bash(git:*), Bash(codex:*), Bash(sleep:*)
description: "Issue Fix: 自動実装→レビュー→マージワークフロー"
---

# Issue Fix: 自動実装→レビュー→マージワークフロー

指定されたGitHub Issueを取得し、実装→PR作成→Codexレビュー→修正→マージまでを自動化します。

## 使用方法

```
/issue-fix <issue番号>
```

例: `/issue-fix 42`

## 引数

Issue番号: $ARGUMENTS

## ワークフロー概要

```
┌────────────────────────────────────────────────────────────────┐
│  1. Issue取得 (gh issue view)                                  │
│     ↓                                                          │
│  2. 実装作業                                                    │
│     ↓                                                          │
│  3. PR作成 (gh pr create)                                      │
│     ↓                                                          │
│  4. Codexにレビュー依頼                                         │
│     - Web版: gh pr comment で @codex メンション                 │
│     - ローカル版: codex CLI + /review コマンド                  │
│     ↓                                                          │
│  5. 15分待機後、レビューコメント確認                            │
│     ↓                                                          │
│  6. 指摘があれば修正→再レビュー依頼（指摘ゼロまで繰り返し）     │
│     - Codex応答なしの場合も限界までリトライ                     │
│     ↓                                                          │
│  7. gh pr merge でマージ、ブランチ削除                          │
└────────────────────────────────────────────────────────────────┘
```

## 実行ステップ

### Step 1: Issue取得

```bash
gh issue view $ARGUMENTS --json title,body,labels,assignees
```

Issue内容を確認し、実装の計画を立てる。

### Step 2: ブランチ作成

Issue番号に基づいてブランチを作成:

```bash
git checkout -b fix/issue-$ARGUMENTS
```

### Step 3: 実装作業

Issue内容に基づいて実装を行う。TDD原則に従い:
1. 失敗するテストを書く
2. テストが通る最小限の実装
3. リファクタリング
4. コミット

### Step 4: PR作成

```bash
git push -u origin fix/issue-$ARGUMENTS
gh pr create --title "Fix #$ARGUMENTS: [Issueタイトル]" --body "[実装内容の説明]

Closes #$ARGUMENTS"
```

### Step 5: Codexレビュー依頼

#### 実行環境の検出

ローカル版（Codex CLI存在確認）:
```bash
command -v codex &> /dev/null
```

#### Web版の場合（Codex CLIが存在しない場合）

```bash
gh pr comment --body "@codex このPRをレビューしてください。"
```

#### ローカル版の場合（Codex CLIが存在する場合）

1. まず `/review` コマンドを実行してCodeRabbitレビュー
2. その後 Codex CLI でセカンドオピニオン:
```bash
codex "このPRの変更内容をレビューしてください"
```

### Step 6: レビューコメント確認ループ

15分待機後、レビューコメントを確認:

```bash
sleep 900  # 15分待機
```

PRのコメントを取得:
```bash
gh pr view --comments --json comments
```

または詳細なレビューコメント:
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments
```

#### レビュー結果の判定

1. **Codex応答なしの場合**: 再度レビュー依頼を出してリトライ（限界まで）
2. **指摘事項ありの場合**:
   - 重要な指摘: 修正を実施
   - 重要度が低い指摘: 除外可能だが、理由をコメントに残す
3. **「指摘事項なし」または承認の場合**: Step 7へ

#### 重要度の低い指摘を除外する場合

```bash
gh pr comment --body "以下の指摘は重要度が低いため対応をスキップします:
- [指摘内容]
理由: [除外理由の説明]"
```

#### 修正後の再レビュー依頼

修正をコミット・プッシュ後:
```bash
git add -A && git commit -m "Address review feedback" && git push
gh pr comment --body "@codex 修正しました。再レビューをお願いします。"
```

### Step 7: マージとクリーンアップ

指摘事項なしが確認できたら:

```bash
# PRをマージ（squash merge推奨）
gh pr merge --squash --delete-branch

# ローカルブランチもクリーンアップ
git checkout main
git pull
git branch -d fix/issue-$ARGUMENTS
```

## 重要なルール

### リトライポリシー

- Codexからの応答がない場合は、応答があるまで限界までリトライする
- リトライ間隔: 5分
- 各リトライ時にコメントで再依頼を出す

### レビューコメントの除外基準

以下の場合、指摘を除外してもよい（必ず理由をghコメントに残す）:
- スタイル上の好み（コードの動作に影響しない）
- プロジェクトの規約と矛盾する指摘
- 実装の範囲外の改善提案

### 除外時のコメント形式

```bash
gh pr comment --body "## レビュー指摘への対応

### 対応済み
- [修正した指摘の概要]

### 対応をスキップ
- **指摘**: [指摘内容]
- **理由**: [除外理由]"
```

## 成功条件

1. Issueが解決される実装が完了している
2. すべてのテストがパスしている
3. Codexから「指摘事項なし」または承認を受けている
4. PRがマージされている
5. ブランチが削除されている

## 失敗時の対応

- 実装が複雑で完了できない場合: 進捗をコメントに残してユーザーに報告
- Codexが応答し続けない場合: 最大リトライ後にユーザーに判断を仰ぐ
- マージコンフリクトが発生した場合: 解決してから再試行
