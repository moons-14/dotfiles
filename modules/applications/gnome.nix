{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.gnome;
in
{
  options.my.applications.gnome = {
    enable = lib.mkEnableOption "GNOME desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;

    # ly is the display manager for switching between installed sessions.
    services.displayManager.gdm.enable = lib.mkForce false;

    home-manager.sharedModules = [
      {
        dconf.settings = {
          "org/gnome/desktop/sound" = {
            event-sounds = false;
            input-feedback-sounds = false;
          };

          "org/gnome/desktop/wm/keybindings" = {
            close = [ "<Super>q" ];
            show-desktop = [ ];
          };

          "org/gnome/settings-daemon/plugins/media-keys" = {
            home = [ ];
            screensaver = [ "<Super>l" ];
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
            ];
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            name = "Open Terminal";
            command = "ghostty";
            binding = "<Super>t";
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
            name = "Run Application";
            command = "vicinae toggle";
            binding = "<Super>d";
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
            name = "Open File Manager";
            command = "nautilus --new-window";
            binding = "<Super>e";
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
            name = "Clipboard History";
            command = "vicinae vicinae://extensions/vicinae/clipboard/history";
            binding = "<Super>v";
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
            name = "Log Out";
            command = "gnome-session-quit --logout --no-prompt";
            binding = "<Super><Shift>e";
          };

          "org/gnome/shell" = {
            favorite-apps = [
              "google-chrome.desktop"
              "code.desktop"
              "com.mitchellh.ghostty.desktop"
              "slack.desktop"
              "vesktop.desktop"
            ];
          };
        };
      }
    ];

    environment.systemPackages = with pkgs; [
      gnome-tweaks # GNOME desktop customization tool
      gnome-extension-manager # GNOME Shell extension manager
    ];
  };
}
