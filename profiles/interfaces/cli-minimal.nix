{
  my.features = {
    cli = {
      base.enable = true;
      shell.enable = true;
    };
    identity.sshDefaultKey.enable = true;
    services.nixcacheOci.enable = true;
  };
}
