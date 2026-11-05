{ lib, pkgs }:
let
  version = "0.83.0";
  architecture =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      "x86_64"
    else if pkgs.stdenv.hostPlatform.isAarch64 then
      "aarch64"
    else
      throw "CodexBar CLI is only packaged for x86_64-linux and aarch64-linux";
  hash =
    {
      x86_64 = "sha256-AORT7ObuLv2prsvYocR/Dupjka4cipIvAZueRm+AnlM=";
      aarch64 = "sha256-lZzM5ySolFZY6ajdu6G5v0q8Qu6upnGkvQzAknBScXg=";
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
