{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    duf
    dust
    eza
    fd
    fastfetch
    fzf
    htop
    jq
    nurl
    ripgrep
    unrar
    unzip
    wget
  ];

  home.activation.generateSshKey = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      key="$HOME/.ssh/id_ed25519"
      if [ ! -f "$key" ]; then
        umask 077
        mkdir -p "$HOME/.ssh"
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -f "$key" \
          -C "moons@$(${pkgs.hostname}/bin/hostname || echo host)"
        echo "Generated SSH key at $key"
      fi
    '';
  };
}
