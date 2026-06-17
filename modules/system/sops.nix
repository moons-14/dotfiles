{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    # sops / age
    sops
    age
    ssh-to-age

    # YubiKey edit key
    age-plugin-yubikey
    yubikey-manager
    pcsc-tools

    # password hash generation
    mkpasswd
  ];

  # age-plugin-yubikey depend
  services.pcscd.enable = true;

  services.openssh.enable = true;

  sops = {
    defaultSopsFormat = "yaml";

    age = {
      # system keys
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
    };
  };
}
