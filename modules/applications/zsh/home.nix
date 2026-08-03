{
  home.shellAliases = {
    "docker-compose" = "docker compose";

    lssh =
      "ssh"
      + " -o KexAlgorithms=+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1"
      + " -o Ciphers=+aes256-cbc,aes128-cbc"
      + " -o HostKeyAlgorithms=+ssh-rsa"
      + " -o SetEnv=TERM=xterm";
  };

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 999999999;
      save = 999999999;

      append = true;
      extended = true;
      findNoDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
      share = false;
    };

    setOptions = [
      "HIST_ALLOW_CLOBBER"
      "HIST_REDUCE_BLANKS"
      "HIST_VERIFY"
      "INC_APPEND_HISTORY_TIME"
    ];
  };
}
