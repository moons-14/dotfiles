{ fetchurl, stdenvNoCC }:
let
  version = "2026.10.18";
  releases = {
    aarch64-linux = {
      platform = "linux-arm64-musl";
      sha256 = "61c5773ca684d12907092263890cb0532c667b3efe64e373f3f7169938cc86d4";
    };
    x86_64-linux = {
      platform = "linux-x64-musl";
      sha256 = "cab4710274e8c5bf0a4753a3e9bf1fd0ae2c0a525a4f2902e1c7658cee699fdb";
    };
    aarch64-darwin = {
      platform = "macos-arm64";
      sha256 = "d40e2fcd96fed7c70b04af282c36534d87d0318bef89c16fa00c9f98e55ade88";
    };
    x86_64-darwin = {
      platform = "macos-x64";
      sha256 = "72e1ced3bac89d0e0aa28b04bd22f8941c111d3b20c74a77bfb6a9486f25f7d3";
    };
  };
  release = releases.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "mise";
  inherit version;

  src = fetchurl {
    url = "https://github.com/jdx/mise/releases/download/v${version}/mise-v${version}-${release.platform}";
    inherit (release) sha256;
  };

  dontUnpack = true;
  meta.mainProgram = "mise";
  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/mise"
    runHook postInstall
  '';
}
