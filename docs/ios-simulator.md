# iOS Simulator 初期セットアップ

この手順は `m2` の macOS 環境で、stable Xcode と最新の stable iOS Simulator Runtime を使える状態にするためのもの。

## 前提

- `m2` が `workload.development` profile を有効にしていること
- Mac App Store に Apple Account でサインイン済みであること
- dotfiles を最新化していること

Xcode 本体は `applications.xcode` が Mac App Store 版を管理する。Simulator Runtime は Apple が管理する mutable state のため、Nix store には入れず専用 dev shell から導入する。

## 1. macOS 設定を反映する

リポジトリ直下で nix-darwin の設定を反映する。

```bash
sudo darwin-rebuild switch --flake .#m2
```

これにより `/Applications/Xcode.app` に stable Xcode がインストールされる。

Xcode のインストールで Mac App Store の認証エラーになる場合は、App Store を一度開いてサインイン状態を確認してから再実行する。

## 2. iOS Simulator Runtime を導入する

初回セットアップは次の1コマンドで行う。

```bash
nix develop .#ios -c ios-simulator-install
```

`ios-simulator-install` は次を順に実行する。

1. `/Applications/Xcode.app` が存在することを確認
2. `xcode-select` の Developer Directory を stable Xcode に切り替え
3. Xcode の first-launch components を導入
4. 利用可能な新しい hardware support components を確認
5. 選択中の Xcode に対応する最新の iOS Simulator Runtime をダウンロードしてインストール
6. Xcode のバージョンとインストール済み Simulator Runtime を表示

途中で `sudo` の認証を求められる場合がある。

## 3. インストールを確認する

```bash
xcodebuild -version
xcode-select -p
xcrun simctl list runtimes
xcrun simctl list devices available
```

`xcode-select -p` は次を指していること。

```text
/Applications/Xcode.app/Contents/Developer
```

`xcrun simctl list runtimes` に iOS runtime が表示されればセットアップ完了。

## 4. Simulator を起動する

```bash
open -a Simulator
```

Simulator の Device メニューから、インストール済み runtime で利用可能な iPhone を選択する。

## Runtime の更新

Xcode を stable の新しいバージョンへ更新した後は、同じコマンドを再実行する。

```bash
nix develop .#ios -c ios-simulator-install
```

Xcode の選択、first-launch components、hardware support、iOS Simulator Runtime の状態をまとめて更新できる。

## トラブルシューティング

### Xcode が見つからない

次のエラーが出る場合、先に nix-darwin の設定を反映する。

```text
Xcode is not installed at /Applications/Xcode.app.
```

```bash
sudo darwin-rebuild switch --flake .#m2
```

### Simulator Runtime が見えない

まず runtime 一覧を確認する。

```bash
xcrun simctl list runtimes
```

iOS runtime がない場合は再度インストーラーを実行する。

```bash
nix develop .#ios -c ios-simulator-install
```

### Command Line Tools 側を参照している

```bash
xcode-select -p
```

が `/Library/Developer/CommandLineTools` を指している場合でも、`ios-simulator-install` が `/Applications/Xcode.app/Contents/Developer` へ切り替える。

手動で直す場合は次を実行する。

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```
