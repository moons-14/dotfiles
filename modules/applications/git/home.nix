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
  };

  config.home-manager.sharedModules = [
    {
      config = lib.mkIf hmCfg.enable {
        programs.git = {
          enable = true;
          ignores = [
            ".direnv/"
            ".envrc"
            "!.envrc.example"
          ];

          signing = {
            key = "~/.ssh/id_ed25519.pub";
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

            gpg.format = "ssh";
            tag.gpgSign = true;

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
      };
    }
  ];
}
