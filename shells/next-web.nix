{ pkgs }:
let
  node = pkgs.nodejs_24;
in
pkgs.mkShell {
  name = "next-web";

  packages = with pkgs; [
    node
    pnpm
    zsh
    openssl
    pkg-config
    jq
  ];

  NODE_ENV = "development";

  shellHook = ''
    # corepack store under repo (avoid polluting home)
    export COREPACK_HOME="$PWD/.corepack"

    # pnpm global bin dir (NixOS/zshでも確実に有効にする)
    export PNPM_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
    mkdir -p "$PNPM_HOME"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac

    # Prisma engines from nixpkgs (avoid binaries.prisma.sh fetch on NixOS)
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
    export PRISMA_SCHEMA_ENGINE_BINARY="${pkgs.prisma-engines}/bin/schema-engine"
    export PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines}/bin/query-engine"
    export PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines}/lib/libquery_engine.node"
    export PRISMA_FMT_BINARY="${pkgs.prisma-engines}/bin/prisma-fmt"

    # ---- show tool versions
    if command -v node >/dev/null; then
      echo "next-web shell -> node $(node -v)"
    fi
    if command -v pnpm >/dev/null; then
      echo "   pnpm $(pnpm --version)"
      echo "   PNPM_HOME=$PNPM_HOME"
    fi

    # Activate packageManager from package.json if present.
    if command -v corepack >/dev/null 2>&1; then
      if [ -f package.json ] && command -v jq >/dev/null 2>&1 && jq -e '.packageManager' package.json >/dev/null; then
        COREPACK_ENABLE_DOWNLOADS=1 corepack prepare --activate || true
      fi
    fi

    # ---- switch to zsh (interactive only). Don't break `nix develop -c ...`
    if [ -z "''${ZSH_VERSION:-}" ] && [[ $- == *i* ]] && [ -t 1 ] && [ -z "''${NIX_SHELL_ZSH_ACTIVATED:-}" ]; then
      export NIX_SHELL_ZSH_ACTIVATED=1
      exec ${pkgs.zsh}/bin/zsh -i
    fi
  '';
}
