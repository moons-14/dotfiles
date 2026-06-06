# Installer recommendations

追加で入れる・運用するとよいもの:

- 有線 Ethernet を標準手順にする。WiFi credential や firmware 問題を避けやすいです。
- 再インストール前に `/var/lib/sops-nix/key.txt` のバックアップをオフライン保管する。
- ホストごとの Disko recipe を用意して、パーティション作成も再現可能にする。
- `moons` の SSH client public key はマシンごとに登録する。秘密鍵を他マシンへコピーしない方針にできます。
- リモート地のインストールが必要になったら ISO へ Tailscale を追加する。ローカル作業だけなら authorized keys 付き SSH の方が単純です。
- ホストごとに disk 名、NIC 名、WiFi chipset、Secure Boot 状態、TPM/FIDO availability の確認 checklist を作る。
