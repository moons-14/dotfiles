# AGENTS.md

NixOS + Home Manager flake。v2 リセット中 — flake-parts 導入済み、outputs はまだスケルトンのみ。

## Commands

```sh
# flake の更新
nix flake update

# フォーマット
nix fmt
```

## Conventions

- User: `moons`, locale: `ja_JP.UTF-8`, timezone: `Asia/Tokyo`
- Commits: conventional commits (`feat:`, `chore:`, `fix:`, etc.)
- リモート: `git@github.com:moons-14/dotfiles.git`
- `modules/system/` や `modules/applications/` に新しいファイルを追加した際は、必ず同ディレクトリの `default.nix` の `imports` に追加する
- `environment.systemPackages` にパッケージを追加する際は、パッケージ名の横に簡単な説明をコメントで追加する

## Module Structure

### `modules/system/`

システムレベル（NixOS）の設定。OS 全体に影響する設定を配置する。

- 例: boot, hardware, network, user, locale, fonts, power, secure-boot, caches, gc, version

### `modules/applications/`

アプリケーション固有の設定。ユーザーが個別に有効/無効を切り替えたいアプリケーションを配置する。

- 例: niri, noctalia, greetd, fcitx5, kde, wayland

### Module Pattern

`modules/system/` と `modules/applications/` のモジュールは、デフォルトで `config.my.*` namespace で有効/無効を切り替えられる仕組みにする。

#### Simple Module (NixOS のみ)

home-manager の設定を含まないモジュール:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.my.<category>.<name>;
in
{
  options.my.<category>.<name> = {
    enable = lib.mkEnableOption "<description>";
  };

  config = lib.mkIf cfg.enable {
    # configuration here
  };
}
```

- `my.system.*` — system モジュール用
- `my.applications.*` — applications モジュール用

#### Complex Module (NixOS + Home Manager)

home-manager の設定も含むモジュールは3つのフラグを設定する:

```
modules/applications/<app>/
├── default.nix    # my.applications.<app>.enable (マスター)
├── system.nix     # my.applications.<app>.system.enable
├── home.nix       # my.applications.<app>.homeManager.enable
└── (other files)  # 設定ファイル等
```

`default.nix`:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.<name>;
in
{
  options.my.applications.<name> = {
    enable = lib.mkEnableOption "<description>";
    system.enable = lib.mkEnableOption "<description> system configuration";
    homeManager.enable = lib.mkEnableOption "<description> home-manager configuration";
  };

  imports = [
    ./system.nix
    ./home.nix
  ];

  config = lib.mkIf cfg.enable {
    my.applications.<name>.system.enable = lib.mkDefault true;
    my.applications.<name>.homeManager.enable = lib.mkDefault true;
  };
}
```

マスターの `enable` を有効にすると、`lib.mkDefault` で system と homeManager の両方が有効化される。個別に無効化も可能。
