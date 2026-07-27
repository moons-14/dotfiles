{ primaryUser, lib, ... }:
{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ primaryUser ];
  };

  programs.ssh.startAgent = lib.mkForce false;
  programs.gnupg.agent.enableSSHSupport = lib.mkForce false;
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
}
