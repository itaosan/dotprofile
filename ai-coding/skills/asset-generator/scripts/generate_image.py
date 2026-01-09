# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "google-genai>=1.0.0",
# ]
# ///
"""
Asset Generator - Gemini画像生成スクリプト

Gemini 3 Pro Image (Nano Banana Pro) を使用してWeb開発用アセットを生成します。
"""

import argparse
import base64
import json
import os
import sys
from pathlib import Path

from google import genai
from google.genai import types


def load_api_key() -> str:
    """APIキーを読み込む（設定ファイル優先、環境変数フォールバック）"""
    config_path = Path.home() / ".gemini" / "config"

    if config_path.exists():
        try:
            with open(config_path) as f:
                config = json.load(f)
                if "api_key" in config:
                    return config["api_key"]
        except (json.JSONDecodeError, IOError) as e:
            print(f"警告: 設定ファイルの読み込みに失敗しました: {e}", file=sys.stderr)

    api_key = os.environ.get("GEMINI_API_KEY")
    if api_key:
        return api_key

    print("エラー: APIキーが見つかりません", file=sys.stderr)
    print("以下のいずれかの方法でAPIキーを設定してください:", file=sys.stderr)
    print("  1. ~/.gemini/config ファイルに {\"api_key\": \"YOUR_KEY\"} を設定", file=sys.stderr)
    print("  2. 環境変数 GEMINI_API_KEY を設定", file=sys.stderr)
    sys.exit(1)


def generate_image(
    prompt: str,
    output_path: str,
    model: str = "gemini-2.0-flash-preview-image-generation",
    aspect_ratio: str = "1:1",
) -> None:
    """Gemini APIで画像を生成して保存"""
    api_key = load_api_key()

    client = genai.Client(api_key=api_key)

    print(f"画像を生成中: {prompt[:50]}{'...' if len(prompt) > 50 else ''}")

    try:
        response = client.models.generate_content(
            model=model,
            contents=prompt,
            config=types.GenerateContentConfig(
                response_modalities=["IMAGE", "TEXT"],
                image_generation_config=types.ImageGenerationConfig(
                    aspect_ratio=aspect_ratio,
                ),
            ),
        )

        if not response.candidates:
            print("エラー: 画像生成に失敗しました（レスポンスが空）", file=sys.stderr)
            sys.exit(1)

        image_saved = False
        for part in response.candidates[0].content.parts:
            if part.inline_data is not None:
                image_data = part.inline_data.data
                mime_type = part.inline_data.mime_type

                output = Path(output_path)
                output.parent.mkdir(parents=True, exist_ok=True)

                with open(output, "wb") as f:
                    f.write(image_data)

                print(f"画像を保存しました: {output}")
                print(f"  MIME Type: {mime_type}")
                print(f"  サイズ: {len(image_data):,} bytes")
                image_saved = True
                break

        if not image_saved:
            print("エラー: レスポンスに画像データが含まれていません", file=sys.stderr)
            for part in response.candidates[0].content.parts:
                if part.text:
                    print(f"テキストレスポンス: {part.text}", file=sys.stderr)
            sys.exit(1)

    except Exception as e:
        error_msg = str(e)
        if "RESOURCE_EXHAUSTED" in error_msg or "429" in error_msg:
            print("エラー: API制限に達しました。しばらく待ってから再試行してください。", file=sys.stderr)
        elif "INVALID_ARGUMENT" in error_msg or "400" in error_msg:
            print(f"エラー: 無効なリクエストです: {error_msg}", file=sys.stderr)
        elif "PERMISSION_DENIED" in error_msg or "403" in error_msg:
            print("エラー: APIキーが無効または権限がありません。", file=sys.stderr)
        else:
            print(f"エラー: 画像生成に失敗しました: {error_msg}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Gemini APIで画像アセットを生成",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用例:
  uv run --script %(prog)s -- --prompt "a cute cat icon" --output ./cat.png
  uv run --script %(prog)s -- --prompt "website banner" --output ./banner.png --aspect-ratio 16:9

アスペクト比:
  1:1   - 正方形（アイコン、プロフィール画像）
  16:9  - 横長（バナー、OGP画像）
  9:16  - 縦長（ストーリー、モバイル向け）
  4:3   - 標準横長
  3:4   - 標準縦長
        """,
    )
    parser.add_argument(
        "--prompt", "-p",
        required=True,
        help="画像生成プロンプト",
    )
    parser.add_argument(
        "--output", "-o",
        required=True,
        help="出力ファイルパス",
    )
    parser.add_argument(
        "--model", "-m",
        default="gemini-2.0-flash-preview-image-generation",
        help="使用するモデル（デフォルト: gemini-2.0-flash-preview-image-generation）",
    )
    parser.add_argument(
        "--aspect-ratio", "-a",
        default="1:1",
        choices=["1:1", "16:9", "9:16", "4:3", "3:4"],
        help="アスペクト比（デフォルト: 1:1）",
    )

    args = parser.parse_args()

    generate_image(
        prompt=args.prompt,
        output_path=args.output,
        model=args.model,
        aspect_ratio=args.aspect_ratio,
    )


if __name__ == "__main__":
    main()
