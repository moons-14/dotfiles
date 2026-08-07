{
  inputs,
  pkgs,
  ...
}:
let
  codexPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
in
{
  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = codexPackage;
    remoteControl = {
      enable = true;
      package = codexPackage;
    };
    remoteMobileControl.enable = true;
    computerUseUi.enable = false;
    linuxFeatures = [
      "appshots"
      "open-target-discovery"
    ];
  };
}
