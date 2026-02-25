---
name: playwright
description: |
  Playwrightによるブラウザ自動化スキル。ページテスト、フォーム入力、スクリーンショット撮影、レスポンシブ確認、UX検証などを実行する。
  トリガー: "playwright", "ブラウザテスト", "E2Eテスト", "スクリーンショット撮影", "画面テスト", "ページ検証"
  使用場面: (1) 開発中のページ動作確認、(2) フォーム・ログインフローのテスト、(3) レスポンシブデザイン確認、(4) リンク切れチェック、(5) スクリーンショットによるエビデンス収集
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
---

# Playwright Browser Automation

Playwrightを使ったブラウザ自動化を実行するスキル。
スクリプトを `/tmp/` に書き出し、`run.js` で実行する。

## Critical Workflow

1. **dev serverの検出**: 実行中のサーバーを自動検出する
2. **スクリプト作成**: `/tmp/playwright-test-*.js` にスクリプトを書き出す
3. **実行**: `node <skill-dir>/run.js /tmp/playwright-test-*.js` で実行
4. **結果確認**: コンソール出力とスクリーンショットで結果を確認

## Execution Pattern

```bash
# スキルディレクトリのパスを取得
SKILL_DIR="$(dirname "$(find ~/.claude -path '*/skills/playwright/run.js' -o -path '*/ai-coding/skills/playwright/run.js' 2>/dev/null | head -1)")"

# スクリプトを /tmp に書き出して実行
node "$SKILL_DIR/run.js" /tmp/playwright-test-XXXX.js
```

**重要**: スクリプトは必ず `/tmp/` に書き出すこと。スキルディレクトリには書き込まない。

## Common Patterns

### 1. ページテスト

```javascript
const browser = await chromium.launch({ headless: true });
const context = await helpers.createContext(browser);
const page = await context.newPage();

await page.goto('http://localhost:3000');
await helpers.waitForPageReady(page);

console.log('Title:', await page.title());

const screenshot = await helpers.takeScreenshot(page, 'homepage');
console.log('Screenshot:', screenshot);

await browser.close();
```

### 2. フォーム入力

```javascript
const browser = await chromium.launch({ headless: true });
const context = await helpers.createContext(browser);
const page = await context.newPage();

await page.goto('http://localhost:3000/form');
await page.fill('input[name="email"]', 'test@example.com');
await page.fill('input[name="password"]', 'password123');
await page.click('button[type="submit"]');
await page.waitForNavigation();

console.log('Current URL:', page.url());
await helpers.takeScreenshot(page, 'after-submit');
await browser.close();
```

### 3. レスポンシブ確認

```javascript
const browser = await chromium.launch({ headless: true });
const viewports = [
  { name: 'mobile', width: 375, height: 667 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1280, height: 720 }
];

for (const vp of viewports) {
  const context = await browser.newContext({ viewport: { width: vp.width, height: vp.height } });
  const page = await context.newPage();
  await page.goto('http://localhost:3000');
  await helpers.waitForPageReady(page);
  await helpers.takeScreenshot(page, `responsive-${vp.name}`);
  await context.close();
}

await browser.close();
```

### 4. Dev Server自動検出

```javascript
const servers = await helpers.detectDevServers();
if (servers.length === 0) {
  console.error('No dev server found');
  process.exit(1);
}

const browser = await chromium.launch({ headless: true });
const context = await helpers.createContext(browser);
const page = await context.newPage();

await page.goto(servers[0]);
await helpers.waitForPageReady(page);
console.log('Testing:', servers[0]);
console.log('Title:', await page.title());

await helpers.takeScreenshot(page, 'dev-server');
await browser.close();
```

## Available Helpers

`helpers` オブジェクトで以下が利用可能:

| Helper | 説明 |
|--------|------|
| `launchBrowser(type, opts)` | ブラウザ起動（chromium/firefox/webkit） |
| `createContext(browser, opts)` | コンテキスト作成（viewport, locale等） |
| `waitForPageReady(page, opts)` | ページ読み込み完了待ち |
| `takeScreenshot(page, name, opts)` | タイムスタンプ付きスクリーンショット |
| `detectDevServers(ports)` | ローカルdev server自動検出 |
| `extractTexts(page, selector)` | 要素群からテキスト抽出 |
| `extractTableData(page, selector)` | テーブルデータ構造化抽出 |

## Setup

初回実行時に自動インストールされる。手動セットアップが必要な場合:

```bash
cd <skill-dir> && npm run setup
```

## Tips

- `headless: true` がデフォルト（CI/ヘッドレス環境向け）
- `HEADLESS=false` 環境変数でブラウザを表示可能
- スクリーンショットはカレントディレクトリに保存される
- 認証が必要なページではcookieやlocalStorageのセットアップが必要
- 詳細なAPIリファレンスは `API_REFERENCE.md` を参照
