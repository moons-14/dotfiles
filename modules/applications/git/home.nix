{
  lib,
  config,
  ...
}:
let
  cfg = config.my.applications.git;
  hmCfg = config.my.applications.git.homeManager;
in
{
  options.my.applications.git.homeManager = {
    enable = lib.mkEnableOption "git home-manager configuration";

    signingKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "~/.ssh/id_ed25519_sk_rk.pub";
      example = "~/.ssh/id_ed25519.pub";
      description = "SSH public key path used for Git commit and tag signing.";
    };
  };

  config = lib.mkIf hmCfg.enable {
    assertions = [
      {
        assertion = hmCfg.signingKey != null;
        message = "my.applications.git.homeManager.signingKey must be set per host.";
      }
    ];

    home-manager.sharedModules = [
      {
        programs.git = {
          enable = true;

          ignores = [
            ".direnv/"
            ".envrc"
            "!.envrc.example"
          ];

          signing = {
            key = hmCfg.signingKey;
            format = "ssh";
            signByDefault = true;
          };

          settings = {
            user.name = cfg.userName;
            user.email = cfg.userEmail;

            push.default = "simple";
            credential.helper = "cache --timeout=7200";
            init.defaultBranch = "main";
            log.decorate = "full";
            log.date = "iso";
            merge.conflictStyle = "diff3";

            alias = {
              br = "branch --sort=-committerdate";
              co = "checkout";
              df = "diff";
              com = "commit -a";
              gs = "stash";
              gp = "pull";
              lg = "log --graph --pretty=format:'%Cred%h%Creset - %C(yellow)%d%Creset %s %C(green)(%cr)%C(bold blue) <%an>%Creset' --abbrev-commit";
              st = "status";
            };
          };
        };
      }
    ];
  };
}
