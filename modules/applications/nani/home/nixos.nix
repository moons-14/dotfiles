{ pkgs, ... }:
let
  tessdataBest = pkgs.runCommand "tessdata-best-jpn-eng-chi-sim" { } ''
    mkdir -p "$out"
    ln -s ${
      pkgs.fetchurl {
        url = "https://github.com/tesseract-ocr/tessdata_best/raw/main/jpn.traineddata";
        hash = "sha256-Nr35rII/WRHmJMMNBVPokLirx8MaZbPvFNqUNljEC3k=";
      }
    } "$out/jpn.traineddata"
    ln -s ${
      pkgs.fetchurl {
        url = "https://github.com/tesseract-ocr/tessdata_best/raw/main/eng.traineddata";
        hash = "sha256-goCu0Hgv4nJXpo6hD+fvMkyg+Nhb0v0UXRwrVgvLZro=";
      }
    } "$out/eng.traineddata"
    ln -s ${
      pkgs.fetchurl {
        url = "https://github.com/tesseract-ocr/tessdata_best/raw/main/chi_sim.traineddata";
        hash = "sha256-T+8tEwbI6HYW1NPkxsZ/r11EvjNCKQz48vD246p+c1s=";
      }
    } "$out/chi_sim.traineddata"
  '';

  tesseract = pkgs.tesseract5.override {
    tessdata = tessdataBest;
  };

  naniTranslatePrimary = pkgs.writeShellApplication {
    name = "nani-translate-primary";

    runtimeInputs = with pkgs; [
      jq
      wl-clipboard
      xdg-utils
    ];

    text = ''
      selected_text="$(wl-paste --primary --no-newline)" || exit 0
      [ -n "$selected_text" ] || exit 0
      encoded_text="$(printf '%s' "$selected_text" | jq -sRr @uri)"
      exec xdg-open "naniapp://translate?source=$encoded_text"
    '';
  };

  naniTranslateOcr = pkgs.writeShellApplication {
    name = "nani-translate-ocr";

    runtimeInputs = with pkgs; [
      grim
      jq
      slurp
      tesseract
      xdg-utils
    ];

    text = ''
      geometry="$(slurp)" || exit 0
      captured_text="$(
        grim -g "$geometry" - \
          | tesseract stdin stdout -l jpn+eng+chi_sim --oem 1 --psm 6
      )"
      [ -n "$captured_text" ] || exit 0
      encoded_text="$(printf '%s' "$captured_text" | jq -sRr @uri)"
      exec xdg-open "naniapp://translate?source=$encoded_text"
    '';
  };
in
{
  programs.naniTranslateLinux.enable = true;

  xdg.mimeApps.defaultApplications."x-scheme-handler/naniapp" = "nani.desktop";

  home.packages = [
    naniTranslatePrimary
    naniTranslateOcr
  ];
}
