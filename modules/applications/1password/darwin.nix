{
  # The macOS app must live in /Applications for its background integrations,
  # including the SSH agent, to work correctly.
  homebrew = {
    enable = true;
    casks = [ "1password" ];
  };
}
