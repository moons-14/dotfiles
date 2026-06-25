# AGENTS.md

NixOS + Home Manager flake (v2)。flake-parts ベース。

## Commands

```sh
nix flake update          # flake の更新
nix fmt                   # フォーマット (treefmt: nixfmt, deadnix, statix, shfmt, shellcheck, prettier, yamlfmt, taplo, oxfmt)
nix develop .#dotnix      # 開発シェル (pre-commit hooks, sops, age 入り)
sudo nixos-rebuild build --flake .#<host>  # ビルド確認
sudo nixos-rebuild switch --flake .#<host> # 適用
```

## Conventions

- User: `moons`, locale: `ja_JP.UTF-8`, timezone: `Asia/Tokyo`
- Commits: conventional commits (`feat:`, `chore:`, `fix:`, etc.)
- リモート: `git@github.com:moons-14/dotfiles.git`
- `environment.systemPackages` にパッケージを追加する際はパッケージ名の横に簡単な説明をコメントで追加する
- 警告を抑制する設定は書かない。根本原因を調査して修正する
- home-manager の `sharedModules` 内で `lib.hm.*` を使う場合は、そのモジュール関数の引数で `lib` を受け取る必要がある（NixOSモジュールの `lib` とは別スコープ）
- `useGlobalPkgs = true` なので、home-manager 内で `nixpkgs.config` を設定しない（NixOSレベルで一括設定）
- `allowUnfree` は `hosts/default.nix` でグローバルに設定済み。各モジュールで個別設定しない
- pre-commit hooks が `git-hooks.nix` で設定済み（treefmt, gitleaks, deadnix, statix, shellcheck）。dev shell で自動有効化

## Secrets

- **sops-nix** + **age** + **YubiKey** で秘密管理
- `.sops.yaml` で暗号化ルール定義、`secrets/` に暗号化済み YAML を配置
- `modules/system/sops.nix` で sops-nix を import、`services.pcscd` (YubiKey用) を有効化
- `modules/system/secret.nix` で `sops.secrets` を宣言
- 平文の秘密をコミットしない（gitleaks が pre-commit で検出）

## Architecture

```
flake.nix
├── hosts/default.nix          # mkSystem でホスト構成を生成
│   ├── modules/               # 全モジュール（常にインポートされる）
│   │   ├── applications/      # アプリケーション設定
│   │   ├── system/            # システム設定
│   │   ├── drivers/           # ドライバ設定
│   │   ├── features/          # 機能バンドル（application/systemを束ねる）
│   │   └── integrations/      # home-manager 統合
│   └── profiles/              # ホストごとに有効化するfeaturesの組み合わせ
│       ├── interfaces/        # 操作インターフェース (CLI/GUI)
│       ├── platforms/         # ハードウェア (desktop/laptop/thinkpad/vm)
│       └── workloads/         # 用途 (dev/personal/srv/remote/secure-storage)
├── overlays/                  # nixpkgs オーバーレイ
├── shells/                    # devShells (dotnix)
└── flake/                     # formatter.nix, git-hooks.nix
```

### 評価の流れ

```
profile (featuresの有効化)
  → features (application/systemの有効化 + パッケージ追加)
    → applications (system.nix + home.nix)
    → system (NixOS設定)
```

## Layer Design

### `modules/system/` — NixOS システム設定

OS全体に影響する設定。`config.my.system.*` namespace。

- audio, boot, camera, disko, fingerprint, fonts, gc, hardware, locale, network, nix, power, secure-boot, sops, user, version, secret
- 常にインポートされるが、`enable` オプションで実効性を制御
- home-manager の設定は含めない

### `modules/applications/` — アプリケーション設定

個別に有効/無効を切り替えたいアプリケーション。`config.my.applications.*` namespace。

- NixOS設定のみ、または NixOS + Home Manager の両方
- Complex Module は system.nix と home.nix に分離

### `modules/drivers/` — ドライバ設定

ハードウェア固有のドライバ。`config.my.drivers.*` namespace。

### `modules/features/` — 機能バンドル

application や system より抽象度の高い「機能」単位で、複数の application/system を束ねて有効化する層。`config.my.features.*` namespace。

