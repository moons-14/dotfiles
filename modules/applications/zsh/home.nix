{ lib, config, ... }:
let
  cfg = config.my.applications.zsh.homeManager;
in
{
  options.my.applications.zsh.homeManager = {
    enable = lib.mkEnableOption "Zsh home-manager configuration";
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf cfg.enable {
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
            # ---- from gist: export / history size ----
            export HISTSIZE=999999999
            export HISTFILESIZE=999999999

            # ---- from gist: setopt ----
            setopt extended_history
            setopt hist_allow_clobber
            setopt hist_fcntl_lock
            setopt hist_find_no_dups
            setopt hist_ignore_all_dups
            setopt hist_ignore_dups
            setopt hist_ignore_space
            # setopt hist_no_functions
            # setopt hist_no_store
            setopt hist_reduce_blanks
            setopt hist_save_no_dups
            setopt hist_verify
            setopt inc_append_history_time

            unsetopt SHARE_HISTORY
            setopt APPEND_HISTORY
            setopt INC_APPEND_HISTORY_TIME

            # ---- from gist: aliases ----
            alias docker-compose="docker compose"
            alias clearsign='export GPG_TTY=$(tty) && openssl rand -hex 16 | gpg --clearsign'
          '';
        };
      };
    }
  ];
}
