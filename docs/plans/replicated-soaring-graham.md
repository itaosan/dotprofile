# Ring Meter ステータスライン統合プラン

## Context

現行の `statusline-detailed.sh` (bash, 357行) は emoji インジケータ (🟢🟡🟠🔴) + ccusage 3回呼び出しで表示中。
記事の Pattern 3 "Ring Meter" スタイルに切り替え、ccusage依存を最小化しつつ既存情報を維持する。

**方針転換**: コンテキストと使用率の実トークン数(used/MAX)は不要。パーセンテージのみ表示。
コストだけはccusageでしか取得できないため残す。

## 表示フォーマット（完成イメージ）

```
Opus 4.6  📁 dotprofile(main)  💵 $3.81/$42.15  ctx ◑ 47%  5h ◔ 1%  7d ◕ 85%  ⏱️ ~2h57m(15:47)
```

| # | セグメント | 表示例 | データソース | Ring Meter |
|---|---|---|---|---|
| 1 | モデル名 | `Opus 4.6` | stdin `model.display_name` | BOLD |
| 2 | プロジェクト | `📁 dotprofile(main)` | stdin + `git rev-parse` | - |
| 3 | コスト | `💵 $3.81/$42.15` | ccusage (session/monthly) | - |
| 4 | コンテキスト | `ctx ◑ 47%` | stdin `context_window.used_percentage` | ✅ |
| 5 | 5h使用率 | `5h ◔ 1%` | stdin `rate_limits.five_hour.used_percentage` | ✅ |
| 6 | 7d使用率 (NEW) | `7d ◕ 85%` | stdin `rate_limits.seven_day.used_percentage` | ✅ |
| 7 | リセット時刻 | `⏱️ ~2h57m(15:47)` | stdin `rate_limits.five_hour.resets_at` | - |

- Ring Meter: リング文字 `○◔◑◕●` + ANSI 24bitカラーグラデーション (緑→黄→赤)
- セグメント区切り: 2スペース
- 7d rate limitは `used_percentage` と `resets_at` のみ (APIヘッダ由来、実数値フィールドなし)

## データソース

### stdin (Claude Code JSON, v2.1.80+) ← メインデータソース
- `model.display_name`, `workspace.project_dir`, `cwd`
- `context_window.used_percentage`
- `rate_limits.five_hour.{used_percentage, resets_at}`
- `rate_limits.seven_day.{used_percentage, resets_at}`

### ccusage (コスト取得のみ、2回→2回維持)
- `npx ccusage blocks --json --active` → `costUSD` (セッションコスト)
- `npx ccusage monthly --json` → 月間コスト
- 2つのccusage呼び出しは `subprocess.Popen` で並行実行

### git
- `git rev-parse --abbrev-ref HEAD` → ブランチ名

**廃止されるもの:**
- ccusage からのトークン数取得 (totalTokens, assumed_limit 等)
- ccusage テキスト出力パース ("assuming X token limit")
- トークン実数表示 (94.0K/200.0K, 4.6M/66.2M)
- バーンレート/プロジェクション

## ファイル構成

| ファイル | 操作 |
|---|---|
| `/home/syu/dotprofile/ai-coding/claude/statusline.py` | **新規作成** (実体、旧.shを置き換え) |
| `~/.claude/statusline.py` | **シンボリックリンク** → 上記 |
| `/home/syu/dotprofile/ai-coding/claude/settings.json` | **変更** statusLine.command |
| `/home/syu/dotprofile/ai-coding/claude/statusline-detailed.sh` | **削除** |
| `~/.claude/statusline-detailed.sh` | **シンボリックリンク削除** |

## Python スクリプト構造

```python
# gradient(pct) → ANSI 24bit color (緑→赤)
# ring(pct) → リング文字
# fmt(label, pct) → "ctx ◑ 47%"
# fmt_reset(resets_at) → "⏱️ ~2h57m(15:47)"
# fetch_ccusage() → blocks + monthly 並行取得 (コストのみ)
# main() → stdin読込 → ccusage取得 → 整形 → stdout
```

## エラーハンドリング (第5原則準拠)

- stdin 不正/ccusage 失敗/タイムアウト → `sys.stderr.write` + `sys.exit(1)`
- **フォールバック値は使わない**
- `rate_limits` フィールド不在は「データ未提供」として該当セグメントを非表示 (エラーではない)

## 実装手順

1. `statusline.py` を新規作成 (全ロジック一本化)
2. 旧 `statusline-detailed.sh` と シンボリックリンクを削除
3. 新 シンボリックリンク作成 + `chmod +x`
4. `settings.json` 変更: `"command": "python3 ~/.claude/statusline.py"`
5. Claude Code再起動で実環境動作確認
