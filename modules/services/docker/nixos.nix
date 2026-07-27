{ primaryUser, ... }:
{
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    daemon.settings = {
      ipv6 = true;
      "fixed-cidr-v6" = "fd00:30::/64";
      ip6tables = true;
    };
  };

  users.users.${primaryUser}.extraGroups = [ "docker" ];
}
