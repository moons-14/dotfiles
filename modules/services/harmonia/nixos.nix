let
  signingKeyPath = "/run/secrets/harmonia/signing-key";
in
{
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ signingKeyPath ];

    settings = {
      bind = "0.0.0.0:5000";
      priority = 30;
    };
  };

  # Keep activation usable while the host-specific SOPS secret is bootstrapped.
  # Once the secret exists, starting the socket also starts Harmonia on demand.
  systemd.sockets.harmonia.unitConfig.ConditionPathExists = signingKeyPath;
  systemd.services.harmonia.unitConfig.ConditionPathExists = signingKeyPath;
}
