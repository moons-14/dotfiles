{
  # The former Codex app cask is deprecated in favor of ChatGPT, whose desktop
  # application includes the current Codex experience on macOS.
  homebrew = {
    enable = true;
    casks = [ "chatgpt" ];
  };
}
