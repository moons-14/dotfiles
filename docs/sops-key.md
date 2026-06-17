# Generate Sops key file

```bash
mkdir -p ~/.config/sops/age
chmod 700 ~/.config/sops/age

age-plugin-yubikey --identity --slot 1 \
  > ~/.config/sops/age/yubikey-identity.txt

chmod 600 ~/.config/sops/age/yubikey-identity.txt
```

## Edit sops file

```bash
sops secrets/common/system.yaml
```
