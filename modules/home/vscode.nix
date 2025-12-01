{ pkgs, lib, ... }:
let
  vsc = pkgs.vscode-extensions;
  inherit (lib) recursiveUpdate;

  layers = rec {
    common = {
      extensions = (with vsc; [
        github.copilot
        github.copilot-chat
        dracula-theme.theme-dracula
        ms-vscode-remote.vscode-remote-extensionpack
        dbaeumer.vscode-eslint
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        github.vscode-github-actions
        github.vscode-pull-request-github
        eamodio.gitlens
        streetsidesoftware.code-spell-checker
        ms-ceintl.vscode-language-pack-ja
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "hadolint";
          publisher = "exiasr";
          version = "1.1.2";
          hash = "sha256-6GO1f8SP4CE8yYl87/tm60FdGHqHsJA4c2B6UKVdpgM=";
        }
      ];
      userSettings = {
        "workbench.colorTheme" = "Dracula";
        "window.autoDetectColorScheme" = false;
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "git.enableSmartCommit" = true;
        "files.autoSave" = "onFocusChange";
        "git.confirmSync" = false;
        "github.copilot.nextEditSuggestions.enabled" = true;
        "editor.suggestOnTriggerCharacters" = true;
        "editor.quickSuggestions" = { other = true; comments = false; strings = true; };
        "git.autofetch" = true;
        "workbench.editor.enablePreview" = false;
      };
    };

    web = {
      extensions = (with vsc; [
        biomejs.biome
        lokalise.i18n-ally
        bradlc.vscode-tailwindcss
        prisma.prisma
        hashicorp.terraform
        yoavbls.pretty-ts-errors
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "pnpm-catalog-lens";
          publisher = "antfu";
          version = "1.0.0";
          hash = "sha256-mCMBVxZRIb3Jao1XSS7EQRQX3Y2vrkpAmy6ldSqZa9c=";
        }
        {
          name = "explorer";
          publisher = "vitest";
          version = "1.32.1";
          hash = "sha256-MAfjS/oFfFuiE+Q2w6leSlao436QSw2fKjd7/BE/Q8Y=";
        }
        {
          name = "native-preview";
          publisher = "typescriptteam";
          version = "0.20251104.1";
          hash = "sha256-lUSwtf7jncnrp6UXgmZU30e+CFRKqf0N41+Xna6daok=";
        }
      ];
      userSettings = {
        "editor.defaultFormatter" = "biomejs.biome";
        "[typescript].editor.defaultFormatter" = "biomejs.biome";
        "[typescriptreact].editor.defaultFormatter" = "biomejs.biome";
      };
    };

    nix = {
      extensions = with vsc; [
        bbenoist.nix
        jnoortheen.nix-ide
      ];
      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "[nix]"={
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
      };
    };

    jupyter = {
      extensions = with vsc; [
        ms-toolsai.jupyter
        ms-python.python
      ];
      userSettings = {};
    };

    java = {
      extensions = (with vsc; [
        vscjava.vscode-java-pack
        sonarsource.sonarlint-vscode
      ]);

      userSettings = {
        "java.jdt.ls.java.home" = "${pkgs.jdk24.home}";
        "java.configuration.runtimes" = [
          {
            "name" = "JavaSE-24";
            "path" = "${pkgs.jdk24.home}";
            "default" = true;
          }
        ];

        "java.jdt.ls.vmargs" =
          "-Xms256m -Xmx2G -XX:+UseG1GC -XX:+UseStringDeduplication";

        "java.configuration.updateBuildConfiguration" = "interactive";

        "java.maven.downloadSources" = true;
        "java.eclipse.downloadSources" = true;

        "maven.executable.path" = "${pkgs.maven}/bin/mvn";
      };
    };
  };

  combine = (ls:
    builtins.foldl' (acc: l: {
      extensions   = acc.extensions   ++ (l.extensions   or []);
      userSettings = recursiveUpdate acc.userSettings (l.userSettings or {});
    }) { extensions = []; userSettings = {}; } ls
  );

  #    mkProfile [layers...] { extensions = [...]; userSettings = { ... }; }
  mkProfile = layersList: extras:
    let base = combine layersList;
    in {
      extensions   = base.extensions ++ (extras.extensions or []);
      userSettings = recursiveUpdate base.userSettings (extras.userSettings or {});
    };

in {
  nixpkgs.config.allowUnfree = true;

  programs.vscode = {
    enable = true;

    profiles = {
      default = mkProfile [ layers.common ] { };

      nix = mkProfile [ layers.common layers.nix ] { };

      web = mkProfile [ layers.common layers.web ] { };

      jupyter = mkProfile [ layers.common layers.jupyter ] { };

      java = mkProfile [ layers.common layers.java ] { };
    };
  };

  xdg.configFile."Code/User/locale.json".text = ''
  {
    "locale": "ja"
  }
  '';
}
