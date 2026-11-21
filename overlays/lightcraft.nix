{ inputs }:
let
  inherit (inputs.nixpkgs) lib;
in
lib.composeExtensions inputs.lightcraft.overlays.default (
  _final: prev: {
    lightcraft = prev.lightcraft.overrideAttrs (old: {
      # LightCraft pins two craft-libs revisions with identically named crates.
      # Give each Git source its own Cargo directory source.
      cargoDeps = old.cargoDeps.overrideAttrs (vendor: {
        buildCommand =
          let
            linkCrate = ''ln -s "$crate" $out/$(basename "$crate" | cut -c 34-)'';
            addSource = ''cat "$crate/.cargo-config" >> $out/.cargo/config.toml'';
          in
          assert lib.hasInfix linkCrate vendor.buildCommand;
          assert lib.hasInfix addSource vendor.buildCommand;
          lib.replaceStrings
            [ linkCrate addSource ]
            [
              ''
                destination="$out"
                if [ -e "$crate/.cargo-config" ]; then
                  sourceHash=$(sha256sum < "$crate/.cargo-config" | cut -d ' ' -f 1)
                  destination="$out/.cargo/git-$sourceHash"
                  mkdir -p "$destination"
                fi
                ln -sT "$crate" "$destination/$(basename "$crate" | cut -c 34-)"
              ''
              ''
                sed "s/^replace-with = .*/replace-with = \"git-$sourceHash\"/" \
                  "$crate/.cargo-config" >> "$out/.cargo/config.toml"
                printf '\n[source.git-%s]\ndirectory = "@vendor@/.cargo/git-%s"\n' \
                  "$sourceHash" "$sourceHash" >> "$out/.cargo/config.toml"
              ''
            ]
            vendor.buildCommand;
      });

      # Upstream 0.21.1 fails this read-count assertion in the Nix build.
      checkFlags = (old.checkFlags or [ ]) ++ [
        "--skip"
        "tests::find_similar::stopping_leaves_the_view_alone_and_the_next_search_reads_only_the_rest"
      ];

      postPatch = (old.postPatch or "") + ''
        # Remove unused egui patches so Cargo does not try to fetch them.
        sed -i \
          -e '/^egui_demo_lib = { git = /d' \
          -e '/^egui_inspection = { git = /d' \
          -e '/^egui_system_font_provider = { git = /d' \
          Cargo.toml

        for lock in Cargo.lock "$cargoDepsCopy/Cargo.lock"; do
          sed -i '/^\[\[patch\.unused\]\]/,/^$/d' "$lock"
        done
      '';
    });
  }
)
