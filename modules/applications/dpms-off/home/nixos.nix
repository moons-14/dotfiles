{ pkgs, ... }:
{
  home.packages = [ pkgs.dpms-off ];

  xdg.desktopEntries.dpms-off = {
    name = "Display Off";
    genericName = "Display Power Management";
    comment = "Turn off all displays using DPMS";
    exec = "${pkgs.dpms-off}/bin/dpms-off";
    icon = "display";
    terminal = false;
    type = "Application";
    categories = [ "System" ];
    settings.Keywords = "Display Off;Screen Saver;DPMS;Power;Monitor;Screen;";
  };
}
