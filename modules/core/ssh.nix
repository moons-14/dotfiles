{ pkgs, ... }:
{

  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = "yes";
    };
  };

  users.users.moons = {

    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKhxDkucmeCor6CKoXAua7DgDSzuXrZOtpdkyzQxz5+aAAAABHNzaDo= moons@moons14.com"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN6hZJyng/5LgFKPjR6uZAd/00UkO0vN0uQOoIvfSELdAAAABHNzaDo= moons@moons14.com"
    ];
  };

}
