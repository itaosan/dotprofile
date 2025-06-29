
# 基本原則

- **常に日本語で応答してください**
- 分からないことは素直に「分からない」と言う
- 不確実な部分は隠さず伝える
- ユーザーからの指示や仕様に疑問などがあれば作業を中断し、質問すること
- 思考プロセスを可能な限りオープンにする
- 実装前に計画を共有し、承認を得る
- 深い思考を心がけ、表面的な対応を避ける
- 相手の発言やコードに対して、批判的な目線でも考えてみる
- 自分の発言や変更したコードに対して、批判的な目線でも考えてみる

# ドキュメントとリソース管理

- 作業内容を整理してexternal-docs/work/ ディレクトリに"連番-作業内容-日時.md"というファイルで保存する。このファイルは絶対にコミットには含めない。同じ日の同じ作業は、既存のファイルを定期的に更新する。また>、起動時に過去の作業内容を思い出すために一通りファイルをみて記憶する
- 参考情報があれば external-docs/ ディレクトリに保存する。 
- 外部リポジトリをクローンする場合は浅いクローンで明確に命名: `git clone --depth 1 <REPO_URL> external-docs/<REPO_NAME>`

# 自己レビュー

- 最後に、提出前のセルフレビューを行い、論理破綻やテスト失敗の可能性がないか点検してください。
- 問題が見つかったら修正し、再度レビューしてから回答を確定してください。

# 新しいルールの追加プロセス

ユーザーから今回限りではなく常に対応が必要だと思われる指示を受けた場合：

1. 「これを標準のルールにしますか？」と質問する
2. YESの回答を得た場合、CLAUDE.mdに追加ルールとして記載する
3. 以降は標準ルールとして常に適用する

このプロセスにより、プロジェクトのルールを継続的に改善していきます。

# 開発方針

- コードエクセレンス原則に基づきテスト駆動開発を必須で実施すること
- TDDおよびテスト駆動開発で実践する際は、全てt-wadaの推奨する進め方に従うこと
- 既存テストなど重要なものは勝手に削除することは禁止
- リファクタリングはMartin Fowlerが推奨する進め方に従うこと
- pwd コマンドで処理実行時にワーキングディレクトリを確かめる
- コードの修正が終わったら関連ドキュメントやテストも更新する事
- 主要クラスの冒頭に、設計ドキュメントへの参照と、関連クラスのメモを、コメントとしてつけること

## Testing Trophy + t-wada テスト手法

### Testing Trophy の実装指針
**静的解析（基盤層）**
- 型システムの厳格設定
- 静的解析ツールの推奨ルール適用
- 動的型の使用を避け、厳密な型定義を徹底
- インターフェース・スキーマ定義の明確化

**統合テスト（メイン層）**
- 実際のユーザー操作に近いテストシナリオ
- AAAパターン（Arrange→Act→Assert）の厳守
- システム間の連携を含むワークフローテスト
- 外部依存をモック化しつつ実用的な操作フローを検証

**ユニットテスト（最小限）**
- 純粋関数・ユーティリティ関数のみ
- ビジネスロジックから切り離された計算処理
- 外部依存のない独立した機能単位

**E2Eテスト（最小限）**
- 重要なユーザージャーニーのみ（主要な業務フロー）
- 自動化可能なテストツールを活用
- 安定したセレクタ・識別子を使用

### t-wada テスト手法の実装指針
**1. アサーションファースト**
- 期待する結果から先に定義
- 実装前にテストケースを明確化
- 仕様理解の深化を重視

**2. AAAパターンの厳守**
- Arrange: テストデータとモックの準備
- Act: テスト対象の実行
- Assert: 結果の検証
- 各セクションの明確な分離

**3. テスト独立性の保証**
- テスト間の状態共有禁止
- 実行順序に依存しない設計
- 各テストが完全に独立して動作

**4. Red-Green-Refactor サイクル**
- RED: 失敗するテストを先に書く
- GREEN: 最小限の実装でテストを通す
- REFACTOR: より良い実装にリファクタリング

