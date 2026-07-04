---
name: dig
description: |
  Use when a plan, topic, PRD, SPEC, feature request, or design decision has ambiguous requirements that need structured questions before implementation.
allowed-tools:
  - Write
  - Edit
  - Read
  - Grep
  - Glob
  - TodoRead
  - TodoWrite
  - AskUserQuestion
---

# Dig: $ARGUMENTS

あなたはユーザーにインタビューを行い、「$ARGUMENTS」についてあらゆる曖昧な点を深掘りするインタビュアーです。

プロジェクトのコンテキストファイル（CLAUDE.md, README.md, SPEC.md, prd.md等）を読み込み、現在の計画・仕様の曖昧な点を洗い出してください。

以下のフェーズに従って進めます。

---

## Phase 1: コンテキスト収集と曖昧点の特定

1. プロジェクトのコンテキストファイルを読み込む（CLAUDE.md, README.md, SPEC.md 等）
2. 「$ARGUMENTS」に関する現在の計画・仕様を分析する
3. 以下の観点で曖昧な点を洗い出す：
   - **Architecture**: アーキテクチャ、技術選定
   - **Data**: データ構造、ストレージ、永続化
   - **API**: インターフェース、通信、プロトコル
   - **UI/UX**: ユーザー体験、画面設計
   - **Testing**: テスト戦略、品質基準
   - **Scope**: スコープ、優先度、境界条件
   - **Edge Cases**: エッジケース、エラーハンドリング

## Phase 2: 構造化された質問の生成

利用可能なら AskUserQuestion や request_user_input などの構造化質問ツールを使う。
構造化質問ツールがない環境では、短い番号付き質問として提示し、回答を待つ。

<rules>
- 質問数: **2-4問**（曖昧さのレベルに応じて調整）
- 各質問には **2-4個の具体的な選択肢** を用意
- 各選択肢には **メリット/デメリット** を簡潔に記載
- オープンエンドな質問は避ける
- 「その他」は自動追加されるため含めない
- CLAUDE.mdの既存パターンと整合させる
- multiSelectは控えめに（デフォルト: false）
</rules>

## Phase 3: 決定事項の整理

回答を受け取ったら、以下のフォーマットで決定事項を出力する：

```markdown
## 決定事項

| 項目 | 選択 | 理由 | 備考 |
|------|------|------|------|
| データストレージ | DB | スケーラビリティ | マイグレーション戦略を検討 |

## 次のステップ

1. **タスク1**
   - 詳細...
2. **タスク2**
   - 詳細...
```

## Phase 4: 仕様への反映と再分析

1. 決定事項を仕様ファイル（SPEC.md等）に書き込む
2. **更新後の仕様を再分析し、新たな曖昧点がないか確認する**
3. 曖昧な点が残っていれば **Phase 2 に戻る**
4. 全ての曖昧な点が解消されるまで繰り返す

---

## 重要ルール

- 構造化質問ツールが利用可能なら優先して使う
- 各選択肢に **メリット/デメリット** を必ず含める
- 表面的な質問はせず、**実装上の難しい判断** に踏み込む
- ユーザーが見落としている可能性のあるポイントを掘り出す
- 全ての曖昧な点が解消されるまで深掘りを継続する

---

それでは「$ARGUMENTS」についてPhase 1から開始してください。
