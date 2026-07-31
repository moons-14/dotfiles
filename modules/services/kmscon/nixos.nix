{ pkgs, ... }:
{
  services.kmscon = {
    enable = true;
    fonts = [
      {
        name = "Noto Sans Mono CJK JP";
        package = pkgs.noto-fonts-cjk-sans;
      }
    ];
    extraConfig = ''
      xkb-layout=jp
    '';
  };
}
