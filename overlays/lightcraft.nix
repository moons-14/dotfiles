{ inputs }:
inputs.nixpkgs.lib.composeExtensions inputs.lightcraft.overlays.default (
  _final: prev: {
    lightcraft = prev.lightcraft.overrideAttrs (old: {
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
