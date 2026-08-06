{ pkgs, lib, ... }:
let
  vsc = pkgs.vscode-extensions;
  inherit (lib) recursiveUpdate;

  layers = {
    common = {
      extensions =
        (with vsc; [
          dracula-theme.theme-dracula
          ms-vscode-remote.vscode-remote-extensionpack
          dbaeumer.vscode-eslint
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          github.vscode-github-actions
          github.vscode-pull-request-github
          streetsidesoftware.code-spell-checker
          ms-ceintl.vscode-language-pack-ja
          mkhl.direnv
          usernamehw.errorlens
        ])
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
        "json.schemaDownload.trustedDomains" = {
          "https://schemastore.azurewebsites.net/" = true;
          "https://raw.githubusercontent.com/microsoft/vscode/" = true;
          "https://raw.githubusercontent.com/devcontainers/spec/" = true;
          "https://www.schemastore.org/" = true;
          "https://json.schemastore.org/" = true;
          "https://json-schema.org/" = true;
          "https://developer.microsoft.com/json-schemas/" = true;
          "https://biomejs.dev" = true;
        };
        "github.copilot.enable" = {
          "*" = true;
        };
        "editor.inlineSuggest.enabled" = true;
        "github.copilot.nextEditSuggestions.fixes" = true;
        "editor.suggestOnTriggerCharacters" = true;
        "editor.quickSuggestions" = {
          other = true;
          comments = false;
          strings = true;
        };
        "git.autofetch" = true;
        "workbench.editor.enablePreview" = false;
        "files.exclude" = {
          "**/.direnv" = true;
          "**/.direnv/**" = true;
        };
        "search.exclude" = {
          "**/.direnv" = true;
          "**/.direnv/**" = true;
        };
      };
    };

    web = {
      extensions =
        (with vsc; [
          lokalise.i18n-ally
          bradlc.vscode-tailwindcss
          prisma.prisma
          hashicorp.terraform
          yoavbls.pretty-ts-errors
          vitest.explorer
        ])
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "pnpm-catalog-lens";
            publisher = "antfu";
            version = "1.0.2";
            hash = "sha256-zPbmPm1hcUab4v54TzYdYhQ71BRvnJHBkkZ9JFR6zS4=";
          }
        ];
      userSettings = { };
    };

    web-biome = {
      extensions = with vsc; [ biomejs.biome ];
      userSettings = {
        "editor.defaultFormatter" = "biomejs.biome";
        "[typescript].editor.defaultFormatter" = "biomejs.biome";
        "[typescriptreact].editor.defaultFormatter" = "biomejs.biome";
      };
    };

    web-oxc = {
      extensions = with vsc; [
        oxc.oxc-vscode
      ];
      userSettings = {
        "editor.defaultFormatter" = "oxc.oxc-vscode";
        "[typescript].editor.defaultFormatter" = "oxc.oxc-vscode";
        "[typescriptreact].editor.defaultFormatter" = "oxc.oxc-vscode";
      };
    };

    nix = {
      extensions = with vsc; [
        bbenoist.nix
        jnoortheen.nix-ide
      ];
      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          nixd = {
            formatting.command = [ "nixfmt" ];
          };
        };

        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
          "editor.formatOnSave" = true;
        };
      };
    };

    jupyter = {
      extensions = with vsc; [
        ms-toolsai.jupyter
        ms-python.python
      ];
      userSettings = { };
    };

    java = {
      extensions = with vsc; [
        vscjava.vscode-java-pack
        sonarsource.sonarlint-vscode
        vscjava.vscode-java-debug
        redhat.java
      ];
      userSettings = {
        "java.jdt.ls.java.home" = "${pkgs.jdk25.home}";
        "java.configuration.runtimes" = [
          {
            name = "JavaSE-25";
            path = "${pkgs.jdk25.home}";
            default = true;
          }
        ];
        "editor.codeLens" = true;
        "java.debug.settings.enableRunDebugCodeLens" = true;
        "java.jdt.ls.vmargs" = "-Xms256m -Xmx2G -XX:+UseG1GC -XX:+UseStringDeduplication";
        "java.configuration.updateBuildConfiguration" = "interactive";
        "java.maven.downloadSources" = true;
        "java.eclipse.downloadSources" = true;
        "maven.executable.path" = "${pkgs.maven}/bin/mvn";
        "[java]" = {
          "editor.defaultFormatter" = "redhat.java";
        };
      };
    };

    rust = {
      extensions = with vsc; [
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb
        serayuzgur.crates
        tamasfe.even-better-toml
      ];
      userSettings = {
        "[rust]" = {
          "editor.defaultFormatter" = "rust-lang.rust-analyzer";
          "editor.formatOnSave" = true;
          "editor.codeActionsOnSave" = {
            "source.organizeImports" = true;
            "source.fixAll" = true;
          };
        };
        "rust-analyzer.checkOnSave" = true;
        "rust-analyzer.check.command" = "clippy";
        "rust-analyzer.cargo.buildScripts.enable" = true;
        "rust-analyzer.procMacro.enable" = true;
        "rust-analyzer.cargo.targetDir" = true;
        "rust-analyzer.lens.enable" = true;
        "rust-analyzer.lens.implementations.enable" = true;
        "rust-analyzer.lens.references.adt.enable" = true;
        "rust-analyzer.lens.references.enumVariant.enable" = true;
        "rust-analyzer.lens.references.method.enable" = true;
        "rust-analyzer.lens.references.trait.enable" = true;
        "files.watcherExclude" = {
          "**/target/**" = true;
        };
        "search.exclude" = {
          "**/target/**" = true;
        };
      };
    };
  };

  combine =
    layersList:
    builtins.foldl'
      (acc: layer: {
        extensions = acc.extensions ++ layer.extensions;
        userSettings = recursiveUpdate acc.userSettings layer.userSettings;
      })
      {
        extensions = [ ];
        userSettings = { };
      }
      layersList;

  mkProfile = combine;
in
{
  programs.vscode = {
    enable = true;
    argvSettings = {
      locale = "ja";
      "enable-crash-reporter" = false;
    };

    profiles = {
      default = mkProfile [ layers.common ];
      nix = mkProfile [
        layers.common
        layers.nix
      ];
      web = mkProfile [
        layers.common
        layers.web
        layers.web-biome
      ];
      web-oxc = mkProfile [
        layers.common
        layers.web
        layers.web-oxc
      ];
      jupyter = mkProfile [
        layers.common
        layers.jupyter
      ];
      java = mkProfile [
        layers.common
        layers.java
      ];
      rust = mkProfile [
        layers.common
        layers.rust
      ];
    };
  };
}
