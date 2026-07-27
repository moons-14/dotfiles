{ lib, ... }:
{
  services.fprintd.enable = true;
  security.polkit.enable = true;
  security.pam.services.polkit-1.fprintAuth = true;
  security.pam.services = {
    login.fprintAuth = false;
    sudo.fprintAuth = true;
    greetd.fprintAuth = lib.mkForce false;
    ly.fprintAuth = lib.mkForce false;
  };
}
