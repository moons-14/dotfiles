# moons14 dotfiles

My NixOS + Home Manager configurations build with flake.

## Ubuntuなど、Nixを入れていないLinuxでNeovimを使う

このリポジトリのNixvim設定・Neovim本体・プラグイン・LSP・フォーマッタをまとめた実行ファイルを配布します。Ubuntu側にNixやHome Managerをインストールする必要はありません。`sudo`も初回の前提パッケージ導入以外は不要です。

対応CPUは`x86_64`（Intel/AMD 64bit）と`aarch64`（ARM64）です。Ubuntu 24.04のNix未導入コンテナで、一般ユーザーとして初回起動・設定と依存ツールの読み込みをテストします。

### 初回導入

Ubuntuで`curl`がなければ導入します。

```sh
sudo apt update
sudo apt install curl ca-certificates coreutils
```

最新の配布物をインストールします。

```sh
curl -fL --retry 3 \
  https://github.com/moons-14/dotfiles/releases/download/nvim-portable/install-moons-nvim.sh \
  -o install-moons-nvim.sh
sh ./install-moons-nvim.sh
```

インストーラーはCPUを判別し、実行ファイルとSHA-256チェックサムを取得して検証した後、`~/.local/bin/moons-nvim`に配置します。既存の`nvim`や`~/.config/nvim`を書き換えません。

```sh
export PATH="$HOME/.local/bin:$PATH"
moons-nvim example.ts
```

`~/.local/bin`がPATHに含まれていない場合は、上の`export`を`~/.bashrc`や`~/.zshrc`にも追加してください。絶対パスの`~/.local/bin/moons-nvim`でも起動できます。

初回起動時は、同梱したランタイムと依存ファイルを`~/.nix-portable`に展開するため時間とディスク容量が必要です。2回目以降は展開済みファイルを再利用します。内部にNixの実行環境を含みますが、システムへのNix導入・デーモン設定は不要です。

### 更新

初回導入と同じコマンドで、インストーラーを取得し直して実行します。

```sh
curl -fL --retry 3 \
  https://github.com/moons-14/dotfiles/releases/download/nvim-portable/install-moons-nvim.sh \
  -o install-moons-nvim.sh
sh ./install-moons-nvim.sh
```

検証済みの新しい実行ファイルに置き換え、直前の実行ファイルを`~/.local/bin/moons-nvim.previous`に残します。ダウンロードやチェックサム検証に失敗した場合、現在の実行ファイルは維持されます。起動中のNeovimは終了してから更新し、更新後に起動し直してください。更新しても、古い依存ファイルがキャッシュに残る場合があります。

設定の更新は、Vim設定や`flake.lock`などの対象ファイルの変更が`main`に入ると自動ビルド・検証されます。両CPUの検証に成功した後、`nvim-portable`リリースが更新されます。Ubuntu側への反映は、上の更新コマンドを実行した時点です。

### 前の版に戻す・特定の版を使う

直前の実行ファイルに戻すには、Neovimを終了してから実行します。

```sh
mv "$HOME/.local/bin/moons-nvim.previous" "$HOME/.local/bin/moons-nvim"
```

成功したビルドは`nvim-<40桁のコミットSHA>`というリリースにも保存します。[Releases](https://github.com/moons-14/dotfiles/releases)から使いたい版のタグを確認し、インストーラーの引数に指定できます。

```sh
# <commit-sha>を使用したい版の40桁のコミットSHAに置き換える
sh ./install-moons-nvim.sh "nvim-<commit-sha>"
```

### 補足

- Copilot・WakaTimeなどの認証情報は含まれません。利用する機能に応じて別途認証してください。これらのオンライン機能はネットワーク接続を必要とします。
- アイコンを表示するNerd Fontは、利用する端末側に設定してください。SSHの場合は接続元のターミナルのフォントです。
- プロジェクト固有の依存・設定や、Gitのユーザー名・SSH鍵などは別途用意します。
- 全LSPやRustツールチェーンを含むため、配布物と展開後のサイズは大きくなります。
- ランタイムを自動判定できない環境では、`NP_RUNTIME=proot moons-nvim`を試せます。`proot`では処理によって速度が落ちます。コンテナなどでUser Namespaceと`ptrace`の両方が禁止されている場合は動作しません。
- 別の場所へ導入する場合は、`MOONS_NVIM_INSTALL_DIR=/path/to/bin sh ./install-moons-nvim.sh`を使えます。

## Neovimのビルド・配布を変更する

共通設定は[`modules/applications/vim/config.nix`](modules/applications/vim/config.nix)から読み込みます。Home Managerと単体パッケージは同じ設定を使います。`home.nix`はHome Manager側の有効化と環境変数を担当します。

Nix導入済みのビルド環境では以下を実行できます。

```sh
# 設定済みNeovim
nix run .#nvim

# Linux用の自己展開型バンドル（result/bin/nvim）
nix build .#nvim-portable

# インストーラーの更新失敗・バックアップ処理のテスト
python3 tests/portable-nvim-installer.py
```

[`Build: Portable Neovim`](.github/workflows/nvim-portable.yaml)は、対象ファイルの変更があるPRではビルド・検証のみを行い、`main`へのpushでは成功後にReleasesへ公開します。GitHubのActions画面から手動実行もできます。公開する場合は`main`を選んでください。リリース作成には標準の`GITHUB_TOKEN`の`contents: write`権限を使用し、追加のシークレットは不要です。初回の公開は、ワークフローを`main`へ取り込んだ後の成功時に行われます。
