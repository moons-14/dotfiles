# カスタムインストーラー ISO

`hosts/installer` から、NixOS 26.05 ベースの `x86_64-linux` 用インストーラー
ISO を作成する。installer ホストは Home Manager を使用せず、`base` プロファイルと
ホスト固有のインストール支援設定だけを含む。

## ビルド

flake 対応の Nix が利用できる環境で、リポジトリのルートから実行する。
`x86_64-linux` 以外のマシンで実行する場合は、対応する Linux リモートビルダーが
必要になる。

```bash
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

生成された ISO は次の場所にある。

```text
result/iso/nixos-minimal-*-x86_64-linux.iso
```

ファイル名に含まれる NixOS のバージョンとリビジョンは、`flake.lock` の更新に応じて
変わる。生成物を確認するには次を実行する。

```bash
ls -lh result/iso/*.iso
sha256sum result/iso/*.iso
```

## USB メモリへの書き込み

書き込み先はパーティション（例: `/dev/sdX1`）ではなく、USB デバイス全体
（例: `/dev/sdX`）を指定する。この操作は指定したデバイスの内容を上書きするため、
サイズ、モデル、マウント先を確認する。

```bash
lsblk -p -o NAME,SIZE,TYPE,MODEL,MOUNTPOINTS
```

USB のマウント済みパーティションをアンマウントしてから、`/dev/sdX` と
`/dev/sdX1` を確認した実際のデバイス名に置き換えて書き込む。パーティションが
複数ある場合は、それぞれをアンマウントする。

```bash
sudo umount /dev/sdX1
sudo dd if=result/iso/nixos-minimal-*-x86_64-linux.iso \
  of=/dev/sdX bs=4M conv=fsync status=progress
sync
```

書き込み完了後、USB を安全に取り外して対象マシンから起動する。

## 起動後の接続

有線 LAN は DHCP で自動設定される。Wi-Fi を使用する場合は、インストーラーの
コンソールで NetworkManager を使って接続する。

```bash
nmcli device wifi list
nmcli device wifi connect <SSID> --ask
```

起動時にコンソールへ IPv4 アドレスと簡易ヘルプが表示される。表示されたアドレスへ
登録済みの SSH 鍵で接続する。

```bash
ssh root@<ip-address>
```

root のパスワードログインとキーボード対話認証は無効で、
`hosts/installer/nixos.nix` に登録された公開鍵だけが利用できる。
以降の作業は [NixOS インストール手順](install.md) を参照する。

## ISO に含まれる主な設定とツール

- Nix flakes と `nix-command`
- NetworkManager、OpenSSH、起動時の IP アドレス表示
- `disko`、`parted`、`cryptsetup`、`btrfs-progs`、`efibootmgr`
- `sops`、`age`、`ssh-to-age`
- `age-plugin-yubikey`、`yubikey-manager`、`pcsc-tools` と `pcscd`
- `sbctl`、`tpm2-tools`
- `git`、`rsync`、`vim`、`wget`、`curl`、`jq`、`pciutils`、`util-linux`
