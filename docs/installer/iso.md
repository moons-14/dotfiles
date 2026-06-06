# Installer ISO

この flake は SSH 経由でのインストールを基本にした `installer-iso` NixOS 構成を公開します。直接接続したディスプレイとキーボードもフォールバックとして使えます。

## ビルド

```sh
nix build .#nixosConfigurations.installer-iso.config.system.build.isoImage
```

ISO は `result/iso/` 以下に生成されます。

## 起動とネットワーク

基本は有線 Ethernet + DHCP です。WiFi は NetworkManager でフォールバックとして使えます。

```sh
nmcli radio wifi on
nmcli device wifi list
nmcli device wifi connect '<ssid>' --ask
```

## SSH-first workflow

OpenSSH は ISO 起動時に有効です。`moons` ユーザーが作成され、リポジトリで管理している authorized keys でログインできます。

別マシンから次のように入ります。

```sh
ssh moons@<installer-ip>
```

IP アドレスが分からない場合は、フォールバックコンソールで次を確認します。

```sh
ip addr
```

## 初回用の sops-nix age 鍵を作る

独自 helper は使わず、`age-keygen` と `install` だけでインストール対象に鍵を作ります。インストール対象の root filesystem を `/mnt` にマウントした後に実行してください。

```sh
sudo install -d -m 0700 /mnt/var/lib/sops-nix
sudo age-keygen -o /mnt/var/lib/sops-nix/key.txt
sudo chmod 0600 /mnt/var/lib/sops-nix/key.txt
```

公開 recipient は次で確認します。

```sh
sudo age-keygen -y /mnt/var/lib/sops-nix/key.txt
```

この recipient を `.sops.yaml` に追加してから secret を暗号化・更新してください。

既存の age identity を使い回す場合は、標準の `install` でコピーします。

```sh
sudo install -d -m 0700 /mnt/var/lib/sops-nix
sudo install -m 0600 ./key.txt /mnt/var/lib/sops-nix/key.txt
```

## インストール後も使われる鍵

`/mnt/var/lib/sops-nix/key.txt` に作った age identity は、そのままインストール後の `/var/lib/sops-nix/key.txt` になります。つまり ISO 上で生成した sops-nix 鍵を、インストール後の通常起動でも継続利用できます。

OpenSSH の host key は NixOS の OpenSSH module が `/etc/ssh/` 以下へ自動生成します。`moons` の SSH client key は Home Manager の user systemd service が `~/.ssh/id_ed25519` が無い場合に初回ログイン後へ自動生成します。

## フォールバックローカルコンソール

SSH が使えない場合は、直接接続したディスプレイとキーボードで作業します。ISO には `neovim`、`tmux`、`git`、`sops`、`age`、`ssh-to-age`、`disko`、OpenSSH tools、NetworkManager tools が入っています。