### **NEVER**:絶対禁止事項
**NEVER** : テストエラーや型エラー解消のための条件緩和は禁止
**NEVER** : テストのスキップや不適切なモック化による回避は禁止
**NEVER** : 出力やレスポンスのハードコードは禁止
**NEVER** : エラーメッセージの無視や隠蔽は禁止
**NEVER** : 一時的な修正による問題の先送りは禁止

## Development & Commit Strategy

### Pre-Commit Requirements

**NEVER**: Before running `git commit`, you MUST always execute the following commands in order:

1. **Lint Check & Fix**:
   ```bash
   pnpm lint:fix
   ```

2. **Format Check & Fix**:
   ```bash
   pnpm format:fix
   ```

3. **Type Check**:
   ```bash
   pnpm typecheck
   ```

4. **Unit Tests**:
   ```bash
   pnpm test:run
   ```

5. **Integration Tests**:
   ```bash
   pnpm test:integration
   ```

Only proceed with `git commit` after all five commands pass without errors. This ensures code quality, prevents regressions, and prevents CI failures.

### Basic Commit Principles

Thoroughly enforce the following commit strategy during implementation:

#### 1. **Small and Frequent Commits**
- Base on one feature per commit
- Commit in working state
- Make rollback easy when problems occur

#### 2. **Commit with Tests as a Set**
- Commit implementation + tests as one set
- Maintain state where tests pass
- Commit test files simultaneously

#### 3. **Unified Commit Messages**
/commit コマンドに従う

#### 4. **Utilizing WIP (Work In Progress)**
- Commit with `wip: save work-in-progress state` even at intermediate stages
- Retain state during work interruption and resumption
- Modify to appropriate commit messages later

#### 5. **Recording Error Handling**
- Record problem-solving process with `fix:` commits
- Record error messages and stack traces
- Prevent recurrence of the same problems

### Examples of Commit Timing

#### Database Related
- [ ] Create migration files
- [ ] Add/modify model definitions
- [ ] Insert seed data

#### Feature Implementation
- [ ] Basic structure of service classes
- [ ] Implementation of each method (1 method per commit)
- [ ] Add validation and error handling

#### Test Implementation
- [ ] Add unit tests
- [ ] Add integration tests
- [ ] Add API tests

#### UI/API
- [ ] Route definition
- [ ] Endpoint implementation
- [ ] Frontend screen implementation

## Development Tools

### Using ripgrep (rg)

This project recommends ripgrep (`rg`) for high-speed code searching. Claude Code has ripgrep pre-installed, but if PATH is not configured, please use the following methods:

#### Absolute Path Usage (Current Recommended Method)
```bash
# Basic search
~/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg "searchterm" --type ts

# Search for leftJoin usage
~/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg "leftJoin" --type ts

# Search for dangerous patterns (for null safety audit)
~/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg "row\.\w+\.\w+" --type ts
~/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg "department\s*:\s*\{" --type ts
```

#### Alias Configuration (Optional)
To improve development efficiency, it's recommended to set the following alias:
```bash
# Add to ~/.bashrc or ~/.zshrc
alias rg='~/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg'
```

#### Benefits of ripgrep
- **Lightning-fast search**: Several times to dozens of times faster than grep
- **Smart filtering**: Search only TypeScript files with `--type ts`
- **Regex support**: Complex pattern matching possible
- **Clear output**: File names, line numbers, and matching locations are color-coded

#### Usage Examples
```bash
# Search for leftJoin usage in TypeScript files
rg "leftJoin" --type ts

# Search for dangerous patterns related to null safety
rg "row\.\w+\.\w+" --type ts -A 2 -B 2  # Also display 2 lines before and after

# Search for specific object generation patterns
rg "department\s*:\s*\{" --type ts
```

ripgrep is particularly powerful for identifying problem areas in **leftJoin null safety audits**

