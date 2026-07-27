{ pkgs, ... }:
let
  oxker = pkgs.oxker.overrideAttrs (oldAttrs: {
    checkFlags =
      (oldAttrs.checkFlags or [ ])
      ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        "--skip=ui::draw_blocks::help::tests::test_draw_blocks_help_custom_keymap_one_two_definition"
        "--skip=ui::draw_blocks::help::tests::test_draw_blocks_help_custom_keymap_two_definition"
      ];
  });
in
{
  home.packages = [
    pkgs.docker-client
    oxker
  ];
}
