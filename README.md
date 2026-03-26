# ProfileSample

SwiftUI の宣言的 UI を学習するための iOS サンプルアプリです。

## 機能

### プロフィール編集
- 氏名・メールアドレス・自己紹介の編集
- プッシュ通知・公開プロフィールのトグル設定
- ダークテーマの UI

### ぷよぷよゲーム
- 13 × 6 のボードで遊べるぷよぷよ風パズルゲーム
- 4 個以上つながると消滅、連鎖ボーナスあり
- 左移動・右移動・時計回り回転・反時計回り回転・ハードドロップの操作に対応

## 動作環境

| 項目 | 内容 |
|------|------|
| Xcode | 26.3 |
| iOS | 26.2+ |
| Swift | 5.0 |
| デバイス | iPhone / iPad |

## ビルド方法

```bash
# Debug ビルド
xcodebuild -project ProfileSample.xcodeproj -scheme ProfileSample -configuration Debug

# シミュレータ向けビルド
xcodebuild -project ProfileSample.xcodeproj -scheme ProfileSample -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Release ビルド
xcodebuild -project ProfileSample.xcodeproj -scheme ProfileSample -configuration Release
```

## プロジェクト構成

```
ProfileSample/
├── ProfileSampleApp.swift   # @main エントリーポイント
├── ContentView.swift        # ルートビュー（ホーム画面）
├── ProfileEditView.swift    # プロフィール編集画面
└── PuyoPuyoGameView.swift   # ぷよぷよゲーム画面
```

## アーキテクチャ

- **UI フレームワーク**: SwiftUI
- **状態管理**: `@State` / `@Binding` / `@StateObject` / `@Published`
- **ナビゲーション**: `NavigationStack` + `NavigationPath`
- **デフォルトアクター分離**: `@MainActor`（`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`）
