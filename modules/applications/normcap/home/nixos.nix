{ pkgs, ... }:
let
  normcap = pkgs.normcap.override {
    tesseract4 = pkgs.tesseract4.override {
      enableLanguages = [
        "chi_sim"
        "jpn"
        "eng"
      ];
    };
  };

  normcapTranslate = pkgs.writeShellApplication {
    name = "normcap-translate";

    runtimeInputs = [
      normcap
      pkgs.jq
      pkgs.xdg-utils
    ];

    text = ''
      captured_text="$(
        normcap \
          --cli-mode \
          --screenshot-handler grim \
          --show-introduction False \
          --update False \
          --detect-codes False \
          --notification False \
          -l jpn eng chi_sim
      )" || exit 0
      [ -n "$captured_text" ] || exit 0
      encoded_text="$(printf '%s' "$captured_text" | jq -sRr @uri)"
      exec xdg-open "naniapp://translate?source=$encoded_text"
    '';
  };
in
{
  home.packages = [
    normcap
    normcapTranslate
  ];
}
