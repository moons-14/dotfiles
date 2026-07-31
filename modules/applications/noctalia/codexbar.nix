{ lib, pkgs }:
let
  version = "0.46.0";
  architecture =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      "x86_64"
    else if pkgs.stdenv.hostPlatform.isAarch64 then
      "aarch64"
    else
      throw "CodexBar CLI is only packaged for x86_64-linux and aarch64-linux";
  hash =
    {
      x86_64 = "sha256-yMrOpu1WIv2sGVgvY9qf2XCoX2AXMSqR2b8bQDRU6os=";
      aarch64 = "sha256-pCp3NOlxFN6zeH67W04WGSPbUae+ktzR5vEunWqu00g=";
    }
    .${architecture};
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "codexbar";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://github.com/steipete/CodexBar/releases/download/v${version}/CodexBarCLI-v${version}-linux-musl-${architecture}.tar.gz";
    inherit hash;
  };

  dontUnpack = true;

  installPhase = ''
    tar -xzf "$src" CodexBarCLI
    install -Dm755 CodexBarCLI "$out/bin/codexbar"
  '';

  meta = {
    description = "CLI for CodexBar usage data";
    homepage = "https://github.com/steipete/CodexBar";
    license = lib.licenses.mit;
    mainProgram = "codexbar";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
