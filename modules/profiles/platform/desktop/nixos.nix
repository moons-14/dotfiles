{
  # A physical desktop is always available for local and remote work.  Disable
  # every system sleep path; screen blanking while locked is handled by
  # services.swayidle in the graphical session.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };

  services.logind.settings.Login.IdleAction = "ignore";

  # Keep the CPU policy at the highest-performance governor.  Hardware may
  # still manage turbo/thermal limits, but it will not select a power-saving
  # governor.
  powerManagement.cpuFreqGovernor = "performance";

  services.displayManager = {
    defaultSession = "labwc";
    ly.settings.default_session = "labwc";
  };
}
