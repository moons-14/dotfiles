{
  inputs,
  pkgs,
  primaryUser,
}:
{
  programs.containerlab.enable = true;

  users.users.${primaryUser}.extraGroups = [ "clab_admins" ];

  programs.containerlab.package =
    inputs.containerlab.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (_old: {
        vendorHash = "sha256-LtLRsSgYnKqJECJkY8PJsO/AxPWzvLjXaW1x9QsjFmE=";
      });

}
