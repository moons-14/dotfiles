{ pkgs, ... }:
let
  # CC-BY-SA 3.0: https://github.com/jiro-aqua/aquamozc-dictionary
  kanaengDictionary =
    pkgs.runCommandNoCC "mozcdic-ut-kanaeng"
      {
        nativeBuildInputs = with pkgs; [
          gawk
          gnutar
          bzip2
        ];
      }
      ''
        mkdir -p "$out"

        awk -F '\t' 'NF == 3 { print $1 "\t0000\t0000\t8000\t" $2; }' \
          ${
            pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/jiro-aqua/aquamozc-dictionary/ae7fae40b18f1500d97e3e4531fdff22abdc6a39/edict-katakana-english/kanaeng.mozc.txt";
              hash = "sha256-rw8AlE2YAc3d4B6qQ6+LYchDiGwm6TesIfOozzZBGXo=";
            }
          } > mozcdic-ut-kanaeng.txt

        tar -cjf "$out/mozcdic-ut-kanaeng.txt.tar.bz2" mozcdic-ut-kanaeng.txt
      '';

  mozcWithKanaeng = pkgs.mozc.override {
    dictionaries = with pkgs; [
      mozcdic-ut-alt-cannadic
      mozcdic-ut-edict2
      mozcdic-ut-jawiki
      mozcdic-ut-neologd
      mozcdic-ut-personal-names
      mozcdic-ut-place-names
      mozcdic-ut-skk-jisyo
      mozcdic-ut-sudachidict
      kanaengDictionary
    ];
  };
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        (fcitx5-mozc.override { mozc = mozcWithKanaeng; })
        fcitx5-gtk
        kdePackages.fcitx5-qt
        qt6Packages.fcitx5-configtool
      ];

      settings.inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "jp";
          DefaultIM = "mozc";
        };
        "Groups/0/Items/0" = {
          Name = "keyboard-jp";
          Layout = "";
        };
        "Groups/0/Items/1" = {
          Name = "mozc";
          Layout = "";
        };
      };
    };
  };
}
