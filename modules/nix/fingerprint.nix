# Documentation : /docs/fingerprint.md
_: {
  services.fprintd.enable = true;

  security.pam.services = {
    login.fprintAuth = true;

    # sudo
    sudo.fprintAuth = true;

    # greetd (tuigreet / ReGreet)
    greetd.fprintAuth = true;
  };
}
