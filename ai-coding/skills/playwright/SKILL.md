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

### Inline Execution（短いコード向け）

```bash
# ファイルを作らずに直接実行も可能
node "$SKILL_DIR/run.js" 'const browser = await chromium.launch({ headless: true }); const page = await browser.newPage(); await page.goto("http://localhost:3000"); console.log(await page.title()); await browser.close();'
```

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

### 5. リンク切れチェック

```javascript
const browser = await chromium.launch({ headless: true });
const context = await helpers.createContext(browser);
const page = await context.newPage();

await page.goto('http://localhost:3000');
await helpers.waitForPageReady(page);

const links = await page.$$eval('a[href]', anchors =>
  anchors.map(a => ({ text: a.textContent?.trim(), href: a.href }))
);

console.log(`Found ${links.length} links`);

for (const link of links) {
  try {
    const res = await page.request.head(link.href);
    if (res.status() >= 400) {
      console.log(`BROKEN [${res.status()}]: ${link.href} ("${link.text}")`);
    }
  } catch (e) {
    console.log(`ERROR: ${link.href} - ${e.message}`);
  }
}

await browser.close();
```

### 6. スクリーンショット撮影（単体）

```javascript
const browser = await chromium.launch({ headless: true });
const context = await helpers.createContext(browser);
const page = await context.newPage();

await page.goto('https://example.com');
await helpers.waitForPageReady(page);

// フルページスクリーンショット
await helpers.takeScreenshot(page, '/tmp/fullpage', { fullPage: true });

// 特定要素のスクリーンショット
const element = await page.$('h1');
if (element) {
  await element.screenshot({ path: '/tmp/element-screenshot.png' });
  console.log('Element screenshot saved');
}

await browser.close();
```

## Custom HTTP Headers

環境変数で全リクエストにカスタムヘッダーを付与できる:

```bash
# 単一ヘッダー
PW_HEADER_NAME="Authorization" PW_HEADER_VALUE="Bearer token123" node "$SKILL_DIR/run.js" /tmp/test.js

# 複数ヘッダー（JSON形式）
PW_EXTRA_HEADERS='{"Authorization":"Bearer token","X-Custom":"value"}' node "$SKILL_DIR/run.js" /tmp/test.js
```

`helpers.createContext()` を使えば自動で適用される。直接 `browser.newContext()` を使う場合は `getContextOptionsWithHeaders()` を呼ぶ。

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

## Troubleshooting

### ブラウザが起動しない
```bash
# Chromiumを再インストール
cd <skill-dir> && npx playwright install chromium
```

### モジュールが見つからない
```bash
# 依存関係を再インストール
cd <skill-dir> && npm install
```

### タイムアウトエラー
- `waitForPageReady` のtimeoutを延長: `{ timeout: 60000 }`
- `networkidle` の代わりに `load` や `domcontentloaded` を使う:
  ```javascript
  await helpers.waitForPageReady(page, { waitUntil: 'load' });
  ```

### WSL環境でのヘッドレスモード
WSL環境では `headless: true` が必須。GUIが必要な場合はWSLgまたはX11転送を設定すること。
