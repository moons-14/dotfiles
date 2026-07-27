{
  system.keyboard = {
    enableKeyMapping = true;
    userKeyMapping = [
      {
        # Caps Lock → left Command
        HIDKeyboardModifierMappingSrc = 30064771129;
        HIDKeyboardModifierMappingDst = 30064771299;
      }
    ];
  };

  system.defaults = {
    NSGlobalDomain."com.apple.keyboard.fnState" = true;

    # These are the standard macOS App Shortcuts for all applications.  Keep
    # both English and Japanese menu titles so they work after changing the
    # macOS display language.
    CustomUserPreferences.NSGlobalDomain.NSUserKeyEquivalents = {
      "Close" = "~q";
      "Close Window" = "~q";
      "閉じる" = "~q";
      "ウインドウを閉じる" = "~q";
      "Zoom" = "~f";
      "拡大/縮小" = "~f";
      "拡大／縮小" = "~f";
    };
  };
}
