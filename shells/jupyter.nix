{ pkgs }:
let
  py = pkgs.python312;
  pyEnv = py.withPackages (
    ps: with ps; [
      ipykernel
      notebook
      jupyterlab
      numpy
      pandas
      matplotlib
      scipy
      scikit-learn

      pyathena
      python-dotenv
      plotly
      seaborn
    ]
  );
in
pkgs.mkShell {
  name = "jupyter-notebook";

  packages = with pkgs; [
    pyEnv
    zsh
  ];

  PYTHONNOUSERSITE = "1";
  JUPYTER_CONFIG_DIR = "$PWD/.jupyter";
  IPYTHONDIR = "$PWD/.ipython";

  shellHook = ''
    set -e

    if command -v python >/dev/null; then
      echo "📓 jupyter shell → python $(python -V | awk '{print $2}')"
    fi

    if [ -z "''${ZSH_VERSION:-}" ] && [[ $- == *i* ]] && [ -t 1 ] && [ -z "''${NIX_SHELL_ZSH_ACTIVATED:-}" ]; then
      export NIX_SHELL_ZSH_ACTIVATED=1
      exec ${pkgs.zsh}/bin/zsh -i
    fi
  '';
}
