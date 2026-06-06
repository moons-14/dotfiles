# sops-nix secrets

このリポジトリでは、`sops-nix` は全 NixOS 構成で常に有効です。復号できるかどうかは Nix の feature ではなく、各 SOPS ファイルがどの age recipient に暗号化されているかで制御します。

## 方針

- sops-nix の NixOS module と `sops.age.generateKey` を使い、独自の鍵生成 shell helper は持ちません。
- 全ホストの sops-nix age identity は `/var/lib/sops-nix/key.txt` に置きます。
- `my.system.secrets.sops.generateKey` のデフォルトは `true` なので、鍵が無い場合は sops-nix 側で生成されます。
- 初回ログインの hashed password など、初回起動時から secret が必要なホストでは、インストーラー ISO 上で先に `/mnt/var/lib/sops-nix/key.txt` を作ってから `nixos-install` します。

## ホスト age 鍵

通常起動後の公開 recipient は次のコマンドで確認します。

```sh
sudo age-keygen -y /var/lib/sops-nix/key.txt
```

インストール対象を `/mnt` にマウントしている間は次のコマンドです。

```sh
sudo age-keygen -y /mnt/var/lib/sops-nix/key.txt
```

## 権限モデル

- `sops-nix` 自体は全環境で有効です。
- 復号権限は `.sops.yaml` と各暗号化ファイルの age recipient で管理します。
- あるホストに読ませたい secret は、そのホストの public age recipient を入れて `sops updatekeys` します。
- 読ませたくないホストの recipient は入れません。

## moons のログインパスワードを SOPS から使う

`moons` ユーザーの hashed password を SOPS から使う場合は、対象ホストや profile で次のように設定します。

```nix
my.features.sops = {
  defaultSopsFile = ../../secrets/users/moons.yaml;
  userPassword.enable = true;
};
```

期待する secret key は次の形です。

```yaml
users:
  moons:
    hashedPassword: "$y$j9T$..."
```

ハッシュは次のコマンドで作ります。

```sh
mkpasswd -m yescrypt
```

暗号化ファイルの編集は次のコマンドです。

```sh
sops secrets/users/moons.yaml
```

## SSH 鍵との関係

- OpenSSH server の host key は、NixOS の `services.openssh.hostKeys` の標準挙動で `/etc/ssh/` 以下へ自動生成されます。
- `moons` の通常の SSH client key は、`my.features.identity.sshDefaultKey.enable` が有効な profile で user systemd service が初回ログイン後に `~/.ssh/id_ed25519` として自動生成します。
- sops-nix の age 鍵は SSH 鍵とは別に `/var/lib/sops-nix/key.txt` へ sops-nix の `generateKey` で自動生成します。

## SSH host key を sops-nix recipient に使う場合

sops-nix の README では、SSH host key から age recipient を作る方法も紹介されています。必要になった場合は次のように public key を age recipient に変換できます。

```sh
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

ただし、初回起動のユーザーパスワード復号に使う場合は、復号前に host key が存在している必要があります。このリポジトリでは初回インストール手順を単純にするため、sops-nix 専用の age key file を標準にしています。
