{
  lib,
  fetchCrate,
  libgbm,
  libglvnd,
  libxkbcommon,
  jq,
  makeWrapper,
  pkg-config,
  rustPlatform,
  wayland,
  wl-clipboard,
}:
rustPlatform.buildRustPackage rec {
  pname = "window-overview";
  version = "1.5.0";

  src = fetchCrate {
    pname = "wlr-chooser";
    inherit version;
    hash = "sha256-Jb59m1z+2G5istcbC0sg9jRVcC/bQh/OY0ny9OdTsdw=";
  };

  patches = [
    ./patches/window-overview.patch
    ./patches/niri-backend.patch
    ./patches/niri-hold-release.patch
  ];

  cargoHash = "sha256-KBLgtS8ULrmsOf6BN5SlkVQyXB12utvr/KonnKnCTCM=";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    libgbm
    libglvnd
    libxkbcommon
    wayland
  ];

  cargoBuildFlags = [
    "--bin"
    "wlr-switcher"
  ];

  postInstall = ''
    mv "$out/bin/wlr-switcher" "$out/bin/.window-overview-wrapped"
    makeWrapper "$out/bin/.window-overview-wrapped" "$out/bin/window-overview" \
      --add-flags "--layout grid" \
      --prefix PATH : "${
        lib.makeBinPath [
          jq
          wl-clipboard
        ]
      }" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libgbm
          libglvnd
        ]
      }:/run/opengl-driver/lib"
    ln -s window-overview "$out/bin/noctalia-taskbar-overview"
  '';

  meta = {
    description = "Fullscreen Wayland window overview with captured previews";
    homepage = "https://github.com/sjourdois/wlr-utils";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "window-overview";
    platforms = lib.platforms.linux;
  };
}
