# User secrets

`moons` の hashed password を SOPS で管理する場合は、`my.features.security.sops.userPassword.enable` を有効にする前に `moons.yaml` を暗号化して作成してください。

```yaml
users:
  moons:
    hashedPassword: "$y$j9T$..."
```

ハッシュ生成コマンド:

```sh
mkpasswd -m yescrypt
```

編集コマンド:

```sh
sops secrets/users/moons.yaml
```
