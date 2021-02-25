# castify-demo-ios

[Castify SDK](https://github.com/castify/castify-sdk-ios-beta) を利用してアプリから以下の機能を利用するサンプルです。

 - カメラ／マイクから入力した映像を Castify プラットフォーム上に配信
 - Castify 上のライブ／アーカイブの再生

準備
----

Castify から取得した API トークンを [AppDelegate.swift](./castify-demo-iOS/AppDelegate.swift) 下記の箇所に設定します。

```swift
let castifyApp = CastifyApp(token: <# Castify API Token #>)
```