**features がやること:**

1. 複数の `my.applications.*.enable` / `my.system.*.enable` をまとめて有効化
2. application/system に属さないパッケージや設定を直接記述（`environment.systemPackages`、`home.activation` 等）
3. 追加オプションの受け渡し（例: tailscale の `acceptDns` を feature から application に passthrough）

**features がやらないこと:**

- 個別アプリケーションの詳細設定（これは applications 層の責務）

### `profiles/` — ホスト構成

features の `enable` を指定するだけの薄い層。ロジックは書かない。
`profiles/` から `my.system.*.enable` / `my.applications.*.enable` を直接指定しない。
必要な場合は必ず `modules/features/` に feature 層を作り、profile では `my.features.*.enable` のみ指定する。

| カテゴリ      | 役割                 | 例                                         |
| ------------- | -------------------- | ------------------------------------------ |
| `interfaces/` | 操作インターフェース | cli-minimal, cli-interactive, gui          |
| `platforms/`  | ハードウェア固有設定 | desktop, laptop, thinkpad, vm              |
| `workloads/`  | 用途・ワークロード   | dev, personal, srv, remote, secure-storage |

profiles は継承可能:

```nix
# cli-interactive.nix
{
  imports = [ ./cli-minimal.nix ];
  my.features.cli.interactive.enable = true;
}
```

### `hosts/` — ホスト定義

`mkSystem` でホストを定義。profiles のリストを指定:

```nix
nix-example = mkSystem {
  host = "nix-example";
  system = "x86_64-linux";
  profiles = [
    "interfaces/cli-interactive"
    "platforms/vm"
    "workloads/dev"
  ];
};
```

`specialArgs` で `inputs`, `username`, `unstable`, `host` が全モジュールに渡される。

**注意:** `installer` ホストは `mkSystem` を使わず直接 `nixosSystem` で定義（インストーラ用）。

## Module Patterns

### Simple Module（NixOS のみ）

home-manager の設定を含まない。1ファイルで完結:

```nix
# modules/system/audio.nix
{ lib, config, ... }:
let
  cfg = config.my.system.audio;
in
{
  options.my.system.audio = {
    enable = lib.mkEnableOption "Audio support (PipeWire)";
  };

  config = lib.mkIf cfg.enable {
    # NixOS設定をここに書く
  };
}
```

### Simple Module（Home Manager のみ）

NixOS設定を含まず、home-manager のみ:

```nix
# modules/applications/zoom.nix
{ pkgs, lib, config, ... }:
let
  cfg = config.my.applications.zoom;
in
{
  options.my.applications.zoom = {
    enable = lib.mkEnableOption "Zoom video conferencing";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          zoom-us # Video conferencing application
        ];
      }
    ];
  };
}
```

### Complex Module（NixOS + Home Manager）

ディレクトリ構造で system と home を分離:

```
modules/applications/<app>/
├── default.nix    # マスター enable + imports
├── system.nix     # NixOS 設定
├── home.nix       # Home Manager 設定
└── (other files)  # 設定ファイル等
```

**default.nix** — `enable` のみ宣言。`system.enable`/`homeManager.enable` は sub-file に任せる:

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
  imports = [
    ./home.nix
    ./system.nix
  ];

  options.my.applications.<name> = {
    enable = lib.mkEnableOption "<description>";
  };

  config = lib.mkIf cfg.enable {
    my.applications.<name>.system.enable = lib.mkDefault true;
    my.applications.<name>.homeManager.enable = lib.mkDefault true;
  };
}
```

**system.nix:**

```nix
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.<name>.system;
in
{
  options.my.applications.<name>.system = {
    enable = lib.mkEnableOption "<name> system configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      <package> # Description
    ];
  };
}
```

**home.nix** — `home-manager.sharedModules` を使用:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.<name>;
  hmCfg = config.my.applications.<name>.homeManager;
in
{
  options.my.applications.<name>.homeManager = {
    enable = lib.mkEnableOption "<name> home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf hmCfg.enable {
        # home-manager 設定をここに書く
      };
    }
  ];
}
```

**注意点:**

