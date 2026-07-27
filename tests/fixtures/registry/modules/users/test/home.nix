{ pkgs, ... }:
{
  home = {
    username = "test";
    homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/test" else "/home/test";
  };
}
