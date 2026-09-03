# NixOSインストール手順（SOPS・ディスク暗号化あり）

この手順は、SOPSによるシークレット管理とLUKSによるディスク暗号化を
使用するホスト向けである。

どちらも使用しない場合は、
[SOPSなし・ディスク暗号化なしの手順](install-simple.md)を参照。

## 事前準備

1. [ISOビルド](iso-build.md)を参照してISOを作成
2. USBに書き込んで対象マシンでブート

## ネットワーク接続

### 有線LAN

DHCPで自動設定される。

### WiFi（有線が使えない場合）

```bash
nmcli device wifi connect <SSID> --ask
```

## SSH接続

コンソールに表示されたIPアドレスに接続：

```bash
ssh root@<ip-address>
```

## インストール手順

### 1. dotfilesのクローン

```bash
git clone git@github.com:moons-14/dotfiles.git ~/dotfiles
```

### 2. SSHホストキーの生成

新しいホスト用のSSHホストキーを生成：

```bash
ssh-keygen -t ed25519 -f /tmp/ssh_host_ed25519_key -N ""
```

### 3. age公開鍵の取得

SSHホストキーからage公開鍵を取得：

```bash
ssh-to-age -i /tmp/ssh_host_ed25519_key.pub
```

出力されたage公開鍵をコピー。

### 4. .sops.yamlの編集

```bash
cd ~/dotfiles
vim .sops.yaml
```

以下を追加：

```yaml
keys:
  - &host_<hostname> <age公開鍵>

creation_rules:
  - path_regex: ^secrets/hosts/<hostname>/[^/]+\.ya?ml$
    key_groups:
      - age:
          - *admin_yubikey1
          - *host_<hostname>
```

### 5. シークレットの再暗号化

```bash
sops updatekeys secrets/common/system.yaml
sops updatekeys secrets/hosts/<hostname>/*.yaml
```

### 6. disko設定の作成

新しいホスト用の`hosts/<hostname>/disko.nix`を作成。

LUKS暗号化とbtrfsの構成は`hosts/x1g13/disko.nix`を参照。

### 7. ディスクのパーティション

```bash
cd ~/dotfiles
disko --mode destroy,format,mount hosts/<hostname>/disko.nix
```

### 8. ハードウェア設定の生成

対象マシンのハードウェア設定を生成し、新しいホストのディレクトリへ直接保存：

```bash
nixos-generate-config --no-filesystems --root /mnt --show-hardware-config \
  > ~/dotfiles/hosts/<hostname>/hardware-configuration.nix
```

`hosts/<hostname>/nixos.nix`から生成した設定とDisko設定を読み込む：

```nix
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];
}
```

### 9. ホストキーのコピー

```bash
mkdir -p /mnt/etc/ssh
cp /tmp/ssh_host_ed25519_key* /mnt/etc/ssh/
chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key
```

### 10. NixOSインストール

```bash
nixos-install --flake ~/dotfiles#<hostname>
```

### 11. 再起動

```bash
reboot
```

## インストール後の確認

- SSHでログインできるか
- sopsシークレットが復号できるか
- diskoでパーティションが正しく設定されているか
