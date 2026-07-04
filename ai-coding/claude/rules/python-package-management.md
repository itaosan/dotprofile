---
paths:
  - "**/*.py"
  - "pyproject.toml"
  - "uv.lock"
  - "requirements*.txt"
---

Python依存関係、仮想環境、Python実行方法を扱うときは `python-package-management` Skill を使う。

この rule は対象ファイルで Skill の使用を促すための入口に留める。
決定的な禁止は `hooks/block-unsafe-bash.sh` で扱う。
