{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      export HISTSIZE=999999999
      export HISTFILESIZE=999999999

      setopt extended_history
      setopt hist_allow_clobber
      setopt hist_fcntl_lock
      setopt hist_find_no_dups
      setopt hist_ignore_all_dups
      setopt hist_ignore_dups
      setopt hist_ignore_space
      setopt hist_reduce_blanks
      setopt hist_save_no_dups
      setopt hist_verify
      setopt inc_append_history_time

      unsetopt SHARE_HISTORY
      setopt APPEND_HISTORY
      setopt INC_APPEND_HISTORY_TIME

      alias docker-compose="docker compose"
      alias lssh='ssh -o KexAlgorithms=+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1 -o Ciphers=+aes256-cbc,aes128-cbc -o HostKeyAlgorithms=+ssh-rsa -o SetEnv=TERM=xterm'
    '';
  };
}
