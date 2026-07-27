{
  services.pcscd.enable = true;

  sops.secrets."users/moons/hashedPassword" = {
    sopsFile = ../../../secrets/common/system.yaml;
    neededForUsers = true;
  };
}
