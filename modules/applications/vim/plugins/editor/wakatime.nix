{ pkgs, ... }:
{
  extraPlugins = [ pkgs.vimPlugins.vim-wakatime ];
  extraPackages = [ pkgs.wakatime-cli ];
  globals.wakatime_CLIPath = "${pkgs.wakatime-cli}/bin/wakatime-cli";
}
