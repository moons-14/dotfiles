# NixOSインストール手順（SOPSなし・ディスク暗号化なし）

この手順は、SOPSによるシークレット管理とLUKSによるディスク暗号化を
使用しないホスト向けの、独立したインストール手順である。

SOPSとディスク暗号化を使用する場合は、[暗号化ありの手順](install.md)を参照。

## 事前準備

1. [ISOビルド](iso-build.md)を参照してISOを作成
2. USBに書き込んで対象マシンでブート

## ネットワーク接続

### 有線LAN

DHCPで自動設定される。

### Wi-Fi（有線が使えない場合）

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
cd ~/dotfiles
```

### 2. ホスト設定の作成

`hosts/<hostname>/nixos.nix`を作成し、`hosts/default.nix`にホストと使用する
プロファイルを登録する。ホスト固有の設定だけをホストディレクトリに置き、
再利用可能な設定は適切なunitまたはprofileに置く。

### 3. インストール先ディスクの確認

```bash
lsblk -o NAME,PATH,SIZE,MODEL,SERIAL,TYPE,FSTYPE,MOUNTPOINTS
ls -l /dev/disk/by-id/
```

以降の操作では指定したディスクの既存データが消去される。対象を必ず確認し、
可能であれば`/dev/sda`や`/dev/nvme0n1`ではなく、安定した
`/dev/disk/by-id/...`パスを使用する。

### 4. Disko設定の作成

`hosts/<hostname>/disko.nix`を作成する：

```nix
_:
{
  disko.enableConfig = true;

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/<target-disk>";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
```

`<target-disk>`を手順3で確認した実際のディスクIDに置き換える。指定した
ディスクの既存データは消去される。

### 5. パーティション作成とマウント

```bash
disko --mode destroy,format,mount hosts/<hostname>/disko.nix
```

Diskoの実行結果を確認する：

```bash
findmnt /mnt
findmnt /mnt/boot
```

### 6. ハードウェア設定の生成

```bash
nixos-generate-config --no-filesystems --root /mnt --show-hardware-config \
  > ~/dotfiles/hosts/<hostname>/hardware-configuration.nix
```

### 7. ホストモジュールから設定を読み込む

`hosts/<hostname>/nixos.nix`で、生成したハードウェア設定とDisko設定を読み込む：

```nix
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];
}
```

### 8. NixOSインストール

```bash
nixos-install --flake ~/dotfiles#<hostname>
```

SOPSを使用しないため、age鍵の登録、シークレットの再暗号化、SSHホストキーの
事前生成とコピーは不要である。OpenSSHを有効にしたホストでは、SSHホストキーは
通常の初回起動時に生成される。

### 9. 再起動

```bash
reboot
```

## インストール後の確認

- 正しいディスクから起動できるか
- `/`と`/boot`が意図したファイルシステムからマウントされているか
- ネットワークと、設定している場合はSSH接続が利用できるか
