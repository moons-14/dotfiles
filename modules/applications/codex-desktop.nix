{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.codexDesktop;
  codexCliPackage = pkgs.llm-agents.codex;
  codexDesktopPackage =
    inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop-computer-use-ui;
  codexDesktopLauncher = pkgs.makeDesktopItem {
    name = "codex";
    desktopName = "Codex";
    genericName = "ChatGPT Desktop";
    comment = "Run Codex Desktop on Linux";
    exec = "env CODEX_CLI_PATH=${lib.getExe' codexCliPackage "codex"} BAMF_DESKTOP_FILE_HINT=codex.desktop CHROME_DESKTOP=codex.desktop ${lib.getExe' codexDesktopPackage "codex-desktop"} %u";
    icon = "codex-desktop";
    terminal = false;
    categories = [ "Development" ];
    keywords = [
      "codex"
      "chatgpt"
      "openai"
      "ai"
      "assistant"
    ];
    startupNotify = true;
    startupWMClass = "codex-desktop";
    actions = {
      new-window = {
        name = "New Window";
        exec = "env CODEX_CLI_PATH=${lib.getExe' codexCliPackage "codex"} BAMF_DESKTOP_FILE_HINT=codex.desktop CHROME_DESKTOP=codex.desktop CODEX_MULTI_LAUNCH=1 ${lib.getExe' codexDesktopPackage "codex-desktop"} --new-instance";
      };
    };
    extraConfig = {
      X-GNOME-WMClass = "codex-desktop";
    };
  };
in
{
  imports = [
    inputs.codex-desktop-linux.nixosModules.default
  ];

  options.my.applications.codexDesktop = {
    enable = lib.mkEnableOption "ChatGPT Desktop for Linux";
  };

  config = lib.mkIf cfg.enable {
    my.applications.codex.enable = true;

    programs.codexDesktopLinux = {
      enable = true;
      package = codexDesktopPackage;
      cliPackage = codexCliPackage;
      computerUseUi.enable = true;
    };

    environment.systemPackages = [
      codexDesktopLauncher # Vicinae-searchable Codex Desktop launcher alias
    ];
  };
}
