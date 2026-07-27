{
  system.defaults.NSGlobalDomain = {
    # Prevent automatic text substitutions from changing code and Markdown.
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;

    # Keep new documents local by default and expand save/print panels.
    NSDocumentSaveNewDocumentsToCloud = false;
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
    PMPrintingExpandedStateForPrint = true;
    PMPrintingExpandedStateForPrint2 = true;
  };

  # Do not restore applications that happened to be open at logout. Declarative
  # launch agents remain the only applications intentionally started at login.
  system.defaults.CustomUserPreferences."com.apple.loginwindow".TALLogoutSavesState = false;
}
