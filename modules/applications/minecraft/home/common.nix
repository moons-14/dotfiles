_: {
  programs.prismlauncher = {
    enable = true;

    package = null;

    settings = {
      UseSystemLocale = true;

      # Minecraftのバージョンに応じてJavaを切り替える。
      AutomaticJavaSwitch = true;

      IgnoreJavaCompatibility = false;

      # 軽量～中規模構成のグローバル既定値。
      MinMemAlloc = 512;
      MaxMemAlloc = 4096;
      LowMemWarning = true;

      # 通常はコンソールを隠し、異常時だけ表示する。
      ShowConsole = false;
      ShowConsoleOnError = true;
      LogPrePostOutput = true;
      ConsoleMaxLines = 100000;
      ConsoleOverflowStop = true;

      # Mod管理。
      ModMetadataDisabled = false;
      ModDependenciesDisabled = false;
      SkipModpackUpdatePrompt = false;
      ShowModIncompat = true;
      DownloadGameFilesDuringInstanceCreation = true;

      # プレイ時間。
      RecordGameTime = true;
      ShowGameTime = true;
      ShowGlobalGameTime = true;

      MetaRefreshOnLaunch = true;
    };
  };
}
