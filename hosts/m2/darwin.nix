{ hostName, ... }:
{
  # networking.hostName and networking.localHostName are derived from the
  # registry name; computerName controls the user-visible macOS name.
  networking.computerName = hostName;

  # Keep this value stable after the first activation. It is independent of
  # the Home Manager stateVersion in hosts/default.nix.
  system.stateVersion = 7;
}
