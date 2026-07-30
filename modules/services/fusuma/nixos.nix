{ primaryUser, ... }:
{
  # Fusuma reads raw touchpad events through libinput.
  users.users.${primaryUser}.extraGroups = [ "input" ];
}
