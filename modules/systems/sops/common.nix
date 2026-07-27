{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
    age-plugin-yubikey
    yubikey-manager
    pcsc-tools
    mkpasswd
  ];

  sops = {
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