- `default.nix` では `enable` のみ宣言。`system.enable`/`homeManager.enable` は `system.nix`/`home.nix` で宣言する（重複宣言エラー回避）
- home.nix で親の `cfg` を参照する場合は `cfg` と `hmCfg` の両方を let で定義
- Complex Module の home-manager 設定は `home-manager.sharedModules` で記述（`home-manager.users.<user>` は使わない）

### Feature Module

**application/system を束ねる場合:**

```nix
# modules/features/services/container.nix
{ lib, config, ... }:
let
  cfg = config.my.features.services.container;
in
{
  options.my.features.services.container = {
    enable = lib.mkEnableOption "Container runtime (Docker)";
  };

  config = lib.mkIf cfg.enable {
    my.applications.docker.enable = true;
  };
}
```

**パッケージを直接追加する場合（application/system に属さない）:**

```nix
# modules/features/gui/capture.nix
{ pkgs, lib, config, ... }:
let
  cfg = config.my.features.gui.capture;
in
{
  options.my.features.gui.capture = {
    enable = lib.mkEnableOption "Screen capture tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      slurp # Tool for selecting a region of the screen
      grim # Screenshot tool for Wayland
    ];
  };
}
```

**オプションを passthrough する場合:**

```nix
# modules/features/network/tailscale.nix
{
  options.my.features.network.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
    acceptDns = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = lib.mkIf cfg.enable {
    my.applications.tailscale = {
      enable = true;
      inherit (cfg) acceptDns;
    };
  };
}
```

**home.activation を使う場合（identity 等）:**

```nix
# modules/features/identity/ssh-default-key.nix
config.home-manager.sharedModules = [
  (
    { lib, ... }:
    {
      config = lib.mkIf cfg.enable {
        home.activation.generateSshKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # shell script here
        '';
      };
    }
  )
];
```

### Profile

features の有効化のみを記述:

```nix
# profiles/platforms/laptop.nix
{
  my.features = {
    boot.power.enable = true;
    connect = {
      wifi.enable = true;
      bluetooth.enable = true;
    };
    gui.camera.enable = true;
    identity.fingerprint.enable = true;
    network.tailscale.enable = true;
  };
}
```

## Adding New Features — Checklist

### 新しいアプリケーションを追加する場合

1. `modules/applications/` にモジュール作成（Simple or Complex）
2. `modules/applications/default.nix` の `imports` に追加
3. `modules/features/` の適切なカテゴリに feature を作成（既存の feature に追記でも可）
4. `modules/features/<category>/default.nix` の `imports` に追加
5. `profiles/` の適切な profile で feature を有効化

### 新しいシステム設定を追加する場合

1. `modules/system/` にモジュール作成（Simple Module）
2. `modules/system/default.nix` の `imports` に追加
3. `modules/features/` の適切なカテゴリに feature を作成
4. `modules/features/<category>/default.nix` の `imports` に追加
5. `profiles/` の適切な profile で feature を有効化

### 新しいホストを追加する場合

1. `hosts/<hostname>/default.nix` を作成（`hardware-configuration.nix` を import）
2. `hosts/default.nix` の `flake.nixosConfigurations` に `mkSystem` で追加
3. profiles のリストを指定

## Key Technical Notes

- **nixpkgs channel**: `nixos-26.05` (stable) + `nixpkgs-unstable`
- **unstable パッケージ**: `specialArgs.unstable` 経由で参照（`unstable.<pkg>`）
- **llm-agents**: `inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.<name>` で参照。overlay も `hosts/default.nix` でグローバルに適用
- **nixvim**: `nixpkgs.source = pkgs.path` と `nixpkgs.config.allowUnfree = true` を vim/home/default.nix で設定
- **home-manager**: `useGlobalPkgs = true`, `useUserPackages = true`, `backupFileExtension = "backup"`
- **hostname**: `specialArgs.host` から `modules/system/network/default.nix` で `networking.hostName` に設定
- **stateVersion**: `config.my.stateVersions.nixos` / `config.my.stateVersions.homeManager` で管理（`modules/system/version.nix`）
- **disko**: `modules/system/disko.nix` で disk パーティション管理。ホスト固有の `disko.nix` を import
- **stylix**: `inputs.stylix` でテーマ管理
