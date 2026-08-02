{
  inputs,
  pkgs,
  ...
}:
{
  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
    remoteControl.enable = true;
    remoteMobileControl.enable = true;
    computerUseUi.enable = false;
    linuxFeatures = [
      "appshots"
      "open-target-discovery"
    ];
  };
}
