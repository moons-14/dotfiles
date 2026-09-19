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
        vendorHash = "sha256-Na2s9GdyYo2e/8dLAs5NPT0auEWq4MKQcnngjaO3r9M=";
      });

}
