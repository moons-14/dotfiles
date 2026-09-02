{
  inputs,
  pkgs,
  primaryUser,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  deployRs = inputs.deploy-rs.packages.${system}.default;

  fleetBuild = pkgs.writeShellApplication {
    name = "fleet-build";
    runtimeInputs = [
      pkgs.jq
      pkgs.nix
    ];
    text = ''
      flake_ref="''${FLAKE:-/home/${primaryUser}/dotfiles}"

      if (( $# == 0 )); then
        # Keep this pipeline inside command substitution so pipefail and
        # writeShellApplication's errexit propagate evaluation failures.
        host_lines="$(
          nix eval --json "$flake_ref#nixosConfigurations" \
            --apply 'configs: builtins.attrNames configs' |
            jq -r '.[] | select(. != "installer")'
        )"
        if [[ -z "$host_lines" ]]; then
          echo "No deployable NixOS hosts found in $flake_ref" >&2
          exit 1
        fi
        mapfile -t hosts <<< "$host_lines"
      else
        hosts=("$@")
      fi

      for host in "''${hosts[@]}"; do
        nix build \
          --out-link "/var/lib/nix-fleet/roots/build/$host" \
          "$flake_ref#nixosConfigurations.$host.config.system.build.toplevel"
      done
    '';
  };

  fleetDeploy = pkgs.writeShellApplication {
    name = "fleet-deploy";
    runtimeInputs = [ deployRs ];
    text = ''
      cd "''${FLAKE:-/home/${primaryUser}/dotfiles}" || exit 1

      exec deploy \
        --keep-result \
        --result-path /var/lib/nix-fleet/roots/deploy \
        "$@"
    '';
  };
in
{
  environment.systemPackages = [
    fleetBuild
    fleetDeploy
  ];
}
