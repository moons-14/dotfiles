{ pkgs, ... }:
{
  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird;

    languagePacks = [ "ja" ];

    policies = {
      DisableTelemetry = true;
      DisableAppUpdate = true;
      InAppNotification_Disabled = true;
    };

    settings = {
      "mailnews.start_page.enabled" = false;
      "mail.shell.checkDefaultClient" = false;
    };

    profiles.default = {
      isDefault = true;
    };
  };
}
