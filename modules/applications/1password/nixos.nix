{ primaryUser, lib, ... }:
{
  programs._1password-gui.polkitPolicyOwners = [ primaryUser ];

  # 1Password SSH Agentと競合するagentを無効化
  programs.ssh.startAgent = lib.mkForce false;
  programs.gnupg.agent.enableSSHSupport = lib.mkForce false;
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
}
