{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  codexCliPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
  codexDesktopPackage =
    inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop-computer-use-ui;
  launcher = pkgs.makeDesktopItem {
    name = "codex";
    desktopName = "Codex";
    genericName = "ChatGPT Desktop";
    comment = "Run Codex Desktop";
    exec = "env CODEX_CLI_PATH=${lib.getExe' codexCliPackage "codex"} BAMF_DESKTOP_FILE_HINT=codex.desktop CHROME_DESKTOP=codex.desktop ${lib.getExe' codexDesktopPackage "codex-desktop"} %u";
    icon = "codex-desktop";
    terminal = false;
    categories = [ "Development" ];
    startupNotify = true;
    startupWMClass = "codex-desktop";
    actions.new-window = {
      name = "New Window";
      exec = "env CODEX_CLI_PATH=${lib.getExe' codexCliPackage "codex"} BAMF_DESKTOP_FILE_HINT=codex.desktop CHROME_DESKTOP=codex.desktop CODEX_MULTI_LAUNCH=1 ${lib.getExe' codexDesktopPackage "codex-desktop"} --new-instance";
    };
  };
in
{
  programs.codexDesktopLinux = {
    enable = true;
    package = codexDesktopPackage;
    cliPackage = codexCliPackage;
    computerUseUi.enable = true;
  };

  environment.systemPackages = [ launcher ];
}
