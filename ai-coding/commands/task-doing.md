# Taskを順次こなす

$ARGUMENTS で指定されたmdファイル。 $ARGUMENTS が無い場合は task.mdに記載された依頼項目を順次実装する

- タスクの1項目毎にsubagentsを使い、Planを立て、その後そのPlanをsubagentsに投げて実装させる
- 実装が終わったらcoderabbit --prompt-onlyをバックグラウンドタスクで実行してレビューを受け、妥当な指摘に対しては修正すること
- 実装が終わったら項目に済マークを付ける
