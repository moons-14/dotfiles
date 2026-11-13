{ fetchurl, stdenvNoCC }:
let
  version = "2026.11.3";
  releases = {
    aarch64-linux = {
      platform = "linux-arm64-musl";
      sha256 = "78c87fb8c8af031755f9241cbcd1886cd458c75e8f324020015445a776789e38";
    };
    x86_64-linux = {
      platform = "linux-x64-musl";
      sha256 = "72f1cb4591ee2ba90150022c3ee8aea4dd88fadac10c56d04ede4faffb5a1b03";
    };
    aarch64-darwin = {
      platform = "macos-arm64";
      sha256 = "6d39119ab914c54ab865204dee9337c71b83a7ed1e730f663c2fc3453e38fe9c";
    };
    x86_64-darwin = {
      platform = "macos-x64";
      sha256 = "49f32abd93f54147af0599a1c9583d2092df8e7250c9fe635783a7932c4087ef";
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
