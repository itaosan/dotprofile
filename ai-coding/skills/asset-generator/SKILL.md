---
name: asset-generator
description: Gemini画像生成APIでWebアセットを生成。アイコン、バナー、サムネイル、OGP画像などが必要な時に使用。「画像を作って」「アイコンが欲しい」「バナーを生成」「ロゴを作成」などの要求で自動起動。
allowed-tools: Bash(uv:*), Read, Write
---

# Vibe Asset Generator

Gemini 2.0 Flash (画像生成) を使用してWeb開発用の画像アセットを生成するスキルです。

## 使用方法

画像生成スクリプトを実行:

```bash
uv run --script ~/.claude/skills/asset-generator/scripts/generate_image.py -- \
  --prompt "プロンプト" \
  --output ./出力パス.png \
  --aspect-ratio アスペクト比
```

## オプション

| オプション | 短縮 | 説明 | デフォルト |
|-----------|------|------|-----------|
| `--prompt` | `-p` | 画像生成プロンプト（必須） | - |
| `--output` | `-o` | 出力ファイルパス（必須） | - |
| `--aspect-ratio` | `-a` | アスペクト比 | `1:1` |
| `--model` | `-m` | 使用モデル | `gemini-2.0-flash-preview-image-generation` |

## アスペクト比ガイド

| 用途 | 推奨アスペクト比 |
|------|-----------------|
| アイコン、favicon、プロフィール | `1:1` |
| バナー、ヘッダー、OGP画像 | `16:9` |
| ストーリー、モバイル向け | `9:16` |
| サムネイル（標準） | `4:3` |
| ポートレート画像 | `3:4` |

## プロンプトのコツ

### 効果的なプロンプト作成

1. **スタイル指定**: flat design, minimalist, 3D, isometric, watercolor など
2. **色指定**: blue and white, vibrant colors, pastel など
3. **背景指定**: transparent background, white background, gradient background
4. **用途明示**: icon, logo, banner, illustration など

### プロンプト例

```bash
# アプリアイコン
uv run --script ~/.claude/skills/asset-generator/scripts/generate_image.py -- \
  -p "a minimalist app icon, blue gradient circle with white lightning bolt, flat design" \
  -o ./icon.png

# Webサイトバナー
uv run --script ~/.claude/skills/asset-generator/scripts/generate_image.py -- \
  -p "modern tech website hero banner, abstract geometric shapes, purple and blue gradient" \
  -o ./banner.png -a 16:9

# OGP画像
uv run --script ~/.claude/skills/asset-generator/scripts/generate_image.py -- \
  -p "blog post OGP image about AI technology, futuristic design, dark background with glowing elements" \
  -o ./ogp.png -a 16:9

# プロフィールアバター
uv run --script ~/.claude/skills/asset-generator/scripts/generate_image.py -- \
  -p "cute cartoon avatar, friendly developer character, simple illustration style" \
  -o ./avatar.png
```

## セットアップ

APIキーを `~/.gemini/config` に設定:

```json
{
  "api_key": "YOUR_GEMINI_API_KEY"
}
```

または環境変数 `GEMINI_API_KEY` を設定。

APIキーは [Google AI Studio](https://aistudio.google.com/apikey) で取得できます。

## 注意事項

- 生成される画像はPNG形式
- API制限に注意（レート制限あり）
- 著作権のあるキャラクター等は生成できない場合あり
