{ config, ... }:
{
  services.systemd-lock-handler.enable = true;

  security.pam.services.swaylock = {
    fprintAuth = true;

    rules.auth.fprintd.order = config.security.pam.services.swaylock.rules.auth.unix.order + 50;
  };
}
