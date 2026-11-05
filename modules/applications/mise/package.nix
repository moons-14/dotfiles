{ fetchurl, stdenvNoCC }:
let
  version = "2026.11.1";
  releases = {
    aarch64-linux = {
      platform = "linux-arm64-musl";
      sha256 = "5ce3806f185a1a05a8d0cf6d3eba3e2656bdca46d22bf851874a5d9fb88f2cc2";
    };
    x86_64-linux = {
      platform = "linux-x64-musl";
      sha256 = "e9b45046f585f0859a68cc72a7aaaa8e44639f0b6487372621dbef93abc022fb";
    };
    aarch64-darwin = {
      platform = "macos-arm64";
      sha256 = "9ca1005930fed90e0f4c30d9b13fe4530fe88d0549a71349716a3aab9051c627";
    };
    x86_64-darwin = {
      platform = "macos-x64";
      sha256 = "ead2414251e8f2909cc7564f8ab5fd1feea6962ed77d0177776d72e08ae747a0";
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
