# カスタムISOビルド

## ビルド

```bash
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

## ISO書き込み

```bash
# USBデバイスの確認
lsblk

# 書き込み（/dev/sdXは実際のデバイスに置き換える）
sudo dd if=./result/nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress
sync
```

## ISOの特徴

- SSH鍵認証でrootログイン可能
- 有線LANはDHCPで自動設定
- WiFiは`nmcli`で手動設定可能
- disko/sops/ageなどのツールを内蔵
- ブート時にIPアドレスとヘルプを表示
