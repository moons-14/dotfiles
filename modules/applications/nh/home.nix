{ config, pkgs, ... }:
{
  home.packages = [ pkgs.nh ];
  home.sessionVariables = {
    NH_FLAKE = "${config.home.homeDirectory}/dotfiles";
    NH_SHOW_ACTIVATION_LOGS = "1";
  };

  programs.zsh.initContent = ''
    export SUDO_PROMPT=$'\a[sudo] authenticate for %u: '

    nh() {
      local notify=false
      local argument

      case "$1:$2" in
        os:switch | os:build) notify=true ;;
      esac

      for argument in "$@"; do
        if [[ "$argument" == "--update" ]]; then
          notify=true
          break
        fi
      done

      command nh "$@"
      local status=$?

      if [[ "$notify" == true ]]; then
        printf '\a'
        if ((status == 0)); then
          print -P "%F{green}nh completed%f"
        else
          print -P "%F{red}nh failed (exit $status)%f"
        fi
      fi

      return "$status"
    }
  '';
}
