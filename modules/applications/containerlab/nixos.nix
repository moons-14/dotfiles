{ primaryUser }: {
  programs.containerlab.enable = true;

  users.users.${primaryUser}.extraGroups = [ "clab_admins" ];
}
