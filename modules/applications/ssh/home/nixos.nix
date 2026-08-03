{ lib, ... }: {
  systemd.user.sockets.gcr-ssh-agent.Install.WantedBy = lib.mkForce [ ];
  services.ssh-agent.enable = lib.mkForce false;
}
