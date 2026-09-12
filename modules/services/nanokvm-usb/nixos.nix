{ primaryUser, ... }:
{
  users.users.${primaryUser}.extraGroups = [ "dialout" ];
}
